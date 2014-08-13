//
//  HorizontalScroller.m
//  BlueLibrary
//
//  Created by Jonyzfu on 8/13/14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "HorizontalScroller.h"

// Define constants to make it easy to modify the layout at design time.
#define VIEW_PADDING 10
#define VIEW_DIMENSIONS 100
#define VIEW_OFFSET 100

// HorizontalScroller conforms to the UIScrollViewDelegate protocol.
@interface HorizontalScroller() <UIScrollViewDelegate>
@end

// Create the scroll view containing the views.
@implementation HorizontalScroller
{
    UIScrollView *scroller;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scroller.delegate = self;
        [self addSubview:scroller];
        
        // detects touches on the scroll view and checks if an album cover has been tapped.
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (void)scrollTapped:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    // we can't use an enumerator here, because we don't want to enumerate over ALL of the UIScrollView subviews.
    // we want to enumerate only the subviews that we added
    for (int index = 0; index < [self.delegate numberOfViewsForHorizontalScroller:self]; index++) {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location)) {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            // center the tapped view in the scroll view
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width / 2 + view.frame.size.width / 2, 0) animated:YES];
            break;
        }
    }
}

- (void)reload
{
    // nothing to load if there's no delegate.
    if (self.delegate == nil) {
        return;
    }
    
    // remove all subviews.
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // xValue is the starting point of the views inside the scroller.
    // All the views are positioned starting from the given offset.
    CGFloat xValue = VIEW_OFFSET;
    for (int i = 0; i < [self.delegate numberOfViewsForHorizontalScroller:self]; i++) {
        // add a view at the right position.
        xValue += VIEW_PADDING;
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(xValue, VIEW_PADDING, VIEW_DIMENSIONS, VIEW_DIMENSIONS);
        [scroller addSubview:view];
        xValue += VIEW_DIMENSIONS + VIEW_PADDING;
    }
    
    // Once all the views are in place, set the content offset for the scroll view to allow the user to scroll through all the albums covers.
    [scroller setContentSize:CGSizeMake(xValue + VIEW_OFFSET, self.frame.size.height)];
    
    // if an initial view is defined, center the scroller on it.
    // This check is necessary because that particular protocol method is optional.
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)]) {
        int initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        [scroller setContentOffset:CGPointMake(initialView * (VIEW_DIMENSIONS + 2 * VIEW_PADDING), 0) animated:YES];
    }
    
}

// message is sent to a view when it’s added to another view as a subview.
- (void)didMoveToSuperview
{
    [self reload];
}

// perform some calculations when the user drags the scroll view with their finger.
- (void)centerCurrentView
{
    int xFinal = scroller.contentOffset.x + (VIEW_OFFSET / 2) + VIEW_PADDING;
    int viewIndex = xFinal / (VIEW_DIMENSIONS + 2 * VIEW_PADDING);
    xFinal = viewIndex * (VIEW_DIMENSIONS + 2 * VIEW_PADDING);
    [scroller setContentOffset:CGPointMake(xFinal, 0) animated:YES];
    
    // once the view is centered, you then inform the delegate that the selected view has changed.
    [self.delegate horizontalScroller:self clickedViewAtIndex:viewIndex];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self centerCurrentView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerCurrentView];
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
