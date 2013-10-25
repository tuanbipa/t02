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
#import "Task.h"
#import "Project.h"
#import "AlertData.h"

#import "TaskManager.h"
#import "ProjectManager.h"
#import "ContactManager.h"
#import "DBManager.h"
#import "TaskLinkManager.h"
#import "MusicManager.h"
#import "AlertManager.h"
#import "ImageManager.h"
#import "BusyController.h"
#import "TimerManager.h"
#import "URLAssetManager.h"
#import "TagDictionary.h"
#import "CommentManager.h"

#import "Settings.h"

#import "ProgressIndicatorView.h"

#import "EKSync.h"
#import "TDSync.h"
#import "SDWSync.h"
#import "EKReminderSync.h"

#import "GTMBase64.h"

#import "SmartDayViewController.h"
#import "CalendarViewController.h"

#import "iPadSmartDayViewController.h"
#import "AbstractSDViewController.h"
#import "iPadViewController.h"

#import "SDApplication.h"

#import "TestFlight.h"

// 1000 * 60 * 5
//#define GEOCODE_FENCING_TIME 30.0

SmartCalAppDelegate *_appDelegate;

SmartDayViewController *_sdViewCtrler = nil;
iPadSmartDayViewController *_iPadSDViewCtrler = nil;
AbstractSDViewController *_abstractViewCtrler = nil;

iPadViewController *_iPadViewCtrler;

extern CalendarViewController *_sc2ViewCtrler;

BOOL _isiPad = NO;
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

@synthesize alertDict;
//@synthesize tabBarController;

- (BOOL)check24HourFormat
{
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

- (BOOL) checkiPad {
	if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)])
		return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

	return NO;
}

