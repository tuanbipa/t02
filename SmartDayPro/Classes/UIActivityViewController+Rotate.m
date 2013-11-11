//
//  UIActivityViewController+Rotate.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/7/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "UIActivityViewController+Rotate.h"

#import "iPadViewController.h"
#import "SmartDayViewController.h"
#import "MapLocationViewController.h"
#import "SDNavigationController.h"

extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@implementation UIActivityViewController (Rotate)

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/*
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIViewController *ctrler = nil;
    
    if ([self.presentingViewController isKindOfClass:[SDNavigationController class]])
    {
        SDNavigationController *navCtrler = (SDNavigationController *) self.presentingViewController;
        
        if ([navCtrler.topViewController isKindOfClass:[iPadViewController class]]
            || [navCtrler.topViewController isKindOfClass:[SmartDayViewController class]]
            || [navCtrler.topViewController isKindOfClass:[MapLocationViewController class]] )
        {
            ctrler = navCtrler.topViewController;
            
        }
        
    }
    
    if (ctrler != nil)
    {
        [ctrler willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    }
}
*/


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIViewController *ctrler = nil;
    
    if ([self.presentingViewController isKindOfClass:[SDNavigationController class]])
    {
        SDNavigationController *navCtrler = (SDNavigationController *) self.presentingViewController;
        
        if ([navCtrler.topViewController isKindOfClass:[iPadViewController class]]
            || [navCtrler.topViewController isKindOfClass:[SmartDayViewController class]]
            || [navCtrler.topViewController isKindOfClass:[MapLocationViewController class]] )
        {
            ctrler = navCtrler.topViewController;
            
        }

    }
    
    if (ctrler != nil)
    {
         [ctrler willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
    }
}

@end
