//
//  SmartCalAppDelegate.m
//  SmartPlan
//
//  Created by Huy Le on 10/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "SmartCalAppDelegate.h"

#import "SmartListViewController.h"

#import "CalendarViewController.h"

#import "SDNavigationController.h"

#import "Common.h"

#import "TaskManager.h"
#import "ProjectManager.h"
#import "ContactManager.h"
#import "DBManager.h"
#import "TaskLinkManager.h"
#import "MusicManager.h"
#import "AlertManager.h"
#import "ImageManager.h"
#import "BusyController.h"
#import "Task.h"

#import "TagDictionary.h"

#import "Settings.h"

#import "ProgressIndicatorView.h"

#import "EKSync.h"
#import "TDSync.h"
#import "SDWSync.h"

#import "GTMBase64.h"

#import "SmartDayViewController.h"
#import "CalendarViewController.h"

#import "TestFlight.h"

SmartCalAppDelegate *_appDelegate;

SmartDayViewController *_sdViewCtrler = nil;

extern CalendarViewController *_sc2ViewCtrler;

NSInteger _gmtSeconds; 

BOOL _scFreeVersion = NO;
BOOL _is24HourFormat = NO;
BOOL _appDidStartup = NO;

BOOL _navigationTabChanged = NO;
BOOL _fromBackground = NO;

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"top_bg.png"];
    [img drawInRect:rect];
}

@end

@implementation SmartCalAppDelegate

@synthesize window;
//@synthesize tabBarController;

- (BOOL)check24HourFormat
{
    /*
	//*Trung 08102101
	[NSDateFormatter setDefaultFormatterBehavior:NSNumberFormatterBehavior10_4];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

	NSDate *date = [NSDate date];
	
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	
	[dateFormatter release];
	
	NSRange range;
	
	range.location = formattedDateString.length - 2;
	
	range.length = 2;
	
	NSString *tail = [formattedDateString substringWithRange:range];
	
	if ([tail isEqualToString:@"AM"] || [tail isEqualToString:@"PM"] || [tail isEqualToString:@"am"] || [tail isEqualToString:@"pm"])
	{
		return NO;
	}
	
	return YES;
	//Trung 08102101*
    */
    
    /*
	NSDateFormatter *testFormatter = [[NSDateFormatter alloc] init];
	[testFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *testTime = [testFormatter stringFromDate:[NSDate date]];
	[testFormatter release];
	BOOL format12 = [testTime hasSuffix:@"M"] || [testTime hasSuffix:@"m"];
    
    return !format12;
    */
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    [formatter release];
    
    return is24h;
}

/*
- (void) showProgress:(NSString *)str
{
	if (!progressView.superview)
	{
		[progressView setText:str];
		
		//[progressView showInView:tabBarController.view];
	}
}

- (void) hideProgress
{
	if (progressView.superview)
	{
		[progressView hide]; 
		[progressView removeFromSuperview];
		
	}
}
*/

