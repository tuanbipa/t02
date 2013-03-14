//
//  NoteViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/21/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "NoteViewController.h"

#import "Common.h"
#import "Settings.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "Task.h"

#import "ContentView.h"
#import "ContentTableView.h"
#import "TaskView.h"

#import "NoteDetailTableViewController.h"

#import "SmartDayViewController.h"
#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize noteList;

@synthesize filterType;

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
    self = [super init];
    
    if (self)
    {
        self.filterType = NOTE_FILTER_ALL;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tabBarModeChanged:)
													 name:@"TabBarModeChangeNotification" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    self.noteList = nil;
    
    [super dealloc];
}

/*
- (void) initData
{
    DBManager *dbm = [DBManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    NSDictionary *tagDict = [tm getFilterTagDict];
    NSDictionary *categoryDict = [tm getFilterCategoryDict];   
    
    //self.noteList = [dbm getAllNotes];
    self.noteList = [NSMutableArray arrayWithCapacity:50];
    
    NSArray *list = [dbm getAllNotes];
    
    for (Task *task in list)
    {
        BOOL filterIn = ([tm checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict]);
        
        if (filterIn)
        {
            task.listSource = SOURCE_NOTE;
            
            [self.noteList addObject:task];
        }        
    }
    
    checkFocus = YES;
    
    focusIndex = -1;
    
    selectedIndex = -1;
    tapCount = 0;
    
    [self reconcileLinkCopy];
    
    [listTableView reloadData];
}
*/

- (void) loadAndShowList
{
    [self filter:self.filterType];
}

- (void) filter:(NSInteger)type
{
    self.filterType = type;
    
    DBManager *dbm = [DBManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    NSDictionary *tagDict = [tm getFilterTagDict];
    NSDictionary *categoryDict = [tm getFilterCategoryDict];
    
    self.noteList = [NSMutableArray arrayWithCapacity:50];
    
    NSArray *list = (self.filterType == NOTE_FILTER_TODAY?[dbm getTodayNotes]:[dbm getAllNotes]);
    
    for (Task *task in list)
    {
        BOOL filterIn = ([tm checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict]);
        
        if (filterIn)
        {
            task.listSource = SOURCE_NOTE;
            
            [self.noteList addObject:task];
        }
    }
    
    checkFocus = YES;
    
    focusIndex = -1;
    
    selectedIndex = -1;
    tapCount = 0;
    
    [self reconcileLinkCopy];
    
    [listTableView reloadData];    
}

- (void) reconcileLinkCopy
{
    if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.listSource == SOURCE_NOTE)
    {
        for (Task *task in self.noteList)
        {
            if (_abstractViewCtrler.task2Link.primaryKey == task.primaryKey)
            {
                _abstractViewCtrler.task2Link = task;
                
                break;
            }
        }
    }
}

- (void) changeSkin
{
    //contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    listTableView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];    
    
    listTableView.separatorColor = [UIColor lightGrayColor];
}

- (void) editNote:(Task *)task
{
    NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
    ctrler.note = task;
    
    [_abstractViewCtrler.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) focus
{
    if (checkFocus)
    {
        int y = focusIndex*60;
        
        listTableView.contentOffset = CGPointMake(0, y > 30?y-30:0);
    }
    
    checkFocus = NO;
}

- (void) enableActions:(BOOL)enable
{
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];

	if (enable)
	{
        
		CGRect frm = CGRectMake(0, selectedIndex*60-listTableView.contentOffset.y, listTableView.bounds.size.width, 60);
        
        Task *task = [self getSelectedTask];
        
        NSInteger pk = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);

        //printf("selected note: %s - pk: %d\n", [task.name UTF8String], pk);
                
        contentView.actionType = ACTION_ITEM_EDIT;
        contentView.tag = pk;
        
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:frm inView:contentView];
		[menuCtrler setMenuVisible:YES animated:NO];
		
	}
	else 
	{
		[menuCtrler setMenuVisible:NO animated:YES];
	}	    
}

- (Task *) getSelectedTask
{
    if (selectedIndex != -1)
    {
        return [self.noteList objectAtIndex:selectedIndex];
    }
}

- (void) changeItem:(Task *)task action:(NSInteger)action
{
    if (action == TASK_CREATE)
    {
        [self.noteList addObject:task];
        
        [Common sortList:self.noteList byKey:@"startTime" ascending:YES];
        
        [listTableView reloadData];
    }
    else if (action == TASK_DELETE)
    {
        //[self.noteList removeObject:task];
        //[self initData]; //reload the list to refresh links
        [self loadAndShowList];
    }

}

- (void) refreshView
{
    [listTableView reloadData];
}

-(void)setNeedsDisplay
{
    [listTableView reloadData];
}

- (void) singleTap
{
    ////printf("single tap\n");
    
    BOOL enabled = (selectedIndex != tapRow);
    
    selectedIndex = (enabled?tapRow:-1);
    
    [self enableActions:enabled];
    
    tapCount = 0;
}

- (void) doubleTap
{
    ////printf("double tap\n");
    /*
    Task *task = [self.noteList objectAtIndex:tapRow];
    [self editNote:task];*/
    
    UITableViewCell *cell = [listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tapRow inSection:0]];
                             
    TaskView *noteView = (TaskView *)[cell.contentView viewWithTag:10000];
    
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editItem:noteView.task inView:noteView];
    }
    
    tapCount = 0;
}

