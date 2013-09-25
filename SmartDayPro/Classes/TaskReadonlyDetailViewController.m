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
#import "DBManager.h"

#import "RepeatTableViewController.h"
#import "TaskNoteViewController.h"

#import "CommentViewController.h"

#import "iPadViewController.h"

//extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;

@implementation TaskReadonlyDetailViewController

@synthesize task;
@synthesize taskCopy;

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
    self.taskCopy = nil;
    
    [super dealloc];
}

- (void) done:(id) sender
{
    [[AbstractActionViewController getInstance] deselect];
    [_iPadViewCtrler closeDetail];
}

- (void) markDone:(id)sender
{
    [_iPadViewCtrler closeDetail];
    [[AbstractActionViewController getInstance] markDoneTask];
}

- (void) share2AirDrop:(id) sender
{
    [_iPadViewCtrler closeDetail];
    [[AbstractActionViewController getInstance] share2AirDrop];
}

- (void) setTask:(Task *)taskParam
{
    task = [taskParam retain];
    
	if (taskParam.original != nil && ![taskParam isREException]) //Calendar Task or REException
	{
        //printf("task original: %s\n", [[task.original name] UTF8String]);
        
		self.taskCopy = taskParam.original;
    }
	else
	{
		self.taskCopy = taskParam;
	}
}

-(void)changeSkin
{
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    //frm = CGRectInset(contentView.bounds, 5, 5);
    
    frm = contentView.bounds;
    frm.size.width -= 10;
    
    taskTableView.frame = frm;
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 2*44;
    
    frm.size.width = 384;
    
    [self changeFrame:frm];
}

