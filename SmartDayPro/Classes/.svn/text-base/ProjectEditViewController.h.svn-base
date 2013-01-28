//
//  ColorPickerViewController.h
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;
@class Settings;

@interface ProjectEditViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>  {
	Project *project;
	Settings *settings;
	
	UIScrollView *mainView;
	
	UITextField *tagInputTextField;
	UIButton *tagButtons[9];
    
    UIView *transparentView;
    UIButton *transparentCheckButton;
    
    UIBarButtonItem *saveButton;
}

@property (nonatomic, retain) 	Project *project;
@property (nonatomic, copy) Project *projectCopy;
@property (nonatomic, assign) 	Settings *settings;

@end
