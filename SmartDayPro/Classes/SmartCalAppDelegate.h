//
//  SmartCalAppDelegate.h
//  SmartPlan
//
//  Created by Huy Le on 10/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartCalAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    UIWindow *window;
	
	UINavigationController *navController;
    
	BOOL callReceived;
		
	BOOL backgroundSupported;
	
	BOOL openByURL;
	
    UIActivityIndicatorView *busyIndicatorView;
	
	UIBackgroundTaskIdentifier bgTask;
	
	BOOL autoSyncPending;
    BOOL launchFromBackground;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) NSMutableDictionary *alertDict;

- (void) showBusyIndicator:(BOOL)enable;

- (void) showFocusPane;

+ (void)backupDB;

@end

