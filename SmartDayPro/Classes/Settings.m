//
//  Settings.m
//  SmartPlan
//
//  Created by Huy Le on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

#import "Common.h"
#import "Colors.h"

#import "TaskManager.h"

#import "NSDataBase64.h"

Settings *_settingsSingleton = nil;

BOOL _evenMapHintShown = NO;
BOOL _smartListHintShown = NO;
BOOL _calendarHintShown = NO;
BOOL _noteHintShown = NO;
BOOL _weekViewHintShown = NO;
BOOL _weekDayQuickAddHintShown = NO;
BOOL _multiSelectHintShown = NO;
BOOL _monthViewHintShown = NO;
BOOL _rtDoneHintShown = NO;
BOOL _syncMatchHintShown = NO;
BOOL _projectHintShown = NO;
BOOL _projectDetailHintShown = NO;
BOOL _firstTimeEventSyncHintShown = NO;
BOOL _workingTimeHintShown = NO;
BOOL _starTabHintShown = NO;
BOOL _gtdoTabHintShown = NO;
BOOL _tagHintShown = NO;
BOOL _featureHintShown = NO;
BOOL _transparentHintShown = NO;
BOOL _detailHintShown = NO;

BOOL _versionUpgrade = NO;
BOOL _dbUpgrade = NO;
BOOL _firstLaunch = NO;

extern BOOL _scFreeVersion;

//extern BOOL _isiPad;

@implementation Settings

@synthesize skinStyle;
@synthesize weekStart;
@synthesize soundEnable;
@synthesize landscapeModeEnable;
@synthesize tabBarAutoHide;
@synthesize filterTab;
@synthesize snoozeDuration;

@synthesize taskDuration;
@synthesize taskDefaultProject;
@synthesize eventCombination;
@synthesize movableAsEvent;
@synthesize newTaskPlacement;
@synthesize minimumSplitSize;
@synthesize hideFutureTasks;

@synthesize weekdayStartTime;
@synthesize weekdayEndTime;
@synthesize weekendStartTime;
@synthesize weekendEndTime;

@synthesize dayManagerStartTime;
@synthesize dayManagerEndTime;
@synthesize dayManagerUpdateTime;

@synthesize monStartTime;
@synthesize monEndTime;
@synthesize tueStartTime;
@synthesize tueEndTime;
@synthesize wedStartTime;
@synthesize wedEndTime;
@synthesize thuStartTime;
@synthesize thuEndTime;
@synthesize friStartTime;
@synthesize friEndTime;
@synthesize satStartTime;
@synthesize satEndTime;
@synthesize sunStartTime;
@synthesize sunEndTime;

@synthesize syncEnabled;
@synthesize autoSyncEnabled;
@synthesize autoPushEnabled;

@synthesize ekAutoSyncEnabled;
@synthesize ekSyncEnabled;
@synthesize rmdSyncEnabled;
@synthesize syncWindowStart;
@synthesize syncWindowEnd;
@synthesize syncDirection;
@synthesize rmdLastSyncTime;

@synthesize eventMapHint;
@synthesize smartListHint;
@synthesize noteHint;
@synthesize weekViewHint;
@synthesize weekDayQuickAddHint;
@synthesize calendarHint;
@synthesize multiSelectHint;
@synthesize monthViewHint;
@synthesize rtDoneHint;
@synthesize syncMatchHint;
@synthesize projectHint;
@synthesize projectDetailHint;
@synthesize firstTimeEventSyncHint;
@synthesize workingTimeHint;
@synthesize starTabHint;
@synthesize gtdoTabHint;
@synthesize tagHint;
@synthesize featureHint;
@synthesize transparentHint;
@synthesize msdBackupHint;
@synthesize guruHint;
@synthesize detailHint;

@synthesize deleteWarning;
@synthesize doneWarning;
@synthesize hideWarning;
@synthesize move2MMConfirmation;

@synthesize tdAutoSyncEnabled;
@synthesize tdSyncEnabled;
@synthesize tdVerified;
@synthesize tdEmail;
@synthesize tdPassword;
@synthesize tdSyncReset; 
@synthesize tdLastAddEditTime;
@synthesize tdLastDeleteTime;
@synthesize tdLastSyncTime;

@synthesize sdwEmail;
@synthesize sdwPassword;
@synthesize sdwDeviceUUID;
@synthesize syncSource;
@synthesize sdwAutoSyncEnabled;
@synthesize sdwSyncEnabled;
@synthesize sdwVerified;
@synthesize sdwLastSyncTime;
@synthesize sdwLastBackupTime;

@synthesize weekPlannerRows;
@synthesize weekPlannerColumns;	
@synthesize mustDoDays;

@synthesize timeZoneSupport;
@synthesize timeZoneID;

// geo fencing
@synthesize geoFencingEnable;
@synthesize geoFencingInterval;

@synthesize updateTime;

@synthesize dbVersion;
@synthesize appVersion;

@synthesize settingDict;
@synthesize hintDict;
@synthesize dayManagerDict;
@synthesize toodledoSyncDict;
@synthesize sdwSyncDict;
@synthesize ekSyncDict;

@synthesize filterPresets;

@synthesize timeZoneDict;

- (id) init
{
	if (self = [super init])
	{
		self.skinStyle = 1;
		self.weekStart = 0;
		self.soundEnable = YES;
		self.landscapeModeEnable = YES;
		self.tabBarAutoHide = NO; 
		self.filterTab = TASK_FILTER_ALL;
        self.snoozeDuration = 15;
		
		self.taskDuration = DEFAULT_TASK_DURATION;
		self.taskDefaultProject = 2;
		self.eventCombination = 0;
		self.movableAsEvent = 0;
		//self.newTaskPlacement = 0; //0:on top - 1: at bottom
        self.newTaskPlacement = 1;
		self.minimumSplitSize = 15*60;
        self.hideFutureTasks = NO;
		
		self.weekdayStartTime = @"08:00";
		self.weekdayEndTime = @"18:00";		
		self.weekendStartTime = @"10:00";
		self.weekendEndTime = @"16:00";
		
		self.monStartTime = @"08:00";
		self.monEndTime = @"18:00";
		self.tueStartTime = @"08:00";
		self.tueEndTime = @"18:00";
		self.wedStartTime = @"08:00";
		self.wedEndTime = @"18:00";
		self.thuStartTime = @"08:00";
		self.thuEndTime = @"18:00";
		self.friStartTime = @"08:00";
		self.friEndTime = @"18:00";
		self.satStartTime = @"08:00";
		self.satEndTime = @"18:00";
		self.sunStartTime = @"08:00";
		self.sunEndTime = @"18:00";
		
		NSString *wkStartTime[7] = {self.sunStartTime, self.monStartTime, self.tueStartTime, self.wedStartTime,
			self.thuStartTime, self.friStartTime, self.satStartTime};
		NSString *wkEndTime[7] = {self.sunEndTime, self.monEndTime, self.tueEndTime, self.wedEndTime,
			self.thuEndTime, self.friEndTime, self.satEndTime};
		
		NSInteger wkday = [Common getWeekday:[NSDate date]]-1;
		self.dayManagerStartTime = wkStartTime[wkday];
		self.dayManagerEndTime = wkEndTime[wkday];
        self.dayManagerUpdateTime = nil;
		
        self.syncEnabled = NO;
        self.autoSyncEnabled = NO;
        self.autoPushEnabled = NO;
        
		self.ekAutoSyncEnabled = NO;
        self.ekSyncEnabled = NO;
        self.rmdSyncEnabled = NO;
		self.syncWindowStart = 1;
		self.syncWindowEnd = 2;
		self.syncDirection = SYNC_2WAY;
        self.rmdLastSyncTime = nil;
		
		self.eventMapHint = YES;
		self.smartListHint = YES;
        self.noteHint = YES;
		self.weekViewHint = YES;
		self.weekDayQuickAddHint = YES;
		self.calendarHint = YES;
		self.multiSelectHint = YES;
		self.monthViewHint = YES;
		self.rtDoneHint = YES;
		self.syncMatchHint = YES;
		self.projectHint = YES;
		self.projectDetailHint = YES;
		self.firstTimeEventSyncHint = YES;
		self.workingTimeHint = YES;
		self.starTabHint = YES;
		self.gtdoTabHint = YES;
		self.tagHint = YES;	
		self.featureHint = YES;
        self.transparentHint = YES;
        self.msdBackupHint = YES;
        self.guruHint = YES;
        self.detailHint = YES;
		
		self.deleteWarning = YES;
		self.doneWarning = YES;
		self.hideWarning = YES;
        self.move2MMConfirmation = YES;
		
		self.tdAutoSyncEnabled = NO;
		self.tdSyncEnabled = NO;
        self.tdVerified = NO;
		self.tdEmail = @"";
		self.tdPassword = @"";
		
		self.tdSyncReset = NO;
		self.tdLastAddEditTime = nil;
		self.tdLastDeleteTime = nil;
		self.tdLastSyncTime = nil;
		
		self.weekPlannerRows = 1;
        self.mustDoDays = 0;
        
        self.timeZoneSupport = NO;
        self.timeZoneID = 0;
        
        // geo fencing
        self.geoFencingEnable = NO;
        self.geoFencingInterval = 5*60;
        
        self.sdwEmail = @"";
        self.sdwPassword = @"";
        
        self.sdwDeviceUUID = nil;
        self.syncSource = 0;
        self.sdwAutoSyncEnabled = NO;
        self.sdwSyncEnabled = YES;
        self.sdwVerified = NO;
        self.sdwLastSyncTime = nil;
        self.sdwLastBackupTime = nil;
        
        self.updateTime = nil;
        
        isExternalUpdate = NO;
		
		[self loadSettingDict];

        BOOL needSaveSetting = NO;
        
        NSString *newDBVersion = @"5.1";
        
        _dbUpgrade = NO;

		if (![self.dbVersion isEqualToString:newDBVersion])
        {
            if (self.dbVersion != nil)
            {
                _dbUpgrade = YES;
            }
            
            self.dbVersion = newDBVersion;
            
            needSaveSetting = YES;
        }
        
        if (_isiPad)
        {
            self.tabBarAutoHide = YES;
        }
				
		NSString *newVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		
		_versionUpgrade = NO;
		
        if (![newVersion isEqualToString:self.appVersion])
		{
            if (self.appVersion == nil)
            {
                _firstLaunch = YES;
            }
			else
			{
				_versionUpgrade = YES;
			}
			
            self.appVersion = newVersion;
            needSaveSetting = YES;
		}

        if (needSaveSetting)
        {
            //save db version and app version
            [self saveSettingDict];
        }
        
        if (_versionUpgrade && [newVersion isEqualToString:@"1.0.1"])
        {
            //move some ek settings into EKSyncDict
            [self saveEKSyncDict];
        }
        
		[self loadDayManagerDict];
				
		[self loadHintDict];
        
        if (_versionUpgrade)
        {
            self.featureHint = YES;
        }
        
        [self loadEKSyncDict];
        
		[self loadToodledoSyncDict];
        
		[self loadSDWSyncDict];
        
        [self loadFilterPresets];
        
        [self loadTimeZoneDict];
        
	}
	
	return self;
}