- (void) showBusyIndicator:(BOOL)enable
{
	if (enable)
	{
		if (![busyIndicatorView superview])
		{
            //printf("add busyIndicator\n");
            
            [self.window addSubview: busyIndicatorView];			
		}
        
        [busyIndicatorView performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];        
	}
	else
	{
		[busyIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        
        if ([busyIndicatorView superview])
        {
            [busyIndicatorView removeFromSuperview];
        }
	}
    
    //[_focusViewCtrler showBusyIndicator:enable];
}

- (void)startup
{
    Settings *settings = [Settings getInstance];
    
    //[_sdViewCtrler clearStartupFlags];
    
	//////NSLog(@"begin start up");
	[TaskManager startup];

	//[self hideProgress];
	
	autoSyncPending = ((settings.ekSyncEnabled && settings.ekAutoSyncEnabled) || (settings.tdSyncEnabled && settings.tdAutoSyncEnabled) || (settings.sdwSyncEnabled && settings.sdwAutoSyncEnabled)) && !openByURL;
    
    [self performSelectorInBackground:@selector(check2AutoSync) withObject:nil]; 
    
    [_sdViewCtrler.miniMonthView performSelector:@selector(initCalendar:) withObject:[NSDate date] afterDelay:0];
    
    //[_sdViewCtrler performSelector:@selector(showFocusView) withObject:nil afterDelay:0];
	
	_appDidStartup = YES;
	
	//////NSLog(@"end start up");
}

- (void)recover
{
    if (!openByURL)
    {
        [self performSelectorOnMainThread:@selector(dismissAllAlertViews) withObject:nil waitUntilDone:NO];
    }
    
    Settings *settings = [Settings getInstance];
    
    [settings clearHintFlags];
    
    //[_sdViewCtrler clearStartupFlags];
	
	[DBManager startup];
	
	[[TaskManager getInstance] recover];
    
	autoSyncPending = ((settings.ekSyncEnabled && settings.ekAutoSyncEnabled) || (settings.tdSyncEnabled && settings.tdAutoSyncEnabled) || (settings.sdwSyncEnabled && settings.sdwAutoSyncEnabled)) && !openByURL;
    
    [self performSelectorInBackground:@selector(check2AutoSync) withObject:nil];
    
    [_sdViewCtrler.miniMonthView performSelector:@selector(initCalendar:) withObject:[NSDate date] afterDelay:0];
    [_sdViewCtrler performSelector:@selector(popupHint) withObject:nil afterDelay:0];
	
	//[self hideProgress];
    
    //[_sdViewCtrler performSelector:@selector(showFocusView) withObject:nil afterDelay:0];    
	
	////NSLog(@"end recover...");
}

- (void) autoSync
{
    Settings *settings = [Settings getInstance];
    
    if (settings.ekSyncEnabled && settings.ekAutoSyncEnabled)
    {
        [[EKSync getInstance] initBackgroundAuto2WaySync];
    }
    else if (settings.tdSyncEnabled && settings.tdAutoSyncEnabled)
    {
        [[TDSync getInstance] initBackgroundAuto2WaySync];
    }
    else if (settings.sdwSyncEnabled && settings.sdwAutoSyncEnabled)
    {
        [[SDWSync getInstance] initBackgroundAuto2WaySync];
    }
    
    [_sdViewCtrler deselect];
}

- (void) confirmAutoSync
{
	if (autoSyncPending)
	{
        if (launchFromBackground)
        {
            [self autoSync];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncNowTitle  message:_syncNowText delegate:self cancelButtonTitle:_noText otherButtonTitles:nil];
            alertView.tag = -10001;
            
            [alertView addButtonWithTitle:_yesText];
            [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            [alertView release];            
        }
        
        autoSyncPending = NO;
	}
}

- (void) check2AutoSync
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    TaskManager *tm = [TaskManager getInstance];
    
    [tm wait4ThumbPlannerInitComplete];
    
    [tm wait4SortComplete];
    
    [tm wait4ScheduleGBComplete];
    
    [self confirmAutoSync];
    
    [pool release];
    
}

- (void) createCustomMenuItems
{
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
    UIMenuItem *doneItem = [[UIMenuItem alloc] initWithTitle:_doneText action:@selector(done:)];
    UIMenuItem *duplicateItem = [[UIMenuItem alloc] initWithTitle:_duplicateText action:@selector(duplicate:)];
    UIMenuItem *doTodayItem = [[UIMenuItem alloc] initWithTitle:_doTodayText action:@selector(doToday:)];
    UIMenuItem *copyLinkItem = [[UIMenuItem alloc] initWithTitle:_copyLinkText action:@selector(copyLink:)];
	UIMenuItem *pasteLinkItem = [[UIMenuItem alloc] initWithTitle:_pasteLinkText action:@selector(pasteLink:)];	
    UIMenuItem *editLinksItem = [[UIMenuItem alloc] initWithTitle:_editLinksText action:@selector(editLinks:)];	

	NSArray *menuItems = [NSArray arrayWithObjects:doneItem, duplicateItem, doTodayItem, copyLinkItem, pasteLinkItem, editLinksItem, nil];
    
    [doneItem release];
    [duplicateItem release];
    [doTodayItem release];
    [copyLinkItem release];
    [pasteLinkItem release];
    [editLinksItem release];
	
	menuCtrler.menuItems = menuItems;
}

- (void) dismissAllAlertViews
{
    for( UIView* subview in [UIApplication sharedApplication].keyWindow.subviews ) {
        if( [subview isKindOfClass:[UIAlertView class]] ) {
            ////NSLog( @"Alert is showing" );
            
            UIAlertView *alertView = (UIAlertView *) subview;
            
            [alertView dismissWithClickedButtonIndex:-1 animated:NO];
        }
    }    
}

//- (void)applicationDidFinishLaunching:(UIApplication *)application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //[self test];
#ifdef _SC_FREE
	_scFreeVersion = YES;
#endif
   
