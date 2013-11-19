    //
//  AlertListViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 8/2/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "AlertListViewController.h"
#import <MapKit/MapKit.h>

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

#import "BusyController.h"

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
    
//    if ([self.taskEdit isEvent]) {
//        [self createBaseAddress:contentView];
//    } else {
//        
//        [self createAlertType4Task:contentView];
//    }
    
    [contentView release];
    
    etaLabel = [[UILabel alloc] init];
}

//- (void)createAlertType4Task:(UIView*)contentView;
//{
//    // alert type
//    CGRect frm = contentView.bounds;
//    
//    frm.origin.y += 10;
//    frm.size.height = 30;
//    alertTypeSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_byLocationText, _byDueText, nil]];
//    alertTypeSegmented.frame = frm;
//    alertTypeSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
//    [alertTypeSegmented addTarget:self action:@selector(changeAlertType:) forControlEvents:UIControlEventValueChanged];
//    
//    [contentView addSubview:alertTypeSegmented];
//    [alertTypeSegmented release];
//    
//    
//    if (self.taskEdit.locationAlert > 0) {
//        
//        [self createBasedLocation];
//    } else {
//        
//        [self createBasedDue];
//    }
//}
//
//- (void)createBasedLocation
//{
//    CGRect frm = alertTypeSegmented.frame;
//    
//    if (self.locationList.count == 0) {
//        
//        UILabel *hintLable = [[UILabel alloc] initWithFrame:CGRectMake(5, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width - 5, 40)];
//        hintLable.backgroundColor = [UIColor clearColor];
//        hintLable.textColor = [UIColor grayColor];
//        hintLable.font = [UIFont systemFontOfSize:(_isiPad?16:14)];
//        hintLable.numberOfLines = 0;
//        hintLable.text = _alertLocationHintText;
//        
//        [self.view addSubview:hintLable];
//        [hintLable release];
//        
//        alertTableView.hidden = YES;
//    } else {
//        alertTableView.frame = CGRectMake(0, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - (frm.origin.y + frm.size.height + 10));
//        alertTableView.hidden = NO;
//    }
//}
//
//- (void)createBasedDue
//{
//    CGRect frm = alertTypeSegmented.frame;
//    
//    if (self.taskEdit.deadline == nil) {
//        
//        UILabel *hintLable = [[UILabel alloc] initWithFrame:CGRectMake(5, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width - 5, 40)];
//        hintLable.backgroundColor = [UIColor clearColor];
//        hintLable.textColor = [UIColor grayColor];
//        hintLable.font = [UIFont systemFontOfSize:(_isiPad?16:14)];
//        hintLable.numberOfLines = 0;
//        hintLable.text = _alertHint;
//        
//        [self.view addSubview:hintLable];
//        [hintLable release];
//        
//        alertTableView.hidden = YES;
//    } else {
//        
//        alertTableView.frame = CGRectMake(0, frm.origin.y + frm.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height - (frm.origin.y + frm.size.height + 10));
//        alertTableView.hidden = NO;
//    }
//}
//
//- (void)createBaseAddress:(UIView*)contentView
//{
//    CGRect frm = contentView.bounds;
//    
//    if ([[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
//        
//        UILabel *alertBasedAddressLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, frm.size.width, 30)];
//        alertBasedAddressLable.text = _alertBasedOnAddressText;
//        alertBasedAddressLable.textColor = [UIColor grayColor];
//        [contentView addSubview:alertBasedAddressLable];
//        [alertBasedAddressLable release];
//        
//        UISegmentedControl *basedAddressSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_onText, _offText, nil]];
//        basedAddressSegmented.frame = CGRectMake(frm.size.width/2, 50, frm.size.width/2, 30);
//        basedAddressSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
//        [basedAddressSegmented addTarget:self action:@selector(changeLocationType:) forControlEvents:UIControlEventValueChanged];
//        
//        frm = basedAddressSegmented.frame;
//        frm.origin.y += frm.size.height;
//        
//        [contentView addSubview:basedAddressSegmented];
//        [basedAddressSegmented release];
//    } else {
//        frm = CGRectZero;
//    }
//    
//    alertTableView.frame = CGRectMake(0, frm.origin.y + 10, contentView.bounds.size.width, contentView.bounds.size.height - (frm.origin.y + 10));
//    
//}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [alertTableView reloadData];
    
    isDone = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.taskEdit.locationAlert > 0 &&
        [[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        
        [self geoLocation];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isDone = YES;
    [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        // check and reset location alert whether its info is incorrect
        if (self.taskEdit.locationAlert == LOCATION_NONE || self.taskEdit.locationAlertID == 0) {
            self.taskEdit.locationAlert = LOCATION_NONE;
            self.taskEdit.locationAlertID = 0;
        }
        
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
    
    [etaLabel release];
	
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
    if (index == 0) {
        
        return;
    } else if (index == 1) {
        
        //self.taskEdit.locationAlert = LOCATION_NONE;
        self.taskEdit.locationAlertID = 0;
    } else {
        
        Location *locationData = [self.locationList objectAtIndex:index - 2];
        
        self.taskEdit.locationAlertID = locationData.primaryKey;
        self.taskEdit.locationAlert = locationTypeSegmented.selectedSegmentIndex + 1;
    }
    
    [alertTableView reloadData];
}

//- (void)changeAlertType: (id)sender
//{
//    UISegmentedControl *seg = (UISegmentedControl*)sender;
//    
//    for (UIView *view in self.view.subviews) {
//        if ([view isKindOfClass:[UILabel class]]) {
//            [view removeFromSuperview];
//        }
//    }
//    
//    if (seg.selectedSegmentIndex == 0) {
//        
//        // remove all alert based due
//        [self deleteAllAlertBasedDue];
//        
//        self.taskEdit.locationAlert = 1;
//        
//        [self createBasedLocation];
//    } else {
//        
//        self.taskEdit.locationAlert = 0;
//        
//        [self createBasedDue];
//    }
//    
//    [alertTableView reloadData];
//}

- (void)changeLocationType:(id)sender
{
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    
    if ([self.taskEdit isEvent]) {
        
        //self.taskEdit.locationAlert = seg.selectedSegmentIndex == 0 ? LOCATION_ARRIVE : LOCATION_NONE;
        
        if (seg.selectedSegmentIndex == 0) {
            
            self.taskEdit.locationAlert = LOCATION_ARRIVE;
            // get driving time
            [self geoLocation];
        } else {
            
            self.taskEdit.locationAlert = LOCATION_NONE;
            
            etaLabel.text = @"";
        }
    } else {
        
        if (self.taskEdit.locationAlertID > 0) {
            
            self.taskEdit.locationAlert = seg.selectedSegmentIndex + 1;
        }
    }
}

- (void)geoLocation
{
    if ([[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        
        [[BusyController getInstance] setBusy:YES withCode:BUSY_SEARCH_LOCATION];
        
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        
        [gc geocodeAddressString:self.taskEdit.location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (isDone) {
                return;
            }
            
            if (placemarks.count > 0) {
                
                CLPlacemark *placemark = placemarks[0];
                
                [self calculateETATime:placemark];
            } else {
                
                 etaLabel.text = _couldNotCalculateETA;
                
                [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
            }
        }];
    }
}

- (void)calculateETATime:(CLPlacemark*)placemark
{
    MKMapItem *currentItem = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *desMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:placemark];
    //MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
    
    MKDirectionsRequest *req = [[MKDirectionsRequest alloc] init];
    req.source = currentItem;
    req.destination = destinationItem;
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:req];
    
    [direction calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        
        if (isDone) {
            return;
        }
        
        [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
        
        if (error) {
            
            etaLabel.text = _couldNotCalculateETA;
        } else {
            
            NSDate *alertDate = [self.taskEdit.startTime dateByAddingTimeInterval:  -(response.expectedTravelTime + 0.25*response.expectedTravelTime)];
            
            etaLabel.text = [Common getFullDateTimeString:alertDate];
        }
    }];
    
    [destinationItem release];
    [req release];
    [direction release];
}

//- (void)showNotFoundLocation
//{
//    //NSString *mess = [NSString stringWithFormat:@"%@ %@ %@", _cannotLocateThe, locationStr, _locationText];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_directionsNotAvailable
//                                                        message:_cannotLocateTheEndLocationText
//                                                       delegate:self
//                                              cancelButtonTitle:_okText
//                                              otherButtonTitles:nil];
//    
//    //[alertView show];
//    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
//}
//
//- (void)deleteAllAlertBasedDue
//{
//    for (AlertData *alert in self.taskEdit.alerts) {
//        
//        if (alert.primaryKey > -1)
//        {
//            [[AlertManager getInstance] cancelAlert:alert.primaryKey];
//            
//            [alert deleteFromDatabase:[[DBManager getInstance] getDatabase]];
//        }
//        
//        [taskEdit.alerts removeObject:alert];
//	
//	}
//}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.taskEdit isEvent] && [[self.taskEdit.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        if ([self.taskEdit isEvent]) {
            return _alertBasedOnStartTimeText;
        } else {
            return _alertBasedOnDueText;
        }
    } else {
        
        if ([self.taskEdit isEvent]) {
            return _alertBasedOnAddressText;
        } else {
            return _alertBasedOnLocationText;
        }
    }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.taskEdit isTask]) {
        if (section == 0) {
            
            return taskEdit.alerts.count + 1;
        } else {
            
            return 2 + self.locationList.count;
        }
    } else {
        
        if (section == 0) {
            
            return taskEdit.alerts.count + 1;
        } else {
            
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && [self.taskEdit isTask] && self.taskEdit.deadline == nil) {
        
        return 88.0f;
    } else if (indexPath.section == 1 && [self.taskEdit isEvent]) {
        return 88.0f;
    }
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
            if ([view isKindOfClass:[UISegmentedControl class]] ||
                [view isKindOfClass:[UILabel class]]) {
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
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0)
        {
            if ([self.taskEdit isTask] && self.taskEdit.deadline == nil) {
                
                // show hint
                cell.textLabel.text = _alertHint;
                cell.accessoryType = UITableViewCellSelectionStyleNone;
                cell.textLabel.numberOfLines = 0;
            } else {
                
                cell.textLabel.text = _addText;
            }
        }
        else
        {
            AlertData *alert = [taskEdit.alerts objectAtIndex:indexPath.row-1];
            
            cell.textLabel.text = _alertText;
            
            cell.detailTextLabel.text = [alert getAbsoluteTimeString:self.taskEdit];
        }
    } else { // section alert based location / driving time
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
        
        if ([self.taskEdit isEvent]) {
            CGRect frm = cell.bounds;
            frm.size.height = 30;
            frm.size.width = alertTableView.frame.size.width;
            frm.origin.y = (frm.size.height - 30)/2;
            
            UISegmentedControl *basedAddressSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_onText, _offText, nil]];
            basedAddressSegmented.frame = frm;
            basedAddressSegmented.selectedSegmentIndex = self.taskEdit.locationAlert == 0 ? 1 : 0;
            [basedAddressSegmented addTarget:self action:@selector(changeLocationType:) forControlEvents:UIControlEventValueChanged];
            
            [cell.contentView addSubview:basedAddressSegmented];
            [basedAddressSegmented release];
            
            // eta label
            frm.origin.y += frm.size.height + 5;
            etaLabel.frame = frm;
            etaLabel.textAlignment = NSTextAlignmentRight;
            
            [cell.contentView addSubview:etaLabel];
        } else { // is task
            
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = _alertWhenText;
                    
                    CGRect frm = alertTableView.frame;
                    CGFloat width = frm.size.width/5 * 3;
                    locationTypeSegmented = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:_arriveText, _leaveText, nil]];
                    locationTypeSegmented.frame = CGRectMake(frm.size.width - width, (cell.frame.size.height - 30)/2, width, 30);
                    [locationTypeSegmented addTarget:self action:@selector(changeLocationType:) forControlEvents:UIControlEventValueChanged];
                    locationTypeSegmented.selectedSegmentIndex = self.taskEdit.locationAlert - 1;
                    
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
    
    if (indexPath.section == 0) {
        if (!([self.taskEdit isTask] && self.taskEdit.deadline == nil)) {
            [self editAlert:indexPath.row];
        }
    } else {
        
        if ([self.taskEdit isTask]) {
            
            // select location
            [self selectLocation:indexPath.row];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return UITableViewCellEditingStyleNone;
        } else {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        return UITableViewCellEditingStyleNone;
    }
}


- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
    
        AlertData *alert = [taskEdit.alerts objectAtIndex:indexPath.row-1];
        
        if (alert.primaryKey > -1)
        {
            [[AlertManager getInstance] cancelAlert:alert.primaryKey];
            
            [alert deleteFromDatabase:[[DBManager getInstance] getDatabase]];
        }

        [taskEdit.alerts removeObject:alert];
        
        
        [alertTableView reloadData];
    } else {
        return;
    }
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
