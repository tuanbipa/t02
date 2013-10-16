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
#import "PlannerView.h"
#import "PlannerViewController.h"

@implementation PlannerHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"planner_top_bg.png"]];
        self.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1];
        
        // next/previous button
        CGRect frm = CGRectMake(0, 0, 50, 50);
        
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
        prevButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:prevButton];
        
        UIImageView *prevImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_prev.png"]];
        prevImgView.frame = CGRectMake(10, 0, 30, 30);
        [prevButton addSubview:prevImgView];
        [prevImgView release];
        
        // month button
        UIButton *monthButton = [Common createButton:@""
                                          buttonType:UIButtonTypeCustom
                                               frame:CGRectMake(frm.origin.x + frm.size.width + 50, 5, 160, 25)
                                          titleColor:[UIColor grayColor]
                                              target:self
                                            selector:@selector(showYearView:)
                                    normalStateImage:nil
                                  selectedStateImage:nil];
        monthButton.tag = 20000;
        [self addSubview:monthButton];
        
        // next button
        frm = CGRectMake(monthButton.frame.origin.x + monthButton.frame.size.width + 50, 0, 50, 50);
        
        UIButton *nextButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
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
        
        // zoom out button (month mode)
        //frm.origin.x = frame.size.width/2 - 50 - PAD_WIDTH;
        //frm.origin.y -= PAD_WIDTH;
        frm.origin = CGPointMake(frm.origin.x + frm.size.width + 50, -8);
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
        
        // zoom in button (week mode)
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
        
        // today button
        UIButton *todayButton = [Common createButton:_todayText
                                          buttonType:UIButtonTypeCustom
                                               frame:CGRectMake(self.bounds.size.width - PAD_WIDTH - 60, 5, 60, 25)
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
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIColor *grnColor = [UIColor colorWithRed:114.0/255 green:134.0/255 blue:195.0/255 alpha:1];
    [grnColor set];
    rect.origin.y = rect.size.height - 18;
    CGContextFillRect(ctx, rect);
    
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
    
    /*UIButton *prevButton = (UIButton *) [self viewWithTag:11000];
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
    
    // update frame of month button
    UIButton *monthButton = (UIButton *) [self viewWithTag:20000];
    monthButton.frame = monRec;*/
    
    UIButton *monthButton = (UIButton *) [self viewWithTag:20000];
    CGRect monRec = monthButton.frame;
    
    /*[[UIColor grayColor] set];
    [title drawInRect:CGRectOffset(monRec, 0, 1) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];*/
    [grnColor set];
    [title drawInRect:monRec withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}

#pragma mark Actions

- (void) shiftTime:(id) sender
{
    UIButton *button = (UIButton *) sender;
    PlannerView *plannerView = (PlannerView *) self.superview;
    [plannerView shiftTime:button.tag-11000];
    
    [self setNeedsDisplay];
}

- (void)switchMWMode:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [self changeMWMode:button.tag - 12000];
}

- (void) changeMWMode:(NSInteger)mode
{
    UIButton *zoomOutButton = (UIButton*)[self viewWithTag:12000];
    UIButton *zoomInButton = (UIButton*)[self viewWithTag:12001];
    zoomOutButton.userInteractionEnabled = mode==1;
    zoomOutButton.selected = !zoomOutButton.userInteractionEnabled;
    zoomInButton.userInteractionEnabled = mode==0;
    zoomInButton.selected = !zoomInButton.userInteractionEnabled;
    
    PlannerView *mmView = (PlannerView *) self.superview;
    
    [mmView switchView:mode];
}

- (void) goToday:(id) sender
{
    PlannerView *plannerView = (PlannerView *) self.superview;
    [plannerView goToday];
    
    [self setNeedsDisplay];
}

- (void) showYearView:(id) sender
{
    UIButton *monthButton = (UIButton *) [self viewWithTag:20000];
    [(PlannerViewController*)[AbstractActionViewController getInstance] showYearView:monthButton];
}

- (NSInteger) getMWMode
{
    //return selectedButton.selected?0:1;
    UIButton *zoomOutButton = (UIButton*)[self viewWithTag:12000];
    return zoomOutButton.selected?0:1;
}
@end
