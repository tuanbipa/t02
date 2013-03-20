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

extern AbstractSDViewController *_abstractViewCtrler;
extern BOOL _isiPad;

@implementation NoteLayoutController

- (BOOL) checkReusableView:(UIView *) view
{
	return [view isKindOfClass:[TaskView class]];
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
    taskView.checkEnable = YES;
    taskView.showSeparator = YES;
    [taskView enableMove:_isiPad?YES:NO];
    
    [taskView setNeedsDisplay];
	
	return taskView;

}

- (NSMutableArray *) getObjectList
{
    NoteViewController *ctrler = [_abstractViewCtrler getNoteViewController];
    
    return ctrler.noteList;
}

@end
