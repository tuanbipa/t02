//
//  DateJumpView.h
//  SmartPlan
//
//  Created by Huy Le on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DateJumpView : UIView 
{
	NSDate *pickedDate;
	
	UIView *contentView;
	UIDatePicker *datePicker;
}

@property (nonatomic, copy) NSDate *pickedDate;

-(void)popUpView;
-(void)popDownView;

@end