/*
- (void) transformBusyIndicator
{
    if (_iPadViewCtrler.interfaceOrientation == UIInterfaceOrientationPortrait)
        busyIndicatorView.transform      = CGAffineTransformIdentity;
    else if (_iPadViewCtrler.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        busyIndicatorView.transform      = CGAffineTransformMakeRotation(-M_PI);
    else if (UIInterfaceOrientationIsLandscape(_iPadViewCtrler.interfaceOrientation))
    {
        float rotate    = ((_iPadViewCtrler.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ? -1:1) * (M_PI / 2.0);
        busyIndicatorView.transform      = CGAffineTransformMakeRotation(rotate);
        busyIndicatorView.transform      = CGAffineTransformTranslate(busyIndicatorView.transform, 0, -busyIndicatorView.frame.origin.y);
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
            
            //[self.window addSubview: busyIndicatorView];
            
            if (_isiPad)
            {
                [_iPadViewCtrler.navigationController.navigationBar addSubview:busyIndicatorView];
            }
            else
            {
                [_sdViewCtrler.navigationController.navigationBar addSubview:busyIndicatorView];
            }
		}

        dispatch_async(dispatch_get_main_queue(),^ {
            [busyIndicatorView startAnimating];
        });
	}
	else
	{
        dispatch_async(dispatch_get_main_queue(),^ {
            [busyIndicatorView stopAnimating];
            
            if ([busyIndicatorView superview])
            {
                [busyIndicatorView removeFromSuperview];
            }
        });
	}
}

- (void) testZone
{
    Settings *settings = [Settings getInstance];
    
    NSMutableArray *zones = [NSMutableArray arrayWithArray:[[[[Settings getInstance] timeZoneDict] objectEnumerator] allObjects]];
    
    NSDictionary *zoneDict = [NSDictionary dictionaryWithObjects:zones forKeys:zones];
    
    NSArray *list = [NSTimeZone knownTimeZoneNames];
    
    printf("zone num: %d - %d\n", list.count, zones.count);
    
    for (NSString *s in list)
    {
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:s];
        
        NSInteger hour = abs(tz.secondsFromGMT)/3600;
        NSInteger minute = (abs(tz.secondsFromGMT) - hour*3600)/60;
        
        NSString *prefix = [NSString stringWithFormat:@"(GMT%@%02d%02d)",tz.secondsFromGMT<0?@"-":@"+",hour, minute];
        
        NSString *query = [NSString stringWithFormat:@"%@ %@", prefix, s];
        
        NSString *zone = [zoneDict objectForKey:query];
        
        if (zone == nil)
        {
            printf("zone: %s NOT FOUND\n", [query UTF8String]);
        }
        else
        {
            printf("%s map to %s\n", [s UTF8String], [zone UTF8String]);
            
            [zones removeObject:zone];
        }
    }
    
/*
    printf("TimeZones NOT Support: %d\n", zones.count);
    for (NSString *zone in zones)
    {
        printf("%s\n", [zone UTF8String]);
    }
    printf("\n\n");
*/
    
    //check offset
    
    NSArray *keys = [settings.timeZoneDict allKeys];
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:keys.count];
    
    for (NSNumber *key in keys)
    {
        NSInteger offset = [Common getSecondsFromTimeZoneID:[key intValue]];
        
        NSInteger hour = abs(offset)/3600;
        NSInteger minute = (abs(offset) - hour*3600)/60;
        
        NSString *prefix = [NSString stringWithFormat:@"(GMT%@%02d%02d)",offset<0?@"-":@"+",hour, minute];
        
        NSString *name = [settings.timeZoneDict objectForKey:key];
        
        [names addObject:name];
        
        if (![[name substringToIndex:10] isEqualToString:prefix])
        {
            printf("zone %s - ID incorrect - prefix: %s\n", [name UTF8String], [prefix UTF8String]);
        }
    }
    
    NSDictionary *nameDict = [NSDictionary dictionaryWithObjects:keys forKeys:names];
    
    printf("TimeZones NOT Support: %d\n", zones.count);
    for (NSString *zone in zones)
    {
        NSNumber *key = [nameDict objectForKey:zone];
        //printf("%d,", [key intValue]);
        printf("%d, %s\n", [key intValue], [zone UTF8String]);
    }
    printf("\n\n");
    
    NSInteger tokyoID = 40264;
    
    NSInteger secs = [Common getSecondsFromTimeZoneID:tokyoID];
    
    NSInteger hour = abs(secs)/3600;
    NSInteger minute = (abs(secs) - hour*3600)/60;
    
    NSString *prefix = [NSString stringWithFormat:@"(GMT%@%02d%02d)",secs<0?@"-":@"+",hour, minute];

    printf("Tokyo offset: %s\n", [prefix UTF8String]);
    
}

- (void) testSound
{
	NSError *error = nil;
	
    NSString *path = [[NSBundle mainBundle] pathForResource:@"close" ofType:@"mp3"];
    
	// Initialize the AVAudioPlayer
	AVAudioPlayer *player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error] autorelease];
    //player.delegate = self;
    
    if (error != nil)
    {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    [player prepareToPlay];
    
	// Set the number of times this music should repeat.  -1 means never stop until its asked to stop
	[player setNumberOfLoops:0];
	
	float backgroundMusicVolume = 1.0f;
	// Set the volume of the music
	[player setVolume:backgroundMusicVolume];
	
	// Play the music
	[player play];
}

- (void)startup
{
    Settings *settings = [Settings getInstance];
    
	[[TaskManager getInstance] initData];
    
    [[AlertManager getInstance] generateAlerts];
	
    autoSyncPending = settings.autoSyncEnabled && !openByURL;
    
    //[self performSelectorInBackground:@selector(check2AutoSync) withObject:nil];
    
    [_abstractViewCtrler.miniMonthView performSelector:@selector(initCalendar:) withObject:[NSDate date] afterDelay:0];

    //[_abstractViewCtrler.miniMonthView initCalendar:[NSDate date]];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self check2AutoSync];
    });
    
	_appDidStartup = YES;
}