#pragma mark Multi Edit
- (void) multiEdit:(BOOL)enabled
{
    Settings *settings = [Settings getInstance];
    
    for (int i=0; i<self.noteList.count; i++)
    {
        UITableViewCell *cell = [listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        TaskView *taskView = (TaskView *) [cell.contentView viewWithTag:10000];
        [taskView multiSelect:enabled];
    }
    
    editBarPlaceHolder.hidden = !enabled;
    
    CGFloat h = (settings.tabBarAutoHide?0:40) + (enabled?40:0);
    
    listTableView.frame = CGRectMake(0, enabled?40:0, contentView.bounds.size.width, contentView.bounds.size.height - h);
}

- (void) cancelMultiEdit:(id) sender
{
    [self multiEdit:NO];
}

- (void) multiDelete:(id)sender
{
	if ([[Settings getInstance] deleteWarning])
	{
		NSString *msg = _itemDeleteText;
		NSInteger tag = -10000;
		
		UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
		
		taskDeleteAlertView.tag = tag;
		
		[taskDeleteAlertView addButtonWithTitle:_okText];
		[taskDeleteAlertView show];
		[taskDeleteAlertView release];
	}
	else
	{
		[self doMultiDeleteTask];
	}
}

- (void) doMultiDeleteTask
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    for (int i=0; i<self.noteList.count; i++)
    {
        UITableViewCell *cell = [listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        TaskView *taskView = (TaskView *) [cell.contentView viewWithTag:10000];
        
        if ([taskView isMultiSelected])
        {
            [taskList addObject:taskView.task];
        }
    }
    
    if (taskList.count > 0)
    {
        [[TaskManager getInstance] deleteTasks:taskList];
        
        for (Task *note in taskList)
        {
            [self.noteList removeObject:note];
        }
    }
    
    [self multiEdit:NO];
    
    [listTableView reloadData];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
        [self doMultiDeleteTask];
	}
}

#pragma mark Views

- (void) changeFrame:(CGRect)frm
{
    Settings *settings = [Settings getInstance];
    
    contentView.frame = frm;
    
    CGRect rec = editBarPlaceHolder.frame;
    
    rec.size.width = frm.size.width;
    
    editBarPlaceHolder.frame = rec;
    
    UIToolbar *editToolbar = (UIToolbar *)[editBarPlaceHolder viewWithTag:10000];
    editToolbar.frame = editBarPlaceHolder.bounds;
    
    listTableView.frame = CGRectMake(0, 0, frm.size.width, frm.size.height - (settings.tabBarAutoHide?0:40));
}

-(void) createEditBar
{
	editBarPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 40)];
	editBarPlaceHolder.backgroundColor = [UIColor clearColor];
	editBarPlaceHolder.hidden = YES;
	
	[contentView addSubview:editBarPlaceHolder];
	[editBarPlaceHolder release];
	
	UIToolbar *editToolbar = [[UIToolbar alloc] initWithFrame:editBarPlaceHolder.bounds];
	editToolbar.barStyle = UIBarStyleBlack;
    editToolbar.tag = 10000;
	
	[editBarPlaceHolder addSubview:editToolbar];
	[editToolbar release];
    
	UIButton *cancelButton = [Common createButton:_cancelText
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 5, 80, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(cancelMultiEdit:)
                                 normalStateImage:@"hide_btn.png"
                               selectedStateImage:nil];
	
	UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
		
	UIButton *deleteButton = [Common createButton:_deleteText
									   buttonType:UIButtonTypeCustom
											frame:CGRectMake(0, 5, 80, 30)
									   titleColor:[UIColor whiteColor]
										   target:self
										 selector:@selector(multiDelete:)
								 normalStateImage:@"delete_btn.png"
							   selectedStateImage:nil];
	
	UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								  target:nil
								  action:nil];
	
	NSArray *items = [NSArray arrayWithObjects:spaceItem, cancelButtonItem, spaceItem, deleteButtonItem, spaceItem, nil];
	
    [cancelButtonItem release];
	[deleteButtonItem release];
	[spaceItem release];
	
	[editToolbar setItems:items animated:NO];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    Settings *settings = [Settings getInstance];
    
    //contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    self.view = contentView;
    
    [contentView release];
    
    //listTableView = [[ContentTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416 - (settings.tabBarAutoHide?0:40)) style:UITableViewStylePlain];
    listTableView = [[ContentTableView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, frm.size.height - (settings.tabBarAutoHide?0:40)) style:UITableViewStylePlain];

    listTableView.backgroundColor = [UIColor clearColor];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    
    [contentView addSubview:listTableView];
    [listTableView release];
    
    [self createEditBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self changeSkin];
    
    //[self initData];
    [self loadAndShowList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.noteList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //cell.backgroundColor = [UIColor clearColor];
    
    Task *task = [self.noteList objectAtIndex:indexPath.row];

    TaskView *taskView = [[TaskView alloc] initWithFrame:CGRectMake(0, 5, tableView.bounds.size.width, 45)];
    taskView.tag = 10000;
    //taskView.tag = task;
    taskView.task = task;
    taskView.listStyle = YES;
    taskView.starEnable = NO;
    taskView.checkEnable = YES;
    taskView.showSeparator = NO;
    
    [cell.contentView addSubview:taskView];
    [taskView release];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (checkFocus)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(focus) object:nil];
    
        [self performSelector:@selector(focus) withObject:nil afterDelay:0.1];
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_abstractViewCtrler deselect];
}

#pragma mark Notification

- (void)tabBarModeChanged:(NSNotification *)notification
{
    CGSize sz = [Common getScreenSize];
    
    Settings *settings = [Settings getInstance];
    
    listTableView.frame = CGRectMake(0, 0, sz.width, sz.height - (settings.tabBarAutoHide?0:40));
}


#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    for (Task *task in self.noteList)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == sourceId)
            {
                task.links = [tlm getLinkIds4Task:sourceId];
            }
            else if (task.primaryKey == destId)
            {
                task.links = [tlm getLinkIds4Task:destId];
            }
        }
    }
}

@end
