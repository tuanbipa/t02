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

BOOL _versionUpgrade = NO;
BOOL _firstLaunch = NO;

extern BOOL _scFreeVersion;

@implementation Settings

@synthesize skinStyle;
@synthesize weekStart;
@synthesize soundEnable;
@synthesize landscapeModeEnable;
@synthesize tabBarAutoHide;
@synthesize filterTab;

@synthesize taskDuration;
@synthesize taskDefaultProject;
@synthesize eventCombination;
@synthesize movableAsEvent;
@synthesize newTaskPlacement;
@synthesize minimumSplitSize;

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
@synthesize ekAutoSyncEnabled;
@synthesize ekSyncEnabled;
@synthesize syncWindowStart;
@synthesize syncWindowEnd;
@synthesize syncDirection;

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

@synthesize deleteWarning;
@synthesize doneWarning;
@synthesize hideWarning;

@synthesize tdAutoSyncEnabled;
@synthesize tdSyncEnabled;
@synthesize tdVerified;
@synthesize tdEmail;
@synthesize tdPassword;
@synthesize tdSyncReset; 
@synthesize tdLastAddEditTime;
@synthesize tdLastDeleteTime;
@synthesize tdLastSyncTime;
@synthesize ekLastSyncTime;

@synthesize sdwEmail;
@synthesize sdwPassword;
@synthesize sdwDeviceUUID;
@synthesize syncSource;
@synthesize sdwAutoSyncEnabled;
@synthesize sdwSyncEnabled;
@synthesize sdwVerified;
@synthesize sdwLastSyncTime;

@synthesize weekPlannerRows;
@synthesize weekPlannerColumns;	
@synthesize mustDoDays;

@synthesize updateTime;

@synthesize dbVersion;
//@synthesize oldAppVersion;

@synthesize settingDict;
@synthesize hintDict;
@synthesize dayManagerDict;
@synthesize toodledoSyncDict;
@synthesize sdwSyncDict;

