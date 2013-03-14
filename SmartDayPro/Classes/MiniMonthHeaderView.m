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

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

extern BOOL _isiPad;

@implementation MiniMonthHeaderView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
		self.backgroundColor = [UIColor lightGrayColor];
        //self.backgroundColor = [UIColor colorWithRed:100.0/255 green:104.0/255 blue:124.0/255 alpha:1];
        
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
        
        //CGRect frm = _isiPad?CGRectMake(35, 0, 50, 50):CGRectMake(65, 0, 50, 50);
        CGRect frm = CGRectMake(35, 0, 50, 50);
        
        UIButton *prevButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                //frame:CGRectMake(65, 0, 50, 50)
                                              frame:frm
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(shiftTime:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
        
        prevButton.tag = 11000;
        
        prevButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        [self addSubview:prevButton];
        
        UIImageView *prevImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_prev.png"]];
        prevImgView.frame = CGRectMake(10, 0, 30, 30);
        
        [prevButton addSubview:prevImgView];
        [prevImgView release];
        
        frm = _isiPad?CGRectMake(self.bounds.size.width-125, 0, 50, 50):CGRectMake(self.bounds.size.width-55, 0, 50, 50);
        
        UIButton *nextButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                //frame:CGRectMake(self.bounds.size.width-55, 0, 50, 50)
                                              frame: frm
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(shiftTime:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        nextButton.tag = 11001;
        
        nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        [self addSubview:nextButton];
        
        UIImageView *nextImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_next.png"]];
        nextImgView.frame = CGRectMake(10, 0, 30, 30);
        
        [nextButton addSubview:nextImgView];
        [nextImgView release];
        
        if (_isiPad)
        {
            UIButton *todayButton = [Common createButton:_todayText
                                              buttonType:UIButtonTypeCustom
                                                   frame:CGRectMake(self.bounds.size.width-75, 5, 60, 25)
                                              titleColor:[UIColor whiteColor]
                                                  target:self
                                                selector:@selector(goToday:)
                                        normalStateImage:@"blue_button.png"
                                      selectedStateImage:nil];
            
            [self addSubview:todayButton];
        }
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
}

- (void) shiftTime:(id) sender
{
    UIButton *button = (UIButton *) sender;
    
    MiniMonthView *mmView = (MiniMonthView *) self.superview;
    
    [mmView shiftTime:button.tag-11000];
    
    [self setNeedsDisplay];
}

- (void) goToday:(id) sender
{
    [_abstractViewCtrler jumpToDate:[NSDate date]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	NSString* _dayNamesMon[7] = {_monText, _tueText, _wedText, _thuText, _friText, _satText, _sunText};
	NSString* _dayNamesSun[7] = {_sunText, _monText, _tueText, _wedText, _thuText, _friText, _satText};

	BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
    
    CGFloat wkHeaderWidth = _isiPad?30:0;
	
	CGRect dayRec = rect;
    
    dayRec.size.width -= wkHeaderWidth;
    
	dayRec.origin.y = rect.size.height - 20 + 3;
	dayRec.size.width /= 7;
	
	UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    if (_isiPad)
    {
        NSString *wkHeader = @"CW";
        
        CGRect r = dayRec;
        r.size.width = MINI_MONTH_WEEK_HEADER_WIDTH;
        
		[[UIColor grayColor] set];
		
		[wkHeader drawInRect:CGRectOffset(r, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[wkHeader drawInRect:r withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    }
	
	for (int i=0; i<7; i++)
	{
		NSString *dayName = weekStartOnMonday?_dayNamesMon[i]:_dayNamesSun[i];
		
		dayRec.origin.x = wkHeaderWidth + i*dayRec.size.width;
		
		[[UIColor grayColor] set];
		
		[dayName drawInRect:CGRectOffset(dayRec, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[dayName drawInRect:dayRec withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
	}
    
    font = [UIFont boldSystemFontOfSize:18];

    NSDate *dt = [[TaskManager getInstance] today];
    
    NSString *title = [Common getFullMonthYearString:dt];
    
    if (!selectedButton.selected)
    {
        title = [NSString stringWithFormat:@"Week #%d, %@", [Common getWeekOfYear:dt], [Common getMonthYearString:dt]];
    }
    
    UIButton *prevButton = (UIButton *) [self viewWithTag:11000];
    UIButton *nextButton = (UIButton *) [self viewWithTag:11001];
    
    CGRect monRec = CGRectZero;
    //monRec.origin.x = 110;
    monRec.origin.x = prevButton.frame.origin.x + 50;
    monRec.origin.y = 5;
    //monRec.size.width = self.bounds.size.width-50-monRec.origin.x;
    monRec.size.width = nextButton.frame.origin.x - monRec.origin.x;
    monRec.size.height = 20;
    
    [[UIColor grayColor] set];
    
    [title drawInRect:CGRectOffset(monRec, 0, 1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    [[UIColor whiteColor] set];
    
    [title drawInRect:monRec withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];   
}

@end
