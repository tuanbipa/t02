//
//  MapLocationViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 9/12/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "MapLocationViewController.h"
#import "Common.h"
#import "LocationViewController.h"
#import "DetailViewController.h"
#import "iPadViewController.h"
#import "SmartDayViewController.h"

extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@interface MapLocationViewController ()

@end

@implementation MapLocationViewController

@synthesize task;
@synthesize destination;

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
    
    // start label
    UILabel *currentLocation  = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 30)];
    currentLocation.text = [_startText stringByAppendingFormat:@": %@", _currentLocationText];
    [contentView addSubview:currentLocation];
    [currentLocation release];
    
    // end lable
    UILabel *endLabel  = [[UILabel alloc] initWithFrame:CGRectMake(_isiPad?(currentLocation.frame.origin.x + currentLocation.frame.size.width + 10):10, _isiPad?5:40, 40, 30)];
    endLabel.text = [NSString stringWithFormat:@"%@:", _endText];
    [contentView addSubview:endLabel];
    [endLabel release];
    
    locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(endLabel.frame.origin.x + endLabel.frame.size.width, endLabel.frame.origin.y, _isiPad?400:220, 30)];
    locationTextField.backgroundColor = [UIColor whiteColor];
    locationTextField.textAlignment = NSTextAlignmentLeft;
	locationTextField.keyboardType = UIKeyboardTypeDefault;
    locationTextField.returnKeyType = UIReturnKeyDone;
    locationTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    locationTextField.delegate = self;
    locationTextField.text = self.task.location;
    
	[contentView addSubview:locationTextField];
	[locationTextField release];
    
    UIButton *editLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editLocationButton setImage:[UIImage imageNamed:@"contact_iOS7.png"] forState:UIControlStateNormal];
    editLocationButton.frame = CGRectMake(locationTextField.frame.origin.x + locationTextField.frame.size.width, locationTextField.frame.origin.y-5, 40, 40);
    [editLocationButton addTarget:self action:@selector(editLocation:) forControlEvents:UIControlEventTouchUpInside];
    editLocationButton.tag = -1000;
    [contentView addSubview:editLocationButton];
    
    //UIColor *textColor = [UIColor colorWithRed:21.0/255 green:125.0/255 blue:251.0/255 alpha:1];
   
    // ETA
    etaLable = [[UILabel alloc] initWithFrame:CGRectMake(_isiPad?10:endLabel.frame.origin.x, endLabel.frame.origin.y + endLabel.frame.size.height + 5, 300, 25)];
    etaLable.textColor = [UIColor blackColor];
    [contentView addSubview:etaLable];
    [etaLable release];
    
    // map view
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, etaLable.frame.origin.y + etaLable.frame.size.height + 10, contentView.frame.size.width, contentView.frame.size.height - etaLable.frame.origin.y + etaLable.frame.size.height + 10)];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [contentView addSubview:mapView];
    [mapView release];
    
    // =========tool bar
    CGFloat iconSize = _isiPad?30:28;
    
    UIButton *openMapsButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, iconSize, iconSize)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(openAppleMaps:)
                                 normalStateImage:@"map_iOS7.png"
                               selectedStateImage:nil];
    
    UIBarButtonItem *openMapsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:openMapsButton];
    
    /*UIButton *exportMapButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, iconSize, iconSize)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(exportMap:)
                                   normalStateImage:@"savemap.png"
                                 selectedStateImage:nil];
    
    UIBarButtonItem *exportMapButtonItem = [[UIBarButtonItem alloc] initWithCustomView:exportMapButton];
    
    // share to airdrop
    UIButton *share2Airdrop = [Common createButton:@""
                                        buttonType:UIButtonTypeSystem
                                             frame:CGRectMake(0, 0, iconSize, iconSize)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(share2Airdrop:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
    
    UIBarButtonItem *share2AirdropItem = [[UIBarButtonItem alloc] initWithCustomView:share2Airdrop];*/
    
    UIBarButtonItem *actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(share2Airdrop:)];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = 10;//(_isiPad?10:0);
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:actionButtonItem, fixedItem, openMapsButtonItem, nil];
    
    [openMapsButtonItem release];
    //[exportMapButtonItem release];
    //[share2AirdropItem release];
    [actionButtonItem release];
    [fixedItem release];
    // ==== end
    
    self.navigationItem.rightBarButtonItems = items;
    
    [self changeOrientation:self.interfaceOrientation];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for half a second.
    [mapView addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    locationTextField.text = self.task.location;
    
    isDone = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![locationTextField.text isEqualToString:@""]) {
        [self routeDirection:nil];
    } else {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mapView userLocation].coordinate, 800, 800);
        [mapView setRegion:[mapView regionThatFits:region] animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // done button
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = doneItem;
    [doneItem release];
    
    locationManager = [[CLLocationManager alloc] init];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];
    
    [mapView setShowsUserLocation:YES];
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (locationManager != nil) {
        [locationManager stopUpdatingLocation];
        [locationManager release];
        locationManager = nil;
    }
    
    [locationTextField resignFirstResponder];
    
    if ([_iPadViewCtrler.detailNavCtrler.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)_iPadViewCtrler.detailNavCtrler.topViewController;
        
        [ctrler refreshTitle];
    } else if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]]){
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
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
    if (destination != nil) {
        [destination release];
    }
    
    [super dealloc];
}

