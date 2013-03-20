//
//  PlannerHeaderView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/12/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerHeaderView.h"
#import "Common.h"
#import "Settings.h"
#import "TaskManager.h"

extern BOOL _isiPad;

@implementation PlannerHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        // next/previous button
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
        
        //frm = _isiPad?CGRectMake(self.bounds.size.width-125, 0, 50, 50):CGRectMake(self.bounds.size.width-55, 0, 50, 50);
        frm = CGRectMake(self.bounds.size.width-125, 0, 30, 30);
        
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
        
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSString* _dayNamesMon[7] = {_monText, _tueText, _wedText, _thuText, _friText, _satText, _sunText};
	NSString* _dayNamesSun[7] = {_sunText, _monText, _tueText, _wedText, _thuText, _friText, _satText};
    
	BOOL weekStartOnMonday = [[Settings getInstance] isMondayAsWeekStart];
    
    CGFloat wkHeaderWidth = _isiPad?30:0;
	
	CGRect dayRec = rect;
    
    dayRec.size.width -= wkHeaderWidth;
    
	dayRec.origin.y = rect.size.height - 20 + 3;
	dayRec.size.width /= 7;
	
	UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    /*if (_isiPad)
    {
        NSString *wkHeader = @"CW";
        
        CGRect r = dayRec;
        r.size.width = MINI_MONTH_WEEK_HEADER_WIDTH;
        
		[[UIColor grayColor] set];
		
		[wkHeader drawInRect:CGRectOffset(r, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[wkHeader drawInRect:r withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    }*/
	
	for (int i=0; i<7; i++)
	{
		NSString *dayName = weekStartOnMonday?_dayNamesMon[i]:_dayNamesSun[i];
		
		dayRec.origin.x = wkHeaderWidth + i*dayRec.size.width;
		
		[[UIColor grayColor] set];
		
		[dayName drawInRect:CGRectOffset(dayRec, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[dayName drawInRect:dayRec withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
	}
    
    font = [UIFont boldSystemFontOfSize:16];
    
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
