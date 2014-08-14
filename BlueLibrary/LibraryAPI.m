//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by Jonyzfu on 8/10/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"
#import "PersistencyManager.h"
#import "HTTPClient.h"

@interface LibraryAPI ()
{
    PersistencyManager *persistencyManager;
    HTTPClient *httpClient;
    BOOL isOnline;  // isOnline determines if the server should be updated with any changes made to the album list.
}

@end

@implementation LibraryAPI

- (id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
        httpClient = [[HTTPClient alloc] init];
        isOnline = NO;
        
        // The observer.
        // Every time an AlbumView class posts a BLDownloadImageNotification notification, since LibraryAPI has registered as an observer for the same notification, the system notifies LibraryAPI. And LibraryAPI executes downloadImage: in response.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"BLDownloadImageNotification" object:nil];
    }
    return self;
}

+ (LibraryAPI *)sharedInstance
{
    // Declare a static variable to hold the instance of your class.
    static LibraryAPI *_sharedInstance = nil;
    
    // Declare the static variable ensures that initialization code executes only once.
    static dispatch_once_t oncePredicate;
    
    // Use Grand Central Dispatch (GCD) to execute a block which initializes an instance of LibraryAPI.
    // The initializer is never called again once the class has been initialized.
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

-(NSArray *)getAlbums
{
    return [persistencyManager getAlbums];
}

-(void)addAlbum:(Album *)album atIndex:(int)index
{
    // update the data locally, and then if there's an internet connection, it updates the remote server.
    [persistencyManager addAlbum:album atIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}

-(void)deleteAlbumAtIndex:(int)index
{
    [persistencyManager deleteAlbumAtIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

- (void)downloadImage:(NSNotification *)notification
{
    // downloadImage is executed via notifications.
    // The UIImageView and image URL are retrieved from the notification.
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"coverUrl"];
    
    // Retrieve the image from the PersistencyManager if it’s been downloaded previously.
    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    
    
    // Facade pattern to hide the complexity of downloading an image from the other classes.
    if (imageView.image == nil) {
        // If the image hasn’t already been downloaded, then retrieve it using HTTPClient.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            // When the download is complete, display the image in the image view and use the PersistencyManager to save it locally.
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
    
}

- (void)dealloc
{
    // remember to unsubscribe from this notification when your class is deallocated.
    // When this class is deallocated, it removes itself as an observer from all notifications it had registered for.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
