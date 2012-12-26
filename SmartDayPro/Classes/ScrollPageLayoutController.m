//
//  ScrollPageLayoutController.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/21/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "ScrollPageLayoutController.h"

#import "Common.h"
#import "MovableView.h"
#import "MovableController.h"

@implementation ScrollPageLayoutController

@synthesize currentPage;
@synthesize previousPage;
@synthesize nextPage;

@synthesize reusableViews;

- (id)init
{
	if (self = [super init])
	{
		self.currentPage = nil;
		self.previousPage = nil;
		self.nextPage = nil;
		
		self.reusableViews = nil;
		
		scrollingOrientationCheck = NO;
        
        bgCount = 0;
	}
	
	return self;
}

- (void) initViewContainer:(UIScrollView *)container
{
	self.viewContainer = container;
	container.delegate = self;
}

- (void) beginReuse:(MovableView *)view
{
    
}

- (void) reuseViews:(NSMutableArray *)views
{
	if (self.reusableViews == nil)
	{
		self.reusableViews = [NSMutableArray arrayWithCapacity:views.count];
	}
	
	for (UIView *view in views)
	{
		if ([view isKindOfClass:[MovableView class]]) //exclude un-reusable views (for example, linked lines)
		{
			[self beginReuse:(MovableView *)view];
			
			[self.reusableViews addObject:view];
		}
		else 
		{
			[view removeFromSuperview];
		}
	}
	
}

- (MovableView *)getReusableView
{
	MovableView *ret = nil;
	
	if (self.reusableViews.count > 0)
	{
		ret = [self.reusableViews lastObject];
	}
	
	if (ret != nil)
	{
		ret.isReused = YES;
		
		[ret retain];
		[self.reusableViews removeLastObject];
	}
	
	return ret;
}

- (void) freeReusableViews
{
	for (UIView *view in self.reusableViews)
	{
        if ([view superview])
        {
            [view removeFromSuperview];
        }
	}
	
	self.reusableViews = nil;
}

- (void) removeView:(UIView *)view
{
	[self.currentPage removeObject:view];
	
	[view removeFromSuperview];
}

- (void)freePage:(NSInteger)page //-1:all, 0:previous page, 1:current page, 2:next page
{
	if (page == -1 || page == 0)
	{
		[self reuseViews:self.previousPage];
		
		self.previousPage = nil;
	}

	if (page == -1 || page == 1)
	{
		[self reuseViews:self.currentPage];
		
		self.currentPage = nil;
	}

	if (page == -1 || page == 2)
	{
		[self reuseViews:self.nextPage];
		
		self.nextPage = nil;
	}
}

- (NSMutableArray *) getObjectListForPage:(NSInteger) page
{
	return nil;
}

- (void) initContentOffset
{
	[(UIScrollView *)self.viewContainer setContentOffset:CGPointMake(self.viewContainer.frame.size.width, 0)];
}

- (void) updateContentOffset
{
	if ([self.viewContainer isKindOfClass:[UIScrollView class]])
	{
		UIScrollView *view = (UIScrollView *) self.viewContainer;
				
		[view setContentOffset:CGPointMake(view.frame.size.width, view.contentOffset.y)];

		//////printf("content offset x:%f\n", view.contentOffset.x); 		
	}
}

- (UIView *) layoutObject:(NSObject *)obj forPage:(NSInteger)page
{
	return nil;
}

- (void) layoutObjectsToList:(NSMutableArray *)list forPage:(NSInteger)page
{
	[self beginLayout];
	
	int index = 0;
	
	NSMutableArray *objectList = [self getObjectListForPage:page];
	
	for (NSObject *obj in objectList)
	{
		UIView *view = [self layoutObject:obj forPage:page];
		
		if ([view isKindOfClass:[MovableView class]])
		{
			((MovableView *)view).movableController = self.movableController;
		}
		
		[self handleOverlap:view];
		
		[list addObject:view];
		
		lastView = view;
		lastIndex = index++;
	}
	
	[self endLayout];
	
}

- (void) refreshBackground4Page:(NSNumber *) pageNum
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    @synchronized(self)
    {
        [self refreshPage:[pageNum intValue] needFree:NO];
        bgCount --;
    }
    
    if (bgCount == 0)
    {        
        [self freeReusableViews];
    }
    
    [pool release];
}