@synthesize filterPresets;

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
		
		self.taskDuration = DEFAULT_TASK_DURATION;
		self.taskDefaultProject = 0;
		self.eventCombination = 0;
		self.movableAsEvent = 0;
		//self.newTaskPlacement = 0; //0:on top - 1: at bottom
        self.newTaskPlacement = 1;
		self.minimumSplitSize = 15*60;
		
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
        
		self.ekAutoSyncEnabled = NO;
        self.ekSyncEnabled = NO;
		self.syncWindowStart = 1;
		self.syncWindowEnd = 2;
		self.syncDirection = SYNC_2WAY;
		
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
		
		self.deleteWarning = YES;
		self.doneWarning = YES;
		self.hideWarning = YES;
		
		self.tdAutoSyncEnabled = NO;
		self.tdSyncEnabled = NO;
        self.tdVerified = NO;
		self.tdEmail = @"";
		self.tdPassword = @"";
		
		self.tdSyncReset = NO;
		self.tdLastAddEditTime = nil;
		self.tdLastDeleteTime = nil;
		self.tdLastSyncTime = nil;
		self.ekLastSyncTime = nil;
		
		self.weekPlannerRows = 1;
        self.mustDoDays = 0;
        
        self.sdwEmail = @"";
        self.sdwPassword = @"";
        
        self.sdwDeviceUUID = nil;
        self.syncSource = 0;
        self.sdwAutoSyncEnabled = NO;
        self.sdwSyncEnabled = YES;
        self.sdwVerified = NO;
        self.sdwLastSyncTime = nil;
        
        self.updateTime = nil;
        
        //self.filterPresets = [NSMutableArray arrayWithCapacity:3];
        
        isExternalUpdate = NO;
		
		self.dbVersion = @"4.0";

		//self.oldAppVersion = nil;
		
		[self loadSettingDict];
		
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
		
        //v4.0: allow to Task move as Event
        /*
		NSNumber *movableAsEventSetting = [self.settingDict objectForKey:@"MovableAsEvent"];
		
		if (movableAsEventSetting != nil)
		{
			self.movableAsEvent = [movableAsEventSetting intValue];
		}	

		NSNumber *newTaskPlacementSetting = [self.settingDict objectForKey:@"NewTaskPlacement"];
		
		if (newTaskPlacementSetting != nil)
		{
			self.newTaskPlacement = [newTaskPlacementSetting intValue];
		}		
        */
        
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
        
		NSNumber *updateTimeSetting = [self.settingDict objectForKey:@"UpdateTime"];
		
		if (updateTimeSetting != nil)
		{
			self.updateTime = [NSDate dateWithTimeIntervalSince1970:[updateTimeSetting doubleValue]];
		}
		
		NSString *version = [self.settingDict objectForKey:@"DBVersion"];
		
		if (version != nil)
		{
			self.dbVersion = version;
		}		
		else
		{
			[settingDict setValue:self.dbVersion forKey:@"DBVersion"];	
			
			[self saveSettingDict];
		}
		
		version = [self.settingDict objectForKey:@"AppVersion"];
		
		NSString *newVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		
		_versionUpgrade = NO;
		
		if (![newVersion isEqualToString:version])
		{
            if (version == nil)
            {
                _firstLaunch = YES;
            }
			else
			{
				_versionUpgrade = YES;
			}
			
			[settingDict setValue:newVersion forKey:@"AppVersion"];	
			
			[self saveSettingDict];			
		}
		
        if (_versionUpgrade && [newVersion isEqualToString:@"3.1"])
		{
			//upgrade to 3.1
			self.ekAutoSyncEnabled = NO;
			self.tdAutoSyncEnabled = NO;
			
			self.syncWindowStart = 1;
			self.syncWindowEnd = 2;
			
			[self saveSettingDict];
		}
        
        if (_versionUpgrade && [newVersion isEqualToString:@"3.2"])
        {
            //disable auto-sync so users can see What's News with no crash
            self.ekAutoSyncEnabled = NO;
			self.tdAutoSyncEnabled = NO;
            
            [self saveSettingDict];
        }
		
		if (_scFreeVersion)
		{
			self.syncWindowStart = 1;
			self.syncWindowEnd = 1;
			
			[self saveSettingDict];			
		}
        
		[self loadDayManagerDict];
		
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
		
		
		[self loadHintDict];
		
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
        
        if (_versionUpgrade)
        {
            self.featureHint = YES;
        }
		
		[self loadToodledoSyncDict];
        
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

		NSNumber *ekLastSyncTimeSetting = [self.toodledoSyncDict objectForKey:@"EKLastSyncTime"];
		
		if (ekLastSyncTimeSetting != nil)
		{
			self.ekLastSyncTime = [NSDate dateWithTimeIntervalSince1970:[ekLastSyncTimeSetting doubleValue]];
		}
        
		[self loadSDWSyncDict];
		
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
        
        [self loadFilterPresets];
        
	}
	
	return self;
}

- (id) copyWithZone:(NSZone*) zone{
	Settings *copy = [[Settings alloc] init];
	copy.skinStyle = skinStyle;
	copy.weekStart = weekStart;
	copy.landscapeModeEnable = landscapeModeEnable;
	copy.tabBarAutoHide = tabBarAutoHide;
	
	copy.taskDuration = taskDuration;
	copy.taskDefaultProject = taskDefaultProject;
	copy.eventCombination = eventCombination;
	copy.movableAsEvent = movableAsEvent;
	copy.minimumSplitSize = minimumSplitSize;
    copy.mustDoDays = mustDoDays;
	
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
	
    copy.ekSyncEnabled = ekSyncEnabled;
	copy.ekAutoSyncEnabled = ekAutoSyncEnabled;
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
    
    copy.updateTime = updateTime;
	
	return copy;
}

