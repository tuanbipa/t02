//
//  MFMailComposeViewController+Rotate.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/9/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "MFMailComposeViewController+Rotate.h"

@implementation MFMailComposeViewController (Rotate)

-(NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskLandscape;
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end