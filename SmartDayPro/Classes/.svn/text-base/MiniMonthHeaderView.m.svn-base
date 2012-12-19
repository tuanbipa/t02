//
//  MiniMonthHeaderView.m
//  SmartCal
//
//  Created by MacBook Pro on 4/11/11.
//  Copyright 2011 LCL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MiniMonthHeaderView.h"

#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"

#import "MiniMonthView.h"

@implementation MiniMonthHeaderView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
		self.backgroundColor = [UIColor lightGrayColor];
        
        UIButton *zoomButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 50, 50)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(switchMWMode:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
        
        [self addSubview:zoomButton];
        
        UIImageView *zoomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_week.png"]];
        zoomImgView.frame = CGRectMake(5, 3, 30, 30);
        zoomImgView.tag = 10000;
        
        [zoomButton addSubview:zoomImgView];
        [zoomImgView release];
        
        
        selectedButton = zoomButton;
        selectedButton.selected = NO;

        UIButton *prevButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             //frame:CGRectMake(0, 0, 30, 25)
                                frame:CGRectMake(65, 0, 50, 50)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(shiftTime:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
        
        prevButton.tag = 0;
        
        prevButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        [self addSubview:prevButton];
        
        UIImageView *prevImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_prev.png"]];
        prevImgView.frame = CGRectMake(10, 0, 30, 30);
        
        [prevButton addSubview:prevImgView];
        [prevImgView release];
        
        UIButton *nextButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              //frame:CGRectMake(31, 0, 30, 25)
                                frame:CGRectMake(self.bounds.size.width-55, 0, 50, 50)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(shiftTime:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        nextButton.tag = 1;
        
        nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        //[pnView addSubview:nextButton];
        [self addSubview:nextButton];
        
        UIImageView *nextImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_next.png"]];
        nextImgView.frame = CGRectMake(10, 0, 30, 30);
        
        [nextButton addSubview:nextImgView];
        [nextImgView release];
        
        /*
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, self.bounds.size.width-50-110, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.shadowOffset = CGSizeMake(0, 1);
        titleLabel.shadowColor = [UIColor grayColor];
        
        [self addSubview:titleLabel];
        [titleLabel release];
        
        [self refreshTitle];
        */
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (NSInteger) getMWMode
{
    return selectedButton.selected?0:1;
}

- (void) changeMWMode:(NSInteger)mode
{
    selectedButton.selected = (mode==0);
    
    UIImageView *imgView = (UIImageView *)[self viewWithTag:10000];
    
    imgView.image = [UIImage imageNamed:mode==0?@"MM_month.png":@"MM_week.png"];
    
    MiniMonthView *mmView = (MiniMonthView *) self.superview;
    
    [mmView switchView:mode];
    
    [self setNeedsDisplay];
}

- (void) switchMWMode:(id) sender
{
    selectedButton.selected = !selectedButton.selected;
    
    [self changeMWMode:selectedButton.selected?0:1];
    
    //[self refreshTitle];
}

- (void) shiftTime:(id) sender
{
    UIButton *button = (UIButton *) sender;
    
    MiniMonthView *mmView = (MiniMonthView *) self.superview;
    
    [mmView shiftTime:button.tag];
    
    //[self refreshTitle];
    
    [self setNeedsDisplay];
}

/*
- (void) refreshTitle
{
    NSDate *dt = [[TaskManager getInstance] today];
    
    NSString *title = [Common getFullMonthYearString:dt];
    
    //if (selectedButton.tag == 1)
    if (!selectedButton.selected)
    {
        title = [NSString stringWithFormat:@"Week #%d, %@", [Common getWeekOfYear:dt], [Common getMonthYearString:dt]];
    }

    titleLabel.text = title;
}
*/

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	NSString* _dayNamesMon[7] = {_monText, _tueText, _wedText, _thuText, _friText, _satText, _sunText};
	NSString* _dayNamesSun[7] = {_sunText, _monText, _tueText, _wedText, _thuText, _friText, _satText};

	BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
	
	CGRect dayRec = rect;
	dayRec.origin.y = rect.size.height - 20 + 3;
	dayRec.size.width /= 7;
	
	UIFont *font = [UIFont boldSystemFontOfSize:12];
	
	for (int i=0; i<7; i++)
	{
		NSString *dayName = weekStartOnMonday?_dayNamesMon[i]:_dayNamesSun[i];
		
		dayRec.origin.x = i*dayRec.size.width;
		
		[[UIColor grayColor] set];
		
		[dayName drawInRect:CGRectOffset(dayRec, 0, -1) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[dayName drawInRect:dayRec withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	}
    
    font = [UIFont boldSystemFontOfSize:16];

    NSDate *dt = [[TaskManager getInstance] today];
    
    NSString *title = [Common getFullMonthYearString:dt];
    
    if (!selectedButton.selected)
    {
        title = [NSString stringWithFormat:@"Week #%d, %@", [Common getWeekOfYear:dt], [Common getMonthYearString:dt]];
    }
    
    CGRect monRec = CGRectZero;
    monRec.origin.x = 110;
    monRec.origin.y = 5;
    monRec.size.width = self.bounds.size.width-50-monRec.origin.x;
    monRec.size.height = 20;
    
    [[UIColor grayColor] set];
    
    [title drawInRect:CGRectOffset(monRec, 0, 1) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    
    [[UIColor whiteColor] set];
    
    [title drawInRect:monRec withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];   
}

@end