/*
#ifdef BETA
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"355eb4e79b186d1df348beced4c96847_MTI0MDMwMjAxMi0wOC0yMiAxMDowNToyMy4wOTg3NDk"];
    
    UIAlertView *testFlightAlertView = [[UIAlertView alloc] initWithTitle:@""  message:@"TestFlight is enabled" delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    
    [testFlightAlertView show];
    [testFlightAlertView release];
    
#endif
*/

	_is24HourFormat = [self check24HourFormat];
	_gmtSeconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
		
	[MusicManager startup];
	
    [Settings startup];
	
	[DBManager startup];
	
	[TagDictionary startup];
	
	[ProjectManager startup];
	
    busyIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 30, 20, 20)];
	
	[self createCustomMenuItems];

    _sdViewCtrler = [[SmartDayViewController alloc] init];
    
    navController = [[SDNavigationController alloc] initWithRootViewController:_sdViewCtrler];
    
    [window setRootViewController:navController];
    
    [window makeKeyAndVisible];
	
	_appDelegate = self;
	
	callReceived = NO;
	
	openByURL = NO;
	
	//OS4 Support	
	_fromBackground = NO;
	
	UIDevice* device = [UIDevice currentDevice]; 
	backgroundSupported = NO; 
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	
	//[self showProgress:_loadingText];
	
	[self performSelector:@selector(startup) withObject:nil afterDelay:0];
	
	//////NSLog(@"did finish lauching");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	callReceived = YES;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	_fromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//////printf("applicationDidBecomeActive ...");
		
	//[self showProgress:_loadingText];
	
	callReceived = NO;
	
	_is24HourFormat = [self check24HourFormat];
    
    launchFromBackground = NO;
		
	if (_fromBackground)
	{
		//////printf("recovering ...");
        launchFromBackground = YES;
        
		_fromBackground = NO;
		
		//[self showProgress:_loadingText];
		
		//tabBarController.view.userInteractionEnabled = NO;
        
		[self performSelector:@selector(recover) withObject:nil afterDelay:0];

	}
    
    //FocusViewController *ctrler = [[FocusViewController alloc] init];
    
    //[_tabBarCtrler presentModalViewController:ctrler withPushDirection:kCATransitionFromBottom];
    
    //[ctrler release];
	
	//////NSLog(@"did become active");
	
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
}

- (void) purge
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	/*
	if ([[Settings getInstance] ekAutoSyncEnabled])
	{
		[[EKSync getInstance] initSync:SYNC_AUTO_1WAY];
	}
	*/
    
    //[_sdViewCtrler.navigationController popToRootViewControllerAnimated:NO];
	
	DBManager *dbm = [DBManager getInstance];

	[dbm cleanTasksToDate:[Common dateByAddNumMonth:-1 toDate:[NSDate date]]];
	
	if ([dbm checkNeedResort])
	{
		NSMutableArray *list = [dbm getAllTasks];
		
		NSInteger c = 0;
		
		for (Task *task in list)
		{
			task.sequenceNo = c++;
			[task updateSeqNoIntoDB:[dbm getDatabase]];
		}
	}
	
	[DBManager free];
	
	[pool release];
	
	[ImageManager free];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [_sdViewCtrler deselect];
    
	[[TagDictionary getInstance] saveDict];
	
	[[Settings getInstance] saveDayManager]; //save change of DayManager

	UIApplication*	app = [UIApplication sharedApplication];
	
	////NSLog(@"background time to run: %f", app.backgroundTimeRemaining); 
	
	bgTask = [app beginBackgroundTaskWithExpirationHandler:^{ 
		// Synchronize the cleanup call on the main thread in case 
		// the task actually finishes at around the same time. 
		dispatch_async(dispatch_get_main_queue(), ^{
			if (bgTask != UIBackgroundTaskInvalid) {
				[app endBackgroundTask:bgTask]; 
				bgTask = UIBackgroundTaskInvalid;
			}			
		}); 
	}];
	
	// Start the long-running task and return immediately.
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Do the work associated with the task.
		[self purge];
		// Synchronize the cleanup call on the main thread in case 
		// the expiration handler is fired at the same time. 
		dispatch_async(dispatch_get_main_queue(), ^{
			if (bgTask != UIBackgroundTaskInvalid) {
				[app endBackgroundTask:bgTask]; 
				bgTask = UIBackgroundTaskInvalid;
			}			
		});		
		
	});		
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification 
{
    UIApplicationState state = [application applicationState];
    if (state != UIApplicationStateInactive) 
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_alertText
												   message:notification.alertBody 
												  delegate:self
										 cancelButtonTitle:_okText
										 otherButtonTitles:nil];
		[alertView show];
		[alertView release];		
	}
    
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[TaskManager free];
	[ProjectManager free];
	[ContactManager free];
	[Settings free];
	[DBManager free];
    [TaskLinkManager free];
	
	[MusicManager free];
	[AlertManager free];
	[ImageManager free];
	[BusyController free];
	
	//[progressView release];
    
    [busyIndicatorView release];
    
    [_sdViewCtrler release];
    
    [navController release];
    
    //[window release];
    self.window = nil;
    
    [super dealloc];
}

- (void) test
{
    NSDate *today = [NSDate date];
    
    //printf("weeks of this month: %d\n", [Common getWeeksInMonth:today]);
    
    today = [Common dateByAddNumMonth:1 toDate:today];

    //printf("weeks of next month: %d\n", [Common getWeeksInMonth:today]);
    
    CGSize screen = [Common getScreenSize];
    
    //printf("screen width: %f - height: %f\n", screen.width, screen.height);

}

