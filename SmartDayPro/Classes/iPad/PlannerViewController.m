//
//  PlannerViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerViewController.h"

#import "Common.h"
#import "ContentView.h"

#import "SmartListViewController.h"
#import "PlannerView.h"
#import "PlannerBottomDayCal.h"

@interface PlannerViewController ()

@end

@implementation PlannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        smartListViewCtrler = [[SmartListViewController alloc] init];
        //plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustSubFrame:) name:@"NotificationAdjustPlannerMiniMonthHeight" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [smartListViewCtrler release];
    [plannerView release];
    [plannerBottomDayCal release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size.width = sz.height + 20 + 44;
    //frm.size.height = sz.width - 20 - 44;
    frm.size.height = sz.width - 20;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor magentaColor];
    
    self.view = contentView;
    
    [contentView release];
    
    [contentView addSubview:smartListViewCtrler.view];
    
    frm.origin.x = frm.size.width - 234;
    frm.size.width = 234;
    
    //[smartListViewCtrler changeFrame:frm];
    
    // planer view in left
    //plannerView
    //plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 0, contentView.frame.size.width - smartListViewCtrler.contentView.frame.size.width, frm.size.height)];
    //[contentView addSubview:plannerView];

    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(8, 8, 750, 206)];
    [contentView addSubview:plannerView];
    
    CGRect tmp = CGRectMake(plannerView.frame.origin.x + plannerView.frame.size.width + 8, 8, contentView.frame.size.width - (plannerView.frame.origin.x + plannerView.frame.size.width + 8), frm.size.height - 16);
    
    [smartListViewCtrler changeFrame:tmp];
    
    // bottom day cal
    plannerBottomDayCal = [[PlannerBottomDayCal alloc] initWithFrame:CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16)];
    [contentView addSubview:plannerBottomDayCal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [smartListViewCtrler refreshLayout];
}

- (void) adjustSubFrame: (NSNotification*) notification {
    
    CGRect frm = CGRectMake(8,plannerView.frame.origin.y + plannerView.frame.size.height + 8, 750, contentView.frame.size.height - (plannerView.frame.origin.y + plannerView.frame.size.height) - 16);
    plannerBottomDayCal.frame = frm;
    
    // change date
    NSDictionary *userInfo = [notification userInfo];
    NSDate *firstDate = [userInfo objectForKey:@"firstDate"];
    
    [plannerBottomDayCal changeWeek:firstDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
