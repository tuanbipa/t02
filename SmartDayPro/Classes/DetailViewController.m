//
//  DetailViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>

#import "DetailViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"
#import "AlertData.h"

#import "DBManager.h"
#import "ProjectManager.h"
#import "TagDictionary.h"
#import "TaskLinkManager.h"
#import "TaskManager.h"

#import "ContentView.h"
#import "HPGrowingTextView.h"
#import "NoteView.h"

#import "DurationInputViewController.h"
#import "DateInputViewController.h"
#import "ProjectInputViewController.h"

#import "WWWTableViewController.h"
#import "RepeatTableViewController.h"
#import "TaskNoteViewController.h"
#import "TagEditViewController.h"
#import "TimerHistoryViewController.h"
#import "AlertListViewController.h"
#import "LinkViewController.h"
#import "PreviewViewController.h"

#import "iPadViewController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"

#import "NoteDetailTableViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

extern iPadViewController *_iPadViewCtrler;

DetailViewController *_detailViewCtrler = nil;

@implementation DetailViewController

@synthesize task;
@synthesize taskCopy;
@synthesize previewViewCtrler;

@synthesize inputViewCtrler;

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
        self.inputViewCtrler = nil;
        self.previewViewCtrler = nil;
        
        showAll = NO;
	}
	
	return self;
}

- (void)dealloc
{
	self.task = nil;
	self.taskCopy = nil;
    
    self.inputViewCtrler = nil;
    self.previewViewCtrler = nil;
    
    [titleTextView release];
	
    [super dealloc];
}

-(void)changeSkin
{
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    frm = CGRectInset(contentView.bounds, 5, 5);
    
    detailTableView.frame = frm;
    
    titleTextView.frame = CGRectMake(0, 0, frm.size.width-20-30, 30);
    
    inputView.frame = CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300);
}

- (void) refreshData
{
	if (task.original != nil && ![task isREException]) //Calendar Task or REException
	{
        //printf("task original: %s\n", [[task.original name] UTF8String]);
        
		self.taskCopy = task.original;
    }
	else
	{
		self.taskCopy = task;
	}
    
	if ([self.taskCopy isEvent])
    {
        if ((self.taskCopy.startTime == nil || self.taskCopy.endTime == nil)) // new Event
        {
            self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:[NSDate date]];
            self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
            
        }
        else if ([task isREInstance])
        {
            NSTimeInterval reDuration = [task.original.endTime timeIntervalSinceDate:task.original.startTime];
            
            self.taskCopy.startTime = task.reInstanceStartTime;
            self.taskCopy.endTime = [task.reInstanceStartTime dateByAddingTimeInterval:reDuration];
        }
        else if (self.task.isSplitted)
        {
            Task *longEvent = [[Task alloc] initWithPrimaryKey:self.task.primaryKey database:[[DBManager getInstance] getDatabase]];
            
            self.taskCopy.startTime = longEvent.startTime;
            self.taskCopy.endTime = longEvent.endTime;
            
            [longEvent release];
        }
	}
    
    titleTextView.text = self.taskCopy.name;
    
    self.previewViewCtrler.item = self.taskCopy;    
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frm.size.height = frm.size.width - 20;
    }
    
    frm.size.width = 384;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor clearColor];
	
	self.view = contentView;
	[contentView release];
    
    frm = CGRectInset(contentView.bounds, 5, 5);
    
    detailTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	detailTableView.delegate = self;
	detailTableView.dataSource = self;
    detailTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:detailTableView];
	[detailTableView release];
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300)];
    inputView.hidden = YES;
    
    [contentView addSubview:inputView];
    [inputView release];
    
	titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width-20-30, 30)];
    titleTextView.placeholder = _titleGuideText;
    
	titleTextView.minNumberOfLines = 1;
	titleTextView.maxNumberOfLines = 4;
	titleTextView.returnKeyType = UIReturnKeyDone; //just as an example
	titleTextView.font = [UIFont systemFontOfSize:15.0f];
	titleTextView.delegate = self;
    titleTextView.backgroundColor = [UIColor clearColor];
    
    self.previewViewCtrler = [[[PreviewViewController alloc] init] autorelease];
    
    [self refreshData];
    
    [self changeSkin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:_closeText style:UIBarButtonItemStyleDone target:self action:@selector(close:)];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.navigationItem.leftBarButtonItem = doneItem;
    
    [doneItem release];
    
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(delete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];

    UIButton *copyButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(0, 0, 30, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(copy:)
                               normalStateImage:@"menu_duplicate.png"
                             selectedStateImage:nil];
    
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    
    UIButton *starButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(0, 0, 30, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(star:)
                               normalStateImage:@"menu_star.png"
                             selectedStateImage:nil];
    
    UIBarButtonItem *starItem = [[UIBarButtonItem alloc] initWithCustomView:starButton];
    
    UIButton *deferButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(0, 0, 30, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(defer:)
                               normalStateImage:@"menu_defer.png"
                             selectedStateImage:nil];
    
    UIBarButtonItem *deferItem = [[UIBarButtonItem alloc] initWithCustomView:deferButton];

    UIButton *todayButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, 30, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(doToday:)
                                normalStateImage:@"menu_dotoday.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithCustomView:todayButton];
    
    UIButton *markDoneButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, 30, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                           selector:@selector(markDone:)
                                normalStateImage:@"menu_done.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *markDoneItem = [[UIBarButtonItem alloc] initWithCustomView:markDoneButton];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 20;
    
    self.navigationItem.rightBarButtonItems = [self.taskCopy isEvent]?[NSArray arrayWithObjects:deleteItem, copyItem, nil]:[NSArray arrayWithObjects:deleteItem, fixedItem, copyItem, fixedItem, starItem, fixedItem, deferItem, fixedItem, todayItem, fixedItem, markDoneItem, nil];
    
    [copyItem release];
    [deleteItem release];
    [starItem release];
    [deferItem release];
    [todayItem release];
    [markDoneItem release];
    [fixedItem release];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _detailViewCtrler = self;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _detailViewCtrler = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:tag];
        }
		
		[self tagInputReset];
	}
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
    
	//tagInputTextField.placeholder = self.taskCopy.tag;
    tagInputTextField.placeholder = [self.taskCopy getCombinedTag];
	
	[tagInputTextField resignFirstResponder];
	
	TagDictionary *dict = [TagDictionary getInstance];
	
	int j = 0;
	
	NSDictionary *prjDict = [ProjectManager getProjectDictionaryByName];
	
	for (NSString *tag in [dict.presetTagDict allKeys])
	{
		[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
		[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[tagButtons[j] setEnabled:YES];
		
		Project *prj = [prjDict objectForKey:tag];
		
		if (prj != nil)
		{
			NSDictionary *tagDict = [TagDictionary getTagDict:prj.tag];
			
			if ([tagDict objectForKey:tag] != nil) //Project has the tag with the same name as Project name
			{
				[tagButtons[j] setTitleColor:[Common getColorByID:prj.colorId colorIndex:0]  forState:UIControlStateNormal];
			}
		}
		
		j++;
	}
	
	for (;j<9;j++)
	{
		[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
		
		[tagButtons[j] setEnabled:NO];
	}
}

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = [self.taskCopy getCombinedTag];
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) createLinkedNote:(Task *)note
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
        
    NSInteger itemId = self.taskCopy.primaryKey;
    
    if (self.taskCopy.original != nil && ![self.taskCopy isREException])
    {
        itemId = self.taskCopy.original.primaryKey;
    }
    
    NSInteger linkId = [tlm createLink:itemId destId:note.primaryKey];
    
    if (linkId != -1)
    {
        [self.taskCopy.links insertObject:[NSNumber numberWithInt:linkId] atIndex:0];
    }
    
    [self.previewViewCtrler refreshData];
}

