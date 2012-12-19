//
//  ContentTableView.m
//  SmartCal
//
//  Created by MacBook Pro on 7/1/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "ContentTableView.h"


@implementation ContentTableView

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event]; 
    
    // only forward the event UP the responder chain if this touch
    // is for a scroll view (self or a subview that inherits from
    // UIScrollView); the default UIScrollView implementation deals 
    // with subview event handling above in the [super] invocation.
    
    //UITouch *touch = [touches anyObject];
    
    //if ([touch.view isKindOfClass:[UIScrollView class]]) 
    {
        if(self.nextResponder != nil &&
           [self.nextResponder respondsToSelector:@selector(touchesEnded:withEvent:)]) 
        {
            [self.nextResponder touchesEnded:touches withEvent:event];
        }
    }
}
@end
