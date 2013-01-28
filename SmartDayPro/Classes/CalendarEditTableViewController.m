//
//  GoalEditTableViewController.m
//  SmartPlan
//
//  Created by Trung Nguyen on 1/29/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "CalendarEditTableViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Project.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "TaskManager.h"
#import "ImageManager.h"
#import "TagDictionary.h"
#import "ProjectIconView.h"

#import "ProjectEditViewController.h"
#import "CategoryNoteViewController.h"
#import "CalendarViewController.h"
#import "SmartListViewController.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

@implementation CalendarEditTableViewController

@synthesize settings;
//@synthesize projectList;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (void)loadView 
{
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
	contentView.backgroundColor=[UIColor groupTableViewBackgroundColor];
	
	//CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	addButton.frame = CGRectMake(10, 10, 30, 30);
	[addButton addTarget:self action:@selector(addCalendar:) forControlEvents:UIControlEventTouchUpInside];	
	[contentView addSubview:addButton];
	
	UIButton *showAllButton = [Common createButton:_showAllText 
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(110, 5, 100, 30) 
										titleColor:[UIColor whiteColor] 
											target:self 
										  selector:@selector(showAllProjects:) 
								  normalStateImage:@"blue_button.png"
								selectedStateImage:nil];
	
	[contentView addSubview:showAllButton];	
		
	//projectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 416-barHeight-40) style:UITableViewStyleGrouped];
	projectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 416-40) style:UITableViewStyleGrouped];
	projectTableView.delegate = self;
	projectTableView.dataSource = self;
	projectTableView.sectionHeaderHeight = 5;
	projectTableView.allowsSelectionDuringEditing=YES;
	
	[contentView addSubview:projectTableView];
	[projectTableView release];
	
	self.view = contentView;
	[contentView release];
	
/*    
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
*/

	//self.projectList = [[NSMutableArray alloc] initWithArray:[[ProjectManager getInstance] getProjectList] copyItems:YES];
    
	//[self.projectList release];
    
    //self.projectList = [[ProjectManager getInstance] getProjectList];
    
    ProjectManager *pm = [ProjectManager getInstance];
		
	NSInteger defaultProject = [settings taskDefaultProject];
	
	//for (int i=0;i<self.projectList.count;i++)
    for (int i=0;i<pm.projectList.count;i++)
	{
		Project *proj = [pm.projectList objectAtIndex:i];
		
		if (proj.primaryKey == defaultProject)
		{
			defaultProjectIndex = i;
			break;
		}
	}	
	
	self.navigationItem.title = _projectsText;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[projectTableView reloadData];	
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