#pragma  mark Actions
- (void) done:(id) sender
{
    [titleTextView resignFirstResponder];
    //[taskLocation resignFirstResponder];
    
    UITableViewCell *cell = [detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UITextField *taskLocation = (UITextField * )[cell.contentView viewWithTag:10000+2];
    
    if (taskLocation != nil)
    {
        [taskLocation resignFirstResponder];
    }
    
    /*if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler updateTask:self.task withTask:self.taskCopy];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler updateTask:self.task withTask:self.taskCopy];
    }*/
    
    [_iPadViewCtrler.activeViewCtrler updateTask:self.task withTask:self.taskCopy];
    
    [_iPadViewCtrler closeDetail];
}

- (void) delete:(id)sender
{
    [_iPadViewCtrler closeDetail];
    [_iPadViewCtrler.activeViewCtrler deleteTask];
}

- (void) copy:(id)sender
{
    self.task = [_iPadViewCtrler.activeViewCtrler copyTask];
    
    [self refreshData];
    
    [detailTableView reloadData];
}

- (void) star:(id)sender
{
    [_iPadViewCtrler closeDetail];
    [_iPadViewCtrler.activeViewCtrler starTask];
}

- (void) defer:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deferText
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:_nextWeekText, _nextMonthText,nil];
    alertView.tag = -10000;
    [alertView show];
    [alertView release];
}

- (void) doToday:(id) sender
{
    [_iPadViewCtrler closeDetail];
    [_iPadViewCtrler.activeViewCtrler moveTask2Top];
}

- (void) markDone:(id)sender
{
    [_iPadViewCtrler closeDetail];
    [_iPadViewCtrler.activeViewCtrler markDoneTask];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -10000)
	{
        [_iPadViewCtrler closeDetail];
        [_iPadViewCtrler.activeViewCtrler defer:buttonIndex];
    }
}