#pragma mark Backup/Restore
+ (void)backupDB
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dBPath = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
    if([fileManager fileExistsAtPath:dBPath]){
		NSData *fileData = [NSData dataWithContentsOfFile:dBPath];
		NSString *versionString = [[Settings getInstance] dbVersion];
		NSString *encodedString = [GTMBase64 stringByWebSafeEncodingData:fileData padded:YES];
		
		NSString *appLinkStr= [[NSString stringWithFormat: @"Hi,\n Your SmartDay database has been backed up into this mail successfully!<br/><br/> <a href=\"SmartDay://localhost/importDatabase?version=%@;data=%@\"",versionString,encodedString] 
							   stringByAppendingString:[[NSString stringWithFormat: @">Tap here to restore the backed up database."]
														stringByAppendingString:@"</a><br/><br/>Thanks for using SmartDay!"]];
		
		////printf("link :%s\n", [appLinkStr UTF8String]);
		
		NSString *bodyStr = [[NSString stringWithFormat:@"mailto:?subject=SmartDay - Data backup: "] stringByAppendingString:[NSString stringWithFormat:@"%@&body=%@",[Common getDateTimeString:[NSDate date]],appLinkStr]];
		
		NSString *encoded =[bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		//		//printf("\n\n\n after endcoding: %s",[encoded UTF8String]);
		NSURL *url = [[NSURL alloc] initWithString:encoded];
		
		BOOL success=NO;
		
		success=[[UIApplication sharedApplication] openURL:url];
		
		if(!success){
			UIAlertView *errorOpen=[[UIAlertView alloc] initWithTitle:@"Could not launch Mail app!" message:@"Either your device does not support Mail app or your database has problem inside." 
															 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[errorOpen show];
			[errorOpen release];
		}
		
		[url release];
	}
}

- (void)restoreDB:(NSURL *)url
{
	NSString *query = [url query];
	
	[url release];
	
	NSArray *components = [query componentsSeparatedByString:@";"];
	NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc] init];
	for (NSString *component in components) {
		[parametersDict setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
	}		
	
	NSString *dbVersion = [parametersDict objectForKey:@"version"];
	
    if (dbVersion) {
        //printf("imported db version: %s\n", [dbVersion UTF8String]);
        /*
         NSString *filename = @"SmartPlanDB_bk.sql";
         
         if ([dbVersion isEqualToString:[[Settings getInstance] dbVersion]])
         {
         filename = @"SmartPlanDB.sql";
         }
         */
        
        NSString *filename = @"SmartCalDB.sql";
        
        NSData *importUrlData = [GTMBase64 webSafeDecodeString:[parametersDict objectForKey:@"data"]];
        
        // NOTE: In practice you will want to prompt the user to confirm before you overwrite their files!
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *uniquePath = [documentsDirectory stringByAppendingPathComponent: filename];
        
        [importUrlData writeToFile:uniquePath atomically:YES];
        
        UIAlertView *finishedAlert=[[UIAlertView alloc] initWithTitle:_restoreDBFinishedTitle 
                                                              message:_restoreDBFinishedText 
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        finishedAlert.tag = -10000;
        [finishedAlert show];
        [finishedAlert release];
    }else {
        //restoring from old spad user
        NSData *importUrlData = [GTMBase64 webSafeDecodeString:query];
        
		NSString *filename = @"Database.sql";
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *uniquePath = [documentsDirectory stringByAppendingPathComponent: filename];
		
        NSError *err=nil;
		[importUrlData writeToFile:uniquePath options:NSAtomicWrite error:&err];
        
        
		UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:_restoreDBFinishedTitle 
												 message:_restoreDBFinishedText 
												delegate:self
									   cancelButtonTitle:@"OK"
									   otherButtonTitles:nil];
        alertView.tag = -10000;
		[alertView show];
		[alertView release];
    }
	
	
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{   
	openByURL = YES;
	
	if([@"/importDatabase" isEqual:[url path]]) 
	{
		UIAlertView *importAlert=[[UIAlertView alloc] initWithTitle:_restoreDBTitle 
															message:_restoreDBText 
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:nil];
		
		[url retain];
		importAlert.tag = url;
		
		[importAlert addButtonWithTitle:@"Ok"];
		[importAlert show];
		[importAlert release];
		
    } 
	else 
	{
		UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Restore backed up database failed!" 
														   message:@"Could not restore database from the backed up." 
														  delegate:self
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
	
    return YES;	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -10000 && buttonIndex == 0)
	{
		exit(0);
	}
	else if (alertView.tag == -10001 && buttonIndex == 1)
	{
		[self autoSync];
	}
	else if(buttonIndex == 1)
	{
		[self restoreDB:(NSURL *)alertView.tag];
	}
}

@end
