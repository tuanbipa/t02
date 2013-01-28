//
//  ContentScrollView.m
//  SmartCal
//
//  Created by MacBook Pro on 7/1/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "ContentScrollView.h"

#import "Common.h"
#import "TaskManager.h"

#import "SmartDayViewController.h"
#import "CalendarViewController.h"

extern SmartDayViewController *_sdViewCtrler;

@implementation ContentScrollView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.canCancelContentTouches = NO;
        self.delaysContentTouches = YES;
        //self.delegate = self;
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //printf("content scroll view touch\n");
    
    [super touchesEnded:touches withEvent:event]; 
    
    if(self.nextResponder != nil &&
       [self.nextResponder respondsToSelector:@selector(touchesEnded:withEvent:)]) 
    {
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
}

/*
- (void)scrollPage:(NSInteger) page
{
    //printf("scroll page: %d\n", page);
    
    if ([_sdViewCtrler.activeViewCtrler isKindOfClass:[CalendarViewController class]] && page != 1)
    {
        //scroll in Calendar view
        
        self.scrollEnabled = NO;
        
        TaskManager *tm = [TaskManager getInstance];
        
        NSDate *dt = [Common dateByAddNumDay:(page==0?-1:1) toDate:tm.today];
        
        [_sdViewCtrler jumpToDate:dt];
    }
}

- (void) scroll:(UIScrollView *)scrollView
{
	if (isVerticalScroll)
	{
		return;
	}
	
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	[self scrollPage:page];
}

- (void) stick:(UIScrollView *)scrollView
{
	[self scroll:scrollView];
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self scroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
	{
		[self stick:scrollView];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	scrollingOrientationCheck = YES;
	lastContentOffset = scrollView.contentOffset;
	isVerticalScroll = NO;
	isHorizontalScroll = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGPoint contentOffset = scrollView.contentOffset;
	
	if (!isHorizontalScroll && !isVerticalScroll && scrollingOrientationCheck)
	{
		if (abs(contentOffset.x - lastContentOffset.x) > abs (contentOffset.y - lastContentOffset.y))
		{
			isHorizontalScroll = YES;
		}
		else
		{
			isVerticalScroll = YES;
		}
		
		scrollingOrientationCheck = NO;
	}
	
	if (isHorizontalScroll)
	{
		contentOffset.y = lastContentOffset.y;
	}
	else if (isVerticalScroll)
	{
		contentOffset.x = lastContentOffset.x;
	}
	
	scrollView.contentOffset = contentOffset;
}
*/

@end