#pragma  mark Edit
- (void)editTitle:(id) sender
{
    [titleTextView resignFirstResponder];
    
	WWWTableViewController *ctrler = [[WWWTableViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

-(void) editDuration
{
    DurationInputViewController *ctrler = [[DurationInputViewController alloc] initWithNibName:@"DurationInputViewController" bundle:nil];
    ctrler.task = self.taskCopy;
    
    [self showInputView:ctrler];
    
    [ctrler release];
}

- (void) editWhen:(id) sender
{
    UIButton *btn = (UIButton *)sender;
    
    DateInputViewController *ctrler = [[DateInputViewController alloc] initWithNibName:@"DateInputViewController" bundle:nil];
    ctrler.task = self.taskCopy;
    ctrler.dateEdit = (btn.tag == 10300+8?TASK_EDIT_START:TASK_EDIT_DEADLINE);
    
    [self showInputView:ctrler];
    
    [ctrler release];
}

- (void)editRepeat
{
    if ([self.taskCopy isREException])
    {
        return;
    }
    
	RepeatTableViewController *ctrler = [[RepeatTableViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editProject
{
	ProjectInputViewController *ctrler = [[ProjectInputViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self showInputView:ctrler];
	[ctrler release];
}

- (void)editDescription
{
	TaskNoteViewController *ctrler = [[TaskNoteViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editTag:(id) sender
{
	TagEditViewController *ctrler = [[TagEditViewController alloc] init];
	
	ctrler.objectEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
	
}

- (void)editAlert
{
	AlertListViewController *ctrler = [[AlertListViewController alloc] init];
	ctrler.taskEdit = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editLink:(id)sender
{
	LinkViewController *ctrler = [[LinkViewController alloc] init];
    //ctrler.task = self.taskCopy;
    
    Task *tmp = (self.task.original != nil && ![self.task isREException])?self.task.original:self.task;
    
    ctrler.task = tmp;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editAsset:(Task *)asset
{
    DetailViewController *ctrler = [[DetailViewController alloc] init];
    ctrler.task = asset;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];    
}

- (void) showTimerHistory
{
	TimerHistoryViewController *ctrler = [[TimerHistoryViewController alloc] init];
    ctrler.task = self.taskCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) showAll
{
    showAll = YES;
    
    [detailTableView reloadData];
}

#pragma mark Refresh
- (void) refreshTitle
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshDuration
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshProject
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshWhen
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self refreshAlert];
}

- (void) refreshUntil
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshAlert
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshDescription
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshTag
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshLink
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:showAll?9:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Input Views
-(void) showInputView:(UIViewController *)ctrler
{
    self.inputViewCtrler = ctrler;
    
    ctrler.view.frame = inputView.bounds;
    
    [inputView addSubview:ctrler.view];
    
    inputView.hidden = NO;
    [contentView bringSubviewToFront:inputView];
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
}

- (void) closeInputView
{
    if (self.inputViewCtrler != nil)
    {
        [self.inputViewCtrler.view removeFromSuperview];
        
        inputView.hidden = YES;
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        self.inputViewCtrler = nil;
    }
}

#pragma mark Actions

- (void) selectContact:(id) sender
{
	ABPeoplePickerNavigationController *contactList = [[ABPeoplePickerNavigationController alloc] init];
	contactList.peoplePickerDelegate = self;
    
    contactList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:contactList animated:YES completion:NULL];
    
	[contactList release];
}

- (void) changeADE:(id)sender
{
	UISegmentedControl *segment = (UISegmentedControl *)sender;
    
	self.taskCopy.type = (segment.selectedSegmentIndex == 0? TYPE_ADE: TYPE_EVENT);
	
    self.taskCopy.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];
    
    if (self.taskCopy.type == TYPE_ADE)
    {
		self.taskCopy.startTime = [Common clearTimeForDate:self.taskCopy.startTime];
        self.taskCopy.endTime = [Common getEndDate:self.taskCopy.endTime];
        self.taskCopy.alerts = [NSMutableArray arrayWithCapacity:0];
        
        self.taskCopy.timeZoneId = 0;
    }
    else
    {
        TaskManager *tm = [TaskManager getInstance];
        
        self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
        self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
    }
    
    [self refreshWhen];
}

#pragma mark Task Cell Creation
- (void) createTitleCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	//task title
    titleTextView.tag = baseTag;
    
    titleTextView.text = self.taskCopy.name;
    [cell.contentView addSubview:titleTextView];
    
    CGFloat y = [titleTextView getHeight];
    
    UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    contactButton.frame = CGRectMake(5, y, 25, 25);
    [contactButton setBackgroundImage:[UIImage imageNamed:@"contact.png"] forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(selectContact:) forControlEvents:UIControlEventTouchUpInside];
    contactButton.tag = baseTag + 1;
    
    [cell.contentView addSubview:contactButton];
    
	//task Location
	UITextField *taskLocation=[[UITextField alloc] initWithFrame:CGRectMake(35, y, detailTableView.bounds.size.width-75, 26)];
	taskLocation.font=[UIFont systemFontOfSize:16];
	taskLocation.textColor=[UIColor brownColor];
	taskLocation.keyboardType=UIKeyboardTypeDefault;
	taskLocation.returnKeyType = UIReturnKeyDone;
	taskLocation.placeholder=_locationGuideText;//@"Location";
	taskLocation.textAlignment=NSTextAlignmentLeft;
	taskLocation.backgroundColor=[UIColor clearColor];
	taskLocation.clearButtonMode=UITextFieldViewModeWhileEditing;
	//taskLocation.enabled=NO;
	taskLocation.delegate=self;
	taskLocation.tag = baseTag + 2;
	taskLocation.text = self.taskCopy.location;
    
	[cell.contentView addSubview:taskLocation];
	[taskLocation release];
	
	UIButton *editTitleButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	editTitleButton.frame = CGRectMake(detailTableView.bounds.size.width-35, y/2, 30, 30);
	[editTitleButton addTarget:self action:@selector(editTitle:) forControlEvents:UIControlEventTouchUpInside];
	
	editTitleButton.tag = baseTag + 3;
	
	[cell.contentView addSubview:editTitleButton];
}

- (void) createDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = _durationText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.detailTextLabel.text = [Common getDurationString:self.taskCopy.duration];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createProjectCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	cell.textLabel.text = _projectText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
	ProjectManager *pm = [ProjectManager getInstance];
	
	Project *prj = [pm getProjectByKey:self.taskCopy.project];
    
    cell.detailTextLabel.text = prj.name;
    cell.detailTextLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createStartDueCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.backgroundColor = [UIColor grayColor];

    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.text = _startText;
    startLabel.textColor = [UIColor grayColor];
    startLabel.font = [UIFont systemFontOfSize:16];
    
    startLabel.tag = baseTag;
    
    [cell.contentView addSubview:startLabel];
    [startLabel release];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.taskCopy.startTime == nil?70:40, 30)];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.text = self.taskCopy.startTime == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.startTime]];
    dayLabel.textColor = [UIColor darkGrayColor];
    dayLabel.font = [UIFont boldSystemFontOfSize:28];
    
    dayLabel.tag = baseTag+1;
    
    [cell.contentView addSubview:dayLabel];
    [dayLabel release];
    
    UILabel *wkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 100, 20)];
    wkdayLabel.backgroundColor = [UIColor clearColor];
    wkdayLabel.text = self.taskCopy.startTime == nil?@"":[Common getFullWeekdayString:self.taskCopy.startTime];
    wkdayLabel.textColor = [UIColor darkGrayColor];
    wkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    wkdayLabel.tag = baseTag+2;
    
    [cell.contentView addSubview:wkdayLabel];
    [wkdayLabel release];
    
    UILabel *monYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 55, 100, 20)];
    monYearLabel.backgroundColor = [UIColor clearColor];
    monYearLabel.text = self.taskCopy.startTime == nil?@"":[Common getMonthYearString:self.taskCopy.startTime];
    monYearLabel.textColor = [UIColor darkGrayColor];
    monYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    monYearLabel.tag = baseTag+3;
    
    [cell.contentView addSubview:monYearLabel];
    [monYearLabel release];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(190, 5, 1, 70)];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:separatorView];
    [separatorView release];
    
    UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 10, 100, 20)];
    dueLabel.backgroundColor = [UIColor clearColor];
    dueLabel.text = _dueText;
    dueLabel.textColor = [UIColor grayColor];
    dueLabel.font = [UIFont systemFontOfSize:16];
    
    dueLabel.tag = baseTag+4;
    
    [cell.contentView addSubview:dueLabel];
    [dueLabel release];
    
    UILabel *dueDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 40, self.taskCopy.deadline == nil?70:40, 30)];
    dueDayLabel.backgroundColor = [UIColor clearColor];
    dueDayLabel.textAlignment = NSTextAlignmentRight;
    dueDayLabel.text = self.taskCopy.deadline == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.deadline]];
    dueDayLabel.textColor = [UIColor darkGrayColor];
    dueDayLabel.font = [UIFont boldSystemFontOfSize:28];
    
    dueDayLabel.tag = baseTag+5;
    
    [cell.contentView addSubview:dueDayLabel];
    [dueDayLabel release];
    
    UILabel *dueWkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 35, 100, 20)];
    dueWkdayLabel.backgroundColor = [UIColor clearColor];
    dueWkdayLabel.text = self.taskCopy.deadline == nil?@"":[Common getFullWeekdayString:self.taskCopy.deadline];
    dueWkdayLabel.textColor = [UIColor darkGrayColor];
    dueWkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueWkdayLabel.tag = baseTag+6;
    
    [cell.contentView addSubview:dueWkdayLabel];
    [dueWkdayLabel release];
    
    UILabel *dueMonYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 55, 100, 20)];
    dueMonYearLabel.backgroundColor = [UIColor clearColor];
    dueMonYearLabel.text = self.taskCopy.deadline == nil?@"":[Common getMonthYearString:self.taskCopy.deadline];
    dueMonYearLabel.textColor = [UIColor darkGrayColor];
    dueMonYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueMonYearLabel.tag = baseTag+7;
    
    [cell.contentView addSubview:dueMonYearLabel];
    [dueMonYearLabel release];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    startButton.frame = CGRectMake(0, 0, 190, 80);
    startButton.backgroundColor = [UIColor clearColor];
    startButton.tag = baseTag + 8;
    [startButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:startButton];
    
    UIButton *dueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    dueButton.frame = CGRectMake(190, 0, 190, 80);
    dueButton.backgroundColor = [UIColor clearColor];
    dueButton.tag = baseTag + 9;
    [dueButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:dueButton];
}