#pragma mark Actions

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    // revert location
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    [self revertLocation:location];
    [location release];
}

- (void)editLocation:(id) sender
{
    //if ([locationTextField isFirstResponder]) {
        isDone = YES;
    //}
    
	LocationViewController *locationViewController=[[LocationViewController alloc] init];
	
	locationViewController.oldSelectedIndex=nil;
	locationViewController.task=self.task;
	[locationViewController setEditing:YES animated:YES];
	[self.navigationController pushViewController:locationViewController animated:YES];
	[locationViewController release];
	
}

- (void)done: (id)sender
{
    self.task.location = locationTextField.text;
    [mapView setUserTrackingMode:MKUserTrackingModeNone];
    [mapView removeFromSuperview];
    mapView = nil;
    
    //if([locationTextField isFirstResponder]){
        isDone = YES;
    //}
    
    if (_isiPad)
    {
        [_iPadViewCtrler dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)share2Airdrop: (id)sender
{
    UIGraphicsBeginImageContext(mapView.frame.size);
    [mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[viewImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && _isiPad) {
        activityViewController.popoverPresentationController.sourceView = self.view;
        CGRect rect = self.view.bounds;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(rect.size.width/4, rect.size.height, rect.size.width/2, rect.size.height/2);
    }
    
    activityViewController.completionHandler = ^(NSString* activityType, BOOL completed) {
        // do whatever you want to do after the activity view controller is finished
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark Map Delegate

//- (void)mapView:(MKMapView *)map didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
//    [mapView setRegion:[mapView regionThatFits:region] animated:YES];
//}

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
    
    [self geoEndLocation];
}

- (void)calculateDirectionToDestination:(CLPlacemark *) placemark
{
    MKMapItem *currentItem = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *desMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:placemark];
    //MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
    self.destination = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
    
    MKDirectionsRequest *req = [[MKDirectionsRequest alloc] init];
    req.source = currentItem;
    req.destination = destination;
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:req];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (isDone) {
            return;
        }

        if (error) {
            /*NSLog(@"1. %@", error.localizedDescription);
            NSLog(@"2. %@", error.localizedRecoveryOptions);
            NSLog(@"3. %@", error.localizedRecoverySuggestion);
            NSLog(@"4. %@", error.localizedFailureReason);*/
            [self showNotFoundLocation:error.localizedRecoverySuggestion];
        } else {
            [self showDirections:response];
            
            //+++++++++ Annotation
            // 1. remove annotations
            [mapView removeAnnotations:[mapView annotations]];
            
            // 2. add annotation
            /*MKPointAnnotation *sourceAnnotation = [[MKPointAnnotation alloc] init];
             sourceAnnotation.coordinate = currentItem.placemark.location.coordinate;
             sourceAnnotation.title = _currentLocationText;
             [mapView addAnnotation:sourceAnnotation];
             [sourceAnnotation release];*/
            
            MKPointAnnotation *destinationAnnotation = [[MKPointAnnotation alloc] init];
            destinationAnnotation.coordinate = placemark.location.coordinate;
            destinationAnnotation.title = locationTextField.text;
            [mapView addAnnotation:destinationAnnotation];
            [destinationAnnotation release];
            
            //
            [self zoomToFitRoutes];
        }
    }];
    
    // release
    [desMapPlaceMark release];
    [destination release];
    
    [req release];
    [direction release];
}

