//
//  ProjectSelectionTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <EventKit/EventKit.h>

#import "CalendarSelectionTableViewController.h"

#import "Common.h"
#import "Colors.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "TaskManager.h"
#import "ImageManager.h"
#import "Project.h"
#import "Task.h"
#import "Settings.h"
#import "EKSync.h"
#import "FilterData.h"

#import "FilterView.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "CategoryViewController.h"

#import "iPadSmartDayViewController.h"
#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

extern BOOL _isiPad;

@implementation CalendarSelectionTableViewController

@synthesize keyEdit;
@synthesize calList;
@synthesize filterData;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (id)init
{
	if (self = [super init])
	{
		self.calList = [[ProjectManager getInstance] projectList];
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;
}

- (void) initData
{
	selectedCalDict = [[NSMutableDictionary alloc] initWithCapacity:calList.count];
    
    if (self.filterData != nil && ![self.filterData.categories isEqualToString:@""])
    {
        NSArray *catList = [self.filterData.categories componentsSeparatedByString:@","];
        
        NSDictionary *catDict = [NSDictionary dictionaryWithObjects:catList forKeys:catList];
        
        int c = 0;
        for (Project *project in self.calList)
        {
            NSObject *found = [catDict objectForKey:[NSString stringWithFormat:@"%d", project.primaryKey]];
            
            [selectedCalDict setObject:(found==nil?[NSNumber numberWithInt:0]:[NSNumber numberWithInt:1]) forKey:[NSNumber numberWithInt:c++]];
        }             
    }
    else 
    {
        NSInteger defaultPrj = [[Settings getInstance] taskDefaultProject];
        
        int c = 0;
        for (Project *project in self.calList)
        {
            if (project.primaryKey == defaultPrj)
            {
                defaultProjectIndex = c;
            }
            
            [selectedCalDict setObject:(project.status == PROJECT_STATUS_INVISIBLE?[NSNumber numberWithInt:0]:[NSNumber numberWithInt:1]) forKey:[NSNumber numberWithInt:c++]];		
        }	
        
    }	
}

- (void)loadView 
{
	[self initData];
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
    if (_isiPad)
    {
        frm.size.height = 440;
    }
	
	UIView *contentView= [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
	self.view = contentView;
	[contentView release];
    
    calendarTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, frm.size.width, frm.size.height-40) style:UITableViewStyleGrouped];
    
	calendarTableView.delegate = self;
	calendarTableView.dataSource = self;
	calendarTableView.sectionHeaderHeight = 5;
	
	[contentView addSubview:calendarTableView];
	[calendarTableView release];    
    
    frm = _isiPad?CGRectMake(10, 5, 100, 30):CGRectMake(40, 5, 100, 30);
	
	UIButton *showAllButton = [Common createButton:_showAllText 
										buttonType:UIButtonTypeCustom
											 //frame:CGRectMake(40, 5, 100, 30)
                                             frame:frm
										titleColor:[UIColor whiteColor] 
											target:self 
										  selector:@selector(showAllProjects:) 
								  normalStateImage:@"blue_button.png"
								selectedStateImage:nil];
	
	[contentView addSubview:showAllButton];
    
    frm = _isiPad?CGRectMake(130, 5, 100, 30):CGRectMake(180, 5, 100, 30);

	UIButton *hideAllButton = [Common createButton:_hideAllText 
										buttonType:UIButtonTypeCustom
											 //frame:CGRectMake(180, 5, 100, 30)
                                             frame:frm
										titleColor:[UIColor whiteColor]
											target:self 
										  selector:@selector(hideAllProjects:) 
								  normalStateImage:@"blue_button.png"
								selectedStateImage:nil];
	
	[contentView addSubview:hideAllButton];

    if (_isiPad)
    {
        frm = CGRectMake(contentView.bounds.size.width-70, 5, 60, 30);
        UIButton *applyButton = [Common createButton:_applyText
                                            buttonType:UIButtonTypeCustom
                                                 frame:frm
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                              selector:@selector(apply:)
                                      normalStateImage:@"blue_button.png"
                                    selectedStateImage:nil];
        
        [contentView addSubview:applyButton];
    }
	
	doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			   target:self action:@selector(done:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];	

	//self.navigationItem.title = (self.keyEdit == EVENT_MAPPING_EDIT?_iPhoneCalendarsText:_toodledoFoldersText);
	self.navigationItem.title = _showProjectsText;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    /*
    if (self.filterData != nil)
    {
        [_smartDayViewCtrler refreshFilterCategories];
    }
    */
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void) showAllProjects:(id)sender
{
	for (int i=0;i<calList.count;i++)
	{
		[selectedCalDict setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:i]];
	}
	
	[calendarTableView reloadData];
}

- (void) hideAllProjects:(id)sender
{
	for (int i=0;i<calList.count;i++)
	{
        if (i != defaultProjectIndex)
        {
            [selectedCalDict setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:i]];
        }
	}
	
	[calendarTableView reloadData];
}

