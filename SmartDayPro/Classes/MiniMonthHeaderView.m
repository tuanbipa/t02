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
#import "FontManager.h"

extern AbstractSDViewController *_abstractViewCtrler;

//extern BOOL _isiPad;

@implementation MiniMonthHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = COLOR_BACKGROUND_HEADER_MINI_MONTH;

        // Create PrevButton
        NSInteger widthPrevNextButton = 30;
        NSInteger heightPrevNextButton = 43;
        NSInteger sizeIconPrevNextButton = 15;
        NSInteger originY = _isiPad ? frame.size.height - 60 : 0;
        
        CGRect frm = CGRectMake(0, originY, widthPrevNextButton, heightPrevNextButton);
        UIButton *prevButton = [Common createButtonWith:@""
                                        buttonType:UIButtonTypeCustom
                                              frame:frm
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(shiftTime:)
                                  normalStateImage:[FontManager flowasticImageWithIconName:@"arrow-left"
                                                                                   andSize:sizeIconPrevNextButton
                                                                                 iconColor:COLOR_PREV_NEXT_BUTTON]
                                selectedStateImage:nil];
        prevButton.backgroundColor = [UIColor yellowColor];
        prevButton.tag = 11000;
        prevButton.backgroundColor = [UIColor clearColor];
        [self addSubview:prevButton];

        // Create NextButton
        frm = CGRectMake(self.bounds.size.width - widthPrevNextButton, originY, widthPrevNextButton, heightPrevNextButton);
        UIButton *nextButton = [Common createButtonWith:@""
                                             buttonType:UIButtonTypeCustom
                                                  frame: frm
                                             titleColor:[UIColor whiteColor]
                                                 target:self
                                               selector:@selector(shiftTime:)
                                       normalStateImage:[FontManager flowasticImageWithIconName:@"arrow-right"
                                                                                        andSize:sizeIconPrevNextButton
                                                                                      iconColor:COLOR_PREV_NEXT_BUTTON]
                                     selectedStateImage:nil];
        nextButton.tag = 11001;
        [self addSubview:nextButton];
        nextButton.backgroundColor = [UIColor clearColor];
        
        // Create Zoom out button
        NSInteger widthIconWeek = 30;
        NSInteger sizeIconWeek = 30;
        NSInteger paddingBetweenZoomOutIn = 30;
        
        frm.origin.x = (frame.size.width - (widthIconWeek * 2) - paddingBetweenZoomOutIn)/2;
        frm.origin.y = originY;
        frm.size = CGSizeMake(widthIconWeek, heightPrevNextButton);

        UIButton *zoomOutButton = [Common createButtonWith:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:frm
                                            titleColor:nil
                                                target:self
                                              selector:@selector(switchMWMode:)
                                      normalStateImage:nil
                                    selectedStateImage:nil];
        zoomOutButton.tag = 12000;
        [self addSubview:zoomOutButton];
        
        UIImage *normalStateImage = [FontManager flowasticImageWithIconName:@"view-2-weeks"
                                                                    andSize:sizeIconWeek
                                                                  iconColor:COLOR_PREV_NEXT_BUTTON];
        
        UIImage *selectedStateImage = [FontManager flowasticImageWithIconName:@"view-2-weeks"
                                                                      andSize:sizeIconWeek
                                                                    iconColor:COLOR_WEEK_BUTTON_SEL];
        
        [zoomOutButton setImage:normalStateImage forState:UIControlStateNormal];
        [zoomOutButton setImage:selectedStateImage forState:UIControlStateSelected];
        
        // Create Zoom in button
        frm.origin.x = zoomOutButton.frame.origin.x + zoomOutButton.frame.size.width + paddingBetweenZoomOutIn;
        frm.origin.y = originY;
        UIButton *zoomInButton = [Common createButtonWith:@""
                                                buttonType:UIButtonTypeCustom
                                                     frame:frm
                                                titleColor:nil
                                                    target:self
                                                  selector:@selector(switchMWMode:)
                                          normalStateImage:nil
                                        selectedStateImage:nil];
        zoomInButton.tag = 12001;
        [self addSubview:zoomInButton];
        
        UIImage *normalStateImageWeek = [FontManager flowasticImageWithIconName:@"view-week"
                                                                    andSize:sizeIconWeek
                                                                  iconColor:COLOR_PREV_NEXT_BUTTON];
        
        UIImage *selectedStateImageWeek = [FontManager flowasticImageWithIconName:@"view-week"
                                                                      andSize:sizeIconWeek
                                                                    iconColor:COLOR_WEEK_BUTTON_SEL];
        
        [zoomInButton setImage:normalStateImageWeek forState:UIControlStateNormal];
        [zoomInButton setImage:selectedStateImageWeek forState:UIControlStateSelected];
        
        // Set state default
        zoomOutButton.selected = YES;
        zoomOutButton.userInteractionEnabled = NO;
        zoomInButton.selected = NO;
        zoomInButton.userInteractionEnabled = YES;
        
        if (_isiPad) {
            UIButton *todayButton = [Common createButton:_todayText
                                              buttonType:UIButtonTypeCustom
                                                   frame:CGRectMake(self.bounds.size.width-65, 5, 60, 25)
                                              titleColor:[UIColor whiteColor]
                                                  target:self
                                                selector:@selector(goToday:)
                                        normalStateImage:nil
                                      selectedStateImage:nil];
            
            todayButton.backgroundColor = COLOR_BACKGROUND_TODAY_IPAD;
            todayButton.layer.cornerRadius = 4;
            todayButton.layer.borderWidth = 1;
            todayButton.layer.borderColor = [COLOR_BACKGROUND_TODAY_IPAD CGColor];
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
	
    UIFont *font = [UIFont systemFontOfSize:12];
    
    // set week header background
    CGRect weekRect = dayRec;
    weekRect.size.width = rect.size.width;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [COLOR_HEADER_MINI_MONTH set];
    CGContextFillRect(ctx, weekRect);
    
    if (_isiPad)
    {
        NSString *wkHeader = @"CW";
        
        CGRect r = dayRec;
        r.size.width = MINI_MONTH_WEEK_HEADER_WIDTH;
        
		[[UIColor whiteColor] set];
		
		[wkHeader drawInRect:CGRectOffset(r, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
		[[UIColor whiteColor] set];
		
		[wkHeader drawInRect:r withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    }
	
	for (int i=0; i<7; i++)
	{
		NSString *dayName = weekStartOnMonday?_dayNamesMon[i]:_dayNamesSun[i];
		
		dayRec.origin.x = wkHeaderWidth + i*dayRec.size.width;
		
		[[UIColor whiteColor] set];
		
//        [dayName drawInRect:CGRectOffset(dayRec, 0, -1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
        
        [dayName drawInRect:CGRectOffset(dayRec, 0, 0) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
		
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
        [COLOR_BACKGROUND_TODAY_IPAD set];
        [day drawInRect:titleRec withFont:font];
        
        // full day
        NSString *fullDay = [Common getFullDateString3:dt];
        font = [UIFont systemFontOfSize:16];
        titleRec.origin.x += titleRec.size.width + 5;
        titleRec.origin.y += 4;
        sz = [fullDay sizeWithFont:font];
        titleRec.size = sz;
        [COLOR_TEXT_DATETODAY_IPAD set];
        [fullDay drawInRect:titleRec withFont:font];
    }
}

@end
