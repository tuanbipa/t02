//
//  ContentView.m
//  SmartCal
//
//  Created by Trung Nguyen on 6/16/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "ContentView.h"

#import "Common.h"
#import "Task.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"
#import "iPadViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation ContentView

@synthesize actionType;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		self.actionType = 0;
        
    }
    return self;
}

- (void) enableSwipe
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewsSwipe:)];
    swipe.numberOfTouchesRequired = 2;
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    swipe.delaysTouchesBegan = YES;

    [self addGestureRecognizer:swipe];    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
    [super dealloc];
}

- (void) handleViewsSwipe:(id)sender
{
    [_iPadViewCtrler slideAndShowDetail];
}

#pragma mark UIResponderStandardEditActions Protocol 
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{
	switch (self.actionType) {
        case ACTION_NOTE_EDIT:
        {
            NSInteger pk = self.tag;
            
            if (pk == 0)
            {
                break;
            }
            
            ////printf("selected primary key: %d\n", pk);
            
            Task *task2Link = (_plannerViewCtrler != nil?_plannerViewCtrler.task2Link:_abstractViewCtrler.task2Link);
            
            //if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.primaryKey != pk)
            if (task2Link != nil && task2Link.primaryKey != pk)
            {
                return action == @selector(copy:) ||
                action == @selector(delete:) ||
                action == @selector(createTask:) ||
                action == @selector(copyLink:) ||
                action == @selector(pasteLink:);
            }
			else
            {
                return action == @selector(copy:) ||
                action == @selector(delete:) ||
                action == @selector(createTask:) ||
                action == @selector(copyLink:);
            }
            
        }
            break;
        case ACTION_TASK_EDIT:
        {
            NSInteger pk = self.tag;
            
            if (pk == 0)
            {
                break;
            }
            
            ////printf("selected primary key: %d\n", pk);
            Task *task2Link = (_plannerViewCtrler != nil?_plannerViewCtrler.task2Link:_abstractViewCtrler.task2Link);
            
            //if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.primaryKey != pk)
            if (task2Link != nil && task2Link.primaryKey != pk)
            {
                return action == @selector(copy:) ||
                action == @selector(done:) ||
                action == @selector(delete:) ||
                action == @selector(copyLink:) ||
                action == @selector(pasteLink:);
            }
			else
            {
                return action == @selector(copy:) ||
                action == @selector(done:) ||
                action == @selector(delete:) ||
                action == @selector(copyLink:);
            }
            
        }
            break;
        case ACTION_ITEM_EDIT:
        {
            NSInteger pk = self.tag;
            
            if (pk == 0)
            {
                break;
            }
            
            ////printf("selected primary key: %d\n", pk);
            
            Task *task2Link = (_plannerViewCtrler != nil?_plannerViewCtrler.task2Link:_abstractViewCtrler.task2Link);
            
            //if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.primaryKey != pk)
            if (task2Link != nil && task2Link.primaryKey != pk)
            {
                return action == @selector(copy:) ||
                action == @selector(delete:) ||
                action == @selector(copyLink:) ||
                action == @selector(pasteLink:);
            }
			else
            {
                return action == @selector(copy:) ||
                action == @selector(delete:) ||
                action == @selector(copyLink:);
            }
            
        }
            break;
        case ACTION_CATEGORY_EDIT:
        {
			if (action == @selector(copy:) || action == @selector(delete:)) 
				return YES; 
            
        }
            break;
	}

	return NO;
}

- (void) copyLink:(id)sender 
{
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler copyLink];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler copyLink];
    }
}

- (void) pasteLink:(id)sender
{
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler pasteLink];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler pasteLink];
    }    
}

- (void) editLinks:(id)sender 
{
}

- (void)copy:(id)sender {
	////////printf("copy\n");
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler copyTask:nil];
    }
    else if (_abstractViewCtrler != nil)
    {
        if (self.actionType == ACTION_CATEGORY_EDIT)
        {
            [_abstractViewCtrler copyCategory];
        }
        else
        {
            [_abstractViewCtrler copyTask:nil];
        }
    }
}


- (void)delete:(id)sender
{    
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler deleteTask];
    }
    else if (_abstractViewCtrler != nil)
    {
        if (self.actionType == ACTION_CATEGORY_EDIT)
        {
            [_abstractViewCtrler deleteCategory];
        }
        else
        {
            [_abstractViewCtrler deleteTask];
        }
    }
}

- (void)done:(id)sender
{
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler markDoneTask];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler markDoneTask];
    }
}

- (void)createTask:(id)sender
{
    if (_plannerViewCtrler != nil) {
        [_plannerViewCtrler createTaskFromNote:nil];
    } else {
        [_abstractViewCtrler createTaskFromNote:nil];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ////printf("content view touch end\n");
    
	[super touchesEnded:touches withEvent:event];
    
    /*
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler deselect];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler deselect];
    }*/
    
    [[AbstractActionViewController getInstance] deselect];
    
    [[AbstractActionViewController getInstance] clearActiveItems];
    
}

@end