-(void) updateSettings:(Settings *) settings
{
	self.skinStyle = settings.skinStyle;
	self.weekStart = settings.weekStart;
	self.landscapeModeEnable = settings.landscapeModeEnable;
	self.tabBarAutoHide = settings.tabBarAutoHide;
	
	self.taskDuration = settings.taskDuration;
	self.taskDefaultProject = settings.taskDefaultProject;
	self.eventCombination = settings.eventCombination;
	self.movableAsEvent = settings.movableAsEvent;
	self.newTaskPlacement = settings.newTaskPlacement;
	self.minimumSplitSize = settings.minimumSplitSize;
    self.mustDoDays = settings.mustDoDays;
	
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
    self.ekSyncEnabled = settings.ekSyncEnabled;
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
    
    self.updateTime = settings.updateTime;
    
	if (!isExternalUpdate)
	{
		self.updateTime = [NSDate date];	
	}
	
	isExternalUpdate = NO;    
	
	NSNumber *skinSetting = [NSNumber numberWithInt:self.skinStyle];	
	[settingDict setValue:skinSetting forKey:@"SkinStyle"];	
	
	NSNumber *weekStartSetting = [NSNumber numberWithInt:self.weekStart];	
	[settingDict setValue:weekStartSetting forKey:@"WeekStart"];	

	NSNumber *landscapeModeEnableSetting = [NSNumber numberWithInt:(self.landscapeModeEnable?1:0)];	
	[settingDict setValue:landscapeModeEnableSetting forKey:@"LandscapeModeEnable"];	

	NSNumber *tabBarAutoHideSetting = [NSNumber numberWithBool:self.tabBarAutoHide];
	[settingDict setValue:tabBarAutoHideSetting forKey:@"TabBarAutoHide"];	
	
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
	
	[settingDict setValue:self.weekdayStartTime forKey:@"WeekdayStartTime"];	
	[settingDict setValue:self.weekdayEndTime forKey:@"WeekdayEndTime"];	
	[settingDict setValue:self.weekendStartTime forKey:@"WeekendStartTime"];	
	[settingDict setValue:self.weekendEndTime forKey:@"WeekendEndTime"];
	
	NSNumber *syncEnabledSetting = [NSNumber numberWithBool:self.syncEnabled];
	[settingDict setValue:syncEnabledSetting forKey:@"SyncEnabled"];
    
	NSNumber *ekAutoSyncEnabledSetting = [NSNumber numberWithBool:self.ekAutoSyncEnabled];
	[settingDict setValue:ekAutoSyncEnabledSetting forKey:@"EKAutoSyncEnabled"];	

	NSNumber *ekSyncEnabledSetting = [NSNumber numberWithBool:self.ekSyncEnabled];	
	[settingDict setValue:ekSyncEnabledSetting forKey:@"EKSyncEnabled"];	
	
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
    
	if (self.updateTime != nil)
	{
		NSNumber *updateTimeSetting = [NSNumber numberWithDouble:[self.updateTime timeIntervalSince1970]];
		[self.settingDict setValue:updateTimeSetting forKey:@"UpdateTime"];
	}    
	
	[self saveSettingDict];
	
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
	
	[self saveToodledoSyncDict];
	
    /*
	[self.sdwSyncDict setValue:self.sdwEmail forKey:@"Email"];
	
	encodedPwd = [NSDataBase64 base64Encoding:[self.sdwPassword dataUsingEncoding:NSUTF8StringEncoding]]; 
	[self.sdwSyncDict setValue:encodedPwd forKey:@"Pwd"];
    
    NSNumber *syncSourceSetting = [NSNumber numberWithInt:self.syncSource];	
	[self.sdwSyncDict setValue:syncSourceSetting forKey:@"SyncSource"];
    */
    
    NSNumber *sdwAutoSyncEnabledSetting = [NSNumber numberWithBool:self.sdwAutoSyncEnabled];	
	[self.sdwSyncDict setValue:sdwAutoSyncEnabledSetting forKey:@"SDWAutoSyncEnabled"];

    NSNumber *sdwSyncEnabledSetting = [NSNumber numberWithBool:self.sdwSyncEnabled];	
	[self.sdwSyncDict setValue:sdwSyncEnabledSetting forKey:@"SDWSyncEnabled"];
    
    /*
    NSNumber *sdwVerifiedSetting = [NSNumber numberWithBool:self.sdwVerified];	
	[self.sdwSyncDict setValue:sdwVerifiedSetting forKey:@"SDWVerified"];
    */
    
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
}

- (void) loadDayManagerDict
{
	self.dayManagerDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"DayManager.dat"]];
	
	if (self.dayManagerDict == nil)
	{
		self.dayManagerDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
}

- (void) loadHintDict
{
	self.hintDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"Hints.dat"]];
	
	if (self.hintDict == nil)
	{
		self.hintDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
}