- (void)dealloc {
	self.weekdayStartTime = nil;
	self.weekdayEndTime = nil;
	self.weekendStartTime = nil;
	self.weekendEndTime = nil;
	
	self.dayManagerStartTime = nil;
	self.dayManagerEndTime = nil;
	
	self.tdEmail = nil;
	self.tdPassword = nil;
	self.tdLastAddEditTime = nil;
	self.tdLastDeleteTime = nil;
	self.tdLastSyncTime = nil;
    
    self.sdwEmail = nil;
    self.sdwPassword = nil;
    self.sdwDeviceUUID = nil;
    self.sdwLastSyncTime = nil;
	
	self.dbVersion = nil;
	self.appVersion = nil;
	
	self.settingDict = nil;
	self.dayManagerDict = nil;
	self.hintDict = nil;
    self.sdwSyncDict = nil;
    self.toodledoSyncDict = nil;
    self.ekSyncDict = nil;
    
    self.filterPresets = nil;
    
    self.timeZoneDict = nil;
    
    self.updateTime = nil;
	
    [super dealloc];
}


- (id) copyWithZone:(NSZone*) zone{
	Settings *copy = [[Settings alloc] init];
	copy.skinStyle = skinStyle;
	copy.weekStart = weekStart;
	copy.landscapeModeEnable = landscapeModeEnable;
	copy.tabBarAutoHide = tabBarAutoHide;
    copy.snoozeDuration = snoozeDuration;
	
	copy.taskDuration = taskDuration;
	copy.taskDefaultProject = taskDefaultProject;
	copy.eventCombination = eventCombination;
	copy.movableAsEvent = movableAsEvent;
	copy.minimumSplitSize = minimumSplitSize;
    copy.mustDoDays = mustDoDays;
    copy.hideFutureTasks = hideFutureTasks;
    copy.soundEnable = soundEnable;
	
	copy.weekdayStartTime = weekdayStartTime;
	copy.weekdayEndTime = weekdayEndTime;
	copy.weekendStartTime = weekendStartTime;
	copy.weekendEndTime = weekendEndTime;
	
	copy.monStartTime = monStartTime;
	copy.tueStartTime = tueStartTime;
	copy.wedStartTime = wedStartTime;
	copy.thuStartTime = thuStartTime;
	copy.friStartTime = friStartTime;
	copy.satStartTime = satStartTime;
	copy.sunStartTime = sunStartTime;
	
	copy.monEndTime = monEndTime;
	copy.tueEndTime = tueEndTime;
	copy.wedEndTime = wedEndTime;
	copy.thuEndTime = thuEndTime;
	copy.friEndTime = friEndTime;
	copy.satEndTime = satEndTime;
	copy.sunEndTime = sunEndTime;
	
	copy.dayManagerStartTime = dayManagerStartTime;
	copy.dayManagerEndTime = dayManagerEndTime;
	
	copy.ekAutoSyncEnabled = ekAutoSyncEnabled;
    copy.rmdSyncEnabled = rmdSyncEnabled;
	copy.syncWindowStart = syncWindowStart;
	copy.syncWindowEnd = syncWindowEnd;
	copy.syncDirection = syncDirection;
	
	copy.deleteWarning = deleteWarning;
	copy.doneWarning = doneWarning;
	copy.hideWarning = hideWarning;
	
	copy.tdAutoSyncEnabled = tdAutoSyncEnabled;	
    copy.tdSyncEnabled = tdSyncEnabled;
    copy.tdVerified = tdVerified;
	copy.tdEmail = tdEmail;
	copy.tdPassword = tdPassword;
	copy.tdLastAddEditTime = tdLastAddEditTime;
	copy.tdLastDeleteTime = tdLastDeleteTime;
	copy.tdLastSyncTime = tdLastSyncTime;
	copy.tdSyncReset = tdSyncReset;
    
    copy.sdwEmail = sdwEmail;
    copy.sdwPassword = sdwPassword;
    copy.sdwAutoSyncEnabled = sdwAutoSyncEnabled;
    copy.sdwSyncEnabled = sdwSyncEnabled;
    copy.sdwVerified = sdwVerified;
    copy.syncSource = syncSource;
    
    copy.timeZoneSupport = timeZoneSupport;
    copy.timeZoneID = timeZoneID;
    
    // geo fencing
    copy.geoFencingEnable = geoFencingEnable;
    copy.geoFencingInterval = geoFencingInterval;
    
    copy.updateTime = updateTime;
	
	return copy;
}

-(void) updateSettings:(Settings *) settings
{
	self.skinStyle = settings.skinStyle;
	self.weekStart = settings.weekStart;
	self.landscapeModeEnable = settings.landscapeModeEnable;
	self.tabBarAutoHide = settings.tabBarAutoHide;
    self.snoozeDuration = settings.snoozeDuration;
	
	self.taskDuration = settings.taskDuration;
	self.taskDefaultProject = settings.taskDefaultProject;
	self.eventCombination = settings.eventCombination;
	self.movableAsEvent = settings.movableAsEvent;
	self.newTaskPlacement = settings.newTaskPlacement;
	self.minimumSplitSize = settings.minimumSplitSize;
    self.mustDoDays = settings.mustDoDays;
    self.hideFutureTasks = settings.hideFutureTasks;
    self.soundEnable = settings.soundEnable;
	
	self.weekdayStartTime = settings.weekdayStartTime;
	self.weekdayEndTime = settings.weekdayEndTime;
	self.weekendStartTime = settings.weekendStartTime;
	self.weekendEndTime = settings.weekendEndTime;
	
	self.monStartTime = settings.monStartTime;
	self.tueStartTime = settings.tueStartTime;
	self.wedStartTime = settings.wedStartTime;
	self.thuStartTime = settings.thuStartTime;
	self.friStartTime = settings.friStartTime;
	self.satStartTime = settings.satStartTime;
	self.sunStartTime = settings.sunStartTime;
	
	self.monEndTime = settings.monEndTime;
	self.tueEndTime = settings.tueEndTime;
	self.wedEndTime = settings.wedEndTime;
	self.thuEndTime = settings.thuEndTime;
	self.friEndTime = settings.friEndTime;
	self.satEndTime = settings.satEndTime;
	self.sunEndTime = settings.sunEndTime;

    self.syncEnabled = settings.syncEnabled;
    self.autoSyncEnabled = settings.autoSyncEnabled;
    self.autoPushEnabled = settings.autoPushEnabled;
    
    self.ekSyncEnabled = settings.ekSyncEnabled;
    self.rmdSyncEnabled = settings.rmdSyncEnabled;
	self.ekAutoSyncEnabled = settings.ekAutoSyncEnabled;	
	self.syncWindowStart = settings.syncWindowStart;
	self.syncWindowEnd = settings.syncWindowEnd;
	self.syncDirection = settings.syncDirection;
	
	self.deleteWarning = settings.deleteWarning;
	self.doneWarning = settings.doneWarning;
	self.hideWarning = settings.hideWarning;
	
    self.tdSyncEnabled = settings.tdSyncEnabled;
	self.tdAutoSyncEnabled = settings.tdAutoSyncEnabled;

    self.sdwSyncEnabled = settings.sdwSyncEnabled;
    self.sdwAutoSyncEnabled = settings.sdwAutoSyncEnabled;
    
    self.timeZoneSupport = settings.timeZoneSupport;
    self.timeZoneID = settings.timeZoneID;
    
    // geo fencing
    self.geoFencingEnable = settings.geoFencingEnable;
    self.geoFencingInterval = settings.geoFencingInterval;
    
    self.updateTime = settings.updateTime;
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];	
	}
	
	isExternalUpdate = NO;
	
	[self saveSettingDict];
	
	[self saveDayManagerDict];
    
	[self saveToodledoSyncDict];
    
    [self saveEKSyncDict];
    
	[self saveSDWSyncDict];
    
    TaskManager *tm = [TaskManager getInstance];
    tm.lastTaskProjectKey = self.taskDefaultProject; //reset default project for Quick Add in Tasks view
}

- (UIColor *)getBackgroundColor
{
	if (skinStyle == 0)
	{
		return [Colors linen];
	}
	
	return [UIColor blackColor];
}