- (void) bgRefreshPage:(NSInteger)page
{
    @synchronized(self)
    {
        bgCount ++;
    }
    
    [self performSelectorInBackground:@selector(refreshBackground4Page:) withObject:[NSNumber numberWithInt:page]];    
}

- (void) layout
{
    @synchronized(self)
    {
	[self freePage:-1];
	
	self.previousPage = [NSMutableArray arrayWithCapacity:10];
	self.currentPage = [NSMutableArray arrayWithCapacity:10];
	self.nextPage = [NSMutableArray arrayWithCapacity:10];
        
    bgCount = 0;
	    
    for (int i=0; i<3; i++)
    {
        if (i==1)
        {
            [self refreshPage:i needFree:NO];
        }
        else
        {
            [self bgRefreshPage:i];
        }
    }
	
	//[self freeReusableViews];
	
	[self initContentOffset];
    }
}

- (void)scrollPage:(NSInteger) page
{
	NSMutableArray *pages[3] = {self.previousPage, self.currentPage, self.nextPage};
	
	if (page == 0) //scroll to right
	{
		[self freePage:2];//free next page
		
		for (int i=0; i<2; i++)
		{
			for (UIView *view in pages[i])
			{
				CGRect frm = CGRectOffset(view.frame, self.viewContainer.frame.size.width, 0);
				
				if ([view isKindOfClass:[MovableView class]])
				{
					[(MovableView *)view changeFrame:frm];
				}
				else 
				{
					view.frame = frm;
				}
				
			}			
		}
		
		self.nextPage = self.currentPage;
		self.currentPage = self.previousPage;
		
		self.previousPage = nil;
		
		[self refreshPage:page needFree:NO];
        //[self bgRefreshPage:page];
	}
	
	if (page == 2) //scroll to left
	{
		[self freePage:0];//free previous page
		
		for (int i=1; i<3; i++)
		{
			for (UIView *view in pages[i])
			{
				CGRect frm = CGRectOffset(view.frame, -self.viewContainer.frame.size.width, 0);
				
				if ([view isKindOfClass:[MovableView class]])
				{
					[(MovableView *)view changeFrame:frm];
				}
				else 
				{
					view.frame = frm;
				}
				
			}			
		}
		
		self.previousPage = self.currentPage;
		self.currentPage = self.nextPage;
		
		self.nextPage = nil;

		[self refreshPage:page needFree:NO];
        //[self bgRefreshPage:page];
	}
	
	[self freeReusableViews];
	
	[self updateContentOffset];
}

- (void) refreshPage:(NSInteger)page needFree:(BOOL)needFree
{
	if (needFree)
	{
		[self freePage:page];
	}
	
	switch (page) {
		case 0:
			self.previousPage = [NSMutableArray arrayWithCapacity:10];
			break;
		case 1:
			self.currentPage = [NSMutableArray arrayWithCapacity:10];
			break;
		case 2:
			self.nextPage = [NSMutableArray arrayWithCapacity:10];
			break;
			
	}
	
	NSMutableArray *pages[3] = {self.previousPage, self.currentPage, self.nextPage};
	
	[self layoutObjectsToList:pages[page] forPage:page];
	
	if (pages[page].count > 0)
	{
		printf("refresh page %d - %d objects\n", page, pages[page].count);
		for (UIView *view in pages[page])
		{
			CGRect frm = CGRectOffset(view.frame, page*self.viewContainer.frame.size.width, 0);
			
			BOOL isReused = NO;
			
			if ([view isKindOfClass:[MovableView class]])
			{
				MovableView *mview = (MovableView *)view;
				
				[mview changeFrame:frm];
				isReused = mview.isReused;
			}
			else 
			{
				view.frame = frm;
			}
			
			if (!isReused)
			{
				[self.viewContainer addSubview:view];
			}
			else 
			{
                [self.viewContainer bringSubviewToFront:view];
				[view setNeedsDisplay];
			}

		}		
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
	[movableController deselect];
	
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
    
    if (bgCount != 0)
    {
        isVerticalScroll = YES;
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

- (void)dealloc {
	
	self.currentPage = nil;
	self.previousPage = nil;
	self.nextPage = nil;
	
	self.reusableViews = nil;
	
	[super dealloc];
}

@end