- (void) createStartEndCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.backgroundColor = [UIColor grayColor];

    UILabel *adeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    adeLabel.backgroundColor = [UIColor clearColor];
    adeLabel.text = _allDayText;
    adeLabel.textColor = [UIColor grayColor];
    adeLabel.font = [UIFont systemFontOfSize:16];
    
    [cell.contentView addSubview:adeLabel];
    [adeLabel release];
    
    NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
    UISegmentedControl *adeSegmentedCtrl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    adeSegmentedCtrl.frame = CGRectMake(detailTableView.bounds.size.width-110, 5, 100, 30);
    [adeSegmentedCtrl addTarget:self action:@selector(changeADE:) forControlEvents:UIControlEventValueChanged];
    adeSegmentedCtrl.selectedSegmentIndex = ([self.taskCopy isADE]?0:1);
    
    [cell.contentView addSubview:adeSegmentedCtrl];
    [adeSegmentedCtrl release];
    
    UIView *adeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, detailTableView.bounds.size.width, 1)];
    adeSeparatorView.backgroundColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:adeSeparatorView];
    [adeSeparatorView release];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 100, 20)];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.text = _startText;
    startLabel.textColor = [UIColor grayColor];
    startLabel.font = [UIFont systemFontOfSize:16];
    
    startLabel.tag = baseTag;
    
    [cell.contentView addSubview:startLabel];
    [startLabel release];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, self.taskCopy.startTime == nil?70:40, 30)];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.text = self.taskCopy.startTime == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.startTime]];
    dayLabel.textColor = [UIColor darkGrayColor];
    dayLabel.font = [UIFont boldSystemFontOfSize:28];
    
    dayLabel.tag = baseTag+1;
    
    [cell.contentView addSubview:dayLabel];
    [dayLabel release];
    
    UILabel *wkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 75, 100, 20)];
    wkdayLabel.backgroundColor = [UIColor clearColor];
    wkdayLabel.text = self.taskCopy.startTime == nil?@"":[Common getFullWeekdayString:self.taskCopy.startTime];
    wkdayLabel.textColor = [UIColor darkGrayColor];
    wkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    wkdayLabel.tag = baseTag+2;
    
    [cell.contentView addSubview:wkdayLabel];
    [wkdayLabel release];
    
    UILabel *monYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 95, 200, 20)];
    monYearLabel.backgroundColor = [UIColor clearColor];
    monYearLabel.text = self.taskCopy.startTime == nil?@"":([self.taskCopy isADE]?[Common getMonthYearString:self.taskCopy.startTime]:[NSString stringWithFormat:@"%@, %@",[Common getMonthYearString:self.taskCopy.startTime], [Common getTimeString:self.taskCopy.startTime]]);
    monYearLabel.textColor = [UIColor darkGrayColor];
    monYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    monYearLabel.tag = baseTag+3;
    
    [cell.contentView addSubview:monYearLabel];
    [monYearLabel release];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(190, 45, 1, 70)];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:separatorView];
    [separatorView release];
    
    UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 50, 100, 20)];
    dueLabel.backgroundColor = [UIColor clearColor];
    dueLabel.text = _endText;
    dueLabel.textColor = [UIColor grayColor];
    dueLabel.font = [UIFont systemFontOfSize:16];
    
    dueLabel.tag = baseTag+4;
    
    [cell.contentView addSubview:dueLabel];
    [dueLabel release];
    
    UILabel *dueDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 80, self.taskCopy.endTime == nil?70:40, 30)];
    dueDayLabel.backgroundColor = [UIColor clearColor];
    dueDayLabel.textAlignment = NSTextAlignmentRight;
    dueDayLabel.text = self.taskCopy.endTime == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.endTime]];
    dueDayLabel.textColor = [UIColor darkGrayColor];
    dueDayLabel.font = [UIFont boldSystemFontOfSize:28];
    
    dueDayLabel.tag = baseTag+5;
    
    [cell.contentView addSubview:dueDayLabel];
    [dueDayLabel release];
    
    UILabel *dueWkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 75, 100, 20)];
    dueWkdayLabel.backgroundColor = [UIColor clearColor];
    dueWkdayLabel.text = self.taskCopy.endTime == nil?@"":[Common getFullWeekdayString:self.taskCopy.endTime];
    dueWkdayLabel.textColor = [UIColor darkGrayColor];
    dueWkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueWkdayLabel.tag = baseTag+6;
    
    [cell.contentView addSubview:dueWkdayLabel];
    [dueWkdayLabel release];
    
    UILabel *dueMonYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 95, 200, 20)];
    dueMonYearLabel.backgroundColor = [UIColor clearColor];
    dueMonYearLabel.text = self.taskCopy.endTime == nil?@"":([self.taskCopy isADE]?[Common getMonthYearString:self.taskCopy.endTime]:[NSString stringWithFormat:@"%@, %@",[Common getMonthYearString:self.taskCopy.endTime], [Common getTimeString:self.taskCopy.endTime]]);
    dueMonYearLabel.textColor = [UIColor darkGrayColor];
    dueMonYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueMonYearLabel.tag = baseTag+7;
    
    [cell.contentView addSubview:dueMonYearLabel];
    [dueMonYearLabel release];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    startButton.frame = CGRectMake(0, 40, 190, 80);
    startButton.backgroundColor = [UIColor clearColor];
    startButton.tag = baseTag + 8;
    [startButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:startButton];
    
    UIButton *dueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    dueButton.frame = CGRectMake(190, 40, 190, 80);
    dueButton.backgroundColor = [UIColor clearColor];
    dueButton.tag = baseTag + 9;
    [dueButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:dueButton];
}