- (void) loadToodledoSyncDict
{
	self.toodledoSyncDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"ToodledoSync.dat"]];
	
	if (self.toodledoSyncDict == nil)
	{
		self.toodledoSyncDict = [NSMutableDictionary dictionaryWithCapacity:5];
	}
}

- (void) loadSDWSyncDict
{
	self.sdwSyncDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"SDWSync.dat"]];
	
	if (self.sdwSyncDict == nil)
	{
		self.sdwSyncDict = [NSMutableDictionary dictionaryWithCapacity:5];
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

- (void) saveSettingDict
{
	[self.settingDict writeToFile:[Common getFilePath:@"Settings.dat"] atomically:YES];
}

- (void) saveDayManagerDict
{
	[self.dayManagerDict writeToFile:[Common getFilePath:@"DayManager.dat"] atomically:YES];
}

- (void) saveHintDict
{
	[self.hintDict writeToFile:[Common getFilePath:@"Hints.dat"] atomically:YES];
}

- (void) saveToodledoSyncDict
{
	[self.toodledoSyncDict writeToFile:[Common getFilePath:@"ToodledoSync.dat"] atomically:YES];
}

- (void) saveSDWSyncDict
{
	[self.sdwSyncDict writeToFile:[Common getFilePath:@"SDWSync.dat"] atomically:YES];
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

- (void) saveEKSync
{
	if (self.ekLastSyncTime != nil)
	{
		NSNumber *ekLastSyncTimeSetting = [NSNumber numberWithDouble:[self.ekLastSyncTime timeIntervalSince1970]];	
		[self.toodledoSyncDict setValue:ekLastSyncTimeSetting forKey:@"EKLastSyncTime"];	
		
		[self saveToodledoSyncDict];
	}	
}

- (void) saveSDWSync 
{
	if (self.sdwLastSyncTime != nil)
	{
		NSNumber *sdwLastSyncTimeSetting = [NSNumber numberWithDouble:[self.sdwLastSyncTime timeIntervalSince1970]];	
		[self.sdwSyncDict setValue:sdwLastSyncTimeSetting forKey:@"SDWLastSyncTime"];		
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
	self.ekLastSyncTime = nil;
    
    self.sdwEmail = nil;
    self.sdwPassword = nil;
    self.sdwDeviceUUID = nil;
    self.sdwLastSyncTime = nil;
	
	self.dbVersion = nil;
	//self.oldAppVersion = nil;
	
	self.settingDict = nil;
	self.dayManagerDict = nil;
	self.hintDict = nil;
    self.sdwSyncDict = nil;
    self.toodledoSyncDict = nil;
    
    self.filterPresets = nil;
    
    self.updateTime = nil;
	
    [super dealloc];
}

#pragma mark Hints
-(void)enableEventMapHint:(BOOL)enabled
{
	self.eventMapHint = enabled;
	
	NSNumber *eventMapHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:eventMapHintSetting forKey:@"EventMapHint"];
	
	[self saveHintDict];
}

-(void)enableSmartListHint:(BOOL)enabled
{
	self.smartListHint = enabled;
	
	NSNumber *smartListHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:smartListHintSetting forKey:@"SmartListHint"];
	
	[self saveHintDict];
}

-(void)enableNoteHint:(BOOL)enabled
{
	self.noteHint = enabled;
	
	NSNumber *noteHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:noteHintSetting forKey:@"NoteHint"];
	
	[self saveHintDict];
}

-(void)enableWeekViewHint:(BOOL)enabled
{
	self.weekViewHint = enabled;
	
	NSNumber *weekViewHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:weekViewHintSetting forKey:@"WeekViewHint"];
	
	[self saveHintDict];
}

-(void)enableWeekDayQuickAddHint:(BOOL)enabled
{
	self.weekDayQuickAddHint = enabled;
	
	NSNumber *weekDayQuickAddHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:weekDayQuickAddHintSetting forKey:@"WeekDayQuickAddHint"];
	
	[self saveHintDict];
}

-(void)enableCalendarHint:(BOOL)enabled
{
	self.calendarHint = enabled;
	
	NSNumber *calendarHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:calendarHintSetting forKey:@"CalendarHint"];
	
	[self saveHintDict];
}

