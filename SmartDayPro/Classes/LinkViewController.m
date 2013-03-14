//
//  LinkViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 4/18/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "LinkViewController.h"

#import "Common.h"
#import "Task.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"
#import "TaskManager.h"

#import "LinkSearchViewController.h"
#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@interface LinkViewController ()

@end

@implementation LinkViewController
@synthesize task;

@synthesize saveEnabled;

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
        self.saveEnabled = NO;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) save:(id) sender
{
    [self.task updateIntoDB:[[DBManager getInstance] getDatabase]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    
    self.view = contentView;
    [contentView release];
    
    linkTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	linkTableView.delegate = self;
	linkTableView.dataSource = self;
    linkTableView.allowsSelectionDuringEditing = YES;
	
	[contentView addSubview:linkTableView];
	[linkTableView release];    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [linkTableView reloadData]; //refresh linked information in case user has edited linked task and back
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.saveEnabled)
    {
        UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                   target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) addLink:(NSInteger)destId
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    NSInteger linkId = [tlm createLink:self.task.primaryKey destId:destId];
    
    if (linkId != -1)
    {
        //edit in Category view
        self.task.links = [tlm getLinkIds4Task:task.primaryKey];
        
        [linkTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
}

- (void) deleteLinkAtIndex:(NSInteger) index
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    [tlm deleteLink:self.task linkIndex:index reloadLink:YES];
    
    [_abstractViewCtrler setNeedsDisplay];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link    
}

#pragma mark - Table view data source

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
    return self.task.links.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LinkCell";
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
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = _addNewLinkText;
    }
    else 
    {
        NSNumber *linkIdNum = [self.task.links objectAtIndex:indexPath.row-1];
        
        NSInteger linkedId = [[TaskLinkManager getInstance] getLinkedId4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
        
        Task *task = [[Task alloc] initWithPrimaryKey:linkedId database:[[DBManager getInstance] getDatabase]];
        
        UIImage *img = nil;
        
        ProjectManager *pm = [ProjectManager getInstance];
        
        if ([task isEvent])
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
        
        cell.imageView.image = img;

        cell.textLabel.text = task.name;
        
        [task release];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        [self deleteLinkAtIndex:indexPath.row - 1];
        
        [tableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    if (indexPath.row > 0)
    {
        return UITableViewCellEditingStyleDelete;	
    }
    
    return UITableViewCellEditingStyleNone;
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
    
    if (indexPath.row == 0)
    {
        LinkSearchViewController *ctrler = [[LinkSearchViewController alloc] init];
        ctrler.excludeId = self.task.primaryKey;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];        
    }
    else 
    {
        NSNumber *linkIdNum = [self.task.links objectAtIndex:indexPath.row-1];
        
        NSInteger linkedId = [[TaskLinkManager getInstance] getLinkedId4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
        
        Task *task = [[Task alloc] initWithPrimaryKey:linkedId database:[[DBManager getInstance] getDatabase]];
        task.listSource = SOURCE_CATEGORY;//to update smart list as well when there is any change
        
        if ([task isRE])
        {
            TaskManager *tm = [TaskManager getInstance];
            
            Task *firstInstance = [tm findRTInstance:task fromDate:task.startTime];
            
            task.startTime = firstInstance.startTime;
            task.endTime = firstInstance.endTime;
            
        }        
        
        if ([task isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            
            ctrler.note = task;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];            
        }
        else 
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = task;
            
            [self.navigationController pushViewController:ctrler animated:YES];
            [ctrler release];            
            
        }
        
    }
}

@end