/*
- (NSString *)dataFilePath: (NSString *) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:path];
}
*/
- (void) loadSettingDict
{
	self.settingDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"Settings.dat"]];
	
	if (self.settingDict == nil)
	{
		self.settingDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
    else
    {
		NSNumber *skinSetting = [self.settingDict objectForKey:@"SkinStyle"];
		
		if (skinSetting != nil)
		{
			self.skinStyle = [skinSetting intValue];
		}
		
		NSNumber *weekStartSetting = [self.settingDict objectForKey:@"WeekStart"];
		
		if (weekStartSetting != nil)
		{
			self.weekStart = [weekStartSetting intValue];
		}
        
        [[NSCalendar currentCalendar] setFirstWeekday:self.weekStart==0?1:2];
        
		NSNumber *landscapeModeEnableSetting = [self.settingDict objectForKey:@"LandscapeModeEnable"];
		
		if (landscapeModeEnableSetting != nil)
		{
			self.landscapeModeEnable = ([landscapeModeEnableSetting intValue] == 1);
		}
        
		NSNumber *tabBarAutoHideSetting = [self.settingDict objectForKey:@"TabBarAutoHide"];
		
		if (tabBarAutoHideSetting != nil)
		{
			self.tabBarAutoHide = [tabBarAutoHideSetting boolValue];
		}
        
		NSNumber *filterTabSetting = [self.settingDict objectForKey:@"FilterTab"];
		
		if (filterTabSetting != nil)
		{
			self.filterTab = [filterTabSetting intValue];
		}
        
		NSNumber *snoozeDurationSetting = [self.settingDict objectForKey:@"SnoozeDuration"];
		
		if (snoozeDurationSetting != nil)
		{
			self.snoozeDuration = [snoozeDurationSetting intValue];
		}
		
		NSNumber *taskDurationSetting = [self.settingDict objectForKey:@"TaskDuration"];
		
		if (taskDurationSetting != nil)
		{
			self.taskDuration = [taskDurationSetting intValue];
		}
		
		NSNumber *taskDefaultProjectSetting = [self.settingDict objectForKey:@"TaskDefaultProject"];
		
		if (taskDefaultProjectSetting != nil)
		{
			self.taskDefaultProject = [taskDefaultProjectSetting intValue];
		}
		
		NSNumber *eventCombinationSetting = [self.settingDict objectForKey:@"EventCombination"];
		
		if (eventCombinationSetting != nil)
		{
			self.eventCombination = [eventCombinationSetting intValue];
		}

		NSNumber *hideFutureTasksSetting = [self.settingDict objectForKey:@"HideFutureTasks"];
		
		if (hideFutureTasksSetting != nil)
		{
			self.hideFutureTasks = [hideFutureTasksSetting boolValue];
		}
        
		NSNumber *soundEnabledSetting = [self.settingDict objectForKey:@"SoundEnabled"];
		
		if (soundEnabledSetting != nil)
		{
			self.soundEnable = [soundEnabledSetting boolValue];
		}
        
		NSNumber *minimumSplitSizeSetting = [self.settingDict objectForKey:@"MinimumSplitSize"];
		
		if (minimumSplitSizeSetting != nil)
		{
			self.minimumSplitSize = [minimumSplitSizeSetting intValue];
		}
		
		NSString *wdStartTime = [self.settingDict objectForKey:@"WeekdayStartTime"];
		
		if (wdStartTime != nil)
		{
			self.weekdayStartTime = wdStartTime;
		}
		
		NSString *wdEndTime = [self.settingDict objectForKey:@"WeekdayEndTime"];
		
		if (wdStartTime != nil)
		{
			self.weekdayEndTime = wdEndTime;
		}
		
		NSString *weStartTime = [self.settingDict objectForKey:@"WeekendStartTime"];
		
		if (weStartTime != nil)
		{
			self.weekendStartTime = weStartTime;
		}
		
		NSString *weEndTime = [self.settingDict objectForKey:@"WeekendEndTime"];
		
		if (weEndTime != nil)
		{
			self.weekendEndTime = weEndTime;
		}
        
        NSNumber *syncEnabledSetting = [self.settingDict objectForKey:@"SyncEnabled"];
		
		if (syncEnabledSetting != nil)
		{
			self.syncEnabled = [syncEnabledSetting boolValue];
		}
        
        NSNumber *autoSyncEnabledSetting = [self.settingDict objectForKey:@"AutoSyncEnabled"];
		
		if (autoSyncEnabledSetting != nil)
		{
			self.autoSyncEnabled = [autoSyncEnabledSetting boolValue];
		}
        
        NSNumber *autoPushEnabledSetting = [self.settingDict objectForKey:@"AutoPushEnabled"];
		
		if (autoPushEnabledSetting != nil)
		{
			self.autoPushEnabled = [autoPushEnabledSetting boolValue];
		}
        
		NSNumber *ekAutoSyncEnabledSetting = [self.settingDict objectForKey:@"EKAutoSyncEnabled"];
		
		if (ekAutoSyncEnabledSetting != nil)
		{
			self.ekAutoSyncEnabled = [ekAutoSyncEnabledSetting boolValue];
		}
		
		NSNumber *ekSyncEnabledSetting = [self.settingDict objectForKey:@"EKSyncEnabled"];
		
		if (ekSyncEnabledSetting != nil)
		{
			self.ekSyncEnabled = [ekSyncEnabledSetting boolValue];
		}
        
		NSNumber *syncWindowStartSetting = [self.settingDict objectForKey:@"SyncWindowStart"];
		
		if (syncWindowStartSetting != nil)
		{
			self.syncWindowStart = [syncWindowStartSetting intValue];
		}
		
		NSNumber *syncWindowEndSetting = [self.settingDict objectForKey:@"SyncWindowEnd"];
		
		if (syncWindowEndSetting != nil)
		{
			self.syncWindowEnd = [syncWindowEndSetting intValue];
		}
		
		NSNumber *syncDirectionSetting = [self.settingDict objectForKey:@"SyncDirection"];
		
		if (syncDirectionSetting != nil)
		{
			self.syncDirection = [syncDirectionSetting intValue];
		}
		
		NSNumber *deleteWarningSetting = [self.settingDict objectForKey:@"DeleteWarning"];
		
		if (deleteWarningSetting != nil)
		{
			self.deleteWarning = ([deleteWarningSetting intValue] == 1);
		}
		
		NSNumber *doneWarningSetting = [self.settingDict objectForKey:@"DoneWarning"];
		
		if (doneWarningSetting != nil)
		{
			self.doneWarning = ([doneWarningSetting intValue] == 1);
		}
        
		NSNumber *hideWarningSetting = [self.settingDict objectForKey:@"HideWarning"];
		
		if (hideWarningSetting != nil)
		{
			self.hideWarning = ([hideWarningSetting intValue] == 1);
		}
		
		NSNumber *weekPlannerRowsSetting = [self.settingDict objectForKey:@"WeekPlannerRows"];
		
		if (weekPlannerRowsSetting != nil)
		{
			self.weekPlannerRows = [weekPlannerRowsSetting intValue];
		}
        
		NSNumber *mustDoDaysSetting = [self.settingDict objectForKey:@"MustDoDays"];
		
		if (mustDoDaysSetting != nil)
		{
			self.mustDoDays = [mustDoDaysSetting intValue];
		}
        
		NSNumber *timeZoneSupportSetting = [self.settingDict objectForKey:@"TimeZoneSupport"];
		
		if (timeZoneSupportSetting != nil)
		{
			self.timeZoneSupport = [timeZoneSupportSetting boolValue];
		}
        
		NSNumber *timeZoneIDSetting = [self.settingDict objectForKey:@"TimeZoneID"];
		
		if (timeZoneIDSetting != nil)
		{
			self.timeZoneID = [timeZoneIDSetting intValue];
		}
        
        // geo fencing
        NSNumber *geoFencingEnableSetting = [self.settingDict objectForKey:@"GeoFencingEnable"];
		
		if (geoFencingEnableSetting != nil)
		{
			self.geoFencingEnable = [geoFencingEnableSetting boolValue];
		}
        
		NSNumber *geoFencingIntervalSetting = [self.settingDict objectForKey:@"GeoFencingInterval"];
		
		if (geoFencingIntervalSetting != nil)
		{
			self.geoFencingInterval = [geoFencingIntervalSetting intValue];
		}

		NSNumber *updateTimeSetting = [self.settingDict objectForKey:@"UpdateTime"];
		
		if (updateTimeSetting != nil)
		{
			self.updateTime = [NSDate dateWithTimeIntervalSince1970:[updateTimeSetting doubleValue]];
		}
        
        NSString *dbVersionSetting = [self.settingDict objectForKey:@"DBVersion"];
		
		if (dbVersionSetting != nil)
		{
			self.dbVersion = dbVersionSetting;
		}
        
        NSString *appVersionSetting = [self.settingDict objectForKey:@"AppVersion"];
		
		if (appVersionSetting != nil)
		{
			self.appVersion = appVersionSetting;
		}
    }
}

- (void) loadDayManagerDict
{
	self.dayManagerDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"DayManager.dat"]];
	
	if (self.dayManagerDict == nil)
	{
		self.dayManagerDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
    else
    {
		NSString *dayStartTime = [self.dayManagerDict objectForKey:@"DayManagerStartTime"];
		
		if (dayStartTime != nil)
		{
			self.dayManagerStartTime = dayStartTime;
		}
		
		NSString *dayEndTime = [self.dayManagerDict objectForKey:@"DayManagerEndTime"];
		
		if (dayEndTime != nil)
		{
			self.dayManagerEndTime = dayEndTime;
		}
		
		NSNumber *dayUpdateTimeSetting = [self.dayManagerDict objectForKey:@"DayManagerUpdateTime"];
		
		if (dayUpdateTimeSetting != nil)
		{
			self.dayManagerUpdateTime = [NSDate dateWithTimeIntervalSince1970:[dayUpdateTimeSetting doubleValue]];
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"MonStartTime"];
		
		if (dayStartTime != nil)
		{
			self.monStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"MonEndTime"];
		
		if (dayEndTime != nil)
		{
			self.monEndTime = dayEndTime;
		}
        
		dayStartTime = [self.dayManagerDict objectForKey:@"TueStartTime"];
		
		if (dayStartTime != nil)
		{
			self.tueStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"TueEndTime"];
		
		if (dayEndTime != nil)
		{
			self.tueEndTime = dayEndTime;
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"WedStartTime"];
		
		if (dayStartTime != nil)
		{
			self.wedStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"WedEndTime"];
		
		if (dayEndTime != nil)
		{
			self.wedEndTime = dayEndTime;
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"ThuStartTime"];
		
		if (dayStartTime != nil)
		{
			self.thuStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"ThuEndTime"];
		
		if (dayEndTime != nil)
		{
			self.thuEndTime = dayEndTime;
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"FriStartTime"];
		
		if (dayStartTime != nil)
		{
			self.friStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"FriEndTime"];
		
		if (dayEndTime != nil)
		{
			self.friEndTime = dayEndTime;
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"SatStartTime"];
		
		if (dayStartTime != nil)
		{
			self.satStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"SatEndTime"];
		
		if (dayEndTime != nil)
		{
			self.satEndTime = dayEndTime;
		}
		
		dayStartTime = [self.dayManagerDict objectForKey:@"SunStartTime"];
		
		if (dayStartTime != nil)
		{
			self.sunStartTime = dayStartTime;
		}
		
		dayEndTime = [self.dayManagerDict objectForKey:@"SunEndTime"];
		
		if (dayEndTime != nil)
		{
			self.sunEndTime = dayEndTime;
		}		
        
    }
}

- (void) loadHintDict
{
	self.hintDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"Hints.dat"]];
	
	if (self.hintDict == nil)
	{
		self.hintDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
    else
    {
		NSNumber *eventMapHintSetting = [self.hintDict objectForKey:@"EventMapHint"];
		
		if (eventMapHintSetting != nil)
		{
			self.eventMapHint = ([eventMapHintSetting intValue] == 1);
		}
		
		NSNumber *smartListHintSetting = [self.hintDict objectForKey:@"SmartListHint"];
		
		if (smartListHintSetting != nil)
		{
			self.smartListHint = ([smartListHintSetting intValue] == 1);
		}
        
		NSNumber *noteHintSetting = [self.hintDict objectForKey:@"NoteHint"];
		
		if (noteHintSetting != nil)
		{
			self.noteHint = ([noteHintSetting intValue] == 1);
		}
		
		NSNumber *weekViewHintSetting = [self.hintDict objectForKey:@"WeekViewHint"];
		
		if (weekViewHintSetting != nil)
		{
			self.weekViewHint = ([weekViewHintSetting intValue] == 1);
		}
		
		NSNumber *weekDayQuickAddHintSetting = [self.hintDict objectForKey:@"WeekDayQuickAddHint"];
		
		if (weekDayQuickAddHintSetting != nil)
		{
			self.weekDayQuickAddHint = ([weekDayQuickAddHintSetting intValue] == 1);
		}
		
		NSNumber *calendarHintSetting = [self.hintDict objectForKey:@"CalendarHint"];
		
		if (calendarHintSetting != nil)
		{
			self.calendarHint = ([calendarHintSetting intValue] == 1);
		}
		
		NSNumber *multiSelectHintSetting = [self.hintDict objectForKey:@"MultiSelectHint"];
		
		if (multiSelectHintSetting != nil)
		{
			self.multiSelectHint = ([multiSelectHintSetting intValue] == 1);
		}
		
		NSNumber *monthViewHintSetting = [self.hintDict objectForKey:@"MonthViewHint"];
		
		if (monthViewHintSetting != nil)
		{
			self.monthViewHint = ([monthViewHintSetting intValue] == 1);
		}
        
		NSNumber *rtDoneHintSetting = [self.hintDict objectForKey:@"RTDoneHint"];
		
		if (rtDoneHintSetting != nil)
		{
			self.rtDoneHint = ([rtDoneHintSetting intValue] == 1);
		}
		
		NSNumber *syncMatchHintSetting = [self.hintDict objectForKey:@"SyncMatchHint"];
		
		if (syncMatchHintSetting != nil)
		{
			self.syncMatchHint = ([syncMatchHintSetting intValue] == 1);
		}
        
		NSNumber *projectHintSetting = [self.hintDict objectForKey:@"ProjectHint"];
		
		if (projectHintSetting != nil)
		{
			self.projectHint = ([projectHintSetting intValue] == 1);
		}
        
		NSNumber *projectDetailHintSetting = [self.hintDict objectForKey:@"ProjectDetailHint"];
		
		if (projectDetailHintSetting != nil)
		{
			self.projectDetailHint = ([projectDetailHintSetting intValue] == 1);
		}
		
		NSNumber *firstTimeEventSyncHintSetting = [self.hintDict objectForKey:@"FirstTimeEventSyncHint"];
		
		if (firstTimeEventSyncHintSetting != nil)
		{
			self.firstTimeEventSyncHint = ([firstTimeEventSyncHintSetting intValue] == 1);
		}
        
		NSNumber *workingTimeHintSetting = [self.hintDict objectForKey:@"WorkingTimeHint"];
		
		if (workingTimeHintSetting != nil)
		{
			self.workingTimeHint = ([workingTimeHintSetting intValue] == 1);
		}
        
		NSNumber *starTabHintSetting = [self.hintDict objectForKey:@"StarTabHint"];
		
		if (starTabHintSetting != nil)
		{
			self.starTabHint = ([starTabHintSetting intValue] == 1);
		}
        
		NSNumber *gtdoTabHintSetting = [self.hintDict objectForKey:@"GTDoTabHint"];
		
		if (gtdoTabHintSetting != nil)
		{
			self.gtdoTabHint = ([gtdoTabHintSetting intValue] == 1);
		}
        
		NSNumber *tagHintSetting = [self.hintDict objectForKey:@"TagHint"];
		
		if (tagHintSetting != nil)
		{
			self.tagHint = ([tagHintSetting intValue] == 1);
		}
        
		NSNumber *featureHintSetting = [self.hintDict objectForKey:@"FeatureHint"];
		
		if (featureHintSetting != nil)
		{
			self.featureHint = ([featureHintSetting intValue] == 1);
		}
        
		NSNumber *transparentHintSetting = [self.hintDict objectForKey:@"TransparentHint"];
		
		if (transparentHintSetting != nil)
		{
			self.transparentHint = ([transparentHintSetting intValue] == 1);
		}
        
		NSNumber *msdBackupHintSetting = [self.hintDict objectForKey:@"MSDBackupHint"];
		
		if (msdBackupHintSetting != nil)
		{
			self.msdBackupHint = [msdBackupHintSetting boolValue];
		}
        
		NSNumber *guruHintSetting = [self.hintDict objectForKey:@"GuruHint"];
		
		if (guruHintSetting != nil)
		{
			self.guruHint = [guruHintSetting boolValue];
		}

		NSNumber *detailHintSetting = [self.hintDict objectForKey:@"DetailHint"];
		
		if (detailHintSetting != nil)
		{
			self.detailHint = [detailHintSetting boolValue];
		}
        
		NSNumber *move2MMConfirmationSetting = [self.hintDict objectForKey:@"Move2MMConfirmation"];
		
		if (move2MMConfirmationSetting != nil)
		{
			self.move2MMConfirmation = [move2MMConfirmationSetting boolValue];
		}
    }
}

