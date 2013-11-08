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

extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@implementation UIActivityViewController (Rotate)

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (_iPadViewCtrler != nil)
    {
        [_iPadViewCtrler changeOrientation:toInterfaceOrientation];
    }
    else if (_sdViewCtrler != nil)
    {
        [_sdViewCtrler changeOrientation:toInterfaceOrientation];
    }
}

@end
