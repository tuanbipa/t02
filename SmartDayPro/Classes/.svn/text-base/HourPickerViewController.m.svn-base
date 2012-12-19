//
//  HourPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HourPickerViewController.h"

#import "Common.h"
#import "Task.h"
#import "Settings.h"

#import "ImageManager.h"

static int _selectedRows[3]; 

@implementation HourPickerViewController

@synthesize objectEdit;

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
- (void)loadView {
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];	
	mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
	
	durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 25)];
	durationLabel.textAlignment = NSTextAlignmentCenter;
	durationLabel.backgroundColor = [UIColor clearColor];
	durationLabel.font = [UIFont boldSystemFontOfSize:16];
	
	[mainView addSubview:durationLabel];
	[durationLabel release];
	
	hourPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 480)];	
	hourPickerView.delegate = self;
	hourPickerView.dataSource = self;
	hourPickerView.showsSelectionIndicator = YES;
	[mainView addSubview:hourPickerView];
	[hourPickerView release];

	self.view = mainView;
	[mainView release];
	
	self.navigationItem.title = _durationText;	
	
	NSInteger duration = 0;
	
	if ([objectEdit isKindOfClass:[Task class]]) 
	{
		duration = [(Task *)objectEdit duration];
	}
	else if ([objectEdit isKindOfClass:[Settings class]]) 
	{
		duration = [(Settings *)objectEdit taskDuration];
	}
	
	durationLabel.text = [Common getDurationString:duration];
	
	int hours = duration/3600;
	
	_selectedRows[2] = (duration%3600)/(60 * 5);
	
	if (hours <= 23)
	{
		_selectedRows[0] = 0;
		_selectedRows[1] = hours;
	}
	else
	{
		for (int i=2; i<=30; i++)
		{
			int div = hours/i;
			int mod = hours%i;
			
			if (div <= 23 && mod == 0)
			{
				_selectedRows[0] = i-1;
				_selectedRows[1] = div;
				
				break;
			}
		}		
	}
	
	for (int i=0; i<3; i++)
	{
		[hourPickerView selectRow:_selectedRows[i] inComponent:i animated:YES];
	}	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
/*
	for (int i=0; i<3; i++)
	{
		[hourPickerView selectRow:_selectedRows[i] inComponent:i animated:YES];
	}
*/	
	
	for (int i=0; i<3; i++)
	{
		[self pickerView:hourPickerView didSelectRow:_selectedRows[i] inComponent:i];
	}	
			
}

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
	return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 30;
			break;
		case 1:
			return 24;
			break;	
		case 2:
			return 12;
			break;	
			
	}
	return 0;
}

- (void) updateDuration
{
	NSInteger duration = ((_selectedRows[0] + 1) * _selectedRows[1]) * 3600 + _selectedRows[2] * 5 * 60;
	
	if ([objectEdit isKindOfClass:[Task class]]) 
	{
		[(Task *)objectEdit setDuration: duration];
	}
	else if ([objectEdit isKindOfClass:[Settings class]]) 
	{
		[(Settings *)objectEdit setTaskDuration: duration];
	}	
	
	durationLabel.text = [Common getDurationString:duration];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{

	////////printf("old:%d, new:%d\n", [pickerView selectedRowInComponent:component], row);
	
	UIView *oldRowView = [pickerView viewForRow:_selectedRows[component] forComponent:component];	
	
	UIView *rowView = [pickerView viewForRow:row forComponent:component];
	
	switch (component) {
		case 0:
		{
			((UILabel *) [oldRowView viewWithTag:10000]).text = [NSString stringWithFormat:@"x%d", _selectedRows[component] + 1];
			((UILabel *) [oldRowView viewWithTag:10001]).text = [NSString stringWithFormat:@"x%d", _selectedRows[component] + 1];
			
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:@"(hrs) x%d", row + 1];
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:@"(hrs) x%d", row + 1];
			
		}
			break;
		case 1:
		{
			((UILabel *) [oldRowView viewWithTag:10000]).text = [NSString stringWithFormat:@"%d", _selectedRows[component]];
			((UILabel *) [oldRowView viewWithTag:10001]).text = [NSString stringWithFormat:@"%d", _selectedRows[component]];			
			
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:(row == 1? @"%d hour": @"%d hours"), row];
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:(row == 1? @"%d hour": @"%d hours"), row];
		}
			break;
		case 2:
		{
			((UILabel *) [oldRowView viewWithTag:10000]).text = [NSString stringWithFormat:@"%d", _selectedRows[component] * 5];	
			((UILabel *) [oldRowView viewWithTag:10001]).text = [NSString stringWithFormat:@"%d", _selectedRows[component] * 5];	
			
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:@"%d mins", row * 5];	
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:@"%d mins", row * 5];	
		}
			break;
	}
	
	_selectedRows[component] = row;
	
	[self updateDuration];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{

	return 100;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
	CGRect frm = CGRectMake(0, 0,
							[self pickerView:pickerView widthForComponent:component]-6,
							[self pickerView:pickerView rowHeightForComponent:component]);
	
	UIView *rowView = view;
	
	if(!rowView)
	{
		rowView = [[[UIView alloc] initWithFrame:frm] autorelease];
		
		UILabel *valueShadowLabel = [[UILabel alloc] initWithFrame:CGRectOffset(frm, 2, 2)];
		
		valueShadowLabel.textAlignment = NSTextAlignmentCenter;
		valueShadowLabel.textColor = [UIColor redColor];
		valueShadowLabel.font = [UIFont boldSystemFontOfSize:22];
		valueShadowLabel.tag = 10000;
		
		[rowView addSubview:valueShadowLabel];
		[valueShadowLabel release];
		
		UILabel *valueLabel = [[UILabel alloc] initWithFrame:frm];

		valueLabel.textAlignment = NSTextAlignmentCenter;
		valueLabel.textColor = [UIColor blackColor];
		valueLabel.font = [UIFont boldSystemFontOfSize:22];	
		valueLabel.tag = 10001;
		
		[rowView addSubview:valueLabel];
		[valueLabel release];
	}
	
	switch (component) {
		case 0:
		{
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:@"x%d", row+1];
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:@"x%d", row+1];

		}
			break;
		case 1:
		{
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:@"%d", row];
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:@"%d", row];
		}
			break;
		case 2:
		{
			((UILabel *) [rowView viewWithTag:10000]).text = [NSString stringWithFormat:@"%d", row * 5];
			((UILabel *) [rowView viewWithTag:10001]).text = [NSString stringWithFormat:@"%d", row * 5];
		}
			break;
	}
	
	return rowView;
	
}

- (void)dealloc {
    [super dealloc];
}


@end
