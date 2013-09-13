//
//  MapLocationViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 9/12/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "MapLocationViewController.h"
#import "Common.h"
#import "LocationViewController.h"
#import "DetailViewController.h"
#import "iPadViewController.h"

extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;

@interface MapLocationViewController ()

@end

@implementation MapLocationViewController

@synthesize task;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        CGFloat w = frm.size.height + 20 + 44;
        
        frm.size.height = frm.size.width - 20 - 44;
        
        frm.size.width = w;
    }
    
	contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    UILabel *currentLocation  = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 40)];
    currentLocation.text = [_startText stringByAppendingFormat:@": %@", _currentLocationText];
    [contentView addSubview:currentLocation];
    [currentLocation release];
    
    locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(currentLocation.frame.origin.x + currentLocation.frame.size.width + 20, currentLocation.frame.origin.y, 400, 40)];
    locationTextField.backgroundColor = [UIColor whiteColor];
    locationTextField.textAlignment = NSTextAlignmentLeft;
	locationTextField.keyboardType = UIKeyboardTypeDefault;
    //locationTextField.returnKeyType = UIReturnKeyDone;
    locationTextField.delegate = self;
    locationTextField.text = self.task.location;
    
	[contentView addSubview:locationTextField];
	[locationTextField release];
    
    UIButton *editLocationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    editLocationButton.frame = CGRectMake(locationTextField.frame.origin.x + locationTextField.frame.size.width, locationTextField.frame.origin.y, 40, 40);
    [editLocationButton addTarget:self action:@selector(editLocation:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:editLocationButton];
    
    UIColor *textColor = [UIColor colorWithRed:21.0/255 green:125.0/255 blue:251.0/255 alpha:1];
    // route button
    UIButton *routeButton = [Common createButton:_routeText
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(editLocationButton.frame.origin.x + editLocationButton.frame.size.width + 20, editLocationButton.frame.origin.y, 80, 40)
                                      titleColor:textColor target:self
                                        selector:@selector(routeDirection:)
                                normalStateImage:nil
                              selectedStateImage:nil];
    [contentView addSubview:routeButton];
    
    // ETA
    etaLable = [[UILabel alloc] initWithFrame:CGRectMake(currentLocation.frame.origin.x, currentLocation.frame.origin.y +currentLocation.frame.size.height + 5, 300, 40)];
    etaLable.textColor = [UIColor blackColor];
    [contentView addSubview:etaLable];
    [etaLable release];
    
    // map view
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, etaLable.frame.origin.y + etaLable.frame.size.height + 10, contentView.frame.size.width, contentView.frame.size.height - etaLable.frame.origin.y + etaLable.frame.size.height + 10)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [contentView addSubview:mapView];
    [mapView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    locationTextField.text = self.task.location;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // done button
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = doneItem;
    [doneItem release];
    
    // save button
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:_exportMapText style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem= saveItem;
    [saveItem release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[locationTextField resignFirstResponder];
    
//    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
//    {
//        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
//        
//        [ctrler refreshTitle];
//    }
    
    if ([_iPadViewCtrler.detailNavCtrler.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)_iPadViewCtrler.detailNavCtrler.topViewController;
        
        [ctrler refreshTitle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //self.task = nil;
    
    [super dealloc];
}

#pragma mark Actions

- (void)editLocation:(id) sender
{
	LocationViewController *locationViewController=[[LocationViewController alloc] init];
	
	locationViewController.oldSelectedIndex=nil;
	locationViewController.task=self.task;
	[locationViewController setEditing:YES animated:YES];
	[self.navigationController pushViewController:locationViewController animated:YES];
	[locationViewController release];
	
}

- (void)done: (id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save: (id)sender
{
    UIGraphicsBeginImageContext(mapView.frame.size);
    [mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Map Delegate

- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *line = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
    line.strokeColor = [UIColor blueColor];
    line.lineWidth = 5;
    return line;
}

#pragma mark
- (void)routeDirection: (id)sender
{
    [self routing:YES];
    
    CLGeocoder *gc = [[[CLGeocoder alloc] init] autorelease];
    // start location
    __block CLLocation *starLocation;
    starLocation = [[mapView userLocation] location];
    
    [gc reverseGeocodeLocation:starLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            CLPlacemark *sPlacemark = placemarks[0];
            [self geoEndLocation:gc startPlacemark:sPlacemark];
        }
    }];
}

- (void)geoEndLocation: (CLGeocoder *) gc startPlacemark: (CLPlacemark*) startPlacemark
{
    // get end location
    [gc geocodeAddressString:locationTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks[0];
            
            // check api
            MKPlacemark *sourceMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:startPlacemark];
            MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourceMapPlaceMark];
            
            MKPlacemark *desMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:placemark];
            MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
            
            MKDirectionsRequest *req = [[MKDirectionsRequest alloc] init];
            req.source = source;
            req.destination = destination;
            
            MKDirections *direction = [[MKDirections alloc] initWithRequest:req];
            [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    //[self handleError:error];
                    NSLog(error.description);
                } else {
                    [self showDirections:response];
                }
            }];
            
            // release
            [sourceMapPlaceMark release];
            [source release];
            [desMapPlaceMark release];
            [destination release];
            
            [req release];
            [direction release];
        } else {
            [self showNotFoundLocation:_endText];
        }
    }];
}

- (void)showDirections: (MKDirectionsResponse*)response
{
    double totalDistance = 0.0;
    double totalTime = 0.0;
    
    // remove old overlay
    if ([mapView.overlays count] > 0) {
        [mapView removeOverlays:mapView.overlays];
    }
    
    for (MKRoute *route in response.routes) {
        [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        totalDistance += route.distance;
        totalTime += route.expectedTravelTime;
    }
    
    MKDistanceFormatter *distanceFormat = [[MKDistanceFormatter alloc] init];
    distanceFormat.units = MKDistanceFormatterUnitsDefault;
    distanceFormat.unitStyle = MKDistanceFormatterUnitStyleAbbreviated;
    
    NSString *distance = [distanceFormat stringFromDistance:totalDistance];
    [distanceFormat release];
    
    etaLable.text = [NSString stringWithFormat:@"ETA: %@, %@ to destination", distance, [Common getDurationString:totalTime]];
    etaLable.tag = totalTime;
}

- (void)showNotFoundLocation: (NSString*) locationStr
{
    NSString *mess = [NSString stringWithFormat:@"%@ %@ %@", _cannotLocateThe, locationStr, _locationText];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_directionsNotAvailable  message:mess delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    
    [alertView show];
    [self routing:NO];
}

- (void)routing: (BOOL) route
{
    if (route) {
        etaLable.text = _loadingText;
    } else {
        etaLable.text = @"";
    }
}

#pragma mark textView delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.task.location = textField.text;
}

#pragma mark Rotation

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
@end
