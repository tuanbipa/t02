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
#import "Location.h"
#import "LocationManager.h"

//extern BOOL _isiPad;

@implementation AlertListViewController

@synthesize taskEdit;
@synthesize locationList;

-(id) init 
{
	if (self = [super init]) 
	{
		//alertDict = [[AlertData getAlertTextDictionary] retain];
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
        
        self.locationList = [[LocationManager getInstance] getAllLocation];
	}
	
	return self;	
}

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
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    self.view = contentView;
    
    frm = contentView.bounds;
    
    // alert table view
    alertTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	alertTableView.delegate = self;
	alertTableView.dataSource = self;
	//alertTableView.sectionHeaderHeight=5;
    alertTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:alertTableView];
	[alertTableView release];
    
    if ([self.taskEdit isEvent]) {
        [self createBaseAddress:contentView];
    } else {
        
        [self createAlertType4Task:contentView];
    }
    
    [contentView release];
}

- (void)createAlertType4Task:(UIView*)contentView;
{
    // alert type
    CGRect frm = contentView.bounds;
    
    frm.origin.y += 10;
    frm.size.height = 30;
    alertTypeSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_byLocationText, _byDueText, nil]];
    alertTypeSegmented.frame = frm;
    alertTypeSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
    [alertTypeSegmented addTarget:self action:@selector(changeAlertType:) forControlEvents:UIControlEventValueChanged];
    
    [contentView addSubview:alertTypeSegmented];
    [alertTypeSegmented release];
    
    
    if (self.taskEdit.locationAlert > 0) {
        
        [self createBasedLocation];
    } else {
        
        [self createBasedDue];
    }
}

- (void)createBasedLocation
{
    CGRect frm = alertTypeSegmented.frame;
    
    if (self.locationList.count == 0) {
        
        UILabel *hintLable = [[UILabel alloc] initWithFrame:CGRectMake(5, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width - 5, 40)];
        hintLable.backgroundColor = [UIColor clearColor];
        hintLable.textColor = [UIColor grayColor];
        hintLable.font = [UIFont systemFontOfSize:(_isiPad?16:14)];
        hintLable.numberOfLines = 0;
        hintLable.text = _alertLocationHintText;
        
        [self.view addSubview:hintLable];
        [hintLable release];
        
        alertTableView.hidden = YES;
    } else {
        alertTableView.frame = CGRectMake(0, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - (frm.origin.y + frm.size.height + 10));
        alertTableView.hidden = NO;
    }
}

- (void)createBasedDue
{
    CGRect frm = alertTypeSegmented.frame;
    
    if (self.taskEdit.deadline == nil) {
        
        UILabel *hintLable = [[UILabel alloc] initWithFrame:CGRectMake(5, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width - 5, 40)];
        hintLable.backgroundColor = [UIColor clearColor];
        hintLable.textColor = [UIColor grayColor];
        hintLable.font = [UIFont systemFontOfSize:(_isiPad?16:14)];
        hintLable.numberOfLines = 0;
        hintLable.text = _alertHint;
        
        [self.view addSubview:hintLable];
        [hintLable release];
        
        alertTableView.hidden = YES;
    } else {
        
        alertTableView.frame = CGRectMake(0, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - (frm.origin.y + frm.size.height + 10));
        alertTableView.hidden = NO;
    }
}

- (void)createBaseAddress:(UIView*)contentView
{
    CGRect frm = contentView.bounds;
    
    if ([[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        
        UILabel *alertBasedAddressLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, frm.size.width, 30)];
        alertBasedAddressLable.text = _alertBasedOnAddressText;
        alertBasedAddressLable.textColor = [UIColor grayColor];
        [contentView addSubview:alertBasedAddressLable];
        [alertBasedAddressLable release];
        
        UISegmentedControl *basedAddressSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_onText, _offText, nil]];
        basedAddressSegmented.frame = CGRectMake(frm.size.width/2, 50, frm.size.width/2, 30);
        basedAddressSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
        [basedAddressSegmented addTarget:self action:@selector(changeLocationType:) forControlEvents:UIControlEventValueChanged];
        
        frm = basedAddressSegmented.frame;
        frm.origin.y += frm.size.height;
        
        [contentView addSubview:basedAddressSegmented];
        [basedAddressSegmented release];
    } else {
        frm = CGRectZero;
    }
    
    alertTableView.frame = CGRectMake(0, frm.origin.y + 10, contentView.bounds.size.width, contentView.bounds.size.height - (frm.origin.y + 10));
    
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [alertTableView reloadData];
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
    self.locationList = nil;
	
    [super dealloc];
}

#pragma mark Support

