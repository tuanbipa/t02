//
//  SmartCalAppDelegate.h
//  SmartPlan
//
//  Created by Huy Le on 10/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface SmartCalAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
	
	UINavigationController *navController;
    
	BOOL callReceived;
		
	BOOL backgroundSupported;
	
	BOOL openByURL;
	
    UIActivityIndicatorView *busyIndicatorView;
	
	UIBackgroundTaskIdentifier bgTask;
	
	BOOL autoSyncPending;
    BOOL launchFromBackground;
    
    // location check
    CLLocationManager *locationManager;
    NSTimer *locationTimer;
    NSInteger geoItemCount;
    NSInteger taskLocationNumber;
    
    //dispatch_group_t geocodeDispatchGroup;
    NSOperationQueue * geocodeQueue;
    dispatch_semaphore_t geocodingLock;
    
    NSMutableString *notifyStr;
    BOOL locationUpdating;
    UILocalNotification *geoLocalNotification;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) NSMutableDictionary *alertDict;

- (void) showBusyIndicator:(BOOL)enable;

- (void) showFocusPane;

- (void) dismissAllAlertViews;

+ (void)backupDB;

- (void)disableGeoFencing;
- (void)startGeoFencing: (NSInteger)interval;
@end

