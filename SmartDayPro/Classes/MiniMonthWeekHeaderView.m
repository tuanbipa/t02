//
//  MiniMonthWeekHeaderView.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/7/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "MiniMonthWeekHeaderView.h"

#import "Common.h"

#import "MiniMonthView.h"
#import "MonthlyCalendarView.h"

extern BOOL _isiPad;

@implementation MiniMonthWeekHeaderView

@synthesize skinStyle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.skinStyle = _isiPad?0:1;
        
        self.backgroundColor = self.skinStyle == 0?[UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1]:[UIColor colorWithRed:100.0/255 green:100.0/255 blue:100.0/255 alpha:1];
    }
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    MiniMonthView *mm = (MiniMonthView *) self.superview;
    
    NSDate *firstDate = [mm.calView getFirstDate];
    
    CGFloat h = (_isiPad?48:40);
    
    UIColor *textColor = (self.skinStyle == 0?[UIColor grayColor]:[UIColor whiteColor]);
    
    [textColor set];
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    for (int i=0; i<6; i++)
    {
        NSDate *dt = i==0?firstDate:[Common dateByAddNumDay:i*7 toDate:firstDate];
        
        NSInteger wkNum = [Common getWeekOfYear:dt];
        
        CGRect rec = CGRectMake(0, i*h + 15, rect.size.width, 20);
        
        NSString *str = [NSString stringWithFormat:@"%d", wkNum];
        
        [str drawInRect:rec withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}


@end