- (void)recover
{
    if (!openByURL)
    {
        [self performSelectorOnMainThread:@selector(dismissAllAlertViews) withObject:nil waitUntilDone:NO];
    }
    
    Settings *settings = [Settings getInstance];
    
    [settings clearHintFlags];
	
	//[DBManager startup];
	
	[[TaskManager getInstance] recover];
    
    [[AlertManager getInstance] generateAlerts];
    
    [TimerManager startup];
    
    autoSyncPending = settings.autoSyncEnabled && !openByURL;
    
    //[self performSelectorInBackground:@selector(check2AutoSync) withObject:nil];

    //[_abstractViewCtrler.miniMonthView performSelector:@selector(initCalendar:) withObject:[NSDate date] afterDelay:0];

    //[_abstractViewCtrler.miniMonthView initCalendar:[NSDate date]];
    
    [[[AbstractActionViewController getInstance] getMiniMonth] performSelector:@selector(initCalendar:) withObject:[NSDate date] afterDelay:0];
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [self check2AutoSync];
    });
    
    /*
    if (_sdViewCtrler != nil)
    {
        [_sdViewCtrler performSelector:@selector(popupHint) withObject:nil afterDelay:0];
    }*/
}

- (void) autoSync
{
    Settings *settings = [Settings getInstance];
    
    [[AbstractActionViewController getInstance] performSelectorOnMainThread:@selector(deselect) withObject:nil waitUntilDone:NO];
    
    if (settings.autoSyncEnabled)
    {
        if (settings.sdwSyncEnabled)
        {
            [[SDWSync getInstance] initBackgroundAuto2WaySync];
        }
        else if (settings.ekSyncEnabled)
        {
            [[EKSync getInstance] initBackgroundAuto2WaySync];
        }
        else if (settings.tdSyncEnabled)
        {
            [[TDSync getInstance] initBackgroundAuto2WaySync];
        }
        else if (settings.rmdSyncEnabled)
        {
            [[EKReminderSync getInstance] initBackgroundAuto2WaySync];
        }
    }
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
    
    //[tm wait4ThumbPlannerInitComplete];
    
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
    UIMenuItem *createTaskItem = [[UIMenuItem alloc] initWithTitle:_createTask action:@selector(createTask:)];

	NSArray *menuItems = [NSArray arrayWithObjects:doneItem, duplicateItem, doTodayItem, copyLinkItem, pasteLinkItem, editLinksItem, createTaskItem, nil];
    
    [doneItem release];
    [duplicateItem release];
    [doTodayItem release];
    [copyLinkItem release];
    [pasteLinkItem release];
    [editLinksItem release];
    [createTaskItem release];
	
	menuCtrler.menuItems = menuItems;
}