- (void) createRepeatUntilCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _repeatUntilText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
    cell.detailTextLabel.text = [self.taskCopy getRepeatDisplayString];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createAlertCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    AlertData *alert = ([self.taskCopy isTask] && self.taskCopy.deadline == nil? nil: (self.taskCopy.alerts.count > 0?[self.taskCopy.alerts objectAtIndex:0]:nil));
    
	cell.textLabel.text = _alertText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
    cell.detailTextLabel.text = alert == nil?_noneText:[alert getAbsoluteTimeString:self.taskCopy];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createDescriptionCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _descriptionText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
    cell.detailTextLabel.text = self.taskCopy.note == nil?@"":self.taskCopy.note;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createTagCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	UILabel *tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	tagLabel.tag = baseTag;
	tagLabel.text=_tagText;
	tagLabel.backgroundColor=[UIColor clearColor];
	tagLabel.font=[UIFont systemFontOfSize:16];
	tagLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:tagLabel];
	[tagLabel release];
    
    /*
    UIImageView *detailImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_disclosure.png"]];
    detailImgView.frame = CGRectMake(detailTableView.bounds.size.width - 25, 5, 20, 20);
    [cell.contentView addSubview:detailImgView];
    [detailImgView release];
    */
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, detailTableView.bounds.size.width - 60, 25)];
	tagInputTextField.tag = baseTag + 1;
	tagInputTextField.textAlignment=NSTextAlignmentLeft;
	tagInputTextField.backgroundColor=[UIColor clearColor];
	tagInputTextField.textColor = [Colors darkSteelBlue];
	tagInputTextField.font=[UIFont systemFontOfSize:15];

	tagInputTextField.placeholder=_tagGuideText;
	tagInputTextField.keyboardType=UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
	tagInputTextField.delegate = self;
	
	[cell.contentView addSubview:tagInputTextField];
	[tagInputTextField release];
    
    
	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(detailTableView.bounds.size.width - 30, 0, 25, 25);
	tagDetailButton.tag = baseTag + 2;
	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:tagDetailButton];
    
    /*
    UIButton *tagEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frm = detailTableView.bounds;
    frm.size.height = 30;
    
    tagEditButton.frame = frm;
    tagEditButton.tag = baseTag + 2;
    [tagEditButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:tagEditButton];
    */
    
    CGFloat w = (detailTableView.bounds.size.width - 50)/3;
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@""
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(mod*(w + 10) + 10, div*30 + 30, w, 25)
										titleColor:[UIColor blackColor]
											target:self
										  selector:@selector(selectTag:)
								  normalStateImage:@"sort_button.png"
								selectedStateImage:nil];
		tagButton.tag = baseTag + 3 +i;
		
		[cell.contentView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
    
	[self tagInputReset];
}

