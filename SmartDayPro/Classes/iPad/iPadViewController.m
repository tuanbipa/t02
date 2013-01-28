//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "iPadViewController.h"

#import "Common.h"
#import "ContentView.h"

#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"

extern BOOL _isiPad;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

@interface iPadViewController ()

@end

@implementation iPadViewController

@synthesize activeViewCtrler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}

- (void) dealloc
{
    self.activeViewCtrler = nil;
    
    [super dealloc];
}

#pragma mark View

- (void) showLandscapeView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }
        
    PlannerViewController *ctrler = [[PlannerViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    [contentView addSubview:self.activeViewCtrler.view];
}

- (void) showPortraitView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }

    iPadSmartDayViewController *ctrler = _iPadSDViewCtrler;
    
    self.activeViewCtrler = _iPadSDViewCtrler;
    
    [contentView addSubview:self.activeViewCtrler.view];    
}

- (void) loadView
{
    CGRect frm = [Common getFrame];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    self.view = contentView;
    
    [self showPortraitView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
        
        [self showLandscapeView];
    }
    else
    {
        frm.size = sz;
        
        [self showPortraitView];
    }
    
    contentView.frame = frm;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