- (void) loadToodledoSyncDict
{
	self.toodledoSyncDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"ToodledoSync.dat"]];
	
	if (self.toodledoSyncDict == nil)
	{
		self.toodledoSyncDict = [NSMutableDictionary dictionaryWithCapacity:5];
	}
    else
    {
		NSNumber *tdAutoSyncEnabledSetting = [self.toodledoSyncDict objectForKey:@"TDAutoSyncEnabled"];
		
		if (tdAutoSyncEnabledSetting != nil)
		{
			self.tdAutoSyncEnabled = [tdAutoSyncEnabledSetting boolValue];
		}
        
		NSNumber *tdSyncEnabledSetting = [self.toodledoSyncDict objectForKey:@"TDSyncEnabled"];
		
		if (tdSyncEnabledSetting != nil)
		{
			self.tdSyncEnabled = [tdSyncEnabledSetting boolValue];
		}
        
		NSNumber *tdVerifiedSetting = [self.toodledoSyncDict objectForKey:@"TDVerified"];
		
		if (tdVerifiedSetting != nil)
		{
			self.tdVerified = [tdVerifiedSetting boolValue];
		}
		
		NSString *tdEmailSetting = [self.toodledoSyncDict objectForKey:@"Email"];
		
		if (tdEmailSetting != nil)
		{
			self.tdEmail = tdEmailSetting;
		}
        
		NSString *tdPwdSetting = [self.toodledoSyncDict objectForKey:@"Pwd"];
		
		if (tdPwdSetting != nil)
		{
			NSString *pwd = [[NSString alloc] initWithData:[NSDataBase64 dataWithBase64EncodedString:tdPwdSetting] encoding:NSUTF8StringEncoding];
			
			self.tdPassword = pwd;
			
			[pwd release];
		}
		
		NSNumber *tdSyncResetSetting = [self.toodledoSyncDict objectForKey:@"Reset"];
		
		if (tdSyncResetSetting != nil)
		{
			self.tdSyncReset = ([tdSyncResetSetting intValue] == 1);
		}
        
		NSNumber *tdLastAddEditTimeSetting = [self.toodledoSyncDict objectForKey:@"LastAddEditTime"];
		
		if (tdLastAddEditTimeSetting != nil)
		{
			self.tdLastAddEditTime = [NSDate dateWithTimeIntervalSince1970:[tdLastAddEditTimeSetting doubleValue]];
		}
        
		NSNumber *tdLastDeleteTimeSetting = [self.toodledoSyncDict objectForKey:@"LastDeleteTime"];
		
		if (tdLastDeleteTimeSetting != nil)
		{
			self.tdLastDeleteTime = [NSDate dateWithTimeIntervalSince1970:[tdLastDeleteTimeSetting doubleValue]];
		}
        
		NSNumber *tdLastSyncTimeSetting = [self.toodledoSyncDict objectForKey:@"LastSyncTime"];
		
		if (tdLastSyncTimeSetting != nil)
		{
			self.tdLastSyncTime = [NSDate dateWithTimeIntervalSince1970:[tdLastSyncTimeSetting doubleValue]];
		}
    }
}

- (void) loadSDWSyncDict
{
	self.sdwSyncDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"SDWSync.dat"]];
	
	if (self.sdwSyncDict == nil)
	{
		self.sdwSyncDict = [NSMutableDictionary dictionaryWithCapacity:5];
	}
    else
    {
		NSString *sdwEmailSetting = [self.sdwSyncDict objectForKey:@"Email"];
		
		if (sdwEmailSetting != nil)
		{
			self.sdwEmail = sdwEmailSetting;
		}
        
		NSString *sdwPwdSetting = [self.sdwSyncDict objectForKey:@"Pwd"];
		
		if (sdwPwdSetting != nil)
		{
			NSString *pwd = [[NSString alloc] initWithData:[NSDataBase64 dataWithBase64EncodedString:sdwPwdSetting] encoding:NSUTF8StringEncoding];
			
			self.sdwPassword = pwd;
			
			[pwd release];
		}
        
		NSString *sdwDeviceUUIDSetting = [self.sdwSyncDict objectForKey:@"SDWDeviceUUID"];
		
		if (sdwDeviceUUIDSetting != nil)
		{
			self.sdwDeviceUUID = sdwDeviceUUIDSetting;
		}
        
		NSNumber *syncSourceSetting = [self.sdwSyncDict objectForKey:@"SyncSource"];
		
		if (syncSourceSetting != nil)
		{
			self.syncSource = [syncSourceSetting intValue];
		}
        
		NSNumber *sdwAutoSyncEnabledSetting = [self.sdwSyncDict objectForKey:@"SDWAutoSyncEnabled"];
		
		if (sdwAutoSyncEnabledSetting != nil)
		{
			self.sdwAutoSyncEnabled = [sdwAutoSyncEnabledSetting boolValue];
		}
        
		NSNumber *sdwVerifiedSetting = [self.sdwSyncDict objectForKey:@"SDWVerified"];
		
		if (sdwVerifiedSetting != nil)
		{
			self.sdwVerified = [sdwVerifiedSetting boolValue];
		}
        
		NSNumber *sdwSyncEnabledSetting = [self.sdwSyncDict objectForKey:@"SDWSyncEnabled"];
		
		if (sdwSyncEnabledSetting != nil)
		{
			self.sdwSyncEnabled = [sdwSyncEnabledSetting boolValue];
		}
        
		NSNumber *sdwLastSyncTimeSetting = [self.sdwSyncDict objectForKey:@"SDWLastSyncTime"];
		
		if (sdwLastSyncTimeSetting != nil)
		{
			self.sdwLastSyncTime = [NSDate dateWithTimeIntervalSince1970:[sdwLastSyncTimeSetting doubleValue]];
		}
        
		NSNumber *sdwLastBackupTimeSetting = [self.sdwSyncDict objectForKey:@"SDWLastBackupTime"];
		
		if (sdwLastBackupTimeSetting != nil)
		{
			self.sdwLastBackupTime = [NSDate dateWithTimeIntervalSince1970:[sdwLastBackupTimeSetting doubleValue]];
		}
    }
}

- (void) loadEKSyncDict
{
	self.ekSyncDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"EKSync.dat"]];
	
	if (self.ekSyncDict == nil)
	{
		self.ekSyncDict = [NSMutableDictionary dictionaryWithCapacity:5];
	}
    else
    {
 		NSNumber *ekAutoSyncEnabledSetting = [self.ekSyncDict objectForKey:@"EKAutoSyncEnabled"];
		
		if (ekAutoSyncEnabledSetting != nil)
		{
			self.ekAutoSyncEnabled = [ekAutoSyncEnabledSetting boolValue];
		}
		
		NSNumber *ekSyncEnabledSetting = [self.ekSyncDict objectForKey:@"EKSyncEnabled"];
		
		if (ekSyncEnabledSetting != nil)
		{
			self.ekSyncEnabled = [ekSyncEnabledSetting boolValue];
		}
        
		NSNumber *rmdSyncEnabledSetting = [self.ekSyncDict objectForKey:@"ReminderSyncEnabled"];
		
		if (rmdSyncEnabledSetting != nil)
		{
			self.rmdSyncEnabled = [rmdSyncEnabledSetting boolValue];
		}
        
		NSNumber *rmdLastSyncTimeSetting = [self.ekSyncDict objectForKey:@"ReminderLastSyncTime"];
		
		if (rmdLastSyncTimeSetting != nil)
		{
			self.rmdLastSyncTime = [NSDate dateWithTimeIntervalSince1970:[rmdLastSyncTimeSetting doubleValue]];
		}
    }
}


- (void) loadFilterPresets
{
	//self.filterPresets = [NSMutableArray arrayWithContentsOfFile:[Common getFilePath:@"FilterPresets.dat"]];
    self.filterPresets = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"FilterPresets.dat"]];
	
	if (self.filterPresets == nil)
	{
		//self.filterPresets = [NSMutableArray arrayWithCapacity:3];
        self.filterPresets = [NSMutableDictionary dictionaryWithCapacity:3];
	}
}

- (void) loadTimeZoneDict
{
    NSError *error = nil;
    
    NSData *jsonData = [NSData dataWithContentsOfFile:[Common getFilePath:@"TimeZone.dat"]];
    
    NSArray *list = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    NSMutableArray *idList = [NSMutableArray arrayWithCapacity:list.count];
    NSMutableArray *nameList = [NSMutableArray arrayWithCapacity:list.count];
    
    for (NSDictionary *dict in list)
    {
        int tzID = [[dict objectForKey:@"timezone_key"] intValue];
        
        NSString *tzName = [dict objectForKey:@"timezone_name"];
        
        [idList addObject:[NSNumber numberWithInt:tzID]];
        [nameList addObject:tzName];
    }

    self.timeZoneDict = [NSDictionary dictionaryWithObjects:nameList forKeys:idList];
}

