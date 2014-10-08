//
//  SDNavigationController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "SDNavigationController.h"

#import "Settings.h"

#import "SmartDayViewController.h"
#import "iPadViewController.h"
#import "iPadSettingViewController.h"
#import "NoteContentViewController.h"
#import "MapLocationViewController.h"
#import "TimerHistoryViewController.h"

extern BOOL _isiPad;

@implementation SDNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    //Settings *settings = [Settings getInstance];
    
    //return settings.landscapeModeEnable;
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if ([self.topViewController isKindOfClass:[SmartDayViewController class]]
        || [self.topViewController isKindOfClass:[iPadViewController class]]
        || [self.topViewController isKindOfClass:[iPadSettingViewController class]]
        || [self.topViewController isKindOfClass:[NoteContentViewController class]]
        || ([self.topViewController isKindOfClass:[MapLocationViewController class]] && _isiPad)
        || [self.topViewController isKindOfClass:[TimerHistoryViewController class]])
    {
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
