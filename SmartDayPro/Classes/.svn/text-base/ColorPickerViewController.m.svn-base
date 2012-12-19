//
//  ColorPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColorPickerViewController.h"

#import "Common.h"
#import "Project.h"

#import "ImageManager.h"

@implementation ColorPickerViewController

@synthesize project;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];	
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	UIPickerView *colorPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 480)];	
	colorPickerView.delegate=self;
	colorPickerView.dataSource=self;
	colorPickerView.showsSelectionIndicator=YES;
	[mainView addSubview: colorPickerView];
	[colorPickerView release];
	
	[colorPickerView selectRow:self.project.colorId inComponent:0 animated:YES];
	
	self.view = mainView;
	[mainView release];
	
	self.navigationItem.title = _colorText;
	
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 21;
			break;
	}
	return 0;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (project != nil && component == 0)
	{
		self.project.colorId = row;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 300;
			break;
	}
	return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
	UILabel	*rowView=(UILabel*)view;
	if(!rowView){
		rowView = [[[UILabel alloc] 
					initWithFrame:CGRectMake(0, 0,
											 [self pickerView:pickerView widthForComponent:component]-6,
											 [self pickerView:pickerView rowHeightForComponent:component])] autorelease];
	}
	
	rowView.textAlignment=NSTextAlignmentCenter;
	rowView.font=[UIFont systemFontOfSize:14];
	rowView.numberOfLines=2;
	
	switch (component) {
		case 0:
		{
			rowView.backgroundColor = [Common getColorByID:row colorIndex:1];
		}
			break;
	}
	
	return rowView;
	
}

- (void)dealloc {
    [super dealloc];
}


@end
