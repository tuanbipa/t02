//
//  MovableController.m
//  SmartPlan
//
//  Created by Huy Le on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MovableController.h"

#import "Common.h"
#import "MovableView.h"

@implementation MovableController

@synthesize activeMovableView;
@synthesize selectionMode;
@synthesize selectedMovableViews;

@synthesize autoScroll;

- (id)init
{
	if (self = [super init])
	{
		self.selectionMode = SELECTION_SINGLE;
		self.selectedMovableViews = [NSMutableArray arrayWithCapacity:5];
		
		self.autoScroll = YES;
	}
	
	return self;
}

-(void)reset
{
	self.activeMovableView = nil;
	
	leftMovableView = nil;
	rightMovableView = nil;
	onMovableView = nil;
	
	self.selectionMode = SELECTION_SINGLE;
	
	[self.selectedMovableViews removeAllObjects];	
}

-(void) enableScroll:(BOOL)enable container:(UIView *)container
{
	for (UIView *view in container.subviews)
	{
		if ([view isKindOfClass:[UIScrollView class]])
		{
			[(UIScrollView *)view setScrollEnabled:enable];
		}
	}
	
	if ([container isKindOfClass:[UIScrollView class]])
	{
		[(UIScrollView *)container setScrollEnabled:enable];
	}
}

- (CGRect) getScrollAreaInContainer:(UIScrollView *)container side:(NSInteger)side
{
    //side value 0: top, 1: bottom
    
    //printf("container w = %f, h = %f\n", container.bounds.size.width, container.bounds.size.height);
    
    CGPoint p = container.contentOffset;
    
    CGRect area = (side == 0?CGRectMake(0, p.y, container.bounds.size.width, SCROLL_CHECK_HEIGHT):CGRectMake(0, p.y + container.bounds.size.height - SCROLL_CHECK_HEIGHT, container.bounds.size.width, SCROLL_CHECK_HEIGHT));
    
    return area;
}

-(void)scroll:(NSSet *)touches container:(UIView *)container
{
	if (self.autoScroll && [container isKindOfClass:[UIScrollView class]])
	{
		UIScrollView *scrollView = (UIScrollView *) container;
		
		CGPoint location = [[touches anyObject] locationInView:scrollView];
		
		CGPoint p = scrollView.contentOffset;
        
        if (location.x > 320)
        {
            location.x -= 320;
        }
        
        CGRect topArea = [self getScrollAreaInContainer:scrollView side:0];
        CGRect bottomArea = [self getScrollAreaInContainer:scrollView side:1];
        
        //printf("top x = %f, top y= %f, bottom x:%f, bottom y:%f, loc x:%f, loc y:%f\n", topArea.origin.x, topArea.origin.y, bottomArea.origin.x, bottomArea.origin.y, location.x, location.y);
		
		//if (location.y > p.y + scrollView.frame.size.height - SCROLL_CHECK_HEIGHT)
        if (CGRectContainsPoint(bottomArea, location))
		{
			p.y += 10;
		}
		//else if (location.y < p.y + SCROLL_CHECK_HEIGHT)
        else if (CGRectContainsPoint(topArea, location))
		{
			p.y -= 10;
		}
		
		if (p.y < 0)
		{
			p.y = 0;
		}
		else if (p.y > scrollView.contentSize.height)
		{
			p.y = scrollView.contentSize.height;
		}
		
		scrollView.contentOffset = p;
	}
}

- (void) separateFrame:(BOOL) needSeparate
{
    //if (!needSeparate)
    //{
    //    //printf("UNSEPARATE: left is %s, right is %s\n", leftMovableView == nil? "NIL":"NOT NIL",rightMovableView == nil? "NIL":"NOT NIL");
    //}
    
	if (rightMovableView != nil)
	{
        ////printf("separate right\n");
		rightMovableView.frame = CGRectOffset(rightMovableView.frame, (needSeparate?SEPARATE_OFFSET:-SEPARATE_OFFSET), 0);		
	}
	
	if (leftMovableView != nil)
	{
        ////printf("separate left\n");
		leftMovableView.frame = CGRectOffset(leftMovableView.frame, (needSeparate?-SEPARATE_OFFSET:SEPARATE_OFFSET), 0);
	}	
}

- (void)unseparateEnd
{
	rightMovableView = nil;
	leftMovableView = nil;
    
    unseparateInProgress = NO;
}

- (void)unseparate
{
    if (unseparateInProgress)
    {
        return;
    }
    
    unseparateInProgress = YES;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SEPARATE_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector:@selector(unseparateEnd)];	
	
	[self separateFrame:NO];
	
	[UIView commitAnimations];	
}

- (BOOL)canSeparate
{
	return YES;
}

- (BOOL)checkSeparate:(MovableView *)view
{
    return YES;
}

- (void)separate: (MovableView *) rightView fromLeft:(MovableView *) leftView
{
    if (rightMovableView != rightView || leftMovableView != leftView)
	{
        ////printf("SEPARATE: left is %s, right is %s\n", leftMovableView == nil? "NIL":"NOT NIL",rightMovableView == nil? "NIL":"NOT NIL");
        
		[self separateFrame:NO];
		
		rightMovableView = rightView;
		leftMovableView = leftView;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:SEPARATE_ANIMATION_DURATION_SECONDS];
		
		[self separateFrame:YES];
		
		[UIView commitAnimations];
	}
}

- (void) unzoom:(MovableView *)view
{
	if (view != nil)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ZOOM_ANIMATION_DURATION_SECONDS];
		[UIView setAnimationDelegate: self];
		//[UIView setAnimationDidStopSelector:@selector(unzoomEnd)];	
        
		view.transform = CGAffineTransformIdentity;
        
		[UIView commitAnimations];
	}    
}

