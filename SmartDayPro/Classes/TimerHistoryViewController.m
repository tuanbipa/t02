//
//  TimerHistoryViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 3/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>

#import "TimerHistoryViewController.h"

#import "Common.h"
#import "Task.h"
#import "TaskProgress.h"

#import "DBManager.h"
#import "ProjectManager.h"

#import "ContentView.h"

@interface TimerHistoryViewController ()

@end

@implementation TimerHistoryViewController

@synthesize task;
@synthesize progressList;

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
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}

- (void) dealloc
{
    self.progressList = nil;
    
    [super dealloc];
}

- (void) report:(id) sender
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    NSString *mailBody = [NSString stringWithFormat:@"Hi,\n This is a report of task '%@' from SmartDay. You can view it in any spreadsheet.", self.task.name];
    
    NSString *csvContent = @"Project, Task Name, Duration, Due Date, Start Date, Completed Date, Timer Duration, Segment No, From Time, To Time, Sub Total \n";
    
    TaskProgress *progress = [self.progressList objectAtIndex:0];
    NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
    
    csvContent = [csvContent stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%d,%@,%@,%@\n",
                                                     [pm getProjectNameByKey:self.task.project],
                                                      self.task.name,
                                                      [Common getDurationString:self.task.duration],
                                                      self.task.startTime == nil? @"None":[Common getFullDateString:self.task.startTime],
                                                      self.task.deadline == nil? @"None":[Common getFullDateString:self.task.deadline],
                                                      self.task.completionTime == nil? @"None":[Common getFullDateString:self.task.completionTime],
                                                      [Common getTimerDurationString:actualDuration],
                                                      1,
                                                      [Common getFullDateTimeString2:progress.startTime],
                                                      [Common getFullDateTimeString2:progress.endTime],
                                                      [Common getTimerDurationString:duration]
                                                      ]];
    
    for (int i=1; i<self.progressList.count; i++)
    {
        TaskProgress *progress = [self.progressList objectAtIndex:i];
        NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
        
        csvContent = [csvContent stringByAppendingString:[NSString stringWithFormat:@",,,,,,,%d,%@,%@,%@\n",
                                                          i+1,
                                                          [Common getFullDateTimeString2:progress.startTime],
                                                          [Common getFullDateTimeString2:progress.endTime],
                                                          [Common getTimerDurationString:duration]
                                                          ]];
        
    }

	MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init] autorelease];
	if (picker) {
		picker.mailComposeDelegate=self;
		[picker setSubject:@"SmartDay Report"];
		
		[picker setToRecipients:nil];
		[picker setCcRecipients:nil];
		[picker setBccRecipients:nil];
		
		if(csvContent)
        {
			NSData *myData = [csvContent dataUsingEncoding:NSUTF8StringEncoding];
			[picker addAttachmentData:myData mimeType:@"text/csv" fileName:@"SmartDay_Report.csv"];
		}
		
		// Fill out the email body text
		if(mailBody)
        {
			[picker setMessageBody:mailBody isHTML:YES];
		}
		
		[self presentModalViewController:picker animated:NO];
	}
}

#pragma mark View

- (void) loadView
{
    ContentView *contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    self.view = contentView;
    
    [contentView release];
    
    historyTableView = [[UITableView alloc] initWithFrame:CGRectInset(contentView.bounds, 5, 5) style:UITableViewStyleGrouped];
    
    historyTableView.delegate = self;
    historyTableView.dataSource = self;
    
	[contentView addSubview:historyTableView];
	[historyTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    DBManager *dbm = [DBManager getInstance];
    
    self.progressList = [dbm getProgressHistoryForTask:self.task.primaryKey];
    
	actualDuration = 0;
	
	for (TaskProgress *progress in self.progressList)
	{
		actualDuration += [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
	}

    [historyTableView reloadData];
    
	UIButton *reportButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 0, 40, 40)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(report:)
                              normalStateImage:@"report.png"
                            selectedStateImage:nil];
    
    self.navigationItem.title = _timerHistoryText;
	
	UIBarButtonItem *reportButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
    
    reportButtonItem.enabled = (self.progressList.count > 0);
    
    self.navigationItem.rightBarButtonItem = reportButtonItem;
    
    [reportButtonItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.progressList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
	return [_totalDurationText stringByAppendingFormat:@": %@", [Common getDurationString:actualDuration]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor clearColor];
    
    TaskProgress *progress = [self.progressList objectAtIndex:indexPath.row];
    
    NSInteger duration = [Common timeIntervalNoDST:progress.endTime sinceDate:progress.startTime];
    
    UILabel *timeValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 25)];
    timeValueLabel.tag = 10013;
    timeValueLabel.textAlignment=UITextAlignmentLeft;
    timeValueLabel.textColor= [Colors darkSteelBlue];
    timeValueLabel.backgroundColor=[UIColor clearColor];
    
    timeValueLabel.text = [Common getDateTimeString:progress.startTime];
    
    [cell.contentView addSubview:timeValueLabel];
    [timeValueLabel release];
    
    UILabel *durationValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(300-120, 5, 100, 25)];
    durationValueLabel.tag = 10014;
    durationValueLabel.textAlignment=UITextAlignmentRight;
    durationValueLabel.textColor= [Colors darkSteelBlue];
    durationValueLabel.backgroundColor=[UIColor clearColor];
    
    durationValueLabel.text = [Common getTimerDurationString:duration];
    
    [cell.contentView addSubview:durationValueLabel];
    [durationValueLabel release];
    
    return cell;
}

#pragma mark Mail
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
	if(result == MFMailComposeResultSent)
    {
		UIAlertView *sentAlertView = [[UIAlertView alloc] initWithTitle:nil
															  message:_reportSuccess
															 delegate:nil
													cancelButtonTitle:_okText
													otherButtonTitles:nil];
		[sentAlertView show];
		[sentAlertView release];
	}
    else if(result == MFMailComposeResultFailed)
    {
		UIAlertView *failedAlertView=[[UIAlertView alloc] initWithTitle:nil
																message:_reportFailure
															   delegate:nil
													  cancelButtonTitle:_okText
													  otherButtonTitles:nil];
		[failedAlertView show];
		[failedAlertView release];
	}	
	
}


@end
