    //
//  AlertListViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 8/2/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "AlertListViewController.h"

#import "Common.h"
#import "Task.h"
#import "AlertData.h"
#import "DBManager.h"
#import "AlertManager.h"
#import "ImageManager.h"

#import "AlertSelectionTableViewController.h"
#import "GuideWebView.h"

#import "DetailViewController.h"
#import "Settings.h"

//extern BOOL _isiPad;

@implementation AlertListViewController

@synthesize taskEdit;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id) init 
{
	if (self = [super init]) 
	{
		//alertDict = [[AlertData getAlertTextDictionary] retain];
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;	
}

/*
- (void)changeTableFrame
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	alertTableView.frame = CGRectMake(0, 0, 320, 416 - barHeight);
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //CGRect frm = CGRectZero;
    //frm.size = [Common getScreenSize];
    //frm.size.width = 320;
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
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
    
    frm = contentView.bounds;
    
    alertTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	alertTableView.delegate = self;
	alertTableView.dataSource = self;
	//alertTableView.sectionHeaderHeight=5;
    alertTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:alertTableView];
	[alertTableView release];
	
    hintView = [[GuideWebView alloc] initWithFrame:frm];
	[hintView loadHTMLFile:@"TaskAlertHint" extension:@"htm"];
    hintView.backgroundColor = [UIColor clearColor];
	hintView.hidden = YES;
	
	[contentView addSubview:hintView];
	[hintView release];
	
	self.view = contentView;
	[contentView release];	
	
	self.navigationItem.title = _alertListText;	
}

- (void)viewWillAppear:(BOOL)animated 
{	
	if (self.taskEdit.deadline == nil && [self.taskEdit isTask])
	{
		alertTableView.hidden = YES;
		hintView.hidden = NO;
	}
	else 
	{
		alertTableView.hidden = NO;
		hintView.hidden = YES;
		[alertTableView reloadData];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
        [ctrler refreshAlert];
    }
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	//[alertDict release];
	
    [super dealloc];
}

#pragma mark Support

- (void) editAlert:(NSInteger) index
{
	AlertSelectionTableViewController *ctrler = [[AlertSelectionTableViewController alloc] init];
	ctrler.taskEdit = self.taskEdit;
	ctrler.alertIndex = index-2;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (taskEdit.alerts != nil)
	{
		return taskEdit.alerts.count + 2;
	}
	
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Settings *setting = [Settings getInstance];
    if (indexPath.row == 0 &&
        (!setting.geoFencingEnable ||
         ![self.taskEdit isEvent] ||
         self.taskEdit.location == nil ||
         [[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0))
    {
        
        return 0.0f;
    }
    return 44.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor clearColor];

    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
	if (indexPath.row == 0)
	{
        Settings *setting = [Settings getInstance];
        if (!setting.geoFencingEnable ||
            ![self.taskEdit isEvent] ||
            self.taskEdit.location == nil ||
            [[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0)
        {
            cell.hidden = YES;
            return cell;
        }
		[self createAlertLocationCell:cell];
	}
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = _addText;
    }
	else
	{
		AlertData *alert = [taskEdit.alerts objectAtIndex:indexPath.row-2];
		
		cell.textLabel.text = _alertText;
		
		cell.detailTextLabel.text = [alert getAbsoluteTimeString:self.taskEdit];
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[self editAlert:indexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

	if(indexPath.row == 0)
	{
		return UITableViewCellEditingStyleNone;
	}
	
	return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	AlertData *alert = [taskEdit.alerts objectAtIndex:indexPath.row-1];
	
	if (alert.primaryKey > -1)
	{
		[[AlertManager getInstance] cancelAlert:alert.primaryKey];
		
		[alert deleteFromDatabase:[[DBManager getInstance] getDatabase]];
	}

	[taskEdit.alerts removeObject:alert];
	
	
	[alertTableView reloadData];
}

- (void) createAlertLocationCell:(UITableViewCell *)cell
{
	cell.textLabel.text = _alertBasedOnLocationText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(alertTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(editAlertBasedLocation:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    segmentedStyleControl.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void)editAlertBasedLocation: (id)sender
{
    UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
    self.taskEdit.locationAlert = segmentedStyleControl.selectedSegmentIndex == 0 ? 1 : 0;
}
@end
