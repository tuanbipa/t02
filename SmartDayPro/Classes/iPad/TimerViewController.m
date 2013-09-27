//
//  TimerViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TimerViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"

#import "TimerManager.h"
#import "ProjectManager.h"
#import "MusicManager.h"

#import "ContentView.h"

@interface TimerViewController ()

@end

@implementation TimerViewController

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
    if (self =[super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320,440);
        
        activeTimer = nil;
    }
    
    return self;
}

- (void) dealloc
{
    [self deactivateTimer];

    [super dealloc];
}

- (void) updateActiveTime: (id) sender
{
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	int c = 0;
	for (Task *task in timer.activeTaskList)
	{
		NSInteger durationValue = [timer getTimerDurationForTask:task];
		//printf("update Time: %s - %d\n", [task.name UTF8String], durationValue);
		
		UITableViewCell *cell = [timerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:c inSection:activateSectionCount]];
		
		UILabel *timeValueLabel = [cell.contentView viewWithTag:10002];
		
		timeValueLabel.text = [Common getTimerDurationString:durationValue];
		
		c++;
	}
}


- (void) deactivateTimer
{
	if (activeTimer != nil)
	{
		if ([activeTimer isValid])
		{
			[activeTimer invalidate];
		}
		
		[activeTimer release];
		activeTimer = nil;
	}
}

- (void) activateTimer
{
	[self deactivateTimer];
	
	activeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateActiveTime:) userInfo:nil repeats:YES];
	
	[activeTimer retain];
}

- (void) checkToActivateTimer
{
    TimerManager *timer = [TimerManager getInstance];
    
    if (timer.activeTaskList != nil && timer.activeTaskList.count > 0 && activeTimer == nil)
    {
        [self activateTimer];
    }
}

- (void) checkToDeactivateTimer
{
    TimerManager *timer = [TimerManager getInstance];
    
    if (timer.activeTaskList != nil && timer.activeTaskList.count == 0 && activeTimer != nil)
    {
        [self deactivateTimer];
    }
}

- (void) startTaskActivation: (id) sender
{
    [[MusicManager getInstance] playSound:SOUND_START];
    
	[[TimerManager getInstance] activateTask];
	
	[timerTableView reloadData];
    
    [self checkToActivateTimer];
}

- (void) holdAllActiveTasksAndStart: (id) sender
{
    [[MusicManager getInstance] playSound:SOUND_START];
    
	[[TimerManager getInstance] holdAllActiveTasksAndStart];
	
	[timerTableView reloadData];
	
	//[self startActiveTimer];
    [self checkToActivateTimer];
}

- (void) pauseTask: (id) sender
{
    [[MusicManager getInstance] playSound:SOUND_PAUSE];
    
	NSInteger row = [sender tag] - 11000;
	
	[[TimerManager getInstance] pauseTask:row];
	
	[timerTableView reloadData];
    
    [self checkToDeactivateTimer];
}

- (void) startTask: (id) sender
{
    [[MusicManager getInstance] playSound:SOUND_START];
    
	NSInteger row = [sender tag] - 11000;
	
	[[TimerManager getInstance] startTask:row];
    
	[timerTableView reloadData];
    
    [self checkToActivateTimer];
}

