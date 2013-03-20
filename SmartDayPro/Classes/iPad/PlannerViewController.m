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
    }
    
    return self;
}

- (void) dealloc
{
    [smartListViewCtrler release];
    [plannerView release];
    
    [super dealloc];
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size.width = sz.height + 20 + 44;
    frm.size.height = sz.width - 20 - 44;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor magentaColor];
    
    self.view = contentView;
    
    [contentView release];
    
    [contentView addSubview:smartListViewCtrler.view];
    
    frm.origin.x = frm.size.width - 320;
    frm.size.width = 320;
    
    [smartListViewCtrler changeFrame:frm];
    
    // planer view in left
    //plannerView
    plannerView = [[PlannerView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width - smartListViewCtrler.contentView.frame.size.width, frm.size.height)];
    [contentView addSubview:plannerView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [smartListViewCtrler refreshLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
