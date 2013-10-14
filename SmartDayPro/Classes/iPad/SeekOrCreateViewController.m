//
//  SeekOrCreateViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "SeekOrCreateViewController.h"

#import "Common.h"
#import "Task.h"

#import "DBManager.h"
#import "ProjectManager.h"

#import "ContentView.h"

#import "iPadSmartDayViewController.h"
#import "iPadViewController.h"

extern iPadSmartDayViewController *_iPadSDViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@interface SeekOrCreateViewController ()

@end

@implementation SeekOrCreateViewController

@synthesize taskList;
@synthesize eventList;
@synthesize noteList;
@synthesize anchorList;

@synthesize title;

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
        self.title = @"";
        
        tapCount = 0;
        tapRow = -1;
        tapSection = -1;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,440);
    }
    
    return self;
}

- (void) dealloc
{
    self.taskList = nil;
    self.eventList = nil;
    self.noteList = nil;
    self.anchorList = nil;
    
    self.title = nil;
    
    [super dealloc];
}

- (void) search:(NSString *)title
{
    self.title = title;
    
    NSMutableArray *result = [[DBManager getInstance] searchTitle:title];
    
    self.eventList = [NSMutableArray arrayWithCapacity:10];
    self.taskList = [NSMutableArray arrayWithCapacity:10];
    self.noteList = [NSMutableArray arrayWithCapacity:10];
    self.anchorList = [NSMutableArray arrayWithCapacity:10];
    
    for (Task *task in result)
    {
        task.listSource = SOURCE_NONE;
        
        if ([task isTask])
        {
            [self.taskList addObject:task];
        }
        else if ([task isEvent] && ![task isManual])
        {
            [self.eventList addObject:task];
        }
        else if ([task isNote])
        {
            [self.noteList addObject:task];
        }
        else if ([task isManual])
        {
            // anchor task
            [self.anchorList addObject:task];
        }
    }
    
    [searchTableView reloadData];
}

- (void) addNew:(id)sender
{
    UISegmentedControl *segmentCtrl = (UISegmentedControl *)sender;
    
    [[AbstractActionViewController getInstance] createItem:segmentCtrl.selectedSegmentIndex title:self.title];
}

- (void) singleTap
{
    tapCount = 0;
    
    if (tapRow >= 0)
    {
    }
}

- (void) doubleTap
{
    tapCount = 0;
    
    if (tapRow >= 0 && tapSection >= 0)
    {
        NSMutableArray *lists[4] = {self.taskList, self.eventList, self.noteList, self.anchorList};
        
        Task *task = [lists[tapSection] objectAtIndex:tapRow];
        
        //[_iPadSDViewCtrler editItem:task inRect:CGRectMake(600, 0, 20, 10)];
        [_iPadViewCtrler deactivateSearchBar];
        [[AbstractActionViewController getInstance] hidePopover];
        [[AbstractActionViewController getInstance] editItem:task inView:nil];
    }
}

- (void)loadView
{
    ContentView *contentView = [[ContentView alloc] initWithFrame:CGRectMake(0, 0, 320, 440)];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1];

    self.view = contentView;
    
    [contentView release];
    
    UILabel *addNewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 100, 20)];
    addNewLabel.backgroundColor = [UIColor clearColor];
    addNewLabel.textAlignment = NSTextAlignmentLeft;
    addNewLabel.font = [UIFont boldSystemFontOfSize:18];
    addNewLabel.text = _createNew;
    
    [contentView addSubview:addNewLabel];
    [addNewLabel release];
    
	UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_taskText, _eventText, _noteText, nil]];
	segmentControl.segmentedControlStyle= UISegmentedControlStyleBar;
	[segmentControl addTarget:self action:@selector(addNew:) forControlEvents:UIControlEventValueChanged];
	segmentControl.frame = CGRectMake(120, 10, 180, 30);
	segmentControl.selectedSegmentIndex = -1;
    
    [contentView addSubview:segmentControl];
    [segmentControl release];
    
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 200, 20)];
    //UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    resultLabel.backgroundColor = [UIColor clearColor];
    resultLabel.textAlignment = NSTextAlignmentLeft;
    resultLabel.font = [UIFont boldSystemFontOfSize:18];
    resultLabel.text = _searchResult;
    
    [contentView addSubview:resultLabel];
    [resultLabel release];
    
	searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, contentView.bounds.size.width, contentView.bounds.size.height-70) style:UITableViewStylePlain];
    //searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, contentView.bounds.size.width, contentView.bounds.size.height-30) style:UITableViewStylePlain];
	searchTableView.delegate = self;
	searchTableView.dataSource = self;
    
	[contentView addSubview:searchTableView];
	[searchTableView release];
    
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
	return 4;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *lists[4] = {self.taskList, self.eventList, self.noteList, self.anchorList};
    
    return lists[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
    NSString *titles[4] = {_tasksText, _eventsText, _notesText, _anchoredText};

    return titles[section];
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
    
    ProjectManager *pm = [ProjectManager getInstance];
    
    NSMutableArray *lists[4] = {self.taskList, self.eventList, self.noteList, self.anchorList};
    
    Task *task = [lists[indexPath.section] objectAtIndex:indexPath.row];
    
    UIImage *img = nil;
    
    if ([task isEvent] && ![task isManual])
    {
        img = [pm getEventIcon:task.project];
    }
    else if ([task isTask])
    {
        img = [pm getTaskIcon:task.project];
    }
    else if ([task isNote])
    {
        img = [pm getNoteIcon:task.project];
    }
    else if ([task isManual])
    {
        // anchor task
        img = [pm getAnchoredIcon:task.project];
    }
	
    cell.imageView.image = img;
    cell.textLabel.text = task.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tapCount++;
    tapRow = indexPath.row;
    tapSection = indexPath.section;
    
    switch (tapCount)
    {
        case 1: //single tap
            [self performSelector:@selector(singleTap) withObject:nil afterDelay: .4];
            break;
        case 2: //double tap
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            
            [self performSelector:@selector(doubleTap) withObject: nil];
        }
            break;
        default:
            break;
    }

}


@end
