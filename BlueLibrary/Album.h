//
//  Album.h
//  BlueLibrary
//
//  Created by Jonyzfu on 8/7/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>

// declare that Album can be archived by conforming to the NSCoding protocol.
@interface Album : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *title, *artist, *genre, *coverUrl, *year;


// Object initializer
- (id)initWithTitle:(NSString *)title artist:(NSString *)artist
           coverUrl:(NSString *)coverUrl year:(NSString *)year;

@end