- (void) saveSettingDict
{
	NSNumber *skinSetting = [NSNumber numberWithInt:self.skinStyle];
	[settingDict setValue:skinSetting forKey:@"SkinStyle"];
	
	NSNumber *weekStartSetting = [NSNumber numberWithInt:self.weekStart];
	[settingDict setValue:weekStartSetting forKey:@"WeekStart"];
    
	NSNumber *landscapeModeEnableSetting = [NSNumber numberWithInt:(self.landscapeModeEnable?1:0)];
	[settingDict setValue:landscapeModeEnableSetting forKey:@"LandscapeModeEnable"];
    
	NSNumber *tabBarAutoHideSetting = [NSNumber numberWithBool:self.tabBarAutoHide];
	[settingDict setValue:tabBarAutoHideSetting forKey:@"TabBarAutoHide"];
    
	NSNumber *snoozeDurationSetting = [NSNumber numberWithInt:self.snoozeDuration];
	[settingDict setValue:snoozeDurationSetting forKey:@"SnoozeDuration"];
	
	NSNumber *taskDurationSetting = [NSNumber numberWithInt:self.taskDuration];
	[settingDict setValue:taskDurationSetting forKey:@"TaskDuration"];
	
	NSNumber *taskDefaultProjectSetting = [NSNumber numberWithInt:self.taskDefaultProject];
	[settingDict setValue:taskDefaultProjectSetting forKey:@"TaskDefaultProject"];
	
	NSNumber *eventCombinationSetting = [NSNumber numberWithInt:self.eventCombination];
	[settingDict setValue:eventCombinationSetting forKey:@"EventCombination"];
	
	NSNumber *movableAsEventSetting = [NSNumber numberWithInt:self.movableAsEvent];
	[settingDict setValue:movableAsEventSetting forKey:@"MovableAsEvent"];
    
	NSNumber *newTaskPlacementSetting = [NSNumber numberWithInt:self.newTaskPlacement];
	[settingDict setValue:newTaskPlacementSetting forKey:@"NewTaskPlacement"];
	
	NSNumber *minimumSplitSizeSetting = [NSNumber numberWithInt:self.minimumSplitSize];
	[settingDict setValue:minimumSplitSizeSetting forKey:@"MinimumSplitSize"];
    
	NSNumber *mustDoDaysSetting = [NSNumber numberWithInt:self.mustDoDays];
	[settingDict setValue:mustDoDaysSetting forKey:@"MustDoDays"];
    
	NSNumber *hideFutureTasksSetting = [NSNumber numberWithBool:self.hideFutureTasks];
	[settingDict setValue:hideFutureTasksSetting forKey:@"HideFutureTasks"];

	NSNumber *soundEnabledSetting = [NSNumber numberWithBool:self.soundEnable];
	[settingDict setValue:soundEnabledSetting forKey:@"SoundEnabled"];
	
	[settingDict setValue:self.weekdayStartTime forKey:@"WeekdayStartTime"];
	[settingDict setValue:self.weekdayEndTime forKey:@"WeekdayEndTime"];
	[settingDict setValue:self.weekendStartTime forKey:@"WeekendStartTime"];
	[settingDict setValue:self.weekendEndTime forKey:@"WeekendEndTime"];
	
	NSNumber *syncEnabledSetting = [NSNumber numberWithBool:self.syncEnabled];
	[settingDict setValue:syncEnabledSetting forKey:@"SyncEnabled"];
	NSNumber *autoSyncEnabledSetting = [NSNumber numberWithBool:self.autoSyncEnabled];
	[settingDict setValue:autoSyncEnabledSetting forKey:@"AutoSyncEnabled"];
	NSNumber *autoPushEnabledSetting = [NSNumber numberWithBool:self.autoPushEnabled];
	[settingDict setValue:autoPushEnabledSetting forKey:@"AutoPushEnabled"];
    
	NSNumber *ekAutoSyncEnabledSetting = [NSNumber numberWithBool:self.ekAutoSyncEnabled];
	[settingDict setValue:ekAutoSyncEnabledSetting forKey:@"EKAutoSyncEnabled"];
    
	NSNumber *ekSyncEnabledSetting = [NSNumber numberWithBool:self.ekSyncEnabled];
	[settingDict setValue:ekSyncEnabledSetting forKey:@"EKSyncEnabled"];
    
	NSNumber *rmdSyncEnabledSetting = [NSNumber numberWithBool:self.rmdSyncEnabled];
	[settingDict setValue:rmdSyncEnabledSetting forKey:@"ReminderSyncEnabled"];
	
	NSNumber *syncWindowStartSetting = [NSNumber numberWithInt:self.syncWindowStart];
	[settingDict setValue:syncWindowStartSetting forKey:@"SyncWindowStart"];
	
	NSNumber *syncWindowEndSetting = [NSNumber numberWithInt:self.syncWindowEnd];
	[settingDict setValue:syncWindowEndSetting forKey:@"SyncWindowEnd"];
	
	NSNumber *syncDirectionSetting = [NSNumber numberWithInt:self.syncDirection];
	[settingDict setValue:syncDirectionSetting forKey:@"SyncDirection"];
    
	NSNumber *deleteWarningSetting = [NSNumber numberWithInt:(self.deleteWarning?1:0)];
	[settingDict setValue:deleteWarningSetting forKey:@"DeleteWarning"];
    
	NSNumber *doneWarningSetting = [NSNumber numberWithInt:(self.doneWarning?1:0)];
	[settingDict setValue:doneWarningSetting forKey:@"DoneWarning"];
    
	NSNumber *hideWarningSetting = [NSNumber numberWithInt:(self.hideWarning?1:0)];
	[settingDict setValue:hideWarningSetting forKey:@"HideWarning"];
    
	NSNumber *timeZoneSupportSetting = [NSNumber numberWithBool:self.timeZoneSupport];
	[settingDict setValue:timeZoneSupportSetting forKey:@"TimeZoneSupport"];

	NSNumber *timeZoneIDSetting = [NSNumber numberWithInt:self.timeZoneID];
	[settingDict setValue:timeZoneIDSetting forKey:@"TimeZoneID"];
    
    // geo fencing
    NSNumber *geoFencingEnableSetting = [NSNumber numberWithBool:self.geoFencingEnable];
	[settingDict setValue:geoFencingEnableSetting forKey:@"GeoFencingEnable"];
    
    NSNumber *geoFencingIntervalSetting = [NSNumber numberWithInt:self.geoFencingInterval];
	[settingDict setValue:geoFencingIntervalSetting forKey:@"GeoFencingInterval"];
    
	if (self.updateTime != nil)
	{
		NSNumber *updateTimeSetting = [NSNumber numberWithDouble:[self.updateTime timeIntervalSince1970]];
		[self.settingDict setValue:updateTimeSetting forKey:@"UpdateTime"];
	}
    
    [settingDict setValue:self.dbVersion forKey:@"DBVersion"];
    [settingDict setValue:self.appVersion forKey:@"AppVersion"];
    
	[self.settingDict writeToFile:[Common getFilePath:@"Settings.dat"] atomically:YES];
}

- (void) saveDayManagerDict
{
	[dayManagerDict setValue:self.monStartTime forKey:@"MonStartTime"];
	[dayManagerDict setValue:self.tueStartTime forKey:@"TueStartTime"];
	[dayManagerDict setValue:self.wedStartTime forKey:@"WedStartTime"];
	[dayManagerDict setValue:self.thuStartTime forKey:@"ThuStartTime"];
	[dayManagerDict setValue:self.friStartTime forKey:@"FriStartTime"];
	[dayManagerDict setValue:self.satStartTime forKey:@"SatStartTime"];
	[dayManagerDict setValue:self.sunStartTime forKey:@"SunStartTime"];
	
	[dayManagerDict setValue:self.monEndTime forKey:@"MonEndTime"];
	[dayManagerDict setValue:self.tueEndTime forKey:@"TueEndTime"];
	[dayManagerDict setValue:self.wedEndTime forKey:@"WedEndTime"];
	[dayManagerDict setValue:self.thuEndTime forKey:@"ThuEndTime"];
	[dayManagerDict setValue:self.friEndTime forKey:@"FriEndTime"];
	[dayManagerDict setValue:self.satEndTime forKey:@"SatEndTime"];
	[dayManagerDict setValue:self.sunEndTime forKey:@"SunEndTime"];
    
    
	[self.dayManagerDict writeToFile:[Common getFilePath:@"DayManager.dat"] atomically:YES];
}

- (void) saveHintDict
{
	NSNumber *eventMapHintSetting = [NSNumber numberWithInt:(self.eventMapHint?1:0)];
	[self.hintDict setValue:eventMapHintSetting forKey:@"EventMapHint"];
	
	NSNumber *smartListHintSetting = [NSNumber numberWithInt:(self.smartListHint?1:0)];
	[self.hintDict setValue:smartListHintSetting forKey:@"SmartListHint"];

    NSNumber *noteHintSetting = [NSNumber numberWithInt:(self.noteHint?1:0)];
	[self.hintDict setValue:noteHintSetting forKey:@"NoteHint"];
		
	NSNumber *weekViewHintSetting = [NSNumber numberWithInt:(self.weekViewHint?1:0)];
	[self.hintDict setValue:weekViewHintSetting forKey:@"WeekViewHint"];
    
	NSNumber *weekDayQuickAddHintSetting = [NSNumber numberWithInt:(self.weekDayQuickAddHint?1:0)];
	[self.hintDict setValue:weekDayQuickAddHintSetting forKey:@"WeekDayQuickAddHint"];
	   
	NSNumber *calendarHintSetting = [NSNumber numberWithInt:(self.calendarHint?1:0)];
	[self.hintDict setValue:calendarHintSetting forKey:@"CalendarHint"];
	
	NSNumber *multiSelectHintSetting = [NSNumber numberWithInt:(self.multiSelectHint?1:0)];
	[self.hintDict setValue:multiSelectHintSetting forKey:@"MultiSelectHint"];
		
	NSNumber *monthViewHintSetting = [NSNumber numberWithInt:(self.monthViewHint?1:0)];
	[self.hintDict setValue:monthViewHintSetting forKey:@"MonthViewHint"];
    
	NSNumber *rtDoneHintSetting = [NSNumber numberWithInt:(self.rtDoneHint?1:0)];
	[self.hintDict setValue:rtDoneHintSetting forKey:@"RTDoneHint"];
	
	NSNumber *syncMatchHintSetting = [NSNumber numberWithInt:(self.syncMatchHint?1:0)];
	[self.hintDict setValue:syncMatchHintSetting forKey:@"SyncMatchHint"];
	
	NSNumber *projectHintSetting = [NSNumber numberWithInt:(self.projectHint?1:0)];
	[self.hintDict setValue:projectHintSetting forKey:@"ProjectHint"];
	
	NSNumber *projectDetailHintSetting = [NSNumber numberWithInt:(self.projectDetailHint?1:0)];
	[self.hintDict setValue:projectDetailHintSetting forKey:@"ProjectDetailHint"];
	
	NSNumber *firstTimeEventSyncHintSetting = [NSNumber numberWithInt:(self.firstTimeEventSyncHint?1:0)];
	[self.hintDict setValue:firstTimeEventSyncHintSetting forKey:@"FirstTimeEventSyncHint"];
	
	NSNumber *workingTimeHintSetting = [NSNumber numberWithInt:(self.workingTimeHint?1:0)];
	[self.hintDict setValue:workingTimeHintSetting forKey:@"WorkingTimeHint"];
	
	NSNumber *starTabHintSetting = [NSNumber numberWithInt:(self.starTabHint?1:0)];
	[self.hintDict setValue:starTabHintSetting forKey:@"StarTabHint"];
	
	NSNumber *gtdoTabHintSetting = [NSNumber numberWithInt:(self.gtdoTabHint?1:0)];
	[self.hintDict setValue:gtdoTabHintSetting forKey:@"GTDoTabHint"];
	
	NSNumber *tagHintSetting = [NSNumber numberWithInt:(self.tagHint?1:0)];
	[self.hintDict setValue:tagHintSetting forKey:@"TagHint"];
    
	NSNumber *featureHintSetting = [NSNumber numberWithInt:(self.featureHint?1:0)];
	[self.hintDict setValue:featureHintSetting forKey:@"FeatureHint"];
    
	NSNumber *transparentHintSetting = [NSNumber numberWithInt:(self.transparentHint?1:0)];
	[self.hintDict setValue:transparentHintSetting forKey:@"TransparentHint"];
	
	NSNumber *msdBackupHintSetting = [NSNumber numberWithBool:self.msdBackupHint];
	[self.hintDict setValue:msdBackupHintSetting forKey:@"MSDBackupHint"];

	NSNumber *guruHintSetting = [NSNumber numberWithBool:self.guruHint];
	[self.hintDict setValue:guruHintSetting forKey:@"GuruHint"];

	NSNumber *detailHintSetting = [NSNumber numberWithBool:self.detailHint];
	[self.hintDict setValue:detailHintSetting forKey:@"DetailHint"];
    
	NSNumber *move2MMConfirmationSetting = [NSNumber numberWithBool:self.move2MMConfirmation];
	[self.hintDict setValue:move2MMConfirmationSetting forKey:@"Move2MMConfirmation"];
    
	[self.hintDict writeToFile:[Common getFilePath:@"Hints.dat"] atomically:YES];
}

