//
//  ProjectSelectionTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProjectSelectionTableViewController.h"

#import "Common.h"
#import "ProjectManager.h"
#import "ImageManager.h"
#import "Project.h"
#import "Task.h"
#import "Settings.h"

//#import "SCTabBarController.h"
#import "NoteDetailTableViewController.h"

//extern SCTabBarController *_tabBarCtrler;

@implementation ProjectSelectionTableViewController

//@synthesize task;
@synthesize objectEdit;
@synthesize projectList;

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
		selectedIndex = -1;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;
}

/*
- (void)changeTableFrame
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	////printf("bar height: %f\n", barHeight);
	
	projectTableView.frame = CGRectMake(0, 0, 320, 416 - barHeight);
}
*/

- (void)loadView 
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	//UIView *contentView= [[UIView alloc] initWithFrame:CGRectZero];
    UIView *contentView= [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	//projectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    projectTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	projectTableView.delegate = self;
	projectTableView.dataSource = self;
	projectTableView.sectionHeaderHeight=5;	
	
	[contentView addSubview:projectTableView];
	[projectTableView release];
	
	//[self changeTableFrame];
	
	self.view = contentView;
	[contentView release];	
	
	self.navigationItem.title = _projectText;

	self.projectList = [[ProjectManager getInstance] getVisibleProjectList];
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
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[NoteDetailTableViewController class]])
    {
        NoteDetailTableViewController *ctrler = (NoteDetailTableViewController *)self.navigationController.topViewController;
        
        [ctrler refreshProject];
    }
}

-(void) setProjectKey:(NSInteger) key
{
	if ([self.objectEdit isKindOfClass:[Task class]])
	{
		//[self.objectEdit setProject:key];
		[(Task *)self.objectEdit changeProject:key];
	}
	else if ([self.objectEdit isKindOfClass:[Settings class]])
	{
		return [(Settings *)self.objectEdit setTaskDefaultProject:key];
	}
}

-(NSInteger) getProjectKey
{
	if ([self.objectEdit isKindOfClass:[Task class]])
	{
		return [(Task *)self.objectEdit project];
	}
	
	if ([self.objectEdit isKindOfClass:[Settings class]])
	{
		return [(Settings *) self.objectEdit taskDefaultProject];
	}
	
	return -1;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	//ProjectManager *pm = [ProjectManager getInstance];
	
    //return pm.projectList.count;
	
	return projectList.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	//Project *prj = [[ProjectManager getInstance] getProjectAtIndex:indexPath.row];
	Project *prj = [projectList objectAtIndex:indexPath.row];
	
	cell.textLabel.text = prj.name;
	cell.textLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
	
	//if (prj.primaryKey == self.task.project)
	if (prj.primaryKey == [self getProjectKey])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedIndex = indexPath.row;
	}
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (selectedIndex >= 0)
	{
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		
		[[projectTableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	[[projectTableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	selectedIndex = indexPath.row;
	
	//Project *prj = [[ProjectManager getInstance] getProjectAtIndex:selectedIndex];
	Project *prj = [projectList objectAtIndex:selectedIndex];
	
	//self.task.project = prj.primaryKey;
	[self setProjectKey:prj.primaryKey];
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
	self.projectList = nil;
	
    [super dealloc];
}


@end

