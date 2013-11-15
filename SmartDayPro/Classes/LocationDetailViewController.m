//
//  LocationDetailViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "Common.h"
#import "Location.h"
#import "LocationManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import "LocationListViewController.h"
#import "BusyController.h"
#import "SettingTableViewController.h"

@interface LocationDetailViewController ()

@end

@implementation LocationDetailViewController

@synthesize location;
@synthesize locationCopy;
@synthesize searchPlacemarksCache;
@synthesize currentLocation;

- (void) dealloc
{
    self.location = nil;
    self.locationCopy = nil;
    self.searchPlacemarksCache = nil;
    self.currentLocation = nil;
    
    [super dealloc];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    NSInteger count = self.navigationController.viewControllers.count;
    
    if (count >= 3 && [[self.navigationController.viewControllers objectAtIndex:count - 3] isKindOfClass:[SettingTableViewController class]])
    {
        frm.size.width = 320;
    }
    else
    {
        frm.size.width = 2*frm.size.width/3;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	self.view = contentView;
	[contentView release];
    
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, frm.size.width - 20, 30)];
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.placeholder = _locationNameText;
    nameTextField.text = location.name;
    
    [contentView addSubview:nameTextField];
    [nameTextField release];
    
    addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 50, frm.size.width - 20, 30)];
    addressTextField.backgroundColor = [UIColor whiteColor];
    addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    addressTextField.placeholder = _locationAddressText;
    [addressTextField setReturnKeyType:UIReturnKeySearch];
    addressTextField.delegate = self;
    addressTextField.text = location.address;
    
    [contentView addSubview:addressTextField];
    [addressTextField release];
    
    currentLocationButton = [Common createButton:_applyCurrentLocationText
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(10, 90, frm.size.width - 20, 40)
                                      titleColor:[Colors blueButton]
                                          target:self selector:@selector(setCurrentLocaton:)
                                normalStateImage:nil selectedStateImage:nil];
    currentLocationButton.backgroundColor = [UIColor clearColor];
    
    currentLocationButton.layer.cornerRadius = 4;
    currentLocationButton.layer.borderWidth = 1;
    currentLocationButton.layer.borderColor = [[Colors blueButton] CGColor];
    
    [contentView addSubview:currentLocationButton];
    
    self.locationCopy = self.location;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[locationManager stopUpdatingLocation];
    
    if (self.isMovingFromParentViewController) {
        [self saveLocation];
    }
    
    if (locationManager != nil) {
        [locationManager stopUpdatingLocation];
        [locationManager release];
    }
    
    [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
}

#pragma mark methods

- (void)saveLocation
{
    if ([[nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]
        || [[addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return;
    }
    self.location.name = nameTextField.text;
    self.location.address = addressTextField.text;
    
    [self.location refreshLatituAndLongitude:self.locationCopy];
    
    [[LocationManager getInstance] saveLocation:location];
}

- (void)setCurrentLocaton: (id)sender
{
    if (self.currentLocation == nil) {
        return;
    }
    
    [[BusyController getInstance] setBusy:YES withCode:BUSY_SEARCH_LOCATION];
    
    CLGeocoder *gc = [[[CLGeocoder alloc] init] autorelease];
    
    [gc reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemark, NSError *error) {
        
        if (error) {
            
            //NSLog(@"========\n%@\n------\n%@", error.localizedDescription, error.debugDescription);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_noResultsFoundText message:error.localizedDescription delegate:nil cancelButtonTitle:_okText otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        } else {
            
            CLPlacemark *pm = [placemark objectAtIndex:0];
            NSDictionary *addressDict = pm.addressDictionary;
            // do something with the address, see keys in the remark below
            NSString *addressStr = ABCreateStringWithAddressDictionary(addressDict, NO);
            addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
            
            addressTextField.text = addressStr;
            
            // kep lat/long
            self.location.latitude = self.locationCopy.latitude =  self.currentLocation.coordinate.latitude;
            self.location.longitude = self.locationCopy.longitude = self.currentLocation.coordinate.longitude;
            self.location.address = self.locationCopy.address = addressStr;
        }
        
        [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
    }];
}

- (void)performPlacemarksSearch
{
    // perform geocode
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [[BusyController getInstance] setBusy:YES withCode:BUSY_SEARCH_LOCATION];
    
    [geocoder geocodeAddressString:addressTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [[BusyController getInstance] setBusy:NO withCode:BUSY_SEARCH_LOCATION];
        
        // There is no guarantee that the CLGeocodeCompletionHandler will be invoked on the main thread.
        // So we use a dispatch_async(dispatch_get_main_queue(),^{}) call to ensure that UI updates are always
        // performed from the main thread.
        //
        dispatch_async(dispatch_get_main_queue(),^ {
            
            //self.searchPlacemarksCache = placemarks;
            if (placemarks.count == 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.title = _noResultsFoundText;
                [alert addButtonWithTitle: _okText];
                [alert show];
                [alert release];
            } else if (placemarks.count == 1) {
                CLPlacemark *placemark = [placemarks lastObject];
                
                NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
                addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
                
                addressTextField.text = addressStr;
                
            } else {
                self.searchPlacemarksCache = placemarks;
                
                UIAlertView *alert = [[UIAlertView alloc] init];
                alert.title = _didYouMean;
                alert.delegate = self;
                for (CLPlacemark *placemark in self.searchPlacemarksCache) {
                    
                    NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
                    addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
                    
                    [alert addButtonWithTitle:addressStr];
                }
                [alert addButtonWithTitle: _cancelText];
                //alert addSubview:<#(UIView *)#>
                [alert show];
                [alert release];
            }
        });
    }];
}

#pragma mark - CLLocationManagerDelegate - Location updates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
}

#pragma mark - UITextFieldDelegate

// dismiss the keyboard for the textfields
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [addressTextField resignFirstResponder];
    
    [self performPlacemarksSearch];
    
	return YES;
}

#pragma mark Alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != self.searchPlacemarksCache.count - 1) {
        CLPlacemark *placemark = [self.searchPlacemarksCache objectAtIndex:buttonIndex];
        
        NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        
        addressTextField.text = addressStr;
    }
}
@end