- (void) saveToodledoSyncDict
{
	NSNumber *tdAutoSyncEnabledSetting = [NSNumber numberWithBool:self.tdAutoSyncEnabled];
	[self.toodledoSyncDict setValue:tdAutoSyncEnabledSetting forKey:@"TDAutoSyncEnabled"];
    
	NSNumber *tdSyncEnabledSetting = [NSNumber numberWithBool:self.tdSyncEnabled];
	[self.toodledoSyncDict setValue:tdSyncEnabledSetting forKey:@"TDSyncEnabled"];
	
	NSNumber *tdVerifiedSetting = [NSNumber numberWithBool:self.tdVerified];
	[self.toodledoSyncDict setValue:tdVerifiedSetting forKey:@"TDVerified"];
    
	[self.toodledoSyncDict setValue:self.tdEmail forKey:@"Email"];
	
	NSString *encodedPwd = [NSDataBase64 base64Encoding:[self.tdPassword dataUsingEncoding:NSUTF8StringEncoding]];
	[self.toodledoSyncDict setValue:encodedPwd forKey:@"Pwd"];
	
	NSNumber *tdSyncResetSetting = [NSNumber numberWithInt:(self.tdSyncReset?1:0)];
	[self.toodledoSyncDict setValue:tdSyncResetSetting forKey:@"Reset"];
	
    
	[self.toodledoSyncDict writeToFile:[Common getFilePath:@"ToodledoSync.dat"] atomically:YES];
}

- (void) saveSDWSyncDict
{
    NSNumber *sdwAutoSyncEnabledSetting = [NSNumber numberWithBool:self.sdwAutoSyncEnabled];
	[self.sdwSyncDict setValue:sdwAutoSyncEnabledSetting forKey:@"SDWAutoSyncEnabled"];
    
    NSNumber *sdwSyncEnabledSetting = [NSNumber numberWithBool:self.sdwSyncEnabled];
	[self.sdwSyncDict setValue:sdwSyncEnabledSetting forKey:@"SDWSyncEnabled"];
    
	[self.sdwSyncDict writeToFile:[Common getFilePath:@"SDWSync.dat"] atomically:YES];
}

- (void) saveEKSyncDict
{
	NSNumber *ekAutoSyncEnabledSetting = [NSNumber numberWithBool:self.ekAutoSyncEnabled];
	[self.ekSyncDict setValue:ekAutoSyncEnabledSetting forKey:@"EKAutoSyncEnabled"];
    
	NSNumber *ekSyncEnabledSetting = [NSNumber numberWithBool:self.ekSyncEnabled];
	[self.ekSyncDict setValue:ekSyncEnabledSetting forKey:@"EKSyncEnabled"];
    
	NSNumber *rmdSyncEnabledSetting = [NSNumber numberWithBool:self.rmdSyncEnabled];
	[self.ekSyncDict setValue:rmdSyncEnabledSetting forKey:@"ReminderSyncEnabled"];
    
	if (self.rmdLastSyncTime != nil)
	{
		NSNumber *rmdLastSyncTimeSetting = [NSNumber numberWithDouble:[self.rmdLastSyncTime timeIntervalSince1970]];
		[self.ekSyncDict setValue:rmdLastSyncTimeSetting forKey:@"ReminderLastSyncTime"];
	}
	
    [self.ekSyncDict writeToFile:[Common getFilePath:@"EKSync.dat"] atomically:YES];
}

- (void) saveFilterPresets
{
	if (![self.filterPresets writeToFile:[Common getFilePath:@"FilterPresets.dat"] atomically:YES])
    {
        //printf("write array failed\n");
    }
}

- (int) getLaunchCount
{
	NSNumber *launchCount = [self.settingDict objectForKey:@"LaunchCount"];
	
	if (launchCount != nil)
	{
		return [launchCount intValue];
	}
	
	return 0;
}

- (void) saveLaunchCount:(int) count
{
	NSNumber *launchCount = [NSNumber numberWithInt:count];
	
	[settingDict setValue:launchCount forKey:@"LaunchCount"];
	
	[self saveSettingDict];
}

- (void) saveWeekPlannerRows:(int) rows
{
    self.weekPlannerRows = rows;
    
	NSNumber *val = [NSNumber numberWithInt:rows];
	
	[settingDict setValue:val forKey:@"WeekPlannerRows"];
	
	[self saveSettingDict];
}

-(void)changeDBVersion:(NSString *)version
{
	self.dbVersion = version;
	
	[self.settingDict setValue:self.dbVersion forKey:@"DBVersion"];
	
	[self saveSettingDict];
}

- (void) saveDayManager
{
	[self.dayManagerDict setValue:self.dayManagerStartTime forKey:@"DayManagerStartTime"];	
	[self.dayManagerDict setValue:self.dayManagerEndTime forKey:@"DayManagerEndTime"];	
	
	NSNumber *dayUpdateTimeSetting = [NSNumber numberWithDouble:[self.dayManagerUpdateTime timeIntervalSince1970]];	
	[self.dayManagerDict setValue:dayUpdateTimeSetting forKey:@"DayManagerUpdateTime"];
	
	[self saveDayManagerDict];
}

- (BOOL) isMondayAsWeekStart
{
	return (self.weekStart == 1);
}

- (BOOL) checkWorkingTimeChange:(Settings *)settings
{
	return ![self.monStartTime isEqualToString:settings.monStartTime] ||
	![self.tueStartTime isEqualToString:settings.tueStartTime] ||
	![self.wedStartTime isEqualToString:settings.wedStartTime] ||
	![self.thuStartTime isEqualToString:settings.thuStartTime] ||
	![self.friStartTime isEqualToString:settings.friStartTime] ||
	![self.satStartTime isEqualToString:settings.satStartTime] ||
	![self.sunStartTime isEqualToString:settings.sunStartTime] ||
	![self.monEndTime isEqualToString:settings.monEndTime] ||
	![self.tueEndTime isEqualToString:settings.tueEndTime] ||
	![self.wedEndTime isEqualToString:settings.wedEndTime] ||
	![self.thuEndTime isEqualToString:settings.thuEndTime] ||
	![self.friEndTime isEqualToString:settings.friEndTime] ||
	![self.satEndTime isEqualToString:settings.satEndTime] ||
	![self.sunEndTime isEqualToString:settings.sunEndTime];
}

- (WorkingTimeInfo) getWorkingTimeInfo:(BOOL) onWeekend
{
	WorkingTimeInfo ret;
	
	NSArray *startParts = (onWeekend?[self.weekendStartTime componentsSeparatedByString:@":"]:[self.weekdayStartTime componentsSeparatedByString:@":"]);	
	NSArray *endParts = (onWeekend?[self.weekendEndTime componentsSeparatedByString:@":"]:[self.weekdayEndTime componentsSeparatedByString:@":"]);	
	
	ret.beginHour = [[startParts objectAtIndex:0] intValue];
	ret.beginMinute = [[startParts objectAtIndex:1] intValue];
	ret.endHour = [[endParts objectAtIndex:0] intValue];
	ret.endMinute = [[endParts objectAtIndex:1] intValue];
	
	return ret;
}

- (WorkingTimeInfo) getWorkingTimeInfoForDate:(NSDate *) date
{
	NSString *wkStartTime[7] = {self.sunStartTime, self.monStartTime, self.tueStartTime, self.wedStartTime,
		self.thuStartTime, self.friStartTime, self.satStartTime};
	
	NSString *wkEndTime[7] = {self.sunEndTime, self.monEndTime, self.tueEndTime, self.wedEndTime,
		self.thuEndTime, self.friEndTime, self.satEndTime};
	
	NSInteger wkday = [Common getWeekday:date]-1;

	NSString *startTime = wkStartTime[wkday];
	
	NSString *endTime = wkEndTime[wkday];
	
	NSArray *startParts = [startTime componentsSeparatedByString:@":"];
	NSArray *endParts = [endTime componentsSeparatedByString:@":"];
	
	WorkingTimeInfo ret;
	
	ret.beginHour = [[startParts objectAtIndex:0] intValue];
	ret.beginMinute = [[startParts objectAtIndex:1] intValue];
	ret.endHour = [[endParts objectAtIndex:0] intValue];
	ret.endMinute = [[endParts objectAtIndex:1] intValue];
	
	return ret;
}


- (NSDate *)getTodayWorkingStartTime
{
	return [self getWorkingStartTimeForDate:[NSDate date]];
}

- (NSDate *)getTodayWorkingEndTime
{
	return [self getWorkingEndTimeForDate:[NSDate date]];
}

- (NSDate *)getWorkingStartTime:(BOOL)onWeekend 
{
	WorkingTimeInfo wti = [self getWorkingTimeInfo:onWeekend];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = wti.beginHour;
	comps.minute = wti.beginMinute;
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
}