- (void) dismissAllAlertViews
{
    for( UIView* subview in [UIApplication sharedApplication].keyWindow.subviews ) {
        if( [subview isKindOfClass:[UIAlertView class]] ) {
            ////NSLog( @"Alert is showing" );
            
            UIAlertView *alertView = (UIAlertView *) subview;
            
            if (alertView.tag > -50000)
            {
                [alertView dismissWithClickedButtonIndex:-1 animated:NO];
            }
        }
    }
    
    /*
    for (UIWindow* w in [UIApplication sharedApplication].windows)
        for (NSObject* o in w.subviews)
            if ([o isKindOfClass:[UIAlertView class]])
            {
                [(UIAlertView*)o dismissWithClickedButtonIndex:[(UIAlertView*)o cancelButtonIndex] animated:YES];
            }*/

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    //NSLog(@"########### Received Background Fetch ###########");
    
    [[SDWSync getInstance] initSyncComments];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//- (void)applicationDidFinishLaunching:(UIApplication *)application
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[self testSound];
    _isiPad = [self checkiPad];
	_is24HourFormat = [self check24HourFormat];

    //[[UINavigationBar appearance] setTintColor:(_isiPad?nil:[UIColor whiteColor])];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setTintColor:[UIColor blueColor]];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];

    [[UITableViewHeaderFooterView appearance] setTintColor:[[Colors slateGray] colorWithAlphaComponent:0.2]];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

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
    self.alertDict = [NSMutableDictionary dictionaryWithCapacity:5];
		
	[MusicManager startup];
	
    [Settings startup];
	
	[DBManager startup];
	
	[TagDictionary startup];
	
	[ProjectManager startup];
    
    [TimerManager startup];
    
    [TaskManager startup];
    
    _versionUpgrade = NO;
    _dbUpgrade = NO;
    
    //[self testZone];
	
    //busyIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(200, 20, 20, 20)];
    busyIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    busyIndicatorView.frame = CGRectMake(_isiPad?320:60, 10, 20, 20);
    //busyIndicatorView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    //busyIndicatorView.center = self.window.center;
    
	//[self createCustomMenuItems];
    
    if (_isiPad)
    {
        _iPadSDViewCtrler = [[iPadSmartDayViewController alloc] init];
    }
    else
    {
        _sdViewCtrler = [[SmartDayViewController alloc] init];
    }
    
    _abstractViewCtrler = _isiPad?_iPadSDViewCtrler:_sdViewCtrler;
    
    UIViewController *ctrler = (_isiPad?[[[iPadViewController alloc] init] autorelease]:_sdViewCtrler);
    
    navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    
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
	
	[self performSelector:@selector(startup) withObject:nil afterDelay:0];
	//[self startup];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:2];
    }

	//////NSLog(@"did finish lauching");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	callReceived = YES;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    SDApplication *app = [UIApplication sharedApplication];
    
    [app cancelAutoSync];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	_fromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//////printf("applicationDidBecomeActive ...");
    
	callReceived = NO;
	
	_is24HourFormat = [self check24HourFormat];
    
    launchFromBackground = NO;
		
	if (_fromBackground)
	{
		//////printf("recovering ...");
        launchFromBackground = YES;
        
		_fromBackground = NO;
		
		[self performSelector:@selector(recover) withObject:nil afterDelay:0];

	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentUpdateNotification" object:nil];
    
	//////NSLog(@"did become active");
	
    // geo-fencing
    Settings *setting = [Settings getInstance];
    if (setting.geoFencingEnable) {
        
        [self startGeoFencing:setting.geoFencingInterval];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void) purge
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
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
	
	//[DBManager free];
	
	[pool release];
	
	[ImageManager free];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //[_abstractViewCtrler deselect];
    [[[AbstractActionViewController getInstance] getActiveModule] cancelMultiEdit];
    [[AbstractActionViewController getInstance] deselect];
    
	[[TagDictionary getInstance] saveDict];
	
	[[Settings getInstance] saveDayManager]; //save change of DayManager
    
    [[TimerManager getInstance] interrupt];
    
    [[BusyController getInstance] reset];

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
    NSNumber *alertKeyNum = [notification.userInfo objectForKey:@"alertKey"];
    
    if (alertKeyNum != nil)
    {
        [[MusicManager getInstance] playSound:SOUND_ALARM];
        
        DBManager *dbm = [DBManager getInstance];
        
        AlertData *dat = [[AlertData alloc] initWithPrimaryKey:[alertKeyNum intValue] database:[dbm getDatabase]];
        
        Task *task = [[Task alloc] initWithPrimaryKey:dat.taskKey database:[dbm getDatabase]];
        
        UIAlertView *alertView = [task isTask]?
                                        [[UIAlertView alloc] initWithTitle:_alertText
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:_okText
                                                                otherButtonTitles:_snooze, _postpone, nil]:
                                        [[UIAlertView alloc] initWithTitle:_alertText
                                                                   message:notification.alertBody
                                                                  delegate:self
                                                         cancelButtonTitle:_okText
                                                         otherButtonTitles:_snooze, nil];
        alertView.tag = -60000-dat.taskKey;
        
        [self.alertDict setObject:notification forKey:[NSNumber numberWithInt:alertView.tag]];

        
        [alertView show];
        [alertView release];
        
        [dat release];
        [task release];
    }
    else if (notification.alertBody && [notification.alertBody length] > 0)
    {
        [self showGeoAlertWithBody:notifyStr];
    }
    else
    {
        NSString *test = [notification.userInfo objectForKey:@"CommentListKey"];
        
        if (test != nil)
        {
            printf("remove notification\n");
            
            [[CommentManager getInstance] show:notification];
        }
    }
    
    //application.applicationIconBadgeNumber = 0;
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
   //[[AlertManager getInstance] generateAlerts];
}