- (void) editAlert:(NSInteger) index
{
	AlertSelectionTableViewController *ctrler = [[AlertSelectionTableViewController alloc] init];
	ctrler.taskEdit = self.taskEdit;
	ctrler.alertIndex = index-1;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)selectLocation: (NSInteger)index
{
    if (index > 1) {
        
        Location *locationData = [self.locationList objectAtIndex:index - 2];
        
        self.taskEdit.locationAlertID = locationData.primaryKey;
    } else {
        self.taskEdit.locationAlertID = 0;
    }
    
    [alertTableView reloadData];
}

- (void)changeAlertType: (id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (seg.selectedSegmentIndex == 0) {
        
        // remove all alert based due
        [self deleteAllAlertBasedDue];
        
        self.taskEdit.locationAlert = 1;
        
        [self createBasedLocation];
    } else {
        
        self.taskEdit.locationAlert = 0;
        
        [self createBasedDue];
    }
    
    [alertTableView reloadData];
}

- (void)changeLocationType:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if ([self.taskEdit isEvent]) {
        
        self.taskEdit.locationAlert = seg.selectedSegmentIndex == 0 ? LOCATION_ARRIVE : LOCATION_NONE;
    } else {
        
        self.taskEdit.locationAlert = seg.selectedSegmentIndex + 1;
    }
}

- (void)deleteAllAlertBasedDue
{
    for (AlertData *alert in self.taskEdit.alerts) {
        
        if (alert.primaryKey > -1)
        {
            [[AlertManager getInstance] cancelAlert:alert.primaryKey];
            
            [alert deleteFromDatabase:[[DBManager getInstance] getDatabase]];
        }
        
        [taskEdit.alerts removeObject:alert];
	
	}
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.taskEdit isTask] && self.taskEdit.locationAlert > 0) {
        return 2 + self.locationList.count;
    } else {
        if (taskEdit.alerts != nil)
        {
            return taskEdit.alerts.count + 1;
        }
        
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*Settings *setting = [Settings getInstance];
    if (indexPath.row == 0 &&
        (!setting.geoFencingEnable ||
         ![self.taskEdit isEvent] ||
         self.taskEdit.location == nil ||
         [[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0))
    {
        
        return 0.0f;
    }*/
    return 44.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    } else {
        
        // remove subviews
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UISegmentedControl class]]) {
                [view removeFromSuperview];
            }
        }
    }
    
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor clearColor];

    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    if ([self.taskEdit isTask] && self.taskEdit.locationAlert > 0) { // alert based on location
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = _alertWhenText;
                
                CGRect frm = alertTableView.frame;
                CGFloat width = frm.size.width/5 * 3;
                locationTypeSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_arriveText, _leaveText, nil]];
                locationTypeSegmented.frame = CGRectMake(frm.size.width - width, 0, width, 30);
                [locationTypeSegmented addTarget:self action:@selector(changeLocationType:) forControlEvents:UIControlEventValueChanged];
                locationTypeSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == LOCATION_ARRIVE ? 0 : 1;
                
                [cell.contentView addSubview:locationTypeSegmented];
                [locationTypeSegmented release];
            }
                break;
            case 1:
            {
                cell.textLabel.text = _noneText;
                if (self.taskEdit.locationAlertID <= 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
                break;
                
            default:
            {
                Location *locationData = [self.locationList objectAtIndex:indexPath.row - 2];
                cell.textLabel.text = locationData.name;
                if (self.taskEdit.locationAlertID == locationData.primaryKey) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
                break;
        }
    } else {
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = _addText;
        }
        else
        {
            AlertData *alert = [taskEdit.alerts objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = _alertText;
            
            cell.detailTextLabel.text = [alert getAbsoluteTimeString:self.taskEdit];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	//[self editAlert:indexPath.row];
    
    if ([self.taskEdit isTask] && self.taskEdit.locationAlert > 0) {
        // select location
        [self selectLocation:indexPath.row];
    } else {
        [self editAlert:indexPath.row];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

	if(indexPath.row == 0 || alertTypeSegmented.selectedSegmentIndex == 0)
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

//- (void) createAlertLocationCell:(UITableViewCell *)cell
//{
//	cell.textLabel.text = _alertBasedOnLocationText;
//	
//	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
//	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
//	segmentedStyleControl.frame = CGRectMake(alertTableView.bounds.size.width - 110, 5, 100, 30);
//	[segmentedStyleControl addTarget:self action:@selector(editAlertBasedLocation:) forControlEvents:UIControlEventValueChanged];
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//    segmentedStyleControl.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
//	
//	[cell.contentView addSubview:segmentedStyleControl];
//	[segmentedStyleControl release];
//}
//
//- (void)editAlertBasedLocation: (id)sender
//{
//    UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
//	
//    self.taskEdit.locationAlert = segmentedStyleControl.selectedSegmentIndex;
//}
@end
