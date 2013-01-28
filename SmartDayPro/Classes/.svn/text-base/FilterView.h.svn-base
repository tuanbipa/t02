//
//  FilterView.h
//  SmartCal
//
//  Created by Trung Nguyen on 6/23/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterData;

@interface FilterView : UIView<UITextFieldDelegate> {
	NSInteger orientation;
	
	UIScrollView *contentView;
	
	FilterData *filterData;
    
    UITextField *presetTextField;
	UITextField *nameTextField;
	UITextField *tagTextField;
	
	UIButton *typeButtons[3];
	UIButton *projectButtons[12];
    UIButton *presetButtons[3];
	
	UITextField *tagInputTextField;
	UIButton *tagButtons[9];
    
    UIView *criteriaView;
    UIView *presetView;
    UIButton *selectedPresetButton;
    
    UIView *filterActionView;
    UIView *presetActionView;
    
    UILabel *categoryCountLabel;
}

@property NSInteger orientation;
@property (nonatomic, retain) FilterData *filterData;

- (void) tagInputReset;
-(void)popDownView;
-(void)popUpView;
- (id)initWithOrientation:(NSInteger)orientation;

- (void) refreshFilterCategories;

@end