/*
- (void) application:(UIApplication *)application
willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation
            duration:(NSTimeInterval)duration
{
    if (newStatusBarOrientation == UIInterfaceOrientationPortrait)
        busyIndicatorView.transform      = CGAffineTransformIdentity;
    else if (newStatusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
        busyIndicatorView.transform      = CGAffineTransformMakeRotation(-M_PI);
    else if (UIInterfaceOrientationIsLandscape(newStatusBarOrientation))
    {
        float rotate    = ((newStatusBarOrientation == UIInterfaceOrientationLandscapeLeft) ? -1:1) * (M_PI / 2.0);
        busyIndicatorView.transform      = CGAffineTransformMakeRotation(rotate);
        busyIndicatorView.transform      = CGAffineTransformTranslate(busyIndicatorView.transform, 0, -busyIndicatorView.frame.origin.y);
    }
}
*/
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[TaskManager free];
	[ProjectManager free];
	[ContactManager free];
	[Settings free];
	[DBManager free];
    [TaskLinkManager free];
    [TimerManager free];
	[URLAssetManager free];
    [TagDictionary free];
	[MusicManager free];
	[AlertManager free];
	[ImageManager free];
	[BusyController free];
    [CommentManager free];
    
    [EKSync free];
    [SDWSync free];
    [TDSync free];
    [EKReminderSync free];
    
    [busyIndicatorView release];
    
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler release];
    }
    
    [navController release];
    
    self.alertDict = nil;
    self.window = nil;
    
    [self deactiveLocationManager];
    [self deactiveLocationTimer];
    if (geoLocalNotification != nil) {
        [geoLocalNotification release];
    }
    if (notifyStr != nil) {
        [notifyStr release];
    }
    
    [super dealloc];
}

