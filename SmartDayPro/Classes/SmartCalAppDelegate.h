//
//  SmartCalAppDelegate.h
//  SmartPlan
//
//  Created by Huy Le on 10/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SmartDayPageViewController;

@class ProgressIndicatorView;

@interface SmartCalAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	//UITabBarController *tabBarController;
	
	UINavigationController *navController;
    
    //SmartDayPageViewController *smartDayViewCtrler;
	
	BOOL callReceived;
		
	BOOL backgroundSupported;
	
	BOOL openByURL;
	
	//ProgressIndicatorView *progressView;
    
    UIActivityIndicatorView *busyIndicatorView;
	
	UIBackgroundTaskIdentifier bgTask;
	
	BOOL autoSyncPending;
    BOOL launchFromBackground;
}

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

//- (void) showProgress:(NSString *)str;
//- (void) hideProgress;

- (void) showBusyIndicator:(BOOL)enable;

- (void) showFocusPane;

+ (void)backupDB;

@end

