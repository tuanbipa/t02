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

@interface TagDetailViewController () {
    UIButton *currentLocationButton;
    UITextField *locationText;
    UITableView *listTableView;
    
    NSArray *searchPlacemarksCache;
}

//@property (nonatomic, strong) NSArray *searchPlacemarksCache;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSIndexPath *checkedIndexPath;

@property (readonly) NSInteger selectedIndex;

@end

@implementation TagDetailViewController

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
    self = [super init];
    if (self) {
        // Custom initialization
        
        _selectedCoordinate = kCLLocationCoordinate2DInvalid;
        _selectedType = CoordinateSelectorLastSelectedTypeUndefined;
        //[self updateSelectedName];
        //[self updateSelectedCoordinate];
    }
    return self;
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    frm.size.width = 2*frm.size.width/3;
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    frm = CGRectMake(0, 40, contentView.frame.size.width, 40);
    currentLocationButton = [Common createButton:_applyCurrentLocationText buttonType:UIButtonTypeCustom frame:frm titleColor:[UIColor blackColor] target:self selector:@selector(setCurrentLocaton:) normalStateImage:nil selectedStateImage:nil];
    currentLocationButton.backgroundColor = [UIColor whiteColor];
    
    [contentView addSubview:currentLocationButton];
    
    frm.origin.y += frm.size.height + 5;
    locationText = [[UITextField alloc] initWithFrame:frm];
    locationText.backgroundColor = [UIColor whiteColor];
    locationText.delegate = self;
    [contentView addSubview:locationText];
    [locationText release];
    
    frm.origin.y += frm.size.height + 5;
    frm.size.height = 400;
    listTableView = [[UITableView alloc] initWithFrame:frm];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.hidden = YES;
    [contentView addSubview:listTableView];
    //listTableView.hidden = YES;
    [listTableView release];
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

- (void)dealloc
{
    [super dealloc];
    [searchPlacemarksCache release];
}

#pragma mark Actions

- (void)setCurrentLocaton: (id)sender
{
    
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateSelectedCoordinate];
}

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
            if (_checkedIndexPath.section == 0)
            {
                // clear any current selections if they are search result selections
                _checkedIndexPath = nil;
            }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // configure the cell...
//    NSInteger section = indexPath.section;
    
    {
        // Search
        //
//        if (indexPath.row == 0)
//        {
//            return _searchCell;
//        }
        // otherwise display the list of results
        CLPlacemark *placemark = searchPlacemarksCache[indexPath.row];
        
        NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        //addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        cell.textLabel.text = addressStr;
        
        CLLocationDegrees latitude = placemark.location.coordinate.latitude;
        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"φ:%.4F, λ:%.4F", latitude, longitude];
    }
    
    // show a check next to the selected option / cell
    if ([_checkedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - update selected cell

// keys off selectedType and selectedCoordinates
- (void)updateSelectedName
{
    switch (_selectedType)
    {
        case CoordinateSelectorLastSelectedTypeCurrent:
        {
            _selectedName = @"Current Location";
            break;
        }
            
        case CoordinateSelectorLastSelectedTypeSearch:
        {
            CLPlacemark *placemark = searchPlacemarksCache[_selectedIndex]; // take into account the first 'search' cell
            _selectedName = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            break;
        }
            
        case CoordinateSelectorLastSelectedTypeUndefined:
        {
            _selectedName = @"Select a Place";
            break;
        }
    }
}

// keys off selectedType and selectedCoordinates
- (void)updateSelectedCoordinate
{
    switch (_selectedType)
    {
        case CoordinateSelectorLastSelectedTypeSearch:
        {
            // allow for the selection of search results,
            // take into account the first 'search' cell
            CLPlacemark *placemark = searchPlacemarksCache[_selectedIndex];
            _selectedCoordinate = placemark.location.coordinate;
            break;
        }
            
        case CoordinateSelectorLastSelectedTypeUndefined:
            _selectedCoordinate = kCLLocationCoordinate2DInvalid;
            break;
            
        case CoordinateSelectorLastSelectedTypeCurrent:
            break; // no need to update for current location (CL delegate callback sets it)
    }
}
@end
