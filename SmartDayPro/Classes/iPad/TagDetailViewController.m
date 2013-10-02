//
//  TagDetailViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 8/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

//#import <CoreLocation/CoreLocation.h>
#import "TagDetailViewController.h"
#import <AddressBookUI/AddressBookUI.h>

#import "Common.h"
#import "iPadGeneralSettingViewController.h"
#import "TagDictionary.h"

@interface TagDetailViewController () {
    UIButton *currentLocationButton;
    UITextField *locationText;
    UITableView *listTableView;
    
    NSArray *searchPlacemarksCache;
    
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
}
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;

@end

@implementation TagDetailViewController

@synthesize keyStr;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];

    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    frm = CGRectMake(contentView.frame.size.width/2-80, 10, 160, 40);
    currentLocationButton = [Common createButton:_applyCurrentLocationText buttonType:UIButtonTypeCustom frame:frm titleColor:[Colors blueButton] target:self selector:@selector(setCurrentLocaton:) normalStateImage:nil selectedStateImage:nil];
    currentLocationButton.backgroundColor = [UIColor clearColor];
    
    currentLocationButton.layer.cornerRadius = 4;
    currentLocationButton.layer.borderWidth = 1;
    currentLocationButton.layer.borderColor = [[Colors blueButton] CGColor];
    
    [contentView addSubview:currentLocationButton];
    
    frm = contentView.bounds;
    frm.origin.y = currentLocationButton.frame.origin.y + currentLocationButton.frame.size.height + 5;
    frm.origin.x = 10;
    frm.size.width -= 20;
    frm.size.height = 40;
    locationText = [[UITextField alloc] initWithFrame:frm];
    locationText.backgroundColor = [UIColor whiteColor];
    locationText.delegate = self;
    [locationText setReturnKeyType:UIReturnKeySearch];
    
    TagDictionary *dict = [TagDictionary getInstance];
    NSString *address = [dict.tagDict objectForKey:self.keyStr];
    locationText.text = address;
    
    [contentView addSubview:locationText];
    [locationText release];
    
    frm.origin.y += frm.size.height + 5;
    frm.size.height = contentView.bounds.size.height - frm.origin.y - 10;
    listTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.hidden = YES;
    listTableView.backgroundColor = [UIColor clearColor];
    
    [contentView addSubview:listTableView];
    //listTableView.hidden = YES;
    [listTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    locationManager = [[CLLocationManager alloc] init];
    
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [locationManager startUpdatingLocation];
    
    // add action for done
    /*UIBarButtonItem *doneButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self action:@selector(saveLocation:)];
	self.navigationItem.rightBarButtonItem = doneButtonItem;
	[doneButtonItem release];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [locationManager stopUpdatingLocation];
    
    if (self.isMovingFromParentViewController) {
        [self saveLocation:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    [searchPlacemarksCache release];
    [locationManager release];
    
    [keyStr release];
    if (currentLocation != nil) {
        [currentLocation release];
    }
}

#pragma mark Actions

- (void)setCurrentLocaton: (id)sender
{
    if (currentLocation == nil) {
        return;
    }
    
    listTableView.hidden = YES;
    
    CLGeocoder *gc = [[[CLGeocoder alloc] init] autorelease];
    
    [gc reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemark, NSError *error) {
        CLPlacemark *pm = [placemark objectAtIndex:0];
        NSDictionary *addressDict = pm.addressDictionary;
        // do something with the address, see keys in the remark below
        NSString *addressStr = ABCreateStringWithAddressDictionary(addressDict, NO);
        addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        
        locationText.text = addressStr;
    }];
}

- (void)saveLocation: (id)sender
{
    TagDictionary *tagDict = [TagDictionary getInstance];
    [tagDict.tagDict setObject:locationText.text forKey:self.keyStr];
    //tagDict setObject:address forKey:tag]
}

#pragma mark - UITextFieldDelegate

// dismiss the keyboard for the textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [locationText resignFirstResponder];
    
    // initiate a search
    [self performPlacemarksSearch];
    
	return YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    [self updateSelectedCoordinate];
//}

#pragma mark Search

- (void)lockSearch:(BOOL)lock
{
    locationText.enabled = !lock;
    //self.searchSpinner.hidden = !lock;
}

- (void)performPlacemarksSearch
{
    [self lockSearch:YES];
    
    // perform geocode
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:locationText.text completionHandler:^(NSArray *placemarks, NSError *error) {
        // There is no guarantee that the CLGeocodeCompletionHandler will be invoked on the main thread.
        // So we use a dispatch_async(dispatch_get_main_queue(),^{}) call to ensure that UI updates are always
        // performed from the main thread.
        //
        dispatch_async(dispatch_get_main_queue(),^ {
            
            //searchPlacemarksCache = placemarks; // might be nil
            if (searchPlacemarksCache != nil) {
                [searchPlacemarksCache release];
            }
            //searchPlacemarksCache = [[NSMutableArray alloc] initWithArray:placemarks copyItems:YES];
            searchPlacemarksCache = [placemarks retain];
            //[[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [listTableView reloadData];
            [self lockSearch:NO];
            listTableView.hidden = NO;
            if (placemarks.count == 0)
            {
                listTableView.hidden = YES;
                // show an alert if no results were found
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.title = @"No places were found.";
                [alert addButtonWithTitle:@"OK"];
                [alert show];
            }
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return the number of rows in the section
    return [searchPlacemarksCache count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    {
        // otherwise display the list of results
        CLPlacemark *placemark = searchPlacemarksCache[indexPath.row];
        
        NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        cell.textLabel.text = addressStr;
        
        /*CLLocationDegrees latitude = placemark.location.coordinate.latitude;
        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4F, λ:%.4F", latitude, longitude];*/
    }
    
    return cell;
}

#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    locationText.text = cell.textLabel.text;
}

#pragma mark - CLLocationManagerDelegate - Location updates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (currentLocation != nil) {
        [currentLocation release];
    }
    currentLocation = [[locations lastObject] retain];
    /*CLLocation *location = [locations lastObject];
    
    CLGeocoder *gc = [[[CLGeocoder alloc] init] autorelease];
    
    [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error) {
        CLPlacemark *pm = [placemark objectAtIndex:0];
        NSDictionary *addressDict = pm.addressDictionary;
        // do something with the address, see keys in the remark below
        NSString *addressStr = ABCreateStringWithAddressDictionary(addressDict, NO);
        addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        
        //NSString *addressStr = ABCreateStringWithAddressDictionary(addressDict, NO);
        NSLog(@"OldLocation %f %f, address %@", location.coordinate.latitude, location.coordinate.longitude, addressStr);
        [currentLocationButton setTitle:addressStr forState:UIControlStateNormal];
    }];*/
}
@end