- (void) done:(id)sender
{
	NSArray *keys = [selectedCalDict allKeys];
    	
	BOOL visibilityChange = NO;
    BOOL becomeVisible = NO;
	
	TaskManager *tm = [TaskManager getInstance];
	
	for (NSNumber *key in keys)
	{
		NSNumber *flag = [selectedCalDict objectForKey:key];
		
		Project *project = [self.calList objectAtIndex:[key intValue]];
		
		NSInteger status = ([flag intValue] == 0?PROJECT_STATUS_INVISIBLE:
                            (project.status == PROJECT_STATUS_INVISIBLE?PROJECT_STATUS_NONE:project.status));
		
		visibilityChange = visibilityChange || project.status != status;
        
        becomeVisible = becomeVisible || (project.status == PROJECT_STATUS_INVISIBLE && status != PROJECT_STATUS_INVISIBLE);
		
        if (project.status != status)
        {
            project.status = status;
		
        //[project enableExternalUpdate]; //don't update time when changing visibility
            [project updateStatusIntoDB:[[DBManager getInstance] getDatabase]];
            
            if (project.primaryKey == tm.lastTaskProjectKey && project.status == PROJECT_STATUS_INVISIBLE)
            {
                tm.lastTaskProjectKey = [[Settings getInstance] taskDefaultProject];
            }
        }
	}
    
	if (visibilityChange)
	{
        //[_abstractViewCtrler resetAllData];
        [_abstractViewCtrler applyFilter];
	}
		
    if (becomeVisible)
    {
        [[Settings getInstance] resetToodledoSync];
        [[Settings getInstance] resetSDWSync];
    }
    
    if (visibilityChange || becomeVisible)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger auto sync        
    }
    
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void) apply:(id)sender
{
    [self done:sender];
    
    [_abstractViewCtrler hidePopover];
    
    [[_abstractViewCtrler getCategoryViewController] loadAndShowList];
    [[_abstractViewCtrler getNoteViewController] loadAndShowList];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return calList.count;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return _plsSelectCalToSyncText;
}
*/

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
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	NSNumber *flag = [selectedCalDict objectForKey:[NSNumber numberWithInt:indexPath.row]];
	
	cell.accessoryType = ([flag intValue] == 1?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
	cell.backgroundColor = ([flag intValue] == 1?[UIColor whiteColor]:[UIColor lightGrayColor]);
	
	Project *prj = [self.calList objectAtIndex:indexPath.row];
    
    BOOL isDefault = [prj checkDefault];
			
	UILabel *prjLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 240 - (isDefault?25:0), 30)];
	prjLabel.backgroundColor = [UIColor clearColor];
	prjLabel.font = [UIFont boldSystemFontOfSize:16];
	prjLabel.text = prj.name;
	prjLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
	prjLabel.tag = 10000;
	
	[cell.contentView addSubview:prjLabel];
	[prjLabel release];
    	
	if (prj.type == TYPE_LIST)
	{
		UIImage *listImage = [[ProjectManager getInstance] getListIcon:prj.primaryKey];
		
		UIImageView *listImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 9, 9)];
		listImageView.image = listImage;
		listImageView.tag = 10001;
		
		[cell.contentView addSubview:listImageView];
		[listImageView release];
		
	}
	else 
	{
		NSInteger taskCount = [[DBManager getInstance] getTaskCountForProject:prj.primaryKey];
		NSInteger eventCount = [[DBManager getInstance] getEventCountForProject:prj.primaryKey];
		
		if (eventCount > 0)
		{
			UIImage *eventImage = [[ProjectManager getInstance] getEventIcon:prj.primaryKey];
			
			UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 16, 8, 8)];
			eventImageView.image = eventImage;
			eventImageView.tag = 10001;	
			
			[cell.contentView addSubview:eventImageView];
			[eventImageView release];			
		}
		
		if (taskCount > 0)
		{
			UIImage *taskImage = [[ProjectManager getInstance] getTaskIcon:prj.primaryKey];
			
			UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 8, 8)];
			taskImageView.image = taskImage;
			taskImageView.tag = 10002;
			
			[cell.contentView addSubview:taskImageView];
			[taskImageView release];			
		}
		
	}
	
    if (isDefault)
    {
		UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:CGRectMake(250, 10, 20, 20)];
		pinImageView.image = [UIImage imageNamed:@"default_cate.png"];
		pinImageView.tag = 10003;
		
		[cell.contentView addSubview:pinImageView];
		[pinImageView release];
        
    }    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.row == defaultProjectIndex)
	{
		return;
	}
	
	NSNumber *flag = [selectedCalDict objectForKey:[NSNumber numberWithInt:indexPath.row]];
	
	int flagVal = [flag intValue];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (flagVal == 1)
	{
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		cell.backgroundColor = [UIColor lightGrayColor];
		
		flagVal = 0;
	}
	else 
	{
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		cell.backgroundColor = [UIColor whiteColor];
		
		flagVal = 1;
	}
	
	[selectedCalDict setObject:[NSNumber numberWithInt:flagVal] forKey:[NSNumber numberWithInt:indexPath.row]];
	
	if (flagVal == 0)
	{
		NSNumber *flag;
		NSEnumerator *enumarator = [selectedCalDict objectEnumerator];
		
		while (flag = [enumarator nextObject])
		//for (NSNumber *flag in [selectedCalDict allObjects])
		{
			if ([flag intValue] == 1)
			{
				flagVal = 1;
				break;
			}
		}		
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	self.calList = nil;
	[selectedCalDict release];
	
    [super dealloc];
}


@end