- (void) refreshToolbar
{
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.navigationItem.leftBarButtonItem = doneItem;
    
    [doneItem release];
    
    if (self.task == nil)
    {
        self.navigationItem.rightBarButtonItems = nil;
        return;
    }
    
    UIButton *markDoneButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(markDone:)
                                   normalStateImage:@"menu_done.png"
                                 selectedStateImage:nil];
    
    UIBarButtonItem *markDoneItem = [[UIBarButtonItem alloc] initWithCustomView:markDoneButton];
    
    UIButton *airDropButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 30, 30)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(share2AirDrop:)
                                  normalStateImage:@"menu_airdrop.png"
                                selectedStateImage:nil];
    
    UIBarButtonItem *airDropItem = [[UIBarButtonItem alloc] initWithCustomView:airDropButton];
    
    NSMutableArray *items = [self.task isTask]?[NSMutableArray arrayWithObjects:markDoneItem, nil]:[NSMutableArray arrayWithCapacity:0];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [items addObject:airDropItem];
    }
    
    self.navigationItem.rightBarButtonItems = items;
    
    [markDoneItem release];
    [airDropItem  release];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frm.size.height = frm.size.width - 20;
    }
    
    frm.size.width = 384;
    
	contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
    
	self.view = contentView;
	[contentView release];
    
    frm = CGRectInset(contentView.bounds, 5, 5);
	
    taskTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	taskTableView.delegate = self;
	taskTableView.dataSource = self;
    taskTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:taskTableView];
	[taskTableView release];
    
    /*
	UISegmentedControl *taskTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:
								[NSArray arrayWithObjects:_taskText, _eventText,nil]];
	
	//[taskTypeSegmentedControl addTarget:self action:@selector(changeTaskType:) forControlEvents:UIControlEventValueChanged];
	taskTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBordered;
	taskTypeSegmentedControl.selectedSegmentIndex = ([self.taskCopy isTask]?0:1);
	taskTypeSegmentedControl.tintColor = [UIColor blueColor];
    taskTypeSegmentedControl.enabled = NO;
	
	frm = taskTypeSegmentedControl.frame;
	frm.size.height = 30;
	taskTypeSegmentedControl.frame = frm;
	
	self.navigationItem.titleView = taskTypeSegmentedControl;
	[taskTypeSegmentedControl release];
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self changeSkin];
    
    [self changeOrientation:_iPadViewCtrler.interfaceOrientation];
    
    [self refreshToolbar];
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
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5)
    {
        return 50;
    }
    
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
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
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	cell.textLabel.text = @"";

    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    
    switch (indexPath.row)
    {
        case 0:
        {
            cell.textLabel.text = self.taskCopy.name;
            //cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor blackColor];
        }
            break;
        case 1:
        {
            if ([self.taskCopy isEvent])
            {
                Settings *settings = [Settings getInstance];
                
                cell.textLabel.text = _timeZone;
                cell.detailTextLabel.text = settings.timeZoneSupport? [Settings getTimeZoneDisplayNameByID:self.taskCopy.timeZoneId]:_floatingText;
            }
            else
            {
                cell.textLabel.text = _durationText;
                cell.detailTextLabel.text = [Common getDurationString:self.taskCopy.duration];
            }
        }
            break;
        case 2:
        {
            if ([self.taskCopy isEvent])
            {
                cell.textLabel.text = _startText;
                cell.detailTextLabel.text = [self.taskCopy getDisplayStartTime];
            }
            else
            {
                cell.textLabel.text = _startText;
                cell.detailTextLabel.text = (self.taskCopy.startTime == nil? _noneText: [Common getFullDateString3:self.taskCopy.startTime]);
            }
        }
            break;
        case 3:
        {
            if ([self.taskCopy isEvent])
            {
                cell.textLabel.text = _endText;
                cell.detailTextLabel.text = [self.taskCopy getDisplayEndTime];
            }
            else
            {
                cell.textLabel.text = _dueText;
                cell.detailTextLabel.text = (self.taskCopy.deadline == nil? _noneText: [Common getFullDateString3:self.taskCopy.deadline]);
            }
            
        }
            break;
        case 4:
        {
            Project *prj = [[ProjectManager getInstance] getProjectByKey:self.taskCopy.project];
            
            cell.textLabel.text = _projectText;
            cell.detailTextLabel.text = prj.name;
            cell.detailTextLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
        }
            break;
        case 5:
        {
            cell.accessoryType = [self.taskCopy isREException]?UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *repeatLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 0, 80, 25)];
            repeatLabel.text=_repeatText;
            repeatLabel.backgroundColor=[UIColor clearColor];
            repeatLabel.font=[UIFont systemFontOfSize:16];
            repeatLabel.textColor=[UIColor grayColor];
            
            [cell.contentView addSubview:repeatLabel];
            [repeatLabel release];
            
            UILabel *repeatValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(taskTableView.bounds.size.width - 30 - 200, 0, 200, 25)];
            repeatValueLabel.textAlignment=NSTextAlignmentRight;
            repeatValueLabel.textColor= [UIColor darkGrayColor];
            repeatValueLabel.font=[UIFont boldSystemFontOfSize:16];
            repeatValueLabel.backgroundColor=[UIColor clearColor];
            
            repeatValueLabel.text = [self.taskCopy getRepeatTypeString];
            
            [cell.contentView addSubview:repeatValueLabel];
            [repeatValueLabel release];
            
            UILabel *repeatUntilLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 25, 120, 25)];
            repeatUntilLabel.text=_untilText;
            repeatUntilLabel.backgroundColor=[UIColor clearColor];
            repeatUntilLabel.font=[UIFont systemFontOfSize:16];
            repeatUntilLabel.textColor=[UIColor grayColor];
            
            [cell.contentView addSubview:repeatUntilLabel];
            [repeatUntilLabel release];
            
            UILabel *repeatUntilValueLabel=[[UILabel alloc] initWithFrame:CGRectMake(taskTableView.bounds.size.width - 30 - 200, 25, 200, 25)];
            repeatUntilValueLabel.textAlignment=NSTextAlignmentRight;
            repeatUntilValueLabel.textColor= [UIColor darkGrayColor];
            repeatUntilValueLabel.font=[UIFont boldSystemFontOfSize:16];
            repeatUntilValueLabel.backgroundColor=[UIColor clearColor];
            
            repeatUntilValueLabel.text = [self.taskCopy getRepeatUntilString];
            
            [cell.contentView addSubview:repeatUntilValueLabel];
            [repeatUntilValueLabel release];
        }
            break;
            
        case 6:
        {
            cell.textLabel.text = _descriptionText;
            cell.detailTextLabel.text = self.taskCopy.note;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 7:
        {
            DBManager *dbm = [DBManager getInstance];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = _conversationsText;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dbm countCommentsForItem:self.task.primaryKey]];
            
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 5:
        {
            if (![self.taskCopy isREException])
            {
                RepeatTableViewController *ctrler = [[RepeatTableViewController alloc] init];
                ctrler.task = self.taskCopy;
                
                [self.navigationController pushViewController:ctrler animated:YES];
                [ctrler release];
            }
            
        }
            break;
        case 6:
        {
            TaskNoteViewController *ctrler = [[TaskNoteViewController alloc] init];
            ctrler.task = self.taskCopy;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
            break;
        case 7:
        {
            CommentViewController *ctrler = [[CommentViewController alloc] init];
            ctrler.itemId = self.task.primaryKey;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
            break;
    }
}

@end
