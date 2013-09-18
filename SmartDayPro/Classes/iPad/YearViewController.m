//
//  YearViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "YearViewController.h"
#import "Common.h"
#import "YearView.h"
#import "TaskManager.h"

@interface YearViewController ()

@end

@implementation YearViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithSize: (CGSize)size {
    if (self = [super init])
    {
        /*CGSize scrSize = [Common getScreenSize];
        self.contentSizeForViewInPopover = CGSizeMake(scrSize.height - 0, scrSize.width - 100);
        
        CGRect frm = CGRectMake(0, 0, scrSize.height, scrSize.width - 100);*/
        
        CGRect frm = CGRectZero;
        frm.size = size;
        self.preferredContentSize = frm.size;
        
        contentView = [[YearView alloc] initWithFrame:frm];
        //self.contentSizeForViewInPopover = scrSize;
        //self.preferredContentSize = scrSize;
        
        self.view = contentView;
        [contentView release];
        
        TaskManager *tm = [TaskManager getInstance];
        NSDate *dt = tm.today;
        NSDate *firstDate = [Common getFirstYearDate:dt];
        contentView.date = firstDate;
        [contentView initCalendar];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /*TaskManager *tm = [TaskManager getInstance];
    NSDate *dt = tm.today;
    NSDate *firstDate = [Common getFirstYearDate:dt];
    contentView.date = firstDate;
    [contentView initCalendar];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