/*
- (void) test
{
    NSDate *today = [NSDate date];
    
    //printf("weeks of this month: %d\n", [Common getWeeksInMonth:today]);
    
    today = [Common dateByAddNumMonth:1 toDate:today];

    //printf("weeks of next month: %d\n", [Common getWeeksInMonth:today]);
    
    //CGSize screen = [Common getScreenSize];
    
    //printf("screen width: %f - height: %f\n", screen.width, screen.height);

}
*/

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
    Settings *settings = [Settings getInstance];
    DBManager *dbm = [DBManager getInstance];
    
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
        
        if ([dbVersion isEqualToString:@"4.0"] && [settings.dbVersion isEqualToString:@"5.0"])
        {
            _dbUpgrade = YES;
        }
        
        [DBManager startup];
        
        _dbUpgrade = NO;
        
        [[AbstractActionViewController getInstance] resetAllData];
        
        /*
        UIAlertView *finishedAlert=[[UIAlertView alloc] initWithTitle:_restoreDBFinishedTitle 
                                                              message:_restoreDBFinishedText 
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        finishedAlert.tag = -10000;
        [finishedAlert show];
        [finishedAlert release];*/
    }
	
    //exit(0);
	
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
		
		//[url retain];
        [self.alertDict setObject:url forKey:[NSNumber numberWithInt:-50000]];
		importAlert.tag = -50000;
		
		[importAlert addButtonWithTitle:@"Ok"];
		[importAlert show];
		[importAlert release];
		
    }
	else if([@"/shareData" isEqual:[url path]])
	{
        NSString *query = [url query];
        
        NSArray *components = [query componentsSeparatedByString:@";"];
        NSMutableDictionary *parametersDict = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            [parametersDict setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
        }
        
        NSString *dataStr = [parametersDict objectForKey:@"data"];
        
        dataStr = [dataStr stringByRemovingPercentEncoding];
        
        /*
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""
                                                      message:dataStr
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
		
		[alert show];*/
        
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSArray *tasks = [dict objectForKey:@"tasks"];
        
        Project *prj = [[Project alloc] init];
        [prj fromjson:dict];
        
        ProjectManager *pm = [ProjectManager getInstance];
        TaskManager *tm = [TaskManager getInstance];
        
        Project *checkPrj = [pm findProjectByName:prj.name];
        
        if (checkPrj == nil)
        {
            checkPrj = prj;
            [pm addProject:checkPrj];
        }
        
        for (NSDictionary *taskDict in tasks)
        {
            Task *task = [[Task alloc] init];
            
            [task fromjson:taskDict];
            
            task.project = checkPrj.primaryKey;
            
            [tm addTask:task];
            
            [task release];
        }
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

- (void) showPostponeOption:(UILocalNotification *)notif
{
    /*
    UIActionSheet *postponeActionSheet = [[UIActionSheet alloc] initWithTitle:_postpone delegate:self cancelButtonTitle:_cancelText destructiveButtonTitle:nil otherButtonTitles: _1DayText, _1WeekText, _1MonthText, nil];
    postponeActionSheet.tag = notif;
    
    [postponeActionSheet showInView:self.window];
    
    [postponeActionSheet release]; 
    */
    
    [self.alertDict setObject:notif forKey:[NSNumber numberWithInt:-50001]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_postpone
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:_1DayText, _1WeekText, _1MonthText,nil];
    alertView.tag = -50001;
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -10000)
	{
        if (buttonIndex == 0)
        {
            exit(0);
        }
	}
	else if (alertView.tag == -10001)
	{
        if (buttonIndex == 1)
        {
            [self autoSync];
        }
	}
    else if (buttonIndex >= 0)
    {
        NSNumber *key = [NSNumber numberWithInt:alertView.tag];
        
        NSObject *obj = [self.alertDict objectForKey:key];
        
        if (obj != nil)
        {
            [obj retain];
            
            [self.alertDict removeObjectForKey:key];
        }
        //BOOL remove = YES;
        
        if (obj != nil)
        {
            if ([obj isKindOfClass:[NSURL class]] && buttonIndex == 1)
            {
                [self restoreDB:(NSURL *)obj];
            }
            else if ([obj isKindOfClass:[UILocalNotification class]])
            {
                [[MusicManager getInstance] stopSound];
                
                if (alertView.tag == -50001) //postpone
                {
                    if (buttonIndex != 3)
                    {
                        [[AlertManager getInstance] postponeAlert:(UILocalNotification *)obj postponeType:buttonIndex];
                    }
                }
                else
                {
                    if (buttonIndex == 0)
                    {
                        [[AlertManager getInstance] stopAlert:(UILocalNotification *)obj];
                    }
                    else if (buttonIndex == 1)
                    {
                        [[AlertManager getInstance] snoozeAlert:(UILocalNotification *)obj];
                    }
                    else if (buttonIndex == 2)
                    {
                        //remove = NO;
                        
                        //[alertView dismissWithClickedButtonIndex:-1 animated:NO];
                        
                        //[self performSelector:@selector(showPostponeOption:) withObject:obj];
                        [self showPostponeOption:(UILocalNotification *)obj];
                    }                    
                }
            }
         
            //[self.alertDict removeObjectForKey:key];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //printf("index: %d\n", buttonIndex);
    
    NSObject *obj = [self.alertDict objectForKey:actionSheet.tag];
    
    if (obj != nil)
    {
        if (buttonIndex != 3)
        {
            [[AlertManager getInstance] postponeAlert:(UILocalNotification *)obj postponeType:buttonIndex];
        }
             
        [self.alertDict removeObjectForKey:obj];
    }
}

#pragma mark location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locationUpdating || taskLocationNumber > 0) {
        return;
    }
    locationUpdating = YES;
    [locationManager stopUpdatingLocation];
    
    isActiveGeoFencing = NO;
    BOOL isChangeLocation = NO;
    if (lastLocation != nil) {
        if ([[locations lastObject] distanceFromLocation:lastLocation] >= 400) {
            isChangeLocation = YES;
            [lastLocation release];
            lastLocation = [[locations lastObject] retain];
        }
    } else {
        isChangeLocation = YES;
        lastLocation = [[locations lastObject] retain];
    }
    
    //locationUpdating = YES;
    Settings *st = [Settings getInstance];
    isActiveGeoFencing = (st.geoFencingEnable && isChangeLocation);
    
    // get all tasks
    DBManager *dbm = [DBManager getInstance];
    NSMutableArray *tasks = [dbm getAllTasksEventsHaveLocation];
    taskLocationNumber = [tasks count];
    
    if (taskLocationNumber > 0) {
        // get placemark
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count > 0) {
                //[self geocodeAllItems:placemarks[0]];
                [self geocodeAllItems:tasks with:placemarks[0]];
            }
        }];
    }
    locationUpdating = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Geocoder Error");
    dispatch_semaphore_signal(geocodingLock);
    locationUpdating = NO;
    taskLocationNumber = 0;
    [locationManager stopUpdatingLocation];
}

