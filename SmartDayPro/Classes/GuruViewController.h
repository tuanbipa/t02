//
//  GuruViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/16/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentView;
@class ContentScrollView;

@interface GuruViewController : UIViewController
{
    ContentView *contentView;
    ContentScrollView *scrollView;
    
    UIPageControl * pageControl;
    
    UITextField *emailTextField;
    UITextField *pwdTextField;
}

@end
