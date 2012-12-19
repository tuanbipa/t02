//
//  ColorPickerViewController.h
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

@interface ColorPickerViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> {
	Project *project;
}

@property (nonatomic, assign) 	Project *project;

@end
