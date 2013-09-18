//
//  YearView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "YearView.h"
#import "Common.h"
#import "MonthInYearView.h"
//#import "TaskManager.h"

@implementation YearView

@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat buttonWidth = 50;
        
        CGFloat monthHeight = frame.size.height/3;
        CGFloat monthWidth = (frame.size.width - buttonWidth*2)/4;
        //CGFloat xOffset = buttonWidth;
        //CGFloat x = xOffset;
        CGFloat x = buttonWidth;
        CGFloat y = 0;
        
        //CGSize contentSize = CGSizeMake(frame.size.width - 60, frame.size.height);
        for (int i = 0; i<12; i++) {
            CGRect monthFrm = CGRectMake(x, y, monthWidth, monthHeight);
            MonthInYearView *monthView = [[MonthInYearView alloc] initWithFrame:monthFrm];
            [self addSubview:monthView];
            [monthView release];
            
            x += monthWidth;
            if ((i+1)%4 == 0) {
                //x = xOffset;
                x = buttonWidth;
                y += monthHeight;
            }
        }
        
        self.backgroundColor = [UIColor whiteColor];
        
        
        CGRect frm = CGRectMake(0, (frame.size.height - buttonWidth)/2, buttonWidth, buttonWidth);
        
        // previous button
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
        [self addSubview:prevButton];
        
        UIImageView *prevImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_prev.png"]];
        prevImgView.frame = CGRectMake(10, 0, 30, 30);
        [prevButton addSubview:prevImgView];
        [prevImgView release];
        
        frm.origin.x = (frame.size.width - buttonWidth);
        
        // next buttom
        UIButton *nextButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame: frm
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(shiftTime:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        nextButton.tag = 11001;
        [self addSubview:nextButton];
        
        UIImageView *nextImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_next.png"]];
        nextImgView.frame = CGRectMake(10, 0, 30, 30);
        [nextButton addSubview:nextImgView];
        [nextImgView release];
        
    }
    return self;
}

- (void)initCalendar {
    NSDate *firstDate = [[self.date copy] autorelease];
    // set day for month calendar
    for (int i = 0; i < 12; i++) {
        MonthInYearView *monthView = [[self subviews] objectAtIndex:i];
        monthView.monthDate = firstDate;
        //[monthView setNeedsDisplay];
        [monthView initCalendar];//:firstDate];
        //[monthView refresh];
        firstDate = [Common dateByAddNumMonth:1 toDate:firstDate];
    }
}

- (void)shiftTime: (id) sender {
    UIButton *button = (UIButton *) sender;
    
    NSInteger mode = button.tag-11000;
    self.date = [Common dateByAddNumYear:(mode == 0?-1:1) toDate:self.date];
    [self initCalendar];
}

- (void)dealloc {
    [date release];
    [super dealloc];
}
@end
