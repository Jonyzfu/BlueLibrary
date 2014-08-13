//
//  Album+TableRepresentation.h
//  BlueLibrary
//
//  Created by Jonyzfu on 8/13/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "Album.h"

@interface Album (TableRepresentation)

- (NSDictionary *)tr_tableRepresentation;   // tr_ as an abbreviation of the name of category.
                                            // Conventions help prevent collisions with other methods.

@end
