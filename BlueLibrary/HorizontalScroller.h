//
//  HorizontalScroller.h
//  BlueLibrary
//
//  Created by Jonyzfu on 8/13/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <UIKit/UIKit.h>

// forward declare the protocol.
@protocol HorizontalScollerDelegate;

@interface HorizontalScroller : UIView

// This is necessary in order to prevent a retain cycle.
// Only be assigned classes that conform to ..Delegate, keep type safety.
@property (weak) id<HorizontalScollerDelegate> delegate;

-(void)reload;

@end

// Send messages defined by NSObject to delegate of HorizontalScroller.
@protocol HorizontalScollerDelegate <NSObject>

// Required methods must be implemented by the delegate and usually contain some data that is absolutely required by the class.
@required
// ask the delegate how many views he wants to present inside the horizontal scroller.
- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller;

// ask the delegate to return the view that should appear at <index>.
- (UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index;

// inform the delegate what the view at <index> has been clicked.
- (void)horizontalScroller:(HorizontalScroller*)scroller clickedViewAtIndex:(int)index;

@optional
// ask the delegate for the index of the initial view to display. this method is optional
// and defaults to 0 if it's not implemented by the delegate.
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller*)scroller;

@end
