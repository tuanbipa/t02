//
//  LinkSearchViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 4/17/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "LinkSearchViewController.h"

#import "Common.h"
#import "DBManager.h"
#import "Task.h"

#import "LinkViewController.h"

//extern BOOL _isiPad;

@implementation LinkSearchViewController

@synthesize taskList;
@synthesize eventList;
@synthesize noteList;
@synthesize anchorList;

//@synthesize excludeId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        selectedSection = -1;
        selectedRow = -1;
        
        //self.excludeId = -1;
        excludeDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        
        self.preferredContentSize = CGSizeMake(320,416);
    }
    
    return self;
}

- (void) dealloc
{
    [excludeDict release];
    
    self.eventList = nil;
    self.taskList = nil;
    self.noteList = nil;
    self.anchorList = nil;
    
    [super dealloc];
}

- (void) excludeId:(NSInteger)excludeId
{
    [excludeDict setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:excludeId]];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //frm.size.width = 320;
    
    if (_isiPad)
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            frm.size.height = frm.size.width - 20;
        }
        
        frm.size.width = 384;
    }
    else
    {
        frm.size.width = 320;
    }

    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];

    self.view = contentView;
    [contentView release];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = _linkSearchHintText;
    searchBar.backgroundColor = [UIColor clearColor];
    
    [contentView addSubview:searchBar];
    [searchBar release];
    
	linkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, frm.size.width, frm.size.height-44) style:UITableViewStylePlain];
	linkTableView.delegate = self;
	linkTableView.dataSource = self;
    linkTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:linkTableView];
	[linkTableView release];    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.topViewController isKindOfClass:[LinkViewController class]])
    {
        LinkViewController *ctrler = (LinkViewController *) self.navigationController.topViewController;
        
        if (selectedSection != -1 && selectedRow != -1)
        {
            NSArray *lists[4] = {self.eventList, self.taskList, self.noteList, self.anchorList};
            
            Task *task = [lists[selectedSection] objectAtIndex:selectedRow];
            
            [ctrler addLink:task.primaryKey];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Scroll View

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [searchBar resignFirstResponder];
}

#pragma mark Search Bar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    selectedSection = -1;
    selectedRow = -1;
    
    ////printf("search text: %s\n", [searchText UTF8String]);
    NSMutableArray *result = [[DBManager getInstance] searchTitle:searchText];
    
    self.eventList = [NSMutableArray arrayWithCapacity:10];
    self.taskList = [NSMutableArray arrayWithCapacity:10];
    self.noteList = [NSMutableArray arrayWithCapacity:10];
    self.anchorList = [NSMutableArray arrayWithCapacity:10];
    
    for (Task *task in result)
    {
        /*
        if (task.primaryKey == self.excludeId)
        {
            continue;
        }*/
        
        if ([excludeDict objectForKey:[NSNumber numberWithInteger:task.primaryKey]] != nil)
        {
            continue;
        }
        
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
            [self.anchorList addObject:task];
        }
    }
    
    [linkTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (self.eventList.count == 0 && self.taskList.count == 0 && self.noteList.count == 0 && self.anchorList.count == 0)
    {
        return 0;
    }
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headers[3] = {_eventsText, _tasksText, _notesText};

    //if (section == 1)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        //label.text = _assetsText;
        label.text = headers[section];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headers[4] = {_eventText, _taskText, _noteText, _anchoredText};
    
    return headers[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSInteger rows[4] = {self.eventList.count, self.taskList.count, self.noteList.count, self.anchorList.count};
    
    return rows[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    // Configure the cell...
    
    NSArray *lists[4] = {self.eventList, self.taskList, self.noteList, self.anchorList};
    
    NSArray *list = lists[indexPath.section];
    
    Task *task = [list objectAtIndex:indexPath.row];
    
    cell.textLabel.text = task.name;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if (selectedSection != -1)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (selectedSection == indexPath.section && selectedRow == indexPath.row)
    {
        selectedRow = -1;
        selectedSection = -1;
    }
    else
    {
        selectedSection = indexPath.section;
        selectedRow = indexPath.row;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