- (void) deletePlans:(NSArray *)delList cleanFromDB:(BOOL)cleanFromDB
{
	TaskManager *tm = [TaskManager getInstance];
	ProjectManager *pm = [ProjectManager getInstance];
	
	for (Project *plan in delList)
	{
		[pm deleteProject:plan cleanFromDB:cleanFromDB];
	}
	
	[tm initData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
	
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void) changeSyncOption:(id) sender
{
    ProjectManager *pm = [ProjectManager getInstance];
    
	UIButton *button = (UIButton *) sender;

	button.selected = !button.selected;
	
	NSInteger tag = button.tag;
	
	if (tag >= 11000)
	{
		Project *project = [pm.projectList objectAtIndex:tag - 11000];
		
		project.tdId = (button.selected?project.name:@"");
	}
	else 
	{
		Project *project = [pm.projectList objectAtIndex:tag - 10000];
		
		project.ekId = (button.selected?project.name:@"");		
	}
}

- (void) addCalendar:(id) sender
{
	Project *project = [[Project alloc] init];
	project.name = _newCalendarText;
	project.type = TYPE_PLAN;
	
	//[self.projectList addObject:project];
	//[project release];
	
	ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
	
	ctrler.project = project;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	/*
	if (buttonIndex == 1)
	{
		[self deleteProjectAtIndex:alertVw.tag];
	}
	*/
	if (buttonIndex != 0)
	{
		//NSArray *delList = (NSArray *)alertVw.tag;
							
		//[self deletePlans:delList cleanFromDB:(buttonIndex == 2)];
		
		//[delList release];
        
        ProjectManager *pm = [ProjectManager getInstance];
        
        NSInteger index = alertVw.tag;
        
        Project *prj = [pm.projectList objectAtIndex:index];
        
        [pm deleteProject:prj cleanFromDB:NO];
        
        [projectTableView reloadData];	
        
	}	
}

- (void) deleteProjectAtIndex:(NSInteger)index
{	
	//[self.projectList removeObjectAtIndex:index];
	
	//[projectTableView reloadData];	
}

- (void) showAllProjects:(id)sender
{
    ProjectManager *pm = [ProjectManager getInstance];
    
	//for (Project *prj in self.projectList)
    for (Project *prj in pm.projectList)
	{
		prj.status = PROJECT_STATUS_NONE;
	}
	
	[projectTableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 6;
	if (section == 1)
	{
		//return projectList.count;
        ProjectManager *pm = [ProjectManager getInstance];
        
        return pm.projectList.count;
	}
	
	return 1;
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
	
	//cell.text = @"";
	cell.textLabel.text = @"";
    cell.backgroundColor = [UIColor whiteColor];
	
	if (indexPath.section == 0)
	{
		//cell.text = _readmeText;
		cell.textLabel.text = _readmeText;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else 
	{
        ProjectManager *pm = [ProjectManager getInstance];
        
		//Project *prj = [self.projectList objectAtIndex:indexPath.row];
        Project *prj = [pm.projectList objectAtIndex:indexPath.row];
        
        UIColor *transColor = nil;
        
        //if (prj.status == PROJECT_STATUS_TRANSPARENT)
        if (prj.isTransparent)
        {
            ProjectIconView *iconView = [[ProjectIconView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            iconView.backgroundColor = [Common getColorByID:prj.colorId colorIndex:0];
            iconView.colorId = -1;
            iconView.type = ICON_RECT;
            
            UIImage *icon = [Common takeSnapshot:iconView size:CGSizeMake(5, 5)]; 
            
            transColor = [[UIColor colorWithPatternImage:icon] colorWithAlphaComponent:0.2];
        }
		
		// Set up the cell...
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.backgroundColor = (prj.status == PROJECT_STATUS_INVISIBLE?[UIColor lightGrayColor]:
                                //(prj.status == PROJECT_STATUS_TRANSPARENT?transColor:[UIColor whiteColor]));
                                (prj.isTransparent?transColor:[UIColor whiteColor]));
		
		UILabel *prjLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 240, 30)];
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
		
	}

	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 0)
	{
		CategoryNoteViewController *ctrler = [[CategoryNoteViewController alloc] init];
		
		//[self presentModalViewController:ctrler animated:YES];
        ctrler.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:ctrler animated:YES completion:NULL];
        
		[ctrler release];		
	}
	else 
	{
        ProjectManager *pm = [ProjectManager getInstance];
        
		ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
		ctrler.settings = self.settings;
		
		//Project *prj = [projectList objectAtIndex:indexPath.row];
        Project *prj = [pm.projectList objectAtIndex:indexPath.row];
		
		ctrler.project = prj;
		
		[self.navigationController pushViewController:ctrler animated:YES];
		[ctrler release];		
	}
}

- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		//if ([[Settings getInstance] deleteWarning])
		{
			NSString *msg = _calendarDeleteText;
			
			UIAlertView *projectDeleteAlertView = [[UIAlertView alloc] initWithTitle:_calendarDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
			
			projectDeleteAlertView.tag = indexPath.row;
			
			[projectDeleteAlertView addButtonWithTitle:_okText];
			[projectDeleteAlertView show];
			[projectDeleteAlertView release];		
		}
		//else 
		//{
		//	[self deleteProjectAtIndex:indexPath.row];
		//}		
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.row == defaultProjectIndex)
	{
		return UITableViewCellEditingStyleNone;
	}
	
	return UITableViewCellEditingStyleDelete;	
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
 
	 if (editingStyle == UITableViewCellEditingStyleDelete) 
	 {
		 // Delete the row from the data source
		 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	 }   
	 else if (editingStyle == UITableViewCellEditingStyleInsert) 
	 {
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

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	projectTableView.frame = CGRectMake(0, 0, 320, 416-50);	
	
	if ([textField.text isEqualToString:@""])
	{
		saveButton.enabled = NO;
	}
	else
	{
		saveButton.enabled = YES;
	}
	
    ProjectManager *pm = [ProjectManager getInstance];
    
	//Project *prj = [self.projectList objectAtIndex:textField.tag - 10000];
    Project *prj = [pm.projectList objectAtIndex:textField.tag - 10000];
    
	prj.name = textField.text;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	saveButton.enabled = NO;
	
	projectTableView.frame = CGRectMake(0, 0, 320, 200);	
	
	[projectTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag-10000 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return YES;
}

- (void)dealloc {
	//self.settingsCopy = nil;
	//self.projectList = nil;
	
    [super dealloc];
}


@end