/*
- (void)unzoomEnd
{
	onMovableView = nil;
}

- (void)unzoom
{
	if (onMovableView != nil)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ZOOM_ANIMATION_DURATION_SECONDS];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector:@selector(unzoomEnd)];	

		onMovableView.transform = CGAffineTransformIdentity;
				
		[UIView commitAnimations];
	}
}

- (void)animateZooming:(NSTimer *)timer
{
	onMovableView = [timer userInfo];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ZOOM_ANIMATION_DURATION_SECONDS];
	onMovableView.transform = CGAffineTransformMakeScale(1.1, 1.1);
	[UIView commitAnimations];	
}
*/

- (void)zoom: (MovableView *) onView
{
	if (onView != onMovableView)
	{
        ////NSLog(@"zoom %@ - %@\n", onView, onMovableView);
		[self unzoom:onMovableView];
		
        /*
		if (onView != nil)
		{
			[NSTimer scheduledTimerWithTimeInterval:ZOOM_ANIMATION_DURATION_SECONDS target:self selector:@selector(animateZooming:) userInfo:onView repeats:NO];
		}
        */
        onMovableView = onView;
        
        if (onMovableView != nil)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:ZOOM_ANIMATION_DURATION_SECONDS];
            onMovableView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            [UIView commitAnimations];	        
        }
	}
    
}

- (void)unhighlight
{
	if (self.activeMovableView != nil)
	{
		[self.activeMovableView doSelect:NO];
	}
	
	self.activeMovableView = nil;	
}

- (void)unselectAll:(BOOL)unhighlight
{
	if (unhighlight)
	{
		for (MovableView *view in self.selectedMovableViews)
		{
			[view doSelect:NO];
		}
	}
	
	self.selectedMovableViews = [NSMutableArray arrayWithCapacity:5]; 
}

- (void)deselect
{
	[self unhighlight];
	[self unselectAll:YES];
}

- (void)highlight: (MovableView *) view
{
	if (self.selectionMode == SELECTION_SINGLE)
	{
		BOOL needHighlight = (self.activeMovableView != view);
		
		[self unhighlight];
		
		if (needHighlight)
		{
			self.activeMovableView = view;
			[view doSelect:YES];
		}
	}
	else 
	{
		if (view.isSelected)
		{
			[view doSelect:NO];
			
			[self.selectedMovableViews removeObject:view];
		}
		else 
		{
			[view doSelect:YES];
			
			[self.selectedMovableViews addObject:view];
		}

	}

}

- (void) beginMove:(MovableView *)view
{
	[self enableScroll:NO container:[view superview]];
	
	leftMovableView = nil;
	rightMovableView = nil;
	onMovableView = nil;
	
	if (self.activeMovableView != view)
	{
		[self highlight:view];
	}
	
	[[view superview] bringSubviewToFront:view];
}

-(void) animateRelations
{
	CGRect rec = self.activeMovableView.frame;
	CGRect leftRec = self.activeMovableView.frame;
    
    leftRec.size.width = 30;
    
	MovableView *rightView = nil;
	
	MovableView *leftView = nil;
	MovableView *onView = nil;
	
	UIView *container = [self.activeMovableView superview];
	
	for (UIView *view in container.subviews)
	{
		if ([view isKindOfClass:[MovableView class]] && view != self.activeMovableView)
		{
			CGRect checkRec = view.frame;
			
			checkRec.size.width = PAD_WIDTH;
			checkRec.origin.x -= PAD_WIDTH;
			
			if (CGRectIntersectsRect(checkRec, leftRec))
			{
				leftView = nil;
				rightView = (MovableView *)view;
				break;
			}
			
			if (CGRectIntersectsRect(view.frame, rec))
			{
				onView = (MovableView *)view;
			}
			
			//leftView = (MovableView *) view;
 		}
	}
	
	//check if Task is moved to end of list
	if (leftView != nil && rightView == nil)
	{
		if (leftRec.origin.y < leftView.frame.origin.y || onView != nil)
		{
			leftView = nil;
		}
	}
	
	if (rightView != nil || leftView != nil)
	{
		onView = nil;
	}
    
    BOOL able2Separate = [self checkSeparate:rightView];
    
    if (!able2Separate)
    {
        [self unseparate];
    }
	
	if ([self canSeparate] && able2Separate)
	{
		[self separate:rightView fromLeft:leftView];		
	}
	else 
	{
		leftView = nil;
		rightView = nil;
	}
    
	
	onView = nil; //unsupport move onto another view
	[self zoom:onView];
    
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.activeMovableView == nil)
	{
		return;
	}
	
	[self.activeMovableView move:touches withEvent:event];
    
    [self animateRelations];
		
	[self scroll:touches container:self.activeMovableView.superview];
}

-(void) restore
{
}

-(void) finishMove:(BOOL)toRestore
{	
	if (self.activeMovableView != nil)
	{
		[self.activeMovableView endMove:toRestore];
		
		[self unhighlight]; 
		
		if (toRestore)
		{
			[self restore];
		}		
	}
}

-(void) endMove:(MovableView *)view
{    
	BOOL toRestore = YES;
	
	[self unseparate];	
	
	[self unzoom:onMovableView];
	
	[self finishMove:toRestore];
	
	[self deselect];
	[self reset];
	
    [self enableScroll:YES container:[view superview]];
}

- (void)dealloc {
	
	self.activeMovableView = nil;
	self.selectedMovableViews = nil;

    [super dealloc];
}

@end
