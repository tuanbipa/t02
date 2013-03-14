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

#import "CalendarViewController.h"

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

@end
