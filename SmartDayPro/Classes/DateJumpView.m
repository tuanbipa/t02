//
//  DateJumpView.m
//  SmartPlan
//
//  Created by Huy Le on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "DateJumpView.h"

#import "Common.h"

#import "MiniMonthView.h"

#import "SmartDayViewController.h"

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation DateJumpView

@synthesize pickedDate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
		
		self.pickedDate = [NSDate date];
		
		frame.origin.x = 0;
		frame.origin.y = 0;
		
		contentView = [[UIView alloc] initWithFrame:self.bounds];
		//contentView.backgroundColor = [UIColor blackColor];
		contentView.backgroundColor = [UIColor clearColor];
		//contentView.alpha = 0.8;
		contentView.hidden = YES;
		
		[self addSubview:contentView];
		[contentView release];		
		
		UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1];
		//backgroundView.backgroundColor = [UIColor blackColor];
		//backgroundView.alpha = 0.8;
		
		[contentView addSubview:backgroundView];
		[backgroundView release];
		
		CGFloat pad = (frame.size.width-320)/2;
		
		//datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(40, 10, frame.size.width, 180)];
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(pad, 50, 320, 180)];
		[datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
		datePicker.datePickerMode = UIDatePickerModeDate;
		datePicker.minuteInterval = 5;
		datePicker.date = self.pickedDate;
		
		[contentView addSubview:datePicker];
		[datePicker release];
		
		UIButton *goButton = [Common createButton:_goText 
										 buttonType:UIButtonTypeCustom
											  //frame:CGRectMake(frame.size.width - 100, 40, 80, 30) 
							  frame:CGRectMake(pad + 20, 10, 80, 30) 
										 titleColor:[Colors blueButton]
											 target:self 
										   selector:@selector(goAction:) 
								   //normalStateImage:@"blue_button.png"
                              normalStateImage:nil
								 selectedStateImage:nil];
		[contentView addSubview:goButton];
        
        goButton.layer.cornerRadius = 4;
        goButton.layer.borderWidth = 1;
        goButton.layer.borderColor = [[Colors blueButton] CGColor];

		UIButton *todayButton = [Common createButton:_todayText 
									 buttonType:UIButtonTypeCustom
										  //frame:CGRectMake(frame.size.width - 100, 110, 80, 30) 
								 frame:CGRectMake(frame.size.width - pad - 100, 10, 80, 30) 
									 titleColor:[Colors blueButton]
										 target:self 
									   selector:@selector(goToday:) 
							   //normalStateImage:@"blue_button.png"
                                 normalStateImage:nil
							 selectedStateImage:nil];
        
        todayButton.layer.cornerRadius = 4;
        todayButton.layer.borderWidth = 1;
        todayButton.layer.borderColor = [[Colors blueButton] CGColor];
        
		[contentView addSubview:todayButton];
		
	}
	
    return self;
}

-(void)popUpView
{	
	self.pickedDate = [NSDate date];
	
	datePicker.date = self.pickedDate;
	
	contentView.hidden = NO;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
	
	self.userInteractionEnabled = YES;
}

-(void)popDownView
{
	contentView.hidden = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
	
	self.userInteractionEnabled = NO;
}

- (void)dateChanged:(id)sender
{
	UIDatePicker *picker = (UIDatePicker *)sender;

	self.pickedDate = picker.date;				
}

- (void)goAction:(id)sender
{
	[self popDownView];
	
	/*if (_sc2ViewCtrler != nil)
	{
		[_sc2ViewCtrler jumpToDate:self.pickedDate];
	}
	else 
    if (_landscapeViewCtrler != nil)
	{
		[_landscapeViewCtrler jumpToDate:self.pickedDate];
	}
    else */
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler jumpToDate:self.pickedDate];
    }
}

- (void)goToday:(id)sender
{
	self.pickedDate = [NSDate date];
	
	[self popDownView];

	/*if (_sc2ViewCtrler != nil)
	{
		[_sc2ViewCtrler jumpToDate:self.pickedDate];
	}
	else
    if (_landscapeViewCtrler != nil)
	{
		[_landscapeViewCtrler jumpToDate:self.pickedDate];
	}
    else */
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler jumpToDate:self.pickedDate];
    }
	
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	
	self.pickedDate = nil;
	
    [super dealloc];
}


@end