- (void) createTimerHistoryCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _timerHistoryText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
}

- (void) createLinkCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	linkLabel.tag = baseTag;
	linkLabel.text = _assetsText;
	linkLabel.backgroundColor = [UIColor clearColor];
	linkLabel.font = [UIFont systemFontOfSize:16];
	linkLabel.textColor = [UIColor grayColor];
	
	[cell.contentView addSubview:linkLabel];
	[linkLabel release];
    
    /*
	UIButton *linkDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	linkDetailButton.frame = CGRectMake(detailTableView.bounds.size.width - 30, 0, 25, 25);
	linkDetailButton.tag = baseTag + 1;
	[linkDetailButton addTarget:self action:@selector(editLink:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:linkDetailButton];*/
    
    UIImageView *detailImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_disclosure.png"]];
    detailImgView.tag = baseTag + 1;
    detailImgView.frame = CGRectMake(detailTableView.bounds.size.width - 25, 5, 20, 20);
    [cell.contentView addSubview:detailImgView];
    [detailImgView release];
    
    UIButton *linkEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frm = detailTableView.bounds;
    frm.size.height = 30;
    
    linkEditButton.frame = frm;
    linkEditButton.tag = baseTag + 2;
    [linkEditButton addTarget:self action:@selector(editLink:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:linkEditButton];
    
/*
    CGFloat h = [self tableView:detailTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:9 inSection:0]];
    
    frm = detailTableView.bounds;

    frm.size.height = h/2;
    frm.origin.y = 40;
    
    noteView = [[NoteView alloc] initWithFrame:frm];
    noteView.editEnabled = YES;
    noteView.touchEnabled = YES;
    noteView.tag = baseTag + 3;
    
    [cell.contentView addSubview:noteView];
    [noteView release];*/
    
    CGFloat h = [self tableView:detailTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:showAll?9:5 inSection:0]];
    
    frm = self.previewViewCtrler.view.frame;
    
    frm.origin.y = 40;
    frm.size.width = detailTableView.bounds.size.width;
    frm.size.height = h - 40;
    
    [cell.contentView addSubview:self.previewViewCtrler.view];
    
    [self.previewViewCtrler changeFrame:frm];
}

