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

@end