- (void)geoEndLocation
{
    CLGeocoder *gc = [[CLGeocoder alloc] init];
    
    [gc geocodeAddressString:locationTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (isDone) {
            return;
        }
        
        if (placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks[0];
            
            [self calculateDirectionToDestination:placemark];
        } else {
            [self showNotFoundLocation:_cannotLocateTheEndLocationText];
        }
    }];
}

- (void)revertLocation:(CLLocation*)location
{
    CLGeocoder *gc = [[CLGeocoder alloc] init];
    [gc reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (isDone) {
            return;
        }

        if (placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks[0];
            
            NSString *addressStr = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
            addressStr = [addressStr stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
            
            locationTextField.text = addressStr;
            
            [self calculateDirectionToDestination:placemark];
        } else {
            [self showNotFoundLocation:_weCouldNotDetectDroppedPinText];
        }
    }];
    
    [gc release];
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
    
    etaLable.text = [NSString stringWithFormat:_isiPad?_etaToDestinationLongText: _etaToDestinationShortText, distance, [Common getDurationString:totalTime]];
    etaLable.tag = totalTime;
    
}

- (void)showNotFoundLocation: (NSString*) message
{
    //NSString *mess = [NSString stringWithFormat:@"%@ %@ %@", _cannotLocateThe, locationStr, _locationText];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_directionsNotAvailable
                                                        //message:_cannotLocateTheEndLocationText
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:_okText
                                              otherButtonTitles:nil];
    
    //[alertView show];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
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

- (void)openAppleMaps: (id)sender
{
    
    if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    } else {
        MKMapItem *mapItem = [[MKMapItem alloc] init];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsMapCenterKey:[NSValue valueWithMKCoordinate:[[mapView userLocation] location].coordinate]}];
        //[[mapView userLocation] location];
        [mapItem release];
    }
}

- (void)zoomToFitRoutes
{
    if ( !mapView.overlays || !mapView.overlays.count ) {
        return;
    }
    
    //Union
    MKMapRect mapRect = MKMapRectNull;
    if ( mapView.overlays.count == 1 ) {
        mapRect = ((id<MKOverlay>)mapView.overlays.lastObject).boundingMapRect;
    } else {
        for ( id<MKOverlay> anOverlay in mapView.overlays ) {
            mapRect = MKMapRectUnion(mapRect, anOverlay.boundingMapRect);
        }
    }
    
    //Inset
    /*CGFloat insetProportion = .1;
    CGFloat insetW = (CGFloat)(mapRect.size.width*insetProportion);
    CGFloat insetH = (CGFloat)(mapRect.size.height*insetProportion);
    mapRect = [mapView mapRectThatFits:MKMapRectInset(mapRect, 0.9, 0.9)];*/
    
    //Set
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    [mapView setRegion:region animated:YES];
}

#pragma mark textView delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//self.task.location = textField.text;
    
    if (isDone) {
        isDone = NO;
        return;
    }
    
    // route
    [self routeDirection:nil];
}

#pragma mark Rotation

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeOrientation:toInterfaceOrientation];
    
    if (_iPadViewCtrler != nil)
    {
        [_iPadViewCtrler changeOrientation:toInterfaceOrientation];
    }
    else if (_sdViewCtrler != nil)
    {
        [_sdViewCtrler changeOrientation:toInterfaceOrientation];
    }
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 44;
    
    NSInteger seperator = 10;
    
    UIView *editLocationButton = [contentView viewWithTag:-1000];
    
    CGRect itemFrm = locationTextField.frame;
    itemFrm.size.width = frm.size.width - itemFrm.origin.x - 2*seperator - editLocationButton.frame.size.width;
    locationTextField.frame = itemFrm;
    
    itemFrm = editLocationButton.frame;
    itemFrm.origin.x =  locationTextField.frame.origin.x + locationTextField.frame.size.width + seperator;
    editLocationButton.frame = itemFrm;
    
    // map view
    mapView.frame = CGRectMake(0, etaLable.frame.origin.y + etaLable.frame.size.height + 10, frm.size.width, frm.size.height - etaLable.frame.origin.y + etaLable.frame.size.height + 10);
}

#pragma mark - CLLocationManagerDelegate - Location updates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
}

@end
