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

//extern BOOL _isiPad;

@implementation MiniMonthHeaderView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat yMargin = (_isiPad?50:10);

        CGRect frm = CGRectMake(5, yMargin, 50, 50);
        
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

        prevImgView.frame = CGRectMake(0, 0, 30, 30);
        
        [prevButton addSubview:prevImgView];
        [prevImgView release];
        
        frm = CGRectMake(self.bounds.size.width-55, yMargin, 50, 50);
        
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
        
        // zoom out button
        UIImageView *nextImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_next.png"]];
        nextImgView.frame = CGRectMake(20, 0, 30, 30);
        
        [nextButton addSubview:nextImgView];
        [nextImgView release];
        
        frm.origin.x = frame.size.width/2 - 50 - PAD_WIDTH;
        frm.origin.y -= PAD_WIDTH;
        frm.size = CGSizeMake(50, 50);
        
        UIButton *zoomOutButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:frm
                                            titleColor:nil
                                                target:self
                                              selector:@selector(switchMWMode:)
                                      normalStateImage:@"MM_month.png"
                                    selectedStateImage:@"MM_month_selected.png"];
        zoomOutButton.tag = 12000;
        [self addSubview:zoomOutButton];
        
        // zoom in button
        frm.origin.x += 50 + PAD_WIDTH/2;
        UIButton *zoomInButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:frm
                                            titleColor:nil
                                                target:self
                                              selector:@selector(switchMWMode:)
                                      normalStateImage:@"MM_week.png"
                                    selectedStateImage:@"MM_week_selected.png"];
        zoomInButton.tag = 12001;
        [self addSubview:zoomInButton];
        
        zoomOutButton.selected = YES;
        zoomOutButton.userInteractionEnabled = NO;
        zoomInButton.selected = NO;
        zoomInButton.userInteractionEnabled = YES;
        
        if (_isiPad)
        {
            UIButton *todayButton = [Common createButton:_todayText
                                              buttonType:UIButtonTypeCustom
                                                   frame:CGRectMake(self.bounds.size.width-65, 5, 60, 25)
                                              titleColor:[Colors blueButton]
                                                  target:self
                                                selector:@selector(goToday:)
                                        normalStateImage:nil
                                      selectedStateImage:nil];
            
            todayButton.layer.cornerRadius = 4;
            todayButton.layer.borderWidth = 1;
            todayButton.layer.borderColor = [[Colors blueButton] CGColor];
            todayButton.titleLabel.font = [UIFont systemFontOfSize:16];
            
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
    //return selectedButton.selected?0:1;
    UIButton *zoomOutButton = (UIButton*)[self viewWithTag:12000];
    return zoomOutButton.selected?0:1;
}

- (void) changeMWMode:(NSInteger)mode
{
    /*selectedButton.selected = (mode==0);
    
    UIImageView *imgView = (UIImageView *)[self viewWithTag:10000];
    
    imgView.image = [UIImage imageNamed:mode==0?@"MM_month.png":@"MM_week.png"];*/
    
    UIButton *zoomOutButton = (UIButton*)[self viewWithTag:12000];
    UIButton *zoomInButton = (UIButton*)[self viewWithTag:12001];
    zoomOutButton.userInteractionEnabled = mode==1;
    zoomOutButton.selected = !zoomOutButton.userInteractionEnabled;
    zoomInButton.userInteractionEnabled = mode==0;
    zoomInButton.selected = !zoomInButton.userInteractionEnabled;
    
    MiniMonthView *mmView = (MiniMonthView *) self.superview;
    
    [mmView switchView:mode];
    
    [self setNeedsDisplay];
}

- (void) switchMWMode:(id) sender
{
    /*selectedButton.selected = !selectedButton.selected;
    
    [self changeMWMode:selectedButton.selected?0:1];*/
    
    UIButton *button = (UIButton*)sender;
    [self changeMWMode:button.tag - 12000];
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
    [self setNeedsDisplay];
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
    
    // set week header background
    CGRect weekRect = dayRec;
    weekRect.size.width = rect.size.width;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] set];
    CGContextFillRect(ctx, weekRect);
    
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
    
    if (_isiPad)
    {
        NSDate *dt = [[TaskManager getInstance] today];
        
        // day
        font = [UIFont systemFontOfSize:40];
        NSString *day = [Common getDayString:dt];
        CGSize sz = [day sizeWithFont:font];
        CGRect titleRec = CGRectMake(5, 5, 0, 0);
        titleRec.size = sz;
        [[UIColor grayColor] set];
        [day drawInRect:titleRec withFont:font];
        
        // full day
        NSString *fullDay = [Common getFullDateString3:dt];
        font = [UIFont systemFontOfSize:16];
        titleRec.origin.x += titleRec.size.width + 5;
        titleRec.origin.y += 4;
        sz = [fullDay sizeWithFont:font];
        titleRec.size = sz;
        [[UIColor grayColor] set];
        [fullDay drawInRect:titleRec withFont:font];
    }
}

@end
