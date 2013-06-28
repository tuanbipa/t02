//
//  TaskReadonlyDetailViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 6/27/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TaskReadonlyDetailViewController.h"

#import "Common.h"
#import "Task.h"
#import "Project.h"
#import "Settings.h"

#import "ProjectManager.h"

#import "RepeatTableViewController.h"
#import "TaskNoteViewController.h"

extern BOOL _isiPad;

@implementation TaskReadonlyDetailViewController

@synthesize task;

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
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;
}


- (void) dealloc
{
    self.task = nil;
    
    [super dealloc];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (_isiPad)
    {
        frm.size.width = 320;
        frm.size.height = 416;
    }
    
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
	
    taskTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	taskTableView.delegate = self;
	taskTableView.dataSource = self;
	
	[contentView addSubview:taskTableView];
	[taskTableView release];
	
	self.view = contentView;
	[contentView release];
    
	UISegmentedControl *taskTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:
								[NSArray arrayWithObjects:_taskText, _eventText,nil]];
	
	//[taskTypeSegmentedControl addTarget:self action:@selector(changeTaskType:) forControlEvents:UIControlEventValueChanged];
	taskTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	taskTypeSegmentedControl.selectedSegmentIndex = ([self.task isTask]?0:1);
	taskTypeSegmentedControl.tintColor = [UIColor blueColor];
    taskTypeSegmentedControl.enabled = NO;
	
	frm = taskTypeSegmentedControl.frame;
	frm.size.height = 30;
	taskTypeSegmentedControl.frame = frm;
	
	self.navigationItem.titleView = taskTypeSegmentedControl;
	[taskTypeSegmentedControl release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5)
    {
        return 50;
    }
    
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.textLabel.text = self.task.name;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }
            break;
        case 1:
        {
            if ([self.task isEvent])
            {
                Settings *settings = [Settings getInstance];
                
                cell.textLabel.text = _timeZone;
                cell.detailTextLabel.text = settings.timeZoneSupport? [Settings getTimeZoneDisplayNameByID:self.task.timeZoneId]:_floatingText;
            }
            else
            {
                cell.textLabel.text = _durationText;
                cell.detailTextLabel.text = [Common getDurationString:self.task.duration];                
            }
        }
            break;
        case 2:
        {
            if ([self.task isEvent])
            {
                cell.textLabel.text = _startText;
                cell.detailTextLabel.text = [self.task getDisplayStartTime];
            }
            else
            {
                cell.textLabel.text = _startText;
                cell.detailTextLabel.text = (self.task.startTime == nil? _noneText: [Common getFullDateString3:self.task.startTime]);                
            }
        }
            break;
        case 3:
        {
            if ([self.task isEvent])
            {
                cell.textLabel.text = _endText;
                cell.detailTextLabel.text = [self.task getDisplayEndTime];
            }
            else
            {
                cell.textLabel.text = _dueText;
                cell.detailTextLabel.text = (self.task.deadline == nil? _noneText: [Common getFullDateString3:self.task.deadline]);
            }
            
        }
            break;
        case 4:
        {
            Project *prj = [[ProjectManager getInstance] getProjectByKey:self.task.project];
            
            cell.textLabel.text = _projectText;
            cell.detailTextLabel.text = prj.name;
            cell.detailTextLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
        }
            break;
        case 5:
        {
            cell.accessoryType = [self.task isREException]?UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *repeatLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 25)];
            repeatLabel.text=_repeatText;
            repeatLabel.backgroundColor=[UIColor clearColor];
            repeatLabel.font=[UIFont boldSystemFontOfSize:16];
            repeatLabel.textColor=[UIColor blackColor];
            
            [cell.contentView addSubview:repeatLabel];
            [repeatLabel release];
            
            UILabel *repeatValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 0, 205, 25)];
            repeatValueLabel.textAlignment=NSTextAlignmentRight;
            repeatValueLabel.textColor= [Colors darkSteelBlue];
            repeatValueLabel.font=[UIFont systemFontOfSize:15];
            repeatValueLabel.backgroundColor=[UIColor clearColor];
            
            repeatValueLabel.text = [self.task getRepeatTypeString];
            
            [cell.contentView addSubview:repeatValueLabel];
            [repeatValueLabel release];
            
            UILabel *repeatUntilLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 25, 120, 25)];
            repeatUntilLabel.text=_untilText;
            repeatUntilLabel.backgroundColor=[UIColor clearColor];
            repeatUntilLabel.font=[UIFont boldSystemFontOfSize:16];
            repeatUntilLabel.textColor=[UIColor blackColor];
            
            [cell.contentView addSubview:repeatUntilLabel];
            [repeatUntilLabel release];
            
            UILabel *repeatUntilValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(60, 25, 205, 25)];
            repeatUntilValueLabel.textAlignment=NSTextAlignmentRight;
            repeatUntilValueLabel.textColor= [Colors darkSteelBlue];
            repeatUntilValueLabel.font=[UIFont systemFontOfSize:15];
            repeatUntilValueLabel.backgroundColor=[UIColor clearColor];
            
            repeatUntilValueLabel.text = [self.task getRepeatUntilString];
            
            [cell.contentView addSubview:repeatUntilValueLabel];
            [repeatUntilValueLabel release];
        }
            break;
            
        case 6:
        {
            cell.textLabel.text = _descriptionText;
            cell.detailTextLabel.text = self.task.note;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 5:
        {
            if (![self.task isREException])
            {
                RepeatTableViewController *ctrler = [[RepeatTableViewController alloc] init];
                ctrler.task = self.task;
                
                [self.navigationController pushViewController:ctrler animated:YES];
                [ctrler release];
            }
            
        }
            break;
        case 6:
        {
            TaskNoteViewController *ctrler = [[TaskNoteViewController alloc] init];
            ctrler.task = self.task;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
            break;
    }
}

@end
