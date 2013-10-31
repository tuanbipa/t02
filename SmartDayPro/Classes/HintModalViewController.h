//
//  HintModalViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/16/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuideWebView;

@interface HintModalViewController : UIViewController
{
    UIButton *closeButton;
    
    UIView *contentView;
    GuideWebView *hintView;
}

@property BOOL closeEnabled;

- (void)loadURL:(NSString *)url;

@end
