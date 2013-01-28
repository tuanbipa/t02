//
//  ToodledoAccountViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 10/8/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface ToodledoAccountViewController : UIViewController<UITextFieldDelegate> {
	UITextField *emailTextField;
	UITextField *pwdTextField;
	UIBarButtonItem *saveButton;
	
	Settings *setting;	
}

@property (nonatomic, assign) Settings *setting;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;

@end
