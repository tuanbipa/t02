//
//  NoteMovableController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "NoteMovableController.h"

#import "TaskView.h"

#import "iPadSmartDayViewController.h"

extern iPadSmartDayViewController *_iPadSDViewCtrler;

@implementation NoteMovableController

- (BOOL) canSeparate
{
    //don't shift notes
    return NO;
}

-(void) endMove:(MovableView *)view
{
    if (!moveInMM)
    {
        CGRect frm = dummyView.frame;
        
        frm.size.width = 20;
        
        if ([_iPadSDViewCtrler checkRect:frm inModule:0])
        {
            [_iPadSDViewCtrler createTaskFromNote:((TaskView *)dummyView).task];
        }
    }
    
    [super endMove:view];
}

@end