- (void)deactiveLocationManager
{
    if (locationManager != nil) {
        [locationManager stopUpdatingLocation];
        [locationManager release];
        locationManager = nil;
    }
    
    if (lastLocation != nil) {
        [lastLocation release];
        lastLocation = nil;
    }
}

-(void) geocodeAllItems: (NSArray*)tasks with: (CLPlacemark*) currentPlacemark
{
    [notifyStr setString:@""];
    
    // do geo-fencing
    //CLLocation *location = [locations lastObject];
    CLGeocoder *gc = [[[CLGeocoder alloc] init] autorelease];
    
    /*dispatch_group_t geocodeDispatchGroup = dispatch_group_create();
     NSOperationQueue * geocodeQueue = [[NSOperationQueue alloc] init];
     dispatch_semaphore_t geocodingLock = dispatch_semaphore_create(1);*/
    
    /*geocodeDispatchGroup = dispatch_group_create();
     geocodeQueue = [[NSOperationQueue alloc] init];
     geocodingLock = dispatch_semaphore_create(1);*/
    geoItemCount = 0;
    
    taskLocationNumber = [tasks count];
    for (Task *task in tasks) {
        
        [geocodeQueue addOperationWithBlock:^{
            //NSLog(@"-Geocode Item-");
            
            [self geocodeItem:task withGeocoder:gc withPlacemark:currentPlacemark];
        }];
    }
}

- (void)geocodeItem:(Task *) task withGeocoder:(CLGeocoder *)gc withPlacemark: (CLPlacemark*) currentPlacemark{
    
    // geo each task
    if ([[task.location stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        // wait semaphore
        dispatch_semaphore_wait(geocodingLock, DISPATCH_TIME_FOREVER);
        
        [gc geocodeAddressString:task.location completionHandler:^(NSArray *placemarks, NSError *error) {
            dispatch_semaphore_signal(geocodingLock);
            taskLocationNumber--;
            
            if (placemarks.count > 0) {
                CLPlacemark *taskPlacemark = placemarks[0];
                CLLocation *taskLocation = taskPlacemark.location;
                
                if (isActiveGeoFencing && [currentPlacemark.location distanceFromLocation:taskLocation] <= 200) {
                    geoItemCount += 1;
                    // add to aler list
                    [notifyStr appendString:[NSString stringWithFormat:@"%d. %@\n",geoItemCount, task.name]];
                    
                    //NSLog(@"\n1. task name: %@", task.name);
                }
                
                if ([task isEvent] && (task.locationAlert == 1)) {
                    
                    // alert based on location
                    MKPlacemark *sourceMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:currentPlacemark];
                    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourceMapPlaceMark];
                    [sourceMapPlaceMark release];
                    
                    MKPlacemark *desMapPlaceMark = [[MKPlacemark alloc] initWithPlacemark:taskPlacemark];
                    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:desMapPlaceMark];
                    [desMapPlaceMark release];
                    
                    MKDirectionsRequest *req = [[MKDirectionsRequest alloc] init];
                    req.source = source;
                    req.destination = destination;
                    [source release];
                    [destination release];
                    
                    MKDirections *direction = [[MKDirections alloc] initWithRequest:req];
                    [req release];
                    [direction calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
                        if (error != nil) {
                            NSLog(@"%@", error.description);
                        } else {
                            NSTimeInterval eta = response.expectedTravelTime;
                            NSDate *dt = [NSDate date];
                            NSDate *alertTime = [task.startTime dateByAddingTimeInterval:  -(eta + 0.25*eta)];
                            if ([dt compare:alertTime] != NSOrderedAscending) {
                                // update task
                                DBManager *dbm = [DBManager getInstance];
                                task.locationAlert = 0;
                                [task updateLocationAlertIntoDB:[dbm getDatabase]];
                                [self showLocationAlert:task];
                            }
                        }
                    }];
                    [direction release];
                }
            }
            
            if (isActiveGeoFencing && taskLocationNumber == 0) {
                // push infor
                [self pushGeoInfor];
            }
        }];
    } else {
        taskLocationNumber--;
        if (isActiveGeoFencing && taskLocationNumber == 0) {
            // push infor
            [self pushGeoInfor];
        }
    }
}

