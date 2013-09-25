//
//  NoteLayoutController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "NoteLayoutController.h"

#import "Common.h"
#import "Task.h"

#import "TaskView.h"

#import "AbstractSDViewController.h"
#import "NoteViewController.h"

#import "iPadViewController.h"

//extern AbstractSDViewController *_abstractViewCtrler;
extern iPadViewController *_iPadViewCtrler;

//extern BOOL _isiPad;

@implementation NoteLayoutController

- (BOOL) checkReusableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
}

- (BOOL) checkRemovableView:(UIView *) view
{
	if ([view isKindOfClass:[TaskView class]])
	{
		return YES;
	}
    
    return NO;
}

- (UIView *) layoutObject:(Task *)task reusableView:(UIView *)reusableView
{
	CGRect lastFrame = (lastView == nil? CGRectZero:lastView.frame);
	
	CGRect frm = CGRectZero;
	frm.origin.y = lastFrame.origin.y + lastFrame.size.height + TASK_PAD_HEIGHT;
	frm.origin.x = 0;
    
    frm.size.width = self.viewContainer.bounds.size.width;
	frm.size.height = 55;
	
	TaskView *taskView = reusableView;
	
	if (taskView != nil)
	{
        [taskView multiSelect:NO];
        [taskView changeFrame:frm];
	}
	else
	{
		taskView = [[[TaskView alloc] initWithFrame:frm] autorelease];
        taskView.listStyle = YES;
	}
    
    task.listSource = SOURCE_NOTE;
    taskView.tag = 10000;
    taskView.task = task;
    taskView.listStyle = YES;
    taskView.starEnable = NO;
    taskView.checkEnable = !_iPadViewCtrler.inSlidingMode;
    taskView.showSeparator = YES;
    [taskView enableMove:_isiPad?![task isShared]:NO];

    [taskView refreshCheckImage];
    
    [taskView setNeedsDisplay];
	
	return taskView;

}

- (NSMutableArray *) getObjectList
{
    //NoteViewController *ctrler = [[AbstractActionViewController getInstance] getNoteViewController];
    
    NoteViewController *ctrler = [[AbstractActionViewController getInstance] getNoteViewController];
    
    return ctrler.noteList;
}

@end
