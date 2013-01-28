//
//  DurationPickerViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DurationPickerViewController : UIViewController {
	NSObject *objectEdit;
	
	NSInteger keyEdit;
    
    UIButton *noneButton;
    UIDatePicker *picker;
}


@property (nonatomic, assign) NSObject *objectEdit;

@property NSInteger keyEdit;

@end