- (void)pushGeoInfor
{
    //locationUpdating = NO;
    
    if ([notifyStr length] > 0) {
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
        {
            // show by local notification
            if (geoLocalNotification != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:geoLocalNotification];
            } else {
                geoLocalNotification = [[UILocalNotification alloc] init];
                //geoLocalNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            }
            geoLocalNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
            
            NSString *alertBody = [NSString stringWithFormat:_atCurrentLocationYouHave,geoItemCount];
            geoLocalNotification.alertBody = alertBody;
            //geoLocalNotification.userInfo = notifyStr;
            geoLocalNotification.timeZone = [NSTimeZone defaultTimeZone];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:geoLocalNotification];
            
            //[geoLocalNotification release];
        }
        else
        {
            [self showGeoAlertWithBody:notifyStr];
        }
    }
}

- (void)initGeoLocation
{
    [self deactiveLocationManager];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [self deactiveLocationTimer];
    
    //geocodeDispatchGroup = dispatch_group_create();
    geocodeQueue = [[NSOperationQueue alloc] init];
    geocodingLock = dispatch_semaphore_create(1);
    
    notifyStr = [[NSMutableString alloc] init];
    
    locationUpdating = NO;
    taskLocationNumber = 0;
}

- (void)showGeoAlertWithBody: (NSString*) alertBody
{
    // dismis old alert view
    [self dismissAllAlertViews];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_atCurrentLocationText
                                                    message:alertBody
                                                   delegate:self cancelButtonTitle:_okText
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showLocationAlert: (Task*)task
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        UILocalNotification *alertLocalNotification = [[UILocalNotification alloc] init];
        alertLocalNotification.alertBody = [NSString stringWithFormat:@"%@ '%@'",_itsTimeToDriveForText, task.name];
        alertLocalNotification.timeZone = [NSTimeZone defaultTimeZone];
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertLocalNotification];
        
        [alertLocalNotification release];
    }
    else
    {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_alertText
                                                        message:[NSString stringWithFormat:@"%@ '%@'",_itsTimeToDriveForText, task.name]
                                                       delegate:self cancelButtonTitle:_okText
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark Location timer

- (void)deactiveLocationTimer
{
    if (locationTimer != nil)
	{
		if ([locationTimer isValid])
		{
			[locationTimer invalidate];
		}
		
		locationTimer = nil;
	}
}

- (void)disableGeoFencing
{
    [self deactiveLocationTimer];
    [self deactiveLocationManager];
}

- (void)startGeoFencing: (NSInteger)interval
{
    [self initGeoLocation];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                     target:locationManager
                                                   selector:@selector(startUpdatingLocation)
                                                   userInfo:nil
                                                    repeats:YES];
}
@end