-(void)confirmMarkDone: (id) sender
{
	UIAlertView *taskDoneAlertView = [[UIAlertView alloc] initWithTitle:_taskMarkDoneTitle  message:_taskMarkDoneText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
	taskDoneAlertView.tag = sender;
	
	[taskDoneAlertView addButtonWithTitle:_okText];
	[taskDoneAlertView show];
	[taskDoneAlertView release];
}

- (void) markDoneTask: (id) sender
{
    [[MusicManager getInstance] playSound:SOUND_STOP];
    
	UIButton *stopButton = (UIButton *) sender;
	
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	NSInteger section = (stopButton.tag >= 13000?1:0) + activateSectionCount;
	
	NSInteger row = stopButton.tag - (section == 1 + activateSectionCount? 13000:12000);
	
	UITableViewCell *cell = [timerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
	
	UIButton *button = [cell.contentView viewWithTag:11000 + row];
	[button removeFromSuperview];
    
	[stopButton removeFromSuperview];
	
	UIImageView *checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check32.png"]];
	checkImageView.frame = CGRectMake(0, 0, 30, 30);
	checkImageView.tag = 10003;
	
	[cell.contentView addSubview:checkImageView];
	[checkImageView release];
    
	[timer markDoneTask:row inProgress:(section == 1 + activateSectionCount)];
	
	[timerTableView reloadData];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[self markDoneTask:alertVw.tag];
	}
}

#pragma mark View

- (void) loadView
{
    contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    self.view = contentView;
    
    [contentView release];
    
    /*
    UIView *bgView = [[UIView alloc] initWithFrame:contentView.bounds];
    bgView.backgroundColor = [[Colors darkSlateGray] colorWithAlphaComponent:0.8];
    
    [contentView addSubview:bgView];
    [bgView release];
    */
        
    timerTableView = [[UITableView alloc] initWithFrame:CGRectInset(contentView.bounds, 5, 5) style:UITableViewStylePlain];

    timerTableView.delegate = self;
    timerTableView.dataSource = self;
    //timerTableView.sectionHeaderHeight=25;
    timerTableView.backgroundColor = [UIColor clearColor];
    timerTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
	[contentView addSubview:timerTableView];
	[timerTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _timerText;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[TimerManager getInstance] refreshTaskLists:YES];
 
    [[MusicManager getInstance] playSound:SOUND_TIMER_ON];
    
    [self checkToActivateTimer];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[MusicManager getInstance] playSound:SOUND_TIMER_OFF];
    
    [self checkToDeactivateTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	taskList = timer.activeTaskList;
	
	if (timer.inProgressTaskList.count > 0 && timer.activeTaskList.count > 0)
	{
		return 2 + activateSectionCount;
	}
    
	if (timer.inProgressTaskList.count > 0)
	{
		taskList = timer.inProgressTaskList;
	}
	
    return 1 + activateSectionCount;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (section == 1+activateSectionCount)
	{
		return timer.inProgressTaskList.count;
	}
	
	if (section == activateSectionCount)
	{
		return taskList.count;
	}
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (activateSectionCount == 1 && indexPath.section == 0)
	{
		return 65;
	}
	
	return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    TimerManager *timer = [TimerManager getInstance];
    NSString *title = nil;
    
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (section == 1+activateSectionCount)
	{
		title = _inProgressTasksText;
	}
    
	if (section == activateSectionCount)
	{
		if (taskList == timer.inProgressTaskList)
		{
			title = _inProgressTasksText;
		}
		
		title = _activeTasksText;
	}
    
    if (title != nil)
    {
        //return 30.0f;
        return 20;
    }
    
    return 0;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TimerManager *timer = [TimerManager getInstance];
    NSString *title = nil;
    
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (section == 1+activateSectionCount)
	{
		title = _inProgressTasksText;
	}
    
	if (section == activateSectionCount)
	{
		if (taskList == timer.inProgressTaskList)
		{
			title = _inProgressTasksText;
		}
		else
        {
            title = _activeTasksText;
        }
	}
    
    if (title != nil)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 30;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = title;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	TimerManager *timer = [TimerManager getInstance];
	
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (section == 1+activateSectionCount)
	{
		return _inProgressTasksText;
	}
    
	if (section == activateSectionCount)
	{
		if (taskList == timer.inProgressTaskList)
		{
			return _inProgressTasksText;
		}
		
		return _activeTasksText;
	}
	
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   	TimerManager *timer = [TimerManager getInstance];
	
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
    
    // Set up the cell...
	NSInteger activateSectionCount = (timer.taskToActivate != nil? 1:0);
	
	if (indexPath.section >= activateSectionCount)
	{
		Task *task = [(indexPath.section == activateSectionCount?taskList:timer.inProgressTaskList) objectAtIndex:indexPath.row];
		
		if (indexPath.section == activateSectionCount && taskList == timer.activeTaskList)
		{
			//NSString *imgName = @"pause_yellow_green.png";
            NSString *imgName = @"timer_pause.png";
			
			UIButton *pauseButton = [Common createButton:@""
											buttonType:UIButtonTypeCustom
												 frame:CGRectMake(10, 5, 30, 30)
											titleColor:nil
												target:self
											  selector:@selector(pauseTask:)
									  normalStateImage:imgName
									selectedStateImage:nil];
			
			pauseButton.tag = 11000 + indexPath.row;
			[cell.contentView addSubview:pauseButton];
		}
		else
		{
			UIButton *startButton = [Common createButton:@""
											buttonType:UIButtonTypeCustom
												 frame:CGRectMake(10, 5, 30, 30)
											titleColor:nil
												target:self
											  selector:@selector(startTask:)
									  //normalStateImage:@"play_green_yellow.png"
                                   normalStateImage:@"timer_play.png"
									selectedStateImage:nil];
			
			startButton.tag = 11000 + indexPath.row;
			[cell.contentView addSubview:startButton];
		}
		
		UIColor *prjColor = [Common getColorByID:0 colorIndex:0];
		
		if (task.project > -1)
		{
			prjColor = [Common getColorByID:[[ProjectManager getInstance] getProjectColorID:task.project] colorIndex:0];
		}
        
		/*UILabel *projectColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 20, 5, 5)];
		projectColorLabel.tag = 10010;
		projectColorLabel.backgroundColor = prjColor;
		
		[cell.contentView addSubview:projectColorLabel];
		[projectColorLabel release];*/
		
		UILabel *taskNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 130, 40)];
		taskNameLabel.numberOfLines = 2;
		taskNameLabel.tag = 10001;
		taskNameLabel.textAlignment = NSTextAlignmentLeft;
		taskNameLabel.text = task.name;
		taskNameLabel.textColor = prjColor;
		
		taskNameLabel.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview:taskNameLabel];
		[taskNameLabel release];
		
		UILabel *timeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 95, 40)];
		timeValueLabel.tag = 10002;
		timeValueLabel.textAlignment = NSTextAlignmentRight;
		timeValueLabel.text = [Common getTimerDurationString:task.actualDuration];
		timeValueLabel.textColor = [UIColor blackColor];
		timeValueLabel.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview:timeValueLabel];
		[timeValueLabel release];
		
        /*
		if (task.isActivating && [task.name isEqualToString:_newItemText])
		{
			editTaskButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			editTaskButton.frame = CGRectMake(160, 0, 40, 40);
			editTaskButton.tag = task;
			[editTaskButton addTarget:self action:@selector(editTask:) forControlEvents:UIControlEventTouchUpInside];
			
			[cell.contentView addSubview:editTaskButton];
			
			UILabel *editHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, 220, 15)];
			editHintLabel.numberOfLines = 1;
			editHintLabel.tag = 10007;
			editHintLabel.textAlignment = UITextAlignmentLeft;
			editHintLabel.text = _propertiesEditText;
			editHintLabel.textColor = [UIColor whiteColor];
			editHintLabel.font = [UIFont italicSystemFontOfSize:13];
			editHintLabel.backgroundColor = [UIColor clearColor];
			
			[cell.contentView addSubview:editHintLabel];
			[editHintLabel release];
		}
        */
		
		//NSString *imgName = (indexPath.section == activateSectionCount?@"stop_red_green.png":@"stop_red_yellow.png");
        NSString *imgName = @"timer_done.png";
		
		UIButton *stopButton = [Common createButton:@""
									   buttonType:UIButtonTypeCustom
											frame:CGRectMake(280, 5, 30, 30)
									   titleColor:nil
										   target:self
										 selector:@selector(confirmMarkDone:)
								 normalStateImage:imgName
							   selectedStateImage:nil];
		
		stopButton.tag = (indexPath.section == activateSectionCount ?12000:13000) + indexPath.row;
		
		[cell.contentView addSubview:stopButton];
		
	}
	else if (activateSectionCount == 1)
	{
		/*UILabel *projectColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 15, 5, 5)];
		projectColorLabel.tag = 10011;
		projectColorLabel.backgroundColor = [Common getColorByID:[[ProjectManager getInstance] getProjectColorID:timer.taskToActivate.project] colorIndex:0];
		
		[cell.contentView addSubview:projectColorLabel];
		[projectColorLabel release];*/
        
        UIColor *prjColor = [Common getColorByID:[[ProjectManager getInstance] getProjectColorID:[[Settings getInstance] taskDefaultProject]] colorIndex:0];
		
		UILabel *activateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
		activateNameLabel.tag = 10004;
		activateNameLabel.textAlignment = NSTextAlignmentLeft;
		activateNameLabel.text = timer.taskToActivate.name;
		activateNameLabel.textColor = prjColor;
		activateNameLabel.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview:activateNameLabel];
		[activateNameLabel release];
		
		UIButton *startButton = [Common createButton:_startText
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(40, 30, 60, 30)
                                        titleColor:[Colors blueButton]
                                            target:self
                                          selector:@selector(startTaskActivation:)
                               normalStateImage:nil
                                selectedStateImage:nil];
        
        startButton.layer.cornerRadius = 8;
        startButton.layer.borderWidth = 1;
        startButton.layer.borderColor = [[Colors blueButton] CGColor];
        startButton.titleLabel.font = [UIFont systemFontOfSize:16];
		
		startButton.tag = 10005;
		
		[cell.contentView addSubview:startButton];
		
		UIButton *holdButton = [Common createButton:_holdAllAndStartText
                                       buttonType:UIButtonTypeCustom
											frame:CGRectMake(140, 30, 140, 30)
									   titleColor:[Colors blueButton]
										   target:self 
										 selector:@selector(holdAllActiveTasksAndStart:) 
								 normalStateImage:nil
							   selectedStateImage:nil];
        
        holdButton.layer.cornerRadius = 8;
        holdButton.layer.borderWidth = 1;
        holdButton.layer.borderColor = [[Colors blueButton] CGColor];
        holdButton.titleLabel.font = [UIFont systemFontOfSize:16];
		
		holdButton.tag = 10006;
		
		[cell.contentView addSubview:holdButton];
	}
	
	return cell;
}	

@end
