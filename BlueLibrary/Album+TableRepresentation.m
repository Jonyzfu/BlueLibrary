//
//  Album+TableRepresentation.m
//  BlueLibrary
//
//  Created by Jonyzfu on 8/13/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "Album+TableRepresentation.h"

@implementation Album (TableRepresentation)

- (NSDictionary *)tr_tableRepresentation
{
    // This simple addition lets you return UITableView-ish representation of an Album, without modifying Album's code.
    return @{@"titles":@[@"Artist", @"Album", @"Genre", @"Year"],
             @"values":@[self.artist, self.title, self.genre, self.year]};
}

@end
