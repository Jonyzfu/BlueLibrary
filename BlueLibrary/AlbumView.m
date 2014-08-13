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
    }
    return self;
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