- (NSDate *)getWorkingEndTime:(BOOL)onWeekend 
{
	WorkingTimeInfo wti = [self getWorkingTimeInfo:onWeekend];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = wti.endHour;
	comps.minute = wti.endMinute;
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
	
}

- (NSDate *)getWorkingStartTimeOnDay:(NSInteger) wkday  
{
	NSString *wkStartTime[7] = {self.sunStartTime, self.monStartTime, self.tueStartTime, self.wedStartTime,
		self.thuStartTime, self.friStartTime, self.satStartTime};
	
	NSString *startTime = wkStartTime[wkday-1];
	
	NSArray *timeParts = [startTime componentsSeparatedByString:@":"];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = [[timeParts objectAtIndex:0] intValue];
	comps.minute = [[timeParts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
}

- (NSDate *)getWorkingEndTimeOnDay:(NSInteger) wkday 
{
	NSString *wkEndTime[7] = {self.sunEndTime, self.monEndTime, self.tueEndTime, self.wedEndTime,
		self.thuEndTime, self.friEndTime, self.satEndTime};
	
	NSString *endTime = wkEndTime[wkday-1];

	NSArray *timeParts = [endTime componentsSeparatedByString:@":"];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = [[timeParts objectAtIndex:0] intValue];
	comps.minute = [[timeParts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
}


- (NSDate *)getWorkingStartTimeForDate:(NSDate *)date 
{
	NSString *wkStartTime[7] = {self.sunStartTime, self.monStartTime, self.tueStartTime, self.wedStartTime,
		self.thuStartTime, self.friStartTime, self.satStartTime};
	
	NSInteger wkday = [Common getWeekday:date]-1;

	NSString *startTime = wkStartTime[wkday];
		
	NSArray *timeParts = [startTime componentsSeparatedByString:@":"];
	
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	comps.hour = [[timeParts objectAtIndex:0] intValue];
	comps.minute = [[timeParts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];

	return ret;
}

- (NSDate *)getWorkingEndTimeForDate:(NSDate *)date 
{
	NSString *wkEndTime[7] = {self.sunEndTime, self.monEndTime, self.tueEndTime, self.wedEndTime,
		self.thuEndTime, self.friEndTime, self.satEndTime};
		
	NSInteger wkday = [Common getWeekday:date]-1;
	
	NSString *endTime = wkEndTime[wkday];
	
	NSArray *timeParts = [endTime componentsSeparatedByString:@":"];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	comps.hour = [[timeParts objectAtIndex:0] intValue];
	comps.minute = [[timeParts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
}

- (NSDate *)getDayManagerStartTime 
{
	NSArray *parts = [self.dayManagerStartTime componentsSeparatedByString:@":"];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = [[parts objectAtIndex:0] intValue];
	comps.minute = [[parts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
	
}

- (NSDate *)getDayManagerEndTime 
{
	NSArray *parts = [self.dayManagerEndTime componentsSeparatedByString:@":"];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
	
	comps.hour = [[parts objectAtIndex:0] intValue];
	comps.minute = [[parts objectAtIndex:1] intValue];
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];
	
	return ret;
}

- (void) setWorkingStartTime:(NSDate *)date
{
    NSInteger wkday = [Common getWeekday:date];
    NSString *time = [Common get24TimeString:date];
    
    switch (wkday) 
    {
        case 1:
            self.sunStartTime = time;
            break;
        case 2:
            self.monStartTime = time;
            break;
        case 3:
            self.tueStartTime = time;
            break;
        case 4:
            self.wedStartTime = time;
            break;
        case 5:
            self.thuStartTime = time;
            break;
        case 6:
            self.friStartTime = time;
            break;
        case 7:
            self.satStartTime = time;
            break;            
    }
    
    [self saveWorkingTimes];
}

- (void) setWorkingEndTime:(NSDate *)date
{
    NSInteger wkday = [Common getWeekday:date];
    NSString *time = [Common get24TimeString:date];
    
    switch (wkday) 
    {
        case 1:
            self.sunEndTime = time;
            break;
        case 2:
            self.monEndTime = time;
            break;
        case 3:
            self.tueEndTime = time;
            break;
        case 4:
            self.wedEndTime = time;
            break;
        case 5:
            self.thuEndTime = time;
            break;
        case 6:
            self.friEndTime = time;
            break;
        case 7:
            self.satEndTime = time;
            break;            
    }
    
    [self saveWorkingTimes];    
}

- (NSDate *) getSyncWindowDate:(BOOL) isStart
{
	NSDate *today = [NSDate date];
	
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
	
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:today];
	
	if (isStart)
	{
		comps.hour = 0;
		comps.minute = 0;
		comps.second = 0;
	}
	else
	{
		comps.hour = 23;
		comps.minute = 59;
		comps.second = 59;		
	}
	
	NSDateComponents *wdComps =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
	NSInteger wd = [wdComps weekday];
	
	if (isStart)
	{		
		switch (self.syncWindowStart)
		{
			case 0: //this week
			{
				today=[Common dateByAddNumDay:-(wd-1) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 1: //last week
			{
				today=[Common dateByAddNumDay:-(wd-1+7) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 2: //last month
			{
				if (comps.month == 1)
				{
					comps.month = 12;
					comps.year -= 1;
				}
				else
				{
					comps.month -= 1;
				}
				
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
			case 3: //last 3 months
			{
				if (comps.month <= 3)
				{
					comps.month = (9 + comps.month);
					comps.year -= 1;
				}
				else
				{
					comps.month -= 3;
				}
				
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
			case 4: //last year
			{
				comps.year -= 1;
				comps.month = 1;
				comps.day = 1;
				
				today=[gregorian dateFromComponents:comps];
			}
				break;
			case 5: //all previous
			{
				today=nil;
			}
				break;
				
		}
		
	}
	else
	{
		switch (self.syncWindowEnd)
		{
			case 0: //this week
			{
				today=[Common dateByAddNumDay:(7-wd) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 1: //next week
			{
				today=[Common dateByAddNumDay:(2*7-wd) toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 2: //next month
			{
				if (comps.month >= 11)
				{
					comps.month = (comps.month + 2 - 12);
					comps.year += 1;
				}
				else
				{
					comps.month += 2;
				}
				
				comps.day = 1;
				
				today=[Common dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 3: //next 3 months
			{
				if (comps.month >= 10)
				{
					comps.month = (comps.month + 4 - 12);
					comps.year += 1;
				}
				else
				{
					comps.month += 4;
				}
				
				comps.day = 1;
				
				today=[Common dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 4: //next year
			{
				comps.year += 2;
				comps.month = 1;
				comps.day = 1;
				
				today=[Common dateByAddNumDay:-1 toDate:[gregorian dateFromComponents:comps]];
			}
				break;
			case 5: //all previous
			{
				today=nil;
			}
				break;
				
		}
		
	}
	
	return today;
}

- (void) changeToodledoSync
{
	if (self.tdLastAddEditTime != nil)
	{
		NSNumber *tdLastAddEditTimeSetting = [NSNumber numberWithDouble:[self.tdLastAddEditTime timeIntervalSince1970]];	
		[self.toodledoSyncDict setValue:tdLastAddEditTimeSetting forKey:@"LastAddEditTime"];		
	}

	if (self.tdLastDeleteTime != nil)
	{
		NSNumber *tdLastDeleteTimeSetting = [NSNumber numberWithDouble:[self.tdLastDeleteTime timeIntervalSince1970]];	
		[self.toodledoSyncDict setValue:tdLastDeleteTimeSetting forKey:@"LastDeleteTime"];		
	}

	if (self.tdLastSyncTime != nil)
	{
		NSNumber *tdLastSyncTimeSetting = [NSNumber numberWithDouble:[self.tdLastSyncTime timeIntervalSince1970]];	
		[self.toodledoSyncDict setValue:tdLastSyncTimeSetting forKey:@"LastSyncTime"];		
	}
	
	NSNumber *tdSyncResetSetting = [NSNumber numberWithInt:(self.tdSyncReset?1:0)];	
	[self.toodledoSyncDict setValue:tdSyncResetSetting forKey:@"Reset"];
	
	[self saveToodledoSyncDict];
}

- (void) resetToodledoSync
{
	self.tdSyncReset = YES;
	
	self.tdLastAddEditTime = nil;
	self.tdLastDeleteTime = nil;
	self.tdLastSyncTime = nil;

	NSNumber *tdSyncResetSetting = [NSNumber numberWithInt:(self.tdSyncReset?1:0)];	
	[self.toodledoSyncDict setValue:tdSyncResetSetting forKey:@"Reset"];
	
	[self.toodledoSyncDict removeObjectForKey:@"LastAddEditTime"];
	[self.toodledoSyncDict removeObjectForKey:@"LastDeleteTime"];
	[self.toodledoSyncDict removeObjectForKey:@"LastSyncTime"];
	
	[self saveToodledoSyncDict];
}

- (void) resetReminderSync
{
    self.rmdLastSyncTime = nil;
    
    [self.ekSyncDict removeObjectForKey:@"ReminderLastSyncTime"];
    
    [self saveSDWSync];
    
}

- (void) verifyToodledo:(BOOL)verified
{
    self.tdVerified = verified;
    
    NSNumber *tdVerifiedSetting = [NSNumber numberWithBool:self.tdVerified];
    [self.toodledoSyncDict setValue:tdVerifiedSetting forKey:@"TDVerified"];
    
    [self saveToodledoSyncDict];
}

- (void) saveWorkingTimes
{
	[dayManagerDict setValue:self.monStartTime forKey:@"MonStartTime"];	
	[dayManagerDict setValue:self.tueStartTime forKey:@"TueStartTime"];
	[dayManagerDict setValue:self.wedStartTime forKey:@"WedStartTime"];
	[dayManagerDict setValue:self.thuStartTime forKey:@"ThuStartTime"];
	[dayManagerDict setValue:self.friStartTime forKey:@"FriStartTime"];
	[dayManagerDict setValue:self.satStartTime forKey:@"SatStartTime"];	
	[dayManagerDict setValue:self.sunStartTime forKey:@"SunStartTime"];
	
	[dayManagerDict setValue:self.monEndTime forKey:@"MonEndTime"];	
	[dayManagerDict setValue:self.tueEndTime forKey:@"TueEndTime"];
	[dayManagerDict setValue:self.wedEndTime forKey:@"WedEndTime"];
	[dayManagerDict setValue:self.thuEndTime forKey:@"ThuEndTime"];
	[dayManagerDict setValue:self.friEndTime forKey:@"FriEndTime"];
	[dayManagerDict setValue:self.satEndTime forKey:@"SatEndTime"];	
	[dayManagerDict setValue:self.sunEndTime forKey:@"SunEndTime"];
    
	[self saveDayManagerDict];    
}

- (void) saveSDWSync 
{
	if (self.sdwLastSyncTime != nil)
	{
		NSNumber *sdwLastSyncTimeSetting = [NSNumber numberWithDouble:[self.sdwLastSyncTime timeIntervalSince1970]];	
		[self.sdwSyncDict setValue:sdwLastSyncTimeSetting forKey:@"SDWLastSyncTime"];		
	}

	if (self.sdwLastBackupTime != nil)
	{
		NSNumber *sdwLastBackupTimeSetting = [NSNumber numberWithDouble:[self.sdwLastBackupTime timeIntervalSince1970]];
		[self.sdwSyncDict setValue:sdwLastBackupTimeSetting forKey:@"SDWLastBackupTime"];
	}
    
    if (self.sdwDeviceUUID != nil)
    {
        [self.sdwSyncDict setValue:self.sdwDeviceUUID forKey:@"SDWDeviceUUID"];
    }
    
    [self saveSDWSyncDict];
}

- (void) resetSDWSync
{
    self.sdwLastSyncTime = nil;
    
    [self.sdwSyncDict removeObjectForKey:@"SDWLastSyncTime"];
    
    [self saveSDWSync];
    
}

- (void) verifyMSD:(BOOL)verified
{
    self.sdwVerified = verified;
    
    NSNumber *sdwVerifiedSetting = [NSNumber numberWithBool:self.sdwVerified];
    [self.sdwSyncDict setValue:sdwVerifiedSetting forKey:@"SDWVerified"];
    
    [self saveSDWSync];
}

- (void) saveMSDAccount
{
	[self.sdwSyncDict setValue:self.sdwEmail forKey:@"Email"];
	
	NSString *encodedPwd = [NSDataBase64 base64Encoding:[self.sdwPassword dataUsingEncoding:NSUTF8StringEncoding]]; 
    
	[self.sdwSyncDict setValue:encodedPwd forKey:@"Pwd"];
    
    NSNumber *sdwVerifiedSetting = [NSNumber numberWithBool:self.sdwVerified];	
    [self.sdwSyncDict setValue:sdwVerifiedSetting forKey:@"SDWVerified"];
    
	[self saveSDWSyncDict];
    
}

- (void) saveToodledoAccount
{
	[self.toodledoSyncDict setValue:self.tdEmail forKey:@"Email"];
	
	NSString *encodedPwd = [NSDataBase64 base64Encoding:[self.tdPassword dataUsingEncoding:NSUTF8StringEncoding]]; 
    
	[self.toodledoSyncDict setValue:encodedPwd forKey:@"Pwd"];
    
    NSNumber *tdVerifiedSetting = [NSNumber numberWithBool:self.tdVerified];	
    [self.toodledoSyncDict setValue:tdVerifiedSetting forKey:@"TDVerified"];
    
	[self saveToodledoSyncDict];
    
}

- (void) changeFilterTab:(NSInteger)tab
{
	self.filterTab = tab;
	
	NSNumber *filterTabSetting = [NSNumber numberWithInt:self.filterTab];	
	
	[self.settingDict setValue:filterTabSetting forKey:@"FilterTab"];
	
	[self saveSettingDict];
}

- (void) modifyUpdateTime
{
    self.updateTime = [NSDate date];
    
    NSNumber *updateTimeSetting = [NSNumber numberWithDouble:[self.updateTime timeIntervalSince1970]];
    [self.settingDict setValue:updateTimeSetting forKey:@"UpdateTime"];

    [self saveSettingDict];
}

- (void) enableExternalUpdate
{
	isExternalUpdate = YES;
}

#pragma mark Hints
-(void)enableEventMapHint:(BOOL)enabled
{
	self.eventMapHint = enabled;
	
	[self saveHintDict];
}

-(void)enableSmartListHint:(BOOL)enabled
{
	self.smartListHint = enabled;
	
	[self saveHintDict];
}

-(void)enableNoteHint:(BOOL)enabled
{
	self.noteHint = enabled;
	
	[self saveHintDict];
}

-(void)enableWeekViewHint:(BOOL)enabled
{
	self.weekViewHint = enabled;
	
	[self saveHintDict];
}

-(void)enableWeekDayQuickAddHint:(BOOL)enabled
{
	self.weekDayQuickAddHint = enabled;
	
	[self saveHintDict];
}

-(void)enableCalendarHint:(BOOL)enabled
{
	self.calendarHint = enabled;
	
	[self saveHintDict];
}

-(void)enableMultiSelectHint:(BOOL)enabled
{
	self.multiSelectHint = enabled;
	
	[self saveHintDict];
}

-(void)enableMonthViewHint:(BOOL)enabled
{
	self.monthViewHint = enabled;
	
	[self saveHintDict];
}

-(void)enableRTDoneHint:(BOOL)enabled
{
	self.rtDoneHint = enabled;
	
	[self saveHintDict];
}

-(void)enableSyncMatchHint:(BOOL)enabled
{
	self.syncMatchHint = enabled;
	
	[self saveHintDict];
}

-(void)enableProjectHint:(BOOL)enabled
{
	self.projectHint = enabled;
	
	[self saveHintDict];
}

-(void)enableProjectDetailHint:(BOOL)enabled
{
	self.projectDetailHint = enabled;

	[self saveHintDict];
}

-(void)enableFirstTimeEventSyncHint:(BOOL)enabled
{
	self.firstTimeEventSyncHint = enabled;
	
	[self saveHintDict];
}

-(void)enableWorkingTimeHint:(BOOL)enabled
{
	self.workingTimeHint = enabled;
	
	[self saveHintDict];
}

-(void)enableStarTabHint:(BOOL)enabled
{
	self.starTabHint = enabled;
	
	[self saveHintDict];
}

-(void)enableGTDoTabHint:(BOOL)enabled
{
	self.gtdoTabHint = enabled;
	
	[self saveHintDict];
}

-(void)enableTagHint:(BOOL)enabled
{
	self.tagHint = enabled;
	
	[self saveHintDict];
}

-(void)enableFeatureHint:(BOOL)enabled
{
	self.featureHint = enabled;
		
	[self saveHintDict];
}

-(void)enableTransparentHint:(BOOL)enabled
{
	self.transparentHint = enabled;
	
	[self saveHintDict];
}

-(void)enableMSDBackupHint:(BOOL)enabled
{
	self.msdBackupHint = enabled;
	
	[self saveHintDict];
}

-(void)enableGuruHint:(BOOL)enabled
{
	self.guruHint = enabled;
	
	[self saveHintDict];
}

-(void)enableDetailHint:(BOOL)enabled
{
	self.detailHint = enabled;
	
	[self saveHintDict];
}

-(void)enableHideWarning:(BOOL)enabled
{
	self.hideWarning = enabled;
	
	NSNumber *hideWarningSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.settingDict setValue:hideWarningSetting forKey:@"HideWarning"];
	
	[self saveSettingDict];
}

-(void)clearHintFlags
{
	_evenMapHintShown = NO;
	_smartListHintShown = NO;
    _noteHintShown = NO;
	_weekDayQuickAddHintShown = NO;
	_weekViewHintShown = NO;
	_calendarHintShown = NO;
	_multiSelectHintShown = NO;
	_monthViewHintShown = NO;
	_rtDoneHintShown = NO;
	_syncMatchHintShown = NO;
	_projectHintShown = NO;
	_projectDetailHintShown = NO;
	_firstTimeEventSyncHintShown = NO;
	_workingTimeHintShown = NO;
	_starTabHintShown = NO;
	_gtdoTabHintShown = NO;
	_tagHintShown = NO;
	_featureHintShown = NO;
    _transparentHintShown = NO;
    _detailHintShown = NO;
}

-(void)enableHints
{
    self.eventMapHint = YES;
    self.smartListHint = YES;
    self.noteHint = YES;
    self.weekViewHint = YES;
    self.weekDayQuickAddHint = YES;
    self.calendarHint = YES;
    self.multiSelectHint = YES;
    self.monthViewHint = YES;
    self.rtDoneHint = YES;
    self.syncMatchHint = YES;
    self.projectHint = YES;
    self.projectDetailHint = YES;
    self.firstTimeEventSyncHint = YES;
    self.workingTimeHint = YES;
    self.starTabHint = YES;
    self.gtdoTabHint = YES;
    self.tagHint = YES;
    self.featureHint = YES;
    self.transparentHint = YES;
	self.msdBackupHint = YES;
    self.guruHint = YES;
    self.detailHint = YES;
    self.move2MMConfirmation = YES;
    
    [self saveHintDict];
    
	[self clearHintFlags];
}

- (void) refreshTimeZone
{
    if (self.timeZoneSupport)
    {
        [NSTimeZone setDefaultTimeZone:[Settings getTimeZoneByID:self.timeZoneID]];
    }
    else
    {
        [NSTimeZone setDefaultTimeZone:[NSTimeZone systemTimeZone]];
    }
}

+ (NSInteger) findTimeZoneID:(NSTimeZone *)tz
{
    if ([tz.name isEqualToString:@"America/Port-au-Prince"])
    {
        return -68008; //(GMT-0500) US/Central
    }
    
    Settings *settings = [Settings getInstance];
    
    NSArray *keys = [settings.timeZoneDict allKeys];

    NSMutableArray *names = [NSMutableArray arrayWithCapacity:keys.count];
    
    for (NSNumber *key in keys)
    {
        NSString *tzName = [settings.timeZoneDict objectForKey:key];
        [names addObject:[tzName substringFromIndex:11]];
    }
    
    NSDictionary *nameDict = [NSDictionary dictionaryWithObjects:keys forKeys:names];
    
    NSNumber *key = [nameDict objectForKey:tz.name];
    
    if (key != nil)
    {
        return [key intValue];
    }
    
    return [Common createTimeZoneIDByOffset:tz.secondsFromGMT];
}

+ (NSString *) getTimeZoneDisplayNameByID:(NSInteger)tzID
{
    Settings *settings = [Settings getInstance];

    NSString *name = [settings.timeZoneDict objectForKey:[NSNumber numberWithInt:tzID]];
    
    if (name != nil)
    {
        return [name substringFromIndex:11];
    }
    else if (tzID == 0)
    {
        return @"Floating";
    }
    else if (tzID != -1)
    {
        NSInteger offset = abs(tzID)%128;
        
        NSInteger min = offset%8;
        
        NSInteger hour = (offset-min)/8;

        name = [NSString stringWithFormat:@"(GMT%@%02d%02d)", tzID<0?@"-":@"+", hour, min==7?7:min*15];
        
        return name;
    }
    
    return @"Unknown";
}

+ (NSString *) getTimeZoneNameByID:(NSInteger)tzID
{
    Settings *settings = [Settings getInstance];
    
    NSString *name = [settings.timeZoneDict objectForKey:[NSNumber numberWithInt:tzID]];
        
    return name != nil?name:@"Unknown";
}

+ (NSTimeZone *) getTimeZoneByID:(NSInteger)tzID
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    
    if (tzID != 0)
    {
        if (tzID/128 == 0)
        {
            tz = [NSTimeZone timeZoneForSecondsFromGMT:[Common getSecondsFromTimeZoneID:tzID]];
        }
        else
        {
            tz = [NSTimeZone timeZoneWithName:[Settings getTimeZoneDisplayNameByID:tzID]];
        }
    }
    
    return tz;
}

+ (void)createTimeZoneDictIfNeeded {
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"TimeZone.dat"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TimeZone.dat"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}

+(void)startup
{
    [Settings createTimeZoneDictIfNeeded];
    
    Settings *settings = [Settings getInstance];
    
	[settings clearHintFlags];
    
    [settings refreshTimeZone];
}

+(id)getInstance
{
	if (_settingsSingleton == nil)
	{
		_settingsSingleton = [[Settings alloc] init];
	}
	
	return _settingsSingleton;
}

+(void)free
{
	if (_settingsSingleton != nil)
	{
		[_settingsSingleton release];
		
		_settingsSingleton = nil;
	}
}

@end
