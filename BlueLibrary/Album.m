//
//  Album.m
//  BlueLibrary
//
//  Created by Jonyzfu on 8/7/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "Album.h"

@implementation Album

// Simple init method to create new album instances.
- (id)initWithTitle:(NSString *)title artist:(NSString *)artist coverUrl:(NSString *)coverUrl year:(NSString *)year
{
    self = [super init];
    if (self)
    {
        _title = title;
        _artist = artist;
        _coverUrl = coverUrl;
        _year = year;
        _genre = @"Pop";
    }
    return self;
}

@end