- (void) createDeleteCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor redColor];
    
    CGRect frm = CGRectZero;
    frm.size.width = detailTableView.bounds.size.width;
    
    frm.size.height = 40;
    
	UILabel *deleteLabel = [[UILabel alloc] initWithFrame:frm];
	deleteLabel.tag = baseTag;
	deleteLabel.text = _deleteText;
	deleteLabel.backgroundColor = [UIColor clearColor];
	deleteLabel.font = [UIFont boldSystemFontOfSize:16];
	deleteLabel.textColor = [UIColor whiteColor];
    deleteLabel.textAlignment = NSTextAlignmentCenter;
	
	[cell.contentView addSubview:deleteLabel];
	[deleteLabel release];
}

- (void) createShowMoreCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag

{
    cell.accessoryType = UITableViewCellAccessoryNone;
    //cell.contentView.backgroundColor = [UIColor blueColor];
    
    CGRect frm = CGRectZero;
    frm.size.width = detailTableView.bounds.size.width;
    
    frm.size.height = 40;
    
	UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:frm];
	showMoreLabel.tag = baseTag;
	showMoreLabel.text = _showMoreText;
	showMoreLabel.backgroundColor = [UIColor clearColor];
	showMoreLabel.font = [UIFont italicSystemFontOfSize:16];
	showMoreLabel.textColor = [Colors darkSlateGray];
    showMoreLabel.textAlignment = NSTextAlignmentCenter;
	
	[cell.contentView addSubview:showMoreLabel];
	[showMoreLabel release];

}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return showAll?10:6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        CGFloat h = [titleTextView getHeight];
        
        return h + 30;
    }
    else if (indexPath.row == 3) //start/due
    {
        return [self.taskCopy isEvent]?120:80;
    }
    else if (indexPath.row == 7) //tag
    {
        return 120;
    }
    else if ((showAll && indexPath.row == 9) || (!showAll && indexPath.row == 5))
    {
        CGFloat rowH = 0;
        
        for (int i=0;i<(showAll?9:5);i++)
        {
            rowH += [self tableView:detailTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        CGFloat h = detailTableView.bounds.size.height - rowH;
        
        return h>400?h:400;
    }
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3 && tableView == detailTableView)
    {
        cell.backgroundColor = [UIColor colorWithRed:223.0/255 green:223.0/255 blue:223.0/255 alpha:1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];

    switch (indexPath.row)
    {
        case 0:
            [self createTitleCell:cell baseTag:10000];
            break;
        case 1:
            [self createDurationCell:cell baseTag:10100];
            break;
        case 2:
            [self createProjectCell:cell baseTag:10200];
            break;
        case 3:
            if ([self.taskCopy isTask])
            {
                [self createStartDueCell:cell baseTag:10300];
            }
            else
            {
                [self createStartEndCell:cell baseTag:10300];
            }
            break;
        case 4:
            if (showAll)
            {
                [self createRepeatUntilCell:cell baseTag:10400];
            }
            else
            {
                [self createShowMoreCell:cell baseTag:10400];
            }
            break;
        case 5:
            if (showAll)
            {
                [self createAlertCell:cell baseTag:10500];
            }
            else
            {
                [self createLinkCell:cell baseTag:10900];
            }
            break;
        case 6:
            [self createDescriptionCell:cell baseTag:10600];
            break;
        case 7:
            [self createTagCell:cell baseTag:10700];
            break;
        case 8:
            [self createTimerHistoryCell:cell baseTag:10800];
            break;
        case 9:
            [self createLinkCell:cell baseTag:10900];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
            [self editDuration];
            break;
        case 2:
            [self editProject];
            break;
        case 4:
            if (showAll)
            {
                [self editRepeat];
            }
            else
            {
                [self showAll];
            }
            break;
        case 5:
            [self editAlert];
            break;
        case 6:
            [self editDescription];
            break;
        case 8:
            [self showTimerHistory];
            break;
    }
}

#pragma mark GrowingTextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    //printf("reload \n");
    self.taskCopy.name = growingTextView.text;
    
    BOOL isFirstResponder = [titleTextView isFirstResponder];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (isFirstResponder)
    {
        [titleTextView becomeFirstResponder];
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return NO;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    NSString *text = [titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.taskCopy.name = text;
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	//[peoplePicker dismissModalViewControllerAnimated:YES];
    [peoplePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
	CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
	
	if (firstName==nil && lastName==nil && company==nil){
		firstName=(CFStringRef)_nonameText;
		lastName=(CFStringRef)@" ";
		company=(CFStringRef)@" ";
	}else{
		if(firstName==nil) {
			firstName=(CFStringRef) @" ";
		}
		if(lastName==nil){
			lastName=(CFStringRef)@" ";
		}
		if(company==nil){
			company=(CFStringRef)@" ";
		}
		
	}
	
	NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	NSString *contactComName=[NSString stringWithFormat:@"%@",company];
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
		contactName=contactComName;
	}
	
	self.taskCopy.contactName=contactName;
	
	//get PHONE NUMBER from contact
	NSString *phoneNumber=@"";
	ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if(ABMultiValueGetCount(phoneEmailValue)>0){
		phoneNumber=@"";
		
		for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
			CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
			CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
			
			if(label==nil){
				label=(CFStringRef)@" ";
			}
			
			if(phoneNo==nil){
				phoneNo=(CFStringRef)@" ";
			}
			phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
		}
		
	}
	CFRelease(phoneEmailValue);
	self.taskCopy.contactPhone=phoneNumber;
	
	NSString *contactAddress=nil;
	//get first address for this contact
	ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
	
	if(ABMultiValueGetCount(multiValue)>0){
		
		//get all address from the contact
		CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
		CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
		CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
		CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
		CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
		CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
		
		CFRelease(dict);
		
		if(street!=nil){
			contactAddress=[NSString stringWithFormat:@"%@",street];
		}else {
			contactAddress=@"";
		}
		
		if(city!=nil){
			if(street!=nil){
				NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
			}else{
				NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
			}
		}
		
		if(country!=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(state !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(zip !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
	}else {
		contactAddress=@"";
	}
	
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	CFRelease(multiValue);
	
	self.taskCopy.location=contactAddress;
	
	//get email address from contact
	NSString *emailAddress=@"";
	ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(multiEmailValue)>0){
		CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
		
		if(emailAddr==nil){
			emailAddr=(CFStringRef)@" ";
		}
		emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
	}
	CFRelease(multiEmailValue);
	self.taskCopy.contactEmail=emailAddress;
	
    self.taskCopy.name = [NSString stringWithFormat:@"%@ %@", _meetText, self.taskCopy.contactName];
    
    titleTextView.text = self.taskCopy.name;
	
	// remove the controller
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}


#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 10000) //edit title
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
		self.taskCopy.name = text;
	}
	else if (textField.tag == 10000 + 2) //edit location
    {
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        self.taskCopy.location = text;
    }
    else if (textField.tag == 10700 + 1) //edit tag
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
            if (![self checkExistingTag:text])
            {
                self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:text];
            }
		}
		
		[self tagInputReset];
	}
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 10000) //edit title
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [detailTableView cellForRowAtIndexPath:indexPath];
		
		UIButton *editTitleButton = (UIButton *) [cell.contentView viewWithTag:10002];
		editTitleButton.enabled = NO;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 10700 + 1) // edit tag
	{
		NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
		
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSArray *tags = [dict findTags:s];
		
		int j = 0;
		
		for (NSString *tag in tags)
		{
			[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:YES];
			j++;
			
			if (j == 8)
			{
				break;
			}
		}
		
		for (;j<9;j++)
		{
			[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:NO];
		}		
	}
	
	return YES;
}

@end
