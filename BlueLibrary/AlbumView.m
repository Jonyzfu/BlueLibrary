//
//  AlbumView.m
//  BlueLibrary
//
//  Created by Jonyzfu on 8/7/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "AlbumView.h"

@implementation AlbumView

{
    UIImageView *coverImage;
    UIActivityIndicatorView *indicator;     // An indicator that spins to indicate activity while the cover is being downloaded.
}

- (id)initWithFrame:(CGRect)frame albumCover:(NSString *)albumCover
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        // the coverImage has 5 pixels margin from its frame
        coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width - 10, frame.size.height - 10)];
        [self addSubview:coverImage];
        
        indicator = [[UIActivityIndicatorView alloc] init];
        indicator.center = self.center;
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicator startAnimating];
        [self addSubview:indicator];
        
        // as an observer for the image property of coverImage.
        [coverImage addObserver:self forKeyPath:@"image" options:0 context:nil];
         
         
        // sends a notification through the NSNotificationCenter singleton.
        // That’s all the information you need to perform the cover download task.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLDownloadImageNotification" object:self userInfo:@{@"imageView": coverImage, @"coverUrl":albumCover}];
        
    }
    return self;
}

// You must implement this method in every class acting as an observer.
// The system executes this method every time the observed property changes.
// when an image is loaded, the spinner will stop spinning.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        [indicator stopAnimating];
    }
}

- (void)dealloc
{
    [coverImage removeObserver:self forKeyPath:@"image"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