-(void)enableMultiSelectHint:(BOOL)enabled
{
	self.multiSelectHint = enabled;
	
	NSNumber *multiSelectHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:multiSelectHintSetting forKey:@"MultiSelectHint"];
	
	[self saveHintDict];
}

-(void)enableMonthViewHint:(BOOL)enabled
{
	self.monthViewHint = enabled;
	
	NSNumber *monthViewHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:monthViewHintSetting forKey:@"MonthViewHint"];
	
	[self saveHintDict];
}

-(void)enableRTDoneHint:(BOOL)enabled
{
	self.rtDoneHint = enabled;
	
	NSNumber *rtDoneHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:rtDoneHintSetting forKey:@"RTDoneHint"];
	
	[self saveHintDict];
}

-(void)enableSyncMatchHint:(BOOL)enabled
{
	self.syncMatchHint = enabled;
	
	NSNumber *syncMatchHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:syncMatchHintSetting forKey:@"SyncMatchHint"];
	
	[self saveHintDict];
}

-(void)enableProjectHint:(BOOL)enabled
{
	self.projectHint = enabled;
	
	NSNumber *projectHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:projectHintSetting forKey:@"ProjectHint"];
	
	[self saveHintDict];
}

-(void)enableProjectDetailHint:(BOOL)enabled
{
	self.projectDetailHint = enabled;
	
	NSNumber *projectDetailHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:projectDetailHintSetting forKey:@"ProjectDetailHint"];
	
	[self saveHintDict];
}

-(void)enableFirstTimeEventSyncHint:(BOOL)enabled
{
	self.firstTimeEventSyncHint = enabled;
	
	NSNumber *firstTimeEventSyncHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:firstTimeEventSyncHintSetting forKey:@"FirstTimeEventSyncHint"];
	
	[self saveHintDict];
}

-(void)enableWorkingTimeHint:(BOOL)enabled
{
	self.workingTimeHint = enabled;
	
	NSNumber *workingTimeHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:workingTimeHintSetting forKey:@"WorkingTimeHint"];
	
	[self saveHintDict];
}

-(void)enableStarTabHint:(BOOL)enabled
{
	self.starTabHint = enabled;
	
	NSNumber *starTabHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:starTabHintSetting forKey:@"StarTabHint"];
	
	[self saveHintDict];
}

-(void)enableGTDoTabHint:(BOOL)enabled
{
	self.gtdoTabHint = enabled;
	
	NSNumber *gtdoTabHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:gtdoTabHintSetting forKey:@"GTDoTabHint"];
	
	[self saveHintDict];
}

-(void)enableTagHint:(BOOL)enabled
{
	self.tagHint = enabled;
	
	NSNumber *tagHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:tagHintSetting forKey:@"TagHint"];
	
	[self saveHintDict];
}

-(void)enableFeatureHint:(BOOL)enabled
{
	self.featureHint = enabled;
	
	NSNumber *featureHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:featureHintSetting forKey:@"FeatureHint"];
	
	[self saveHintDict];
}

-(void)enableTransparentHint:(BOOL)enabled
{
	self.transparentHint = enabled;
	
	NSNumber *transparentHintSetting = [NSNumber numberWithInt:(enabled?1:0)];
	[self.hintDict setValue:transparentHintSetting forKey:@"TransparentHint"];
	
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
}

-(void)enableHints
{
	[self enableEventMapHint:YES];
	[self enableSmartListHint:YES];
    [self enableNoteHint:YES];
	[self enableWeekViewHint:YES];
	[self enableWeekDayQuickAddHint:YES];
	[self enableCalendarHint:YES];
	[self enableMultiSelectHint:YES];
	[self enableMonthViewHint:YES];
	[self enableRTDoneHint:YES];
	[self enableSyncMatchHint:YES];
	[self enableProjectHint:YES];
	[self enableProjectDetailHint:YES];
	[self enableFirstTimeEventSyncHint:YES];
	[self enableWorkingTimeHint:YES];
	[self enableStarTabHint:YES];
	[self enableGTDoTabHint:YES];
	[self enableTagHint:YES];
	[self enableFeatureHint:YES];
    [self enableTransparentHint:YES];
	
	[self clearHintFlags];
}


+(void)startup
{
	[[Settings getInstance] clearHintFlags];
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
