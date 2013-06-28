//
//  LayoutController.m
//  SmartPlan
//
//  Created by Huy Le on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LayoutController.h"

#import "Common.h"

#import "MovableController.h"
#import "MovableView.h"

#import "Task.h"

@implementation LayoutController

@synthesize viewContainer;
@synthesize movableController;

- (id)init
{
	if (self = [super init])
	{
        lastContentOffset = CGPointZero;
	}
	
	return self;
}

-(void)reset
{
	lastView = nil;
	lastIndex = -1;	
}

- (UIView *) layoutObject:(NSObject *) obj reusableView:(UIView *)reusableView
{
	return nil;
}

- (NSMutableArray *) getObjectList
{
	return nil;
}

- (BOOL) checkOverlap:(UIView *)view
{
	if (lastView != nil)
	{
		return CGRectIntersectsRect(lastView.frame, CGRectOffset(view.frame, 0, 5));
	}
	
	return NO;
}

- (void) handleOverlap:(UIView *)view
{
	if ([self checkOverlap:view])
	{
		CGRect frm = view.frame;
		
		frm.size.width -= HASHMARK_WIDTH + SPACE_PAD;
		frm.origin.x += HASHMARK_WIDTH + SPACE_PAD;
		view.frame = frm;
		
	}			
}

- (BOOL) checkRemovableView:(UIView *) view
{
	if ([view isKindOfClass:[UIView class]])
	{
		return YES;
	}
	
	return NO;
}

- (BOOL) checkReusableView:(UIView *) view
{
	return NO;
}

- (void) initContentOffset
{
	if ([self.viewContainer isKindOfClass:[UIScrollView class]])
	{
        UIScrollView *scrollView = (UIScrollView *) self.viewContainer;
        
		CGSize size = scrollView.bounds.size;
        
        size.height = 1.2*scrollView.bounds.size.height;

		if (lastView != nil)
		{
            CGFloat lastH = lastView.frame.origin.y + lastView.frame.size.height;
			size.height = lastH + scrollView.bounds.size.height/2;
            
            if (size.height < scrollView.bounds.size.height)
            {
                size.height = 1.2*scrollView.bounds.size.height;
            }
		}
        
        [scrollView setContentSize:size];
		
        /*
        if (size.height > scrollView.contentSize.height)
        {
            [scrollView setContentSize:size];
        }*/
		
        [scrollView setContentOffset:lastContentOffset];
	}	
}

- (UIView *) layoutSingleObject:(NSObject *)object reusableView:(UIView *)reusableView
{
	UIView *view = [self layoutObject:object reusableView:reusableView];
	
	if ([view isKindOfClass:[MovableView class]])
	{
		((MovableView *)view).movableController = self.movableController;				
	}
	
	[self handleOverlap:view];
	
	if (view != reusableView)
	{
		[self.viewContainer addSubview:view];
	}
	
	lastView = view;
	lastIndex = lastIndex++;
	
	return view;
}

- (void) enableViewContainer:(NSNumber *) enableVal
{
	BOOL enable = ([enableVal intValue] == 1);
	
	self.viewContainer.userInteractionEnabled = enable;
	
	viewContainerDisable = !enable;
}

- (void) layoutBackground 
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *objList = [self getObjectList];
	
	NSInteger idx = 0;
	
	lastView = nil;
    
    NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:50];
	
	for (UIView *view in self.viewContainer.subviews)
	{
        if (idx < objList.count && [self checkReusableView:view])
        {
            NSObject *obj = [objList objectAtIndex:idx++];
            
            [self layoutSingleObject:obj reusableView:view];
            
            [view setNeedsDisplay];            
        }
        else if ([self checkRemovableView:view])
        {
            //[view removeFromSuperview];
            [removeList addObject:view];
        }
	}
    
    for (UIView *view in removeList)
    {
        [view removeFromSuperview];
    }
	
	for (int i=idx; i<objList.count; i++)
	{
		NSObject *obj = [objList objectAtIndex:idx++];
		
		[self layoutSingleObject:obj reusableView:nil];
	}
    
    ////printf("view container count: %d\n", self.viewContainer.subviews.count);
	
	[self initContentOffset];
	
	[pool release];
}

- (void) layout
{
	//////NSLog(@"list begin layout");
    @synchronized(self)
    {
    [self beginLayout];
    
	[self layoutBackground];
    
    [self endLayout];
    }
	//////NSLog(@"list end layout");
}

- (void) updateEnd
{
	for (UIView *view in self.viewContainer.subviews)
	{
		if ([self checkRemovableView:view]) 
		{
			[view removeFromSuperview];
		}
	}
	
	for (UIView *view in inMemoryTaskViewList)
	{
		[self.viewContainer addSubview:view];
	}
	
	[inMemoryTaskViewList release]; //after finished animation release the temporary list
	inMemoryTaskViewList = nil;
}

- (UIView *) findByTag:(NSInteger)tag list:(NSMutableArray*)list
{
	for (UIView *view in list)
	{
		if (view.tag == tag)
		{
			return view;
		}
	}
	
	return nil;
}

- (NSDictionary *)getInMemoryViewDict
{
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:inMemoryTaskViewList.count];
	
	for (UIView *view in inMemoryTaskViewList)
	{
		[keys addObject:[NSNumber numberWithInt:view.tag]];
	}
	
	return [NSDictionary dictionaryWithObjects:inMemoryTaskViewList forKeys:keys];
}

- (void) updateViewFrames
{
	NSDictionary *viewDict = [self getInMemoryViewDict];
	
	for (UIView *view in self.viewContainer.subviews)
	{
		if ([self checkRemovableView:view])
		{
			//UIView *newView = [self findByTag:view.tag list:inMemoryTaskViewList];
			
			UIView *newView = [viewDict objectForKey:[NSNumber numberWithInt:view.tag]];
			
			if (newView != nil)
			{
				view.frame = newView.frame;				
			}
		}
	}	
}

- (void) beginLayout
{
	[self reset];
	
    if ([self.viewContainer isKindOfClass:[UIScrollView class]])
    {
        lastContentOffset = [(UIScrollView *) self.viewContainer contentOffset];
    }
}

/*
- (void) endLayout:(NSMutableArray *)views
{
}
*/

- (void) endLayout
{
    
}

- (void) layoutObjectsToList:(NSMutableArray *)list objectList:(NSArray *)objectList
{
	[self beginLayout];
	
	int index = 0;
	
	for (NSObject *obj in objectList)
	{
		UIView *view = [self layoutObject:obj reusableView:nil];
		
		if ([view isKindOfClass:[MovableView class]])
		{
			((MovableView *)view).movableController = self.movableController;
		}

		[self handleOverlap:view];
		
		[list addObject:view];
		
		lastView = view;
		lastIndex = index++;
		
		[view release];
	}
	
	//[self endLayout:list];
    [self endLayout];
	
}

- (void) updateView:(NSArray *)objList
{
	if (objList == nil)
	{
		return;
	}

	inMemoryTaskViewList = [[NSMutableArray alloc] initWithCapacity:objList.count];
	
	[self layoutObjectsToList:inMemoryTaskViewList objectList:objList];
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate: self];
	
	[UIView setAnimationDuration:0.5];
	
	[self updateViewFrames];
	
	[UIView commitAnimations];
}

- (void)dealloc {
	
	self.movableController = nil;
	
   [super dealloc];
}

@end
