//
//  Album.h
//  BlueLibrary
//
//  Created by Jonyzfu on 8/7/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

@property (nonatomic, copy, readonly) NSString *title, *artist, *genre, *coverUrl, *year;


// Object initializer
- (id)initWithTitle:(NSString *)title artist:(NSString *)artist
           coverUrl:(NSString *)coverUrl year:(NSString *)year;

@end
