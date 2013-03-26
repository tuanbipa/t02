//
//  SDWSync.m
//  SmartCal
//
//  Created by Mac book Pro on 2/7/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "SDWSync.h"

#import "Common.h"
#import "Settings.h"
#import "ProjectManager.h"
#import "DBManager.h"
#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "AlertManager.h"
#import "Project.h"
#import "Task.h"
#import "Link.h"
#import "RepeatData.h"
#import "AlertData.h"
#import "TagDictionary.h"

#import "BusyController.h"

#import "SDWSection.h"

#import "NSData+CommonCrypto.h"

#define MAX_SYNC_ITEMS 50

typedef enum
{
    ADD_TASK,
    UPDATE_TASK,
    DELETE_TASK,
    CLEAN_TASK,
    ADD_CATEGORY,
    UPDATE_CATEGORY,
    DELETE_CATEGORY,
    ADD_LINK,
    UPDATE_LINK,
    DELETE_LINK,
    UPDATE_TASK_ORDER,
    UPDATE_CATEGORY_ORDER,
    ADD_TAG
    
} SyncCommand;

SDWSync *_sdwSyncSingleton;

@implementation SDWSync

@synthesize syncMode;

@synthesize sdwSection;
@synthesize scSDWMappingDict;
@synthesize sdwSCMappingDict;
@synthesize dupCategoryList;
@synthesize errorDescription;

@synthesize lastTaskUpdateTime;

NSInteger _sdwColor[32] = {
    0x18a4dc, 0xffa024, 0xbea27e, 0xaee100, 0xbbac80, 0xb95fb9, 0xa489a4, 0xb69191,
    0x5c85d6, 0xef7234, 0xa8a86b, 0x17d321, 0xe3e316, 0x855cd6, 0xad96db, 0xa2a1a1,
    0x3434f5, 0xd65c5c, 0x987021, 0x108e78, 0xffd414, 0x70a8a2, 0xd57696, 0x737373,
    0x115192, 0x76332c, 0x91683f, 0x38af3f, 0xbaa133, 0x33d7c1, 0x6e4f5e, 0x4c4c4c
};

- (id)init
{
	if (self = [super init])
	{
        self.sdwSection = [[[SDWSection alloc] init] autorelease];
        
        self.syncMode = -1;
        
        sync2WayPending = NO;
        syncAuto1WayPending = NO;
	}
	
	return self;
}

- (void)dealloc 
{
    self.sdwSection = nil;
    
    self.sdwSCMappingDict = nil;
    self.scSDWMappingDict = nil;
    
    self.dupCategoryList = nil;
    
	[super dealloc];
}

- (void) notifySyncCompletion:(NSNumber *)mode
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[BusyController getInstance] setBusy:NO withCode:BUSY_TD_SYNC];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          mode, 
                          @"SyncMode",
                          nil];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SDWSyncCompleteNotification" object:nil userInfo:dict];
}

- (void) syncComplete
{
    Settings *settings = [Settings getInstance];
        
    if (needResetSection)
    {
        [self.sdwSection reset];
    }
    
    if (self.errorDescription == nil)
    {
        settings.sdwLastSyncTime = [NSDate date];
    }
    else
    {
        //printf("sync error: %s\n", [self.errorDescription UTF8String]);
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:self.errorDescription delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        
        [alertView release];        
    }
    
    needResetSection = NO;
    self.errorDescription = nil;
    
    //printf("last mySD sync time: %s\n", [[settings.sdwLastSyncTime description] UTF8String]);
    
    [settings saveSDWSync];
    
    [[BusyController getInstance] setBusy:NO withCode:BUSY_SDW_SYNC];
    
    [self performSelectorOnMainThread:@selector(notifySyncCompletion:) withObject:[NSNumber numberWithInt:self.syncMode] waitUntilDone:NO];    
    
    self.syncMode = -1;
        
    if (sync2WayPending)
	{
		sync2WayPending = NO;
		
		//printf("continue to sync 2 way\n");
		
        //printf("[4] init sdw sync 2-way\n");
		[self initBackgroundSync];
	}
	else if (syncAuto1WayPending)
	{
		syncAuto1WayPending = NO;
		
		//printf("continue to sync 1 way\n");
		
		[self initBackgroundAuto1WaySync];
	}    
}

- (void)resetSyncSection
{
	[self.sdwSection reset];
}

- (BOOL) check2Backup
{
    Settings *settings = [Settings getInstance];
    
    BOOL needBackup = (settings.sdwLastBackupTime == nil);
    
    if (settings.sdwLastBackupTime != nil)
    {
        NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:settings.sdwLastBackupTime];
        
        if (diff >= 8*3600)
        {
            needBackup = YES;
        }
    }
    
    if (needBackup)
    {
        if (settings.msdBackupHint)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:_msdBackupHint delegate:self cancelButtonTitle:_okText otherButtonTitles:_dontShowText, nil];
            alertView.tag = -10000;
            
            [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            
            [alertView release];            
        }
        
        if (![self backup])
        {
//           self.errorDescription = _msdBackupFailed;
            return NO;
        }
        else
        {
            settings.sdwLastBackupTime = [NSDate date];
            
            [settings saveSDWSync];            
        }
    }
        
    return YES;
}

- (void) sync
{
    if (self.syncMode == SYNC_MANUAL_1WAY_SD2mSD)
    {
        [self push1way];
    }
    else if (self.syncMode == SYNC_MANUAL_1WAY_mSD2SD)
    {
        [self get1way];
    }
    else
    {
        [self syncProjects];
        
        if (self.errorDescription == nil)
        {
            [self syncSetting];
            
            [self syncTags];
            
            NSDate *lastUpdateTime = [[DBManager getInstance] getLastestTaskUpdateTime];
            
            //printf("*** Last Update - sdw: %s - sd: %s\n", [[self.lastTaskUpdateTime description] UTF8String], [[lastUpdateTime description] UTF8String]);
            
            NSComparisonResult comp = [Common compareDate:lastUpdateTime withDate:self.lastTaskUpdateTime];
            
            if (self.syncMode == SYNC_AUTO_1WAY)
            {
                [self sync1way];
            }
            else
            {
                [self syncTasks];
                [self syncLinks];
                
                [self syncProjectOrder];
                
                if (comp != NSOrderedSame)
                {
                    [self syncTaskOrder:(comp == NSOrderedAscending)];
                }
            }
        }
    }
}

- (void) initSync:(NSInteger)mode
{
    //NSLog(@"SDW init sync mode: %s\n", (mode == SYNC_AUTO_1WAY?"auto 1 way":(mode == SYNC_MANUAL_2WAY?"2 way manual":"2 way auto")));
    
    Settings *settings = [Settings getInstance];
    
    self.syncMode = mode;
    
    self.lastTaskUpdateTime = nil;
    
    self.errorDescription = nil;
    
    needResetSection = NO;
    
    BOOL backupSuccess = YES;
    
    if ([self.sdwSection checkTokenExpired])
    {
        NSString *token = [self getToken:settings.sdwEmail password:settings.sdwPassword];
        
        self.sdwSection.token = token;
        
        if (self.sdwSection.token != nil)
        {
            self.sdwSection.lastTokenAcquireTime = [NSDate date];
        
            [self.sdwSection refreshKey];
        }
    }
    
    /*if (self.errorDescription != nil)
    {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:self.errorDescription delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        
        [alertView release];  
    }
    else */
    
    if (self.errorDescription == nil)
    {
        if (self.sdwSection.key != nil)
        {
            backupSuccess = [self check2Backup];
            
            if (backupSuccess)
            {
                [self sync];
            }
            /*else //backup failed
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:_msdBackupFailed delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
                
                [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
                
                [alertView release];
            }
            else
             {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:_msdBackupFailed delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_goText, nil];
             alertView.tag = -11000;
             
             [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
             
             [alertView release];
             }*/
        }
        /*else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_syncErrorText message:_msdSyncFailed delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
            
            [alertView performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            
            [alertView release];        
        }*/
    }
    
    //if (backupSuccess)
    {
        [self syncComplete];
    }
}

-(void)initBackgroundSync
{
	@synchronized(self)
	{
        if (self.syncMode != -1)
        {
            ////printf("other sync is in progress, wait for 2 way sync\n");
            sync2WayPending = YES;
        }
        else 
        {
            ////printf("start 2 way syncing\n");
            
            sync2WayPending = NO;
            
            [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
            [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_2WAY]];		
        }			
	}	
}

-(void)initBackground1WayPush
{
	@synchronized(self)
	{
        [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
        [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_SD2mSD]];        
    }
}

-(void)initBackground1WayGet
{
	@synchronized(self)
	{
        [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
        [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_mSD2SD]];        
    }
}

-(void)initBackgroundAuto1WaySync
{
	@synchronized(self)
	{
        /*
        if (self.syncMode != -1)
        {
            ////printf("other sync is in progress, wait for 1 way sync\n");
            syncAuto1WayPending = sync2WayPending?NO:YES;
        }
        else 
        {
            ////printf("start 1 way syncing\n");
            syncAuto1WayPending = NO;
            
            [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
            [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];
        }
        */
        
        if (!syncAuto1WayPending)
        {
            NSInteger busyFlag = [[BusyController getInstance] getBusyFlag];
            
            if ((busyFlag & BUSY_SDW_SYNC) != 0) //sync is progress
            {
                syncAuto1WayPending = YES;
            }
            else
            {
                [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
                [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_1WAY]];                
            }
        }
	}
}

-(void)initBackgroundAuto2WaySync
{
	@synchronized(self)
	{
        /*
        if (self.syncMode != -1)
        {
            ////printf("other sync is in progress, wait for 2 way sync\n");
            sync2WayPending = YES;
        }
        else 
        {
            ////printf("start 2 way syncing\n");
            
            sync2WayPending = NO;
            
            [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
            [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];		
        }
        */
        
        if (!sync2WayPending)
        {
            NSInteger busyFlag = [[BusyController getInstance] getBusyFlag];
            
            if ((busyFlag & BUSY_SDW_SYNC) != 0) //sync is progress
            {
                sync2WayPending = YES;
            }
            else
            {
                [[BusyController getInstance] setBusy:YES withCode:BUSY_SDW_SYNC];
                [self performSelectorInBackground:@selector(syncBackground:) withObject:[NSNumber numberWithInt:SYNC_AUTO_2WAY]];
            }
        }        
	}	
}


-(void)syncBackground:(NSNumber *) mode
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[self initSync:[mode intValue]];
	
	[pool release];
}

- (NSInteger) getColorIndex:(NSInteger)color
{
    for (int i=0; i<32; i++)
    {
        if (color == _sdwColor[i])
        {
            return i;
        }
    }
    
    return 0;
}

- (void) breakSync:(NSArray *)syncList command:(SyncCommand)command
{
    int div = syncList.count/MAX_SYNC_ITEMS;
    int mod = syncList.count%MAX_SYNC_ITEMS;
    
    if (div > 0)
    {
        for (int i=0; i<div; i++)
        {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:MAX_SYNC_ITEMS];
            
            for (int j=i*MAX_SYNC_ITEMS; j<i*MAX_SYNC_ITEMS+50; j++)
            {
                [list addObject:[syncList objectAtIndex:j]];
            }
            
            switch (command) 
            {
                case ADD_TASK:
                    [self addTasks:list];
                    break;
                case UPDATE_TASK:
                    [self updateTasks:list];
                    break;
                case DELETE_TASK:
                    [self deleteTasks:list cleanFromDB:NO];
                    break;
                case CLEAN_TASK:
                    [self deleteTasks:list cleanFromDB:YES];
                    break;
                case ADD_CATEGORY:
                    [self addCategories:list];
                    break;
                case UPDATE_CATEGORY:
                    [self updateCategories:list];
                    break;
                case DELETE_CATEGORY:
                    [self deleteCategories:list];
                    break;
                case ADD_LINK:
                    [self addLinks:list];
                    break;
                case UPDATE_LINK:
                    [self updateLinks:list];
                    break;
                case DELETE_LINK:
                    [self deleteLinks:list];
                    break;
                case UPDATE_TASK_ORDER:
                    [self updateOrder4Tasks:list];
                    break;
                case UPDATE_CATEGORY_ORDER:
                    [self updateOrder4Categories:list];
                    break;
                case ADD_TAG:
                    [self addTags:list];
                    break;
            }
        }
    }
    
    if (mod > 0)
    {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:MAX_SYNC_ITEMS];
        
        for (int j=div*MAX_SYNC_ITEMS; j<div*MAX_SYNC_ITEMS+mod; j++)
        {
            [list addObject:[syncList objectAtIndex:j]];
        }
        
        switch (command) 
        {
            case ADD_TASK:
                [self addTasks:list];
                break;
            case UPDATE_TASK:
                [self updateTasks:list];
                break;
            case DELETE_TASK:
                [self deleteTasks:list cleanFromDB:NO];
                break;
            case CLEAN_TASK:
                [self deleteTasks:list cleanFromDB:YES];
                break;
            case ADD_CATEGORY:
                [self addCategories:list];
                break;
            case UPDATE_CATEGORY:
                [self updateCategories:list];
                break;
            case DELETE_CATEGORY:
                [self deleteCategories:list];
                break; 
            case ADD_LINK:
                [self addLinks:list];
                break;
            case UPDATE_LINK:
                [self updateLinks:list];
                break;
            case DELETE_LINK:
                [self deleteLinks:list];
                break; 
            case UPDATE_TASK_ORDER:
                [self updateOrder4Tasks:list];
                break;
            case UPDATE_CATEGORY_ORDER:
                [self updateOrder4Categories:list];
                break;
            case ADD_TAG:
                [self addTags:list];
        }
        
    }
    
}

- (NSArray *) getArrayResult:(NSData *)urlData
{
    NSArray *result = nil;
    
    NSError *error = nil;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
    
    if ([jsonObj isKindOfClass:[NSDictionary class]])
    {
        if ([(NSDictionary *)jsonObj objectForKey:@"error"])
        {
            int errorCode = [[(NSDictionary *)jsonObj objectForKey:@"error"] intValue];
            
            if (errorCode == 2)
            {
                needResetSection = YES;
            }
            
            self.errorDescription = _msdSyncFailed;
        }
    }
    else if ([jsonObj isKindOfClass:[NSArray class]])
    {
        result = jsonObj;
    }
    
    return result;
}

- (NSDictionary *) getDictionaryResult:(NSData *)urlData
{
    NSDictionary *result = nil;
    
    NSError *error = nil;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:urlData options:0 error:&error];
    
    if ([jsonObj isKindOfClass:[NSDictionary class]])
    {
        result = jsonObj;
        
        if ([result objectForKey:@"error"])
        {
            int errorCode = [[result objectForKey:@"error"] intValue];
            
            if (errorCode == 2)
            {
                needResetSection = YES;
            }
            
            self.errorDescription = _msdSyncFailed;
        }
    }
    
    return result;
}

#pragma mark Sync Setting

- (Settings *) getSDWSettings:(NSDictionary *) dict
{
    Settings *ret = [[[Settings getInstance] copy] autorelease];
    
    ret.deleteWarning = [[dict objectForKey:@"confirm_delete"] boolValue];
    
    NSString *catId = [[dict objectForKey:@"default_category_id"] stringValue];
    ret.taskDefaultProject = [[self.sdwSCMappingDict objectForKey:catId] intValue];
    
    ret.taskDuration = [[dict objectForKey:@"default_task_dur"] intValue]*60;
    
    ret.eventCombination = ([[dict objectForKey:@"show_task"] intValue] == 1?0:1);
    
    ret.hideFutureTasks = ([[dict objectForKey:@"hide_future_task"] intValue] == 1?YES:NO);
    
    //NSInteger dt = [[dict objectForKey:@"last_update"] intValue];
    NSDictionary *lastUpdateDict = [dict objectForKey:@"last_updates"];
    
    NSInteger dt = [[lastUpdateDict objectForKey:@"lastupdatesetting"] intValue];
    
    ret.updateTime = [NSDate dateWithTimeIntervalSince1970:dt];
    
    ////printf("Settings SDW - dt: %d - update time: %s\n", dt, [[ret.updateTime description] UTF8String]);
    
    dt = [[lastUpdateDict objectForKey:@"lastupdatetask"] intValue];
    
    self.lastTaskUpdateTime = [NSDate dateWithTimeIntervalSince1970:dt];
    
    //printf("Settings SDW - dt: %d - last task update time: %s\n", dt, [[self.lastTaskUpdateTime description] UTF8String]);
    
    return ret;
}

- (NSDictionary *) toSDWSettingsDict:(Settings *)settings
{
    NSDictionary *catDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:(settings.deleteWarning?1:0)],@"confirm_delete",
                             [self.scSDWMappingDict objectForKey:[NSNumber numberWithInt:settings.taskDefaultProject]], @"default_category_id",
                             [NSNumber numberWithInt:settings.taskDuration/60], @"default_task_dur",
                             [NSNumber numberWithInt:(settings.eventCombination == 0?1:0)], @"show_task",
                             [NSNumber numberWithInt:settings.hideFutureTasks?1:0], @"hide_future_task",
                             nil];
    
    return catDict;
}

- (void) updateSettings:(Settings *)settings withSDWSettings:(Settings *)sdwSettings
{
    settings.deleteWarning = sdwSettings.deleteWarning;
    settings.taskDefaultProject = sdwSettings.taskDefaultProject;
    settings.taskDuration = sdwSettings.taskDuration;
    settings.eventCombination = sdwSettings.eventCombination;
}

- (void) updateSDWSettings:(Settings *)settings
{
    NSString *urlString =[NSString stringWithFormat:@"%@/api/settings/updates.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response; 
    
    NSDictionary *dict = [self toSDWSettingsDict:settings];
    
    NSArray *bodyData = [NSArray arrayWithObject:dict];
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:bodyData options:0 error:&error];
	
    [request setHTTPBody:jsonBody];
    
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            NSInteger lastUpdate = [[result objectForKey:@"last_update"] intValue];
            
            settings.updateTime = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
            
            [settings saveSDWSyncDict];
        }
    }
}

- (void) syncSetting
{
    NSString *url = [NSString stringWithFormat:@"%@/api/settings.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        ////printf("settings:\n%s\n", [str UTF8String]);
        
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            Settings *sdwSettings = [self getSDWSettings:result];
            
            Settings *settings = [Settings getInstance];
            
            NSComparisonResult compRes = [Common compareDate:settings.updateTime withDate:sdwSettings.updateTime];
            
            //printf("sc settings time: %s, sdw settings time: %s\n", [[settings.updateTime description] UTF8String], [[sdwSettings.updateTime description] UTF8String]);
            
            if (compRes == NSOrderedAscending) //update SDW->SC
            {
                //printf("update settings SDW->SC\n");
                
                [settings enableExternalUpdate];
                
                [settings updateSettings:sdwSettings];
            }
            else if (compRes == NSOrderedDescending) //update SC->SDW
            {
                //printf("update settings SC->SDW\n");
                
                [self updateSDWSettings:settings];
            }
        }
    }
}

- (void) push1waySetting
{
    [self updateSDWSettings:[Settings getInstance]];
}

- (void) get1waySetting
{
    NSString *url = [NSString stringWithFormat:@"%@/api/settings.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        ////printf("settings:\n%s\n", [str UTF8String]);
        
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            Settings *sdwSettings = [self getSDWSettings:result];
            
            Settings *settings = [Settings getInstance];
            
            [settings enableExternalUpdate];
            
            [settings updateSettings:sdwSettings];
        }
    }
}

#pragma mark Sync Category
- (Project *) getSDWCategory:(NSDictionary *) dict
{
    Project *ret = [[[Project alloc] init] autorelease];
    
    ret.sdwId = [[dict objectForKey:@"id"] stringValue];
    ret.name = [dict objectForKey:@"name"];
    ret.type = [[dict objectForKey:@"category_type"] intValue];
    ret.colorId = [self getColorIndex:[[dict objectForKey:@"color"] intValue]];
    ret.tag = [dict objectForKey:@"tags"];
    ret.isTransparent = ([[dict objectForKey:@"is_transparent"] intValue] == 1);
    ret.status = ([[dict objectForKey:@"invisible"] intValue] == 1?PROJECT_STATUS_INVISIBLE:PROJECT_STATUS_NONE);
    ret.extraStatus = [[dict objectForKey:@"shared"] intValue];
    
    if ([ret isShared])
    {
        NSDictionary *ownerDict = [dict objectForKey:@"owner"];
        
        if (ownerDict != nil)
        {
            NSString *lastName = [ownerDict objectForKey:@"oLastName"];
            NSString *firstName = [ownerDict objectForKey:@"oFirstName"];
            
            if (lastName == nil)
            {
                lastName = @"";
            }
            
            if (firstName == nil)
            {
                firstName = @"";
            }
            
            //ret.ownerName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            ret.ownerName = firstName;
            
            //printf("project:%s - onwer: %s\n", [ret.name UTF8String], [ret.ownerName UTF8String]);
        }
    }
    
    NSInteger source = [[dict objectForKey:@"source"] intValue];
    
    ret.source = (source == 1?CATEGORY_SOURCE_ICAL:CATEGORY_SOURCE_SDW);
    
    //printf("get Category: %s - source: %s\n", [ret.name UTF8String], (source == 1?"SOURCE ICAL":"SOURCE SmartDay"));
    
    ret.updateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"last_update"] intValue]];
    
    return ret;
}

- (NSDictionary *) toSDWCategoryDict:(Project *)prj
{
    NSDictionary *catDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             prj.sdwId,@"id",
                             prj.name, @"name",
                             [NSNumber numberWithInt:prj.type], @"type",
                             [NSNumber numberWithInt:_sdwColor[prj.colorId]], @"color",
                             prj.tag, @"tags",
                             [NSNumber numberWithInt:prj.isTransparent?1:0], @"is_transparent",
                             [NSNumber numberWithInt:prj.status == PROJECT_STATUS_INVISIBLE?1:0], @"invisible",
                             [NSNumber numberWithInt:prj.primaryKey], @"ref",
                             [NSNumber numberWithInt:(prj.source == CATEGORY_SOURCE_ICAL?1:0)], @"source",
                             nil];
    
    //printf("set Category: %s - source: %s\n", [prj.name UTF8String], (prj.source == CATEGORY_SOURCE_ICAL?"SOURCE ICAL":"SOURCE SmartDay"));

    return catDict;
}

- (void) updateProject:(Project *)prj withSDWCategory:(Project *)cat
{
    prj.name = cat.name;
    prj.ownerName = (cat.ownerName == nil?@"":cat.ownerName);
    prj.sdwId = cat.sdwId;
    prj.updateTime = cat.updateTime;
    prj.type = cat.type;
    prj.colorId = cat.colorId;
    prj.tag = cat.tag;
    prj.isTransparent = cat.isTransparent;
    prj.status = cat.status;
    prj.extraStatus = cat.extraStatus;
    prj.source = cat.source;
    
	if (prj.primaryKey > -1)
	{
		[prj enableExternalUpdate];		
	}    
    
    //[prj updateIntoDB:[[DBManager getInstance] getDatabase]];
}

- (void) addCategories:(NSArray *)prjList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/categories.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    //printf("add project url:%s\n", [urlString UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *catList = [NSMutableArray arrayWithCapacity:prjList.count];
    NSDictionary *prjDict = [ProjectManager getProjectDictById:prjList];
    
    for (Project *prj in prjList)
    {
        [catList addObject:[self toSDWCategoryDict:prj]];
        
    }
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:catList options:0 error:&error];
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (urlData) 
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *catId = [[dict objectForKey:@"id"] stringValue];
            NSInteger key = [[dict objectForKey:@"ref"] intValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (catId != nil)
            {
                Project *prj = [prjDict objectForKey:[NSNumber numberWithInt:key]];
                
                if (prj != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    prj.updateTime = dt;
                    prj.sdwId = catId;
                                        
                    [prj updateSDWIDIntoDB:[dbm getDatabase]];
                    
                    [self.scSDWMappingDict setObject:prj.sdwId forKey:[NSNumber numberWithInt:prj.primaryKey]];
                    [self.sdwSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:prj.sdwId];                    
                }
            }
        }        
    }
}

- (void) updateCategories:(NSArray *)prjList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/categories/updates.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"PUT"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 

    NSMutableArray *catList = [NSMutableArray arrayWithCapacity:prjList.count];
    NSDictionary *prjDict = [ProjectManager getProjectDictBySDWID:prjList];
    
    for (Project *prj in prjList)
    {
        [catList addObject:[self toSDWCategoryDict:prj]];
        
    }
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:catList options:0 error:&error];
    
    [request setHTTPBody:jsonBody];
    
    NSString* body = [[NSString alloc] initWithData:jsonBody
                                           encoding:NSUTF8StringEncoding];
    
    //printf("update category body:\n%s\n", [body UTF8String]);    
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (urlData) 
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *catId = [[dict objectForKey:@"id"] stringValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (catId != nil)
            {
                Project *prj = [prjDict objectForKey:catId];
                
                if (prj != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    prj.updateTime = dt;
                    [prj enableExternalUpdate];
                    
                    [prj modifyUpdateTimeIntoDB:[dbm getDatabase]];
                }
            }
        }        
    }
}

- (void) deleteCategories:(NSMutableArray *)delList
{
    DBManager *dbm = [DBManager getInstance];
    
    NSDictionary *delDict = [ProjectManager getProjectDictBySDWID:delList];
    
    NSString *idList = nil;
    
	for (Project *plan in delList)
	{
        if (plan.sdwId != nil && ![plan.sdwId isEqualToString:@""])
        {
            //printf("delete category %s SD->SDW\n", [plan.name UTF8String]);
            
            if (idList == nil)
            {
                idList = plan.sdwId;
            }
            else 
            {
                idList = [NSString stringWithFormat:@"%@,%@", idList, plan.sdwId];
            }
        }
    } 
    
    if (idList != nil)
    {
        NSString *urlString=[NSString stringWithFormat:@"%@/api/categories/%@.json?keyapi=%@",SDWSite,idList,self.sdwSection.key];
        
        //printf("delete categories URL: %s\n", [urlString UTF8String]);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
        [request setURL:[NSURL URLWithString:urlString]]; 
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
        
        NSError *error; 
        NSURLResponse *response; 
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        [request release];
        
        if (urlData) 
        {
            //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            
            //printf("delete returns:\n%s\n", [str UTF8String]);
            
            NSArray *result = [self getArrayResult:urlData];
            
            if (result == nil)
            {
                return;
            }
            
            for (NSDictionary *dict in result)
            {
                NSString *delId = [dict objectForKey:@"success"];
                
                if (delId != nil)
                {
                    Project *delPrj = [delDict objectForKey:delId];
                    
                    if (delPrj != nil)
                    {
                        if ((delPrj.tdId != nil && ![delPrj.tdId isEqualToString:@""]) 
                            || (delPrj.ekId != nil && ![delPrj.ekId isEqualToString:@""]))
                        {
                            delPrj.sdwId = @"";
                            [delPrj updateSDWIDIntoDB:[dbm getDatabase]];
                        }
                        else
                        {
                            [delPrj cleanFromDatabase];
                        }
                    }
                }
            }
        }
    }
}


- (void) syncDeletedProjects
{
	NSMutableArray *delList = [[DBManager getInstance] getDeletedPlans];
    
    if (delList.count > 0)
    {
        [self breakSync:delList command:DELETE_CATEGORY];
    }
}

- (void) syncProjects 
{
    [self syncDeletedProjects];
    
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    self.sdwSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scSDWMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.dupCategoryList = [NSMutableArray arrayWithCapacity:10];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/categories.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    ////printf("getTasks: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("get categories:\n%s\n", [str UTF8String]);

        NSMutableArray *prjList = [NSMutableArray arrayWithArray: pm.projectList];
        
        NSDictionary *projectNameDict = [ProjectManager getProjectDictByName:prjList]; 
        NSDictionary *projectSyncDict = [ProjectManager getProjectDictBySDWID:prjList];
        
        NSMutableArray *swdUpdateList = [NSMutableArray arrayWithCapacity:5];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            if ([dict objectForKey:@"id"] == nil)
            {
                continue;
            }
            
            Project *sdwCat = [self getSDWCategory:dict];
            
            if (sdwCat.type == 1) //Old CheckList style -> not sync
            {
                continue;
            }
            
            Project *prj = [projectSyncDict objectForKey:sdwCat.sdwId];
            
            if (prj != nil) //already sync
            {
                //printf("category %s was synced in SD\n", [prj.name UTF8String]);
                
                //if (prj.status == PROJECT_STATUS_INVISIBLE) //don't sync INVISIBLE projects
                //{
                //    continue;
                //}
                
                NSComparisonResult compRes = [Common compareDate:prj.updateTime withDate:sdwCat.updateTime];
                
                //printf("sc time: %s, sdw time: %s\n", [[prj.updateTime description] UTF8String], [[sdwCat.updateTime description] UTF8String]);
                
                if (compRes == NSOrderedAscending || [prj isShared]) //update SDW->SC
                {
                    //printf("update SDW->SC for project: %s\n", [prj.name UTF8String]);
                    
                    BOOL colorChange = (prj.colorId != sdwCat.colorId);
                    
                    [self updateProject:prj withSDWCategory:sdwCat];
                    [prj updateIntoDB:[[DBManager getInstance] getDatabase]];
                    
                    if (colorChange)
                    {
                        [pm makeIcon:prj];
                    }
                    
                }
                else if (compRes == NSOrderedDescending) //update SC->SDW
                {
                    //printf("update SC->SDW for project: %s\n", [prj.name UTF8String]);
                    
                    sdwCat.status = prj.status; //update status so that it is included in mapping list when visibility change (hidden->visible) in SD
                    
                    [swdUpdateList addObject:prj];
                }
                
                if (sdwCat.status != PROJECT_STATUS_INVISIBLE)
                {
                    [self.scSDWMappingDict setObject:sdwCat.sdwId forKey:[NSNumber numberWithInt:prj.primaryKey]];
                    [self.sdwSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:sdwCat.sdwId];
                }
                
                [prjList removeObject:prj];
            }
            else 
            {
                prj = [projectNameDict objectForKey:[sdwCat.name uppercaseString]];
                
                if (prj != nil) // matching Project Name
                {
                    //printf("category %s matches name in SD -> suspect duplication\n", [prj.name UTF8String]);
                    
                    NSComparisonResult compRes = [Common compareDate:prj.updateTime withDate:sdwCat.updateTime];
                    
                    //printf("category %s - sc time: %s, sdw time: %s\n", [prj.name UTF8String], [[prj.updateTime description] UTF8String], [[sdwCat.updateTime description] UTF8String]);
                    
                    if (compRes == NSOrderedAscending) //update SDW->SC
                    {
                        //printf("update SDW->SC for project: %s\n", [prj.name UTF8String]);
                        
                        BOOL colorChange = (prj.colorId != sdwCat.colorId);
                        
                        [self updateProject:prj withSDWCategory:sdwCat];
                        [prj updateIntoDB:[[DBManager getInstance] getDatabase]];
                        
                        if (colorChange)
                        {
                            [pm makeIcon:prj];
                        }                        
                        
                    }
                    else if (compRes == NSOrderedDescending) //update SC->SDW
                    {
                        //printf("update SC->SDW for project: %s\n", [prj.name UTF8String]);
                        sdwCat.status = prj.status;
                        
                        [swdUpdateList addObject:prj];
                    }
                    
                    prj.sdwId = sdwCat.sdwId;
                    
                    [prj updateSDWIDIntoDB:[dbm getDatabase]];
                                        
                    [self.dupCategoryList addObject:[NSNumber numberWithInt:prj.primaryKey]];
                    
                    [prjList removeObject:prj];
                }
                else 
                {
                    prj = [[Project alloc] init];
                    
                    prj.sdwId = sdwCat.sdwId;
                    prj.source = CATEGORY_SOURCE_SDW;
                    
                    [self updateProject:prj withSDWCategory:sdwCat];
                    
                    //printf("create category %s in SD\n", [prj.name UTF8String]);
                    
                    [pm addProject:prj];
                    
                    [prj release];                    
                }
                
                if (sdwCat.status != PROJECT_STATUS_INVISIBLE)
                {               
                    [self.scSDWMappingDict setObject:sdwCat.sdwId forKey:[NSNumber numberWithInt:prj.primaryKey]];
                    [self.sdwSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:sdwCat.sdwId];
                }
            }
        }
        
        if (swdUpdateList.count > 0)
        {
            [self breakSync:swdUpdateList command:UPDATE_CATEGORY];
        }
        
        NSMutableArray *delList = [NSMutableArray arrayWithCapacity:5];
        
        NSMutableArray *hiddenList = [NSMutableArray arrayWithCapacity:5];
        
        for (Project *prj in prjList)
        {
            if (prj.status == PROJECT_STATUS_INVISIBLE) //don't sync INVISIBLE projects
            {
                [hiddenList addObject:prj];
                
                continue;
            }
            
            if (prj.sdwId != nil && ![prj.sdwId isEqualToString:@""]) //project was deleted in SDW
            {
                [delList addObject:prj];                
            }
        }
        
        for (Project *prj in delList)
        {
            [prjList removeObject:prj];  
            
            //[pm deleteProject:prj cleanFromDB:YES];
            
            prj.sdwId = @"";
            [prj updateSDWIDIntoDB:[dbm getDatabase]];
            
            //[pm deleteProject:prj cleanFromDB:NO];
            [pm deleteProject:prj cleanFromDB:YES];
        } 
        
        for (Project *prj in hiddenList)
        {
            [prjList removeObject:prj];
        }
        
        if (prjList.count > 0) //sync new Projects from SC
        {
            [self breakSync:prjList command:ADD_CATEGORY];
        }
    }
}

#pragma mark Sync Task
- (Task *) getSDWTask:(NSDictionary *) dict
{
    Task *ret = [[[Task alloc] init] autorelease];
    
    ret.sdwId = [[dict objectForKey:@"id"] stringValue];
    ret.name = [dict objectForKey:@"title"];
    ret.note = [dict objectForKey:@"content"];
    ret.extraStatus = [[dict objectForKey:@"shared"] intValue];
    
    //NSLog(@"Task from SDW: %@ - name: %@", ret.note, ret.name);
    
    NSInteger type = [[dict objectForKey:@"task_type"] intValue];
    
    if (type == 4)
    {
        //does not sync CheckList items
        
        return nil;
    }
    
    NSInteger typeList[4] = {TYPE_NOTE, TYPE_TASK, TYPE_EVENT, TYPE_SHOPPING_ITEM};
    
    ret.type = typeList[type-1];
    
    BOOL isADE = [[dict objectForKey:@"ade"] boolValue];

    if (isADE)
    {
        ret.type = TYPE_ADE;
    }
    
    NSString *catId = [[dict objectForKey:@"category_id"] stringValue];
    
    NSNumber *prjNum = [self.sdwSCMappingDict objectForKey:catId];
    
    ret.project = (prjNum != nil? [prjNum intValue]:-1);
    
    ret.location = [dict objectForKey:@"location"];
    
    ret.tag = [dict objectForKey:@"tags"];
    
    ret.duration = ([[dict objectForKey:@"duration"] intValue])*60;
    
    NSInteger dt = [[dict valueForKey:@"start_time"] intValue];
    ret.startTime = (dt == 0?nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:dt]]);
    
    dt = [[dict objectForKey:@"end_time"] intValue];
    
    BOOL due = [[dict objectForKey:@"due"] boolValue];
    
    BOOL isTask = (type == 2 || type == 4);
    BOOL isEvent = (type == 3);
    
    if (due && isTask)
    {
        ret.deadline = [Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:dt]];
    }
    
    if (isEvent)
    {
        ret.endTime = (dt == 0?nil:[Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:dt]]);        
    }
        
    BOOL star = [[dict objectForKey:@"star"] boolValue];
    
    ret.status = (star?TASK_STATUS_PINNED:TASK_STATUS_NONE);
    
    BOOL done = [[dict objectForKey:@"completed"] boolValue];
    
    if (done)
    {
        dt = [[dict objectForKey:@"completed_date"] intValue];
        //ret.completionTime = [NSDate dateWithTimeIntervalSince1970:dt];
        ret.completionTime = [Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:dt]];
        
        ret.status = TASK_STATUS_DONE;
    }
    
    NSString *groupId = ( [dict objectForKey:@"group_id"] != [NSNull null]?[[dict objectForKey:@"group_id"] stringValue]:nil);
    
    if (groupId != nil && ![groupId isEqualToString:@"0"])
    {
        ret.groupKey = [[DBManager getInstance] getKey4SDWId:groupId];
        
        if (ret.groupKey == -1) //cannot find parent
        {
            //printf("cannot find root with sdw id: %s\n", [groupId UTF8String]);
            
            return nil;
        }
        
        //printf("task %s has groupId: %s - key link: %d\n", [ret.name UTF8String], [groupId UTF8String], ret.groupKey);
        
        ret.repeatData = [[[RepeatData alloc] init] autorelease];
        ret.repeatData.originalStartTime = ret.startTime;
    }
    
    NSDictionary *repeatDict = [dict objectForKey:@"repeat"];

    if (repeatDict != nil)
    {
        ret.repeatData = [self toRepeatData:repeatDict];
        
        //printf("repeat data for task %s : %s\n", [ret.name  UTF8String], [[RepeatData stringOfRepeatData:ret.repeatData] UTF8String]);
        
        NSArray *repeatExceptionList = [repeatDict objectForKey:@"repeat_exceptions"];
        
        if (repeatExceptionList != nil && repeatExceptionList.count > 0)
        {
            Task *deletedExc = [[[Task alloc] init] autorelease];
            deletedExc.type = TYPE_RE_DELETED_EXCEPTION;
            deletedExc.repeatData = [[[RepeatData alloc] init] autorelease];
            deletedExc.repeatData.deletedExceptionDates = [NSMutableArray arrayWithCapacity:10];
            
            NSMutableDictionary *excDict = [NSMutableDictionary dictionaryWithCapacity:10];
            
            for (NSDictionary *rptExcDict in repeatExceptionList)
            {
                NSInteger dt = [[rptExcDict objectForKey:@"exception_date"] intValue];
                
                NSDate *excDate = [Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:dt]];
                
                [deletedExc.repeatData.deletedExceptionDates addObject:excDate];
                
                dt = [excDate timeIntervalSince1970]; 
                
                [excDict setObject:deletedExc forKey:[NSNumber numberWithInt:dt]];
            }
            
            ret.exceptions = excDict;
        }
    }
    
    NSArray *arrayOfAlert = [dict objectForKey:@"alerts"];
        
    for (int j=0; j<arrayOfAlert.count; j++) 
    {    
        NSDictionary *alertDict = (NSDictionary *)[arrayOfAlert objectAtIndex:j];
        
        NSInteger minutes = [[alertDict valueForKey:@"minutes"] intValue];
        
        if (ret.alerts == nil)
        {
            ret.alerts = [NSMutableArray arrayWithCapacity:arrayOfAlert.count];            
        }
        
        AlertData *dat = [[AlertData alloc] init];
        dat.taskKey = ret.primaryKey;
        
        dat.absoluteTime = nil;
        dat.beforeDuration = -minutes*60;
        
        [ret.alerts addObject:dat];
        [dat release];
    }
    
    ret.updateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"last_update"] intValue]];
    
    //printf("sdw task %s - id:%s - duration: %d - type:%d - start:%s - end:%s\n", [ret.name UTF8String], [ret.sdwId UTF8String], ret.duration, type, [[ret.startTime description] UTF8String], [[ret.endTime description] UTF8String]);
        
    
    return ret;
}

- (RepeatData *) toRepeatData:(NSDictionary *)repeatDict
{
    RepeatData *repeatData = [[[RepeatData alloc] init] autorelease];
    
    NSString *repeatTypeStr = [repeatDict objectForKey:@"repeat_type"];
    
    if ([repeatTypeStr isEqualToString:@"D"])
    {
        repeatData.type = REPEAT_DAILY;
    }
    else if ([repeatTypeStr isEqualToString:@"W"])
    {
        repeatData.type = REPEAT_WEEKLY;
        
        repeatData.weekOption = 0;
        
        NSString *repeatFlagStr = [repeatDict objectForKey:@"repeat_flag"];
        
        for (int i=0; i<7; i++)
        {
            if ([repeatFlagStr characterAtIndex:i] == 0x0031)
            {
                NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 

                repeatData.weekOption |= wkOptions[i];
            }
        }        
    }
    else if ([repeatTypeStr isEqualToString:@"M"])
    {
        repeatData.type = REPEAT_MONTHLY;
        
        NSString *repeatFlagStr = [repeatDict objectForKey:@"repeat_flag"];
        
        if ([repeatFlagStr isEqualToString:@"1000000"])
        {
            repeatData.monthOption = BY_DAY_OF_WEEK;
        }
        else if ([repeatFlagStr isEqualToString:@"0000000"])
        {
            repeatData.monthOption = BY_DAY_OF_MONTH;
        }
    }
    else if ([repeatTypeStr isEqualToString:@"Y"])
    {
        repeatData.type = REPEAT_YEARLY;
    }
    
    repeatData.interval = [[repeatDict objectForKey:@"repeat_interval"] intValue];
    
    NSInteger repeatEnd = [[repeatDict objectForKey:@"repeat_end"] intValue];
    
    if (repeatEnd == 0)
    {
        repeatData.until = nil;
    }
    else 
    {
        repeatData.until = [Common fromDBDate:[NSDate dateWithTimeIntervalSince1970:repeatEnd]];
    }
    
    NSInteger repeatByDue = [[repeatDict objectForKey:@"repeat_by_due"] intValue];
    
    repeatData.repeatFrom = (repeatByDue == 1?REPEAT_FROM_DUE:REPEAT_FROM_COMPLETION);
    
    return repeatData;
}

- (NSDictionary *) getRepeatDataDict:(RepeatData *)repeatData
{
    NSString *repeatFlagStr = @"0000000";
    NSString *repeatTypeStr = @"D";
    
    switch (repeatData.type) 
    {
        case REPEAT_DAILY:
        {
            repeatTypeStr = @"D";
        }
            break;
        case REPEAT_WEEKLY:
        {
            repeatTypeStr = @"W";
            
            if (repeatData.weekOption > 0)
            {
                NSInteger wkOptions[7] = {ON_SUNDAY, ON_MONDAY, ON_TUESDAY, ON_WEDNESDAY, ON_THURSDAY, ON_FRIDAY, ON_SATURDAY}; 

                repeatFlagStr = @"";
                
                for (int i=0; i<7; i++)
                {
                    repeatFlagStr = [repeatFlagStr stringByAppendingFormat:@"%d", (repeatData.weekOption & wkOptions[i])?1:0];
                }
            }
        }
            break;
        case REPEAT_MONTHLY:
        {
            repeatTypeStr = @"M";
            
            repeatFlagStr = (repeatData.monthOption == BY_DAY_OF_WEEK?@"1000000":@"0000000");
        }
            break;
        case REPEAT_YEARLY:
        {
            repeatTypeStr = @"Y";
        }
            break;
    }
    
    NSInteger repeatEnd = (repeatData.until != nil?[[Common toDBDate:repeatData.until] timeIntervalSince1970]:0);
    NSInteger repeatByDue = (repeatData.repeatFrom == REPEAT_FROM_DUE?1:0);
    
    NSDictionary *repeatDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              repeatTypeStr,@"repeat_type",
                              repeatFlagStr, @"repeat_flag",
                              [NSNumber numberWithInt:repeatData.interval], @"repeat_interval",
                              [NSNumber numberWithInt:repeatEnd],  @"repeat_end",
                              [NSNumber numberWithInt:repeatByDue], @"repeat_by_due",
                            nil];
    
    return repeatDict;
    
}

- (NSDictionary *) toSDWTaskDict:(Task *)task
{
    NSInteger startTime = (task.startTime != nil?[[Common toDBDate:task.startTime] timeIntervalSince1970]:0);
    NSInteger endTime = (task.endTime != nil?[[Common toDBDate:task.endTime] timeIntervalSince1970]:0);
    NSInteger dueTime = (task.deadline != nil?[[Common toDBDate:task.deadline] timeIntervalSince1970]:0);
    //NSInteger doneTime = (task.completionTime != nil?[task.completionTime timeIntervalSince1970]:0);
    NSInteger doneTime = (task.completionTime != nil?[[Common toDBDate:task.completionTime] timeIntervalSince1970]:0);
    
    NSInteger type = 0;
    
    switch (task.type)
    {
        case TYPE_NOTE:
            type = 1;
            break;
        case TYPE_TASK:
            type = 2;
            break;
        case TYPE_EVENT:
        case TYPE_ADE:
            type = 3;
            break;
        case TYPE_SHOPPING_ITEM:
            type = 4;
            break;
    }
    
    NSMutableDictionary *repeatDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
	if (task.repeatData != nil && task.groupKey == -1)
	{
		RepeatData *rptDat = [task.repeatData copy];
		
		if (rptDat.type == REPEAT_MONTHLY && rptDat.monthOption == BY_DAY_OF_WEEK && rptDat.weekDay == 0 && rptDat.weekOrdinal == 0)
		{
			NSDate *dt = task.updateTime;
			
			if (rptDat.repeatFrom == REPEAT_FROM_DUE)
			{
				if (task.deadline == nil)
				{
					dt = (task.startTime!=nil?task.startTime:task.updateTime);
				}
				else
				{
					dt = task.deadline;
				}
			}
			
			rptDat.weekDay = [Common getWeekday:dt];
			rptDat.weekOrdinal = [Common getWeekdayOrdinal:dt];
		}		
		
		repeatDict = [NSMutableDictionary dictionaryWithDictionary:[self getRepeatDataDict:rptDat]];
        
        //populate exceptions
        
        if (task.exceptions != nil)
        {
            NSMutableArray *exceptions = [NSMutableArray arrayWithCapacity:task.exceptions.count];
            
            NSEnumerator *keyEnum = [task.exceptions keyEnumerator];
            
            NSNumber *key;
            
            while ((key = [keyEnum nextObject]) != nil)
            {
                NSDate *dt = [NSDate dateWithTimeIntervalSince1970:[key intValue]];
                
                dt = [Common copyTimeFromDate:task.startTime toDate:dt];
                
                //printf("exception date: %s\n", [dt.description UTF8String]);
                
                NSDictionary *excDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[Common toDBDate:dt] timeIntervalSince1970]],@"exception_date", nil];
                
                [exceptions addObject:excDict];
            }
            
            [repeatDict setObject:exceptions forKey:@"repeat_exceptions"];
        }
    }
    
    NSString *groupId = @"0";
    
    if (task.groupKey != -1 && task.original != nil) //exception
    {
        groupId = task.original.sdwId;
        
        //printf("exception %s - root sdw id: %s\n", [task.name UTF8String], [groupId UTF8String]);
    }
    
    NSMutableArray *alertList = [NSMutableArray arrayWithCapacity:10];
    
    if (task.alerts != nil)
    {
        for (AlertData *alert in task.alerts)
        {
            NSDictionary *alertDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-alert.beforeDuration/60],@"minutes", nil];
            
            [alertList addObject:alertDict];
        }
    }
    
    NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             task.sdwId,@"id",
                             task.name, @"title",
                              task.note, @"content",
                             [NSNumber numberWithInt:type], @"task_type",
                             [self.scSDWMappingDict objectForKey:[NSNumber numberWithInt:task.project]], @"category_id",
                             task.location, @"location",
                              task.tag, @"tags",
                             [NSNumber numberWithInt: task.duration/60], @"duration",
                             [NSNumber numberWithInt:startTime], @"start_time",
                              [NSNumber numberWithInt:([task isTask]?dueTime:endTime)], @"end_time",
                             [NSNumber numberWithInt:doneTime], @"completed_date",
                             [NSNumber numberWithBool:(task.type == TYPE_ADE)], @"ade",
                             [NSNumber numberWithBool:(dueTime != 0)], @"due",
                             [NSNumber numberWithBool:(task.status == TASK_STATUS_PINNED)], @"star",
                             [NSNumber numberWithBool:(task.status == TASK_STATUS_DONE)], @"completed",
                             [NSNumber numberWithInt:task.primaryKey], @"ref",
                              repeatDict, @"repeat",
                              alertList, @"alerts",
                              groupId, @"group_id", 
                             nil];
    
    return taskDict; 
}

- (void) updateTask:(Task *)task withSDWTask:(Task *)sdwTask
{
    DBManager *dbm = [DBManager getInstance];
    
    task.type = sdwTask.type;
    task.name = sdwTask.name;
    task.note = sdwTask.note;
    task.sdwId = sdwTask.sdwId;
    task.project = sdwTask.project;
    task.groupKey = sdwTask.groupKey;
    task.location = sdwTask.location;
    task.tag = sdwTask.tag;
    task.duration = sdwTask.duration;
    task.startTime = sdwTask.startTime;
    task.endTime = sdwTask.endTime;
    task.deadline = sdwTask.deadline;
    task.status = sdwTask.status;
    task.extraStatus = sdwTask.extraStatus;
    task.completionTime = sdwTask.completionTime;
    task.updateTime = sdwTask.updateTime;
    task.repeatData = sdwTask.repeatData;
    
    if (sdwTask.exceptions != nil)
    {
        Task *delExc = [[DBManager getInstance] getDeletedExceptionForRE:task.primaryKey];
        
        if (delExc == nil)
        {
            Task *delExc = [[[Task alloc] init] autorelease];
            delExc.type = TYPE_RE_DELETED_EXCEPTION;
            delExc.primaryKey = -1;
            delExc.groupKey = task.primaryKey;
            delExc.repeatData = [[[RepeatData alloc] init] autorelease];
            delExc.repeatData.deletedExceptionDates = [NSMutableArray arrayWithCapacity:10];
            
            [delExc insertIntoDB:[dbm getDatabase]];
        }
        
        NSDictionary *delDateDict = [NSDictionary dictionaryWithObjects:delExc.repeatData.deletedExceptionDates forKeys:delExc.repeatData.deletedExceptionDates];
        
        NSEnumerator *keyEnum = [sdwTask.exceptions keyEnumerator];
        
        NSNumber *key;
        
        while ((key = [keyEnum nextObject]) != nil)
        {
            NSDate *dt = [NSDate dateWithTimeIntervalSince1970:[key intValue]];
            
            if (![delDateDict objectForKey:dt])
            {
                [delExc.repeatData.deletedExceptionDates addObject:dt];
            }
        }
        
        [delExc updateRepeatDataIntoDB:[dbm getDatabase]];
        
    }
    
	NSInteger taskPlacement = [[Settings getInstance] newTaskPlacement];    
	
	if (task.primaryKey == -1)
	{
		if (taskPlacement == 0) //on top
		{
			task.sequenceNo = [dbm getTaskMinSortSeqNo] - 1;
		}
		else 
		{
			task.sequenceNo = [dbm getTaskMaxSortSeqNo] + 1;
		}		
	}    
    
	if (task.primaryKey > -1)
	{
		[task enableExternalUpdate];		
	}    
}

- (BOOL) checkTaskCompletedInRange:(Task *)task
{
    NSDate *endDate = [Common getEndDate:[NSDate date]];
    
    NSDate *startDate = [Common clearTimeForDate:[Common dateByAddNumDay:-14 toDate:endDate]];
    
    return [task.completionTime compare:startDate] != NSOrderedAscending && [task.completionTime compare:endDate] != NSOrderedDescending;
}

- (void) addTasks:(NSArray *)taskList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/tasks.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    //printf("add task url:%s\n", [urlString UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *sdwList = [NSMutableArray arrayWithCapacity:taskList.count];
    NSDictionary *taskDict = [ProjectManager getProjectDictById:taskList];
    
    for (Task *task in taskList)
    {
        //printf("insert SC->SDW: %s \n", [task.name UTF8String]);
        [sdwList addObject:[self toSDWTaskDict:task]];
        
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwList options:0 error:&error];
    
    NSString* body = [[NSString alloc] initWithData:jsonBody
                                           encoding:NSUTF8StringEncoding];
    
    //printf("add task body:\n%s\n", [body UTF8String]);
    
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("add tasks return:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger key = [[dict objectForKey:@"ref"] intValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Task *task = [taskDict objectForKey:[NSNumber numberWithInt:key]];
                
                if (task != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    task.updateTime = dt;
                    task.sdwId = sdwId;
                    
                    [task updateSDWIDIntoDB:[dbm getDatabase]];
                    
                    [self syncExceptions:task];
                }
                
                //printf("add Task - SDW returns ID:%s - %s\n", [sdwId UTF8String], task != nil? [task.name UTF8String]:"task NOT FOUND");
            }
        }        
    }
}

- (void) updateTasks:(NSArray *)taskList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/tasks/updates.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    printf("update URL:\n%s\n", [urlString UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"PUT"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *sdwTaskList = [NSMutableArray arrayWithCapacity:taskList.count];
    NSDictionary *taskDict = [TaskManager getTaskDictBySDWID:taskList];
    
    for (Task *task in taskList)
    {
        [sdwTaskList addObject:[self toSDWTaskDict:task]];
        
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwTaskList options:0 error:&error];
    
    NSString* body = [[NSString alloc] initWithData:jsonBody
                                           encoding:NSUTF8StringEncoding];
    
    printf("update task body:\n%s\n", [body UTF8String]);
    
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        printf("update results:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Task *task = [taskDict objectForKey:sdwId];
                
                if (task != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    //printf("update task %s - key: %d - with mySD last update: %s\n", [task.name UTF8String], task.primaryKey, [[dt description] UTF8String]);
                    
                    task.updateTime = dt;
                    [task enableExternalUpdate];
                    
                    [task modifyUpdateTimeIntoDB:[dbm getDatabase]];
                }
            }
        }        
    }
}

- (void) deleteTasks:(NSArray *)delList cleanFromDB:(BOOL) cleanFromDB
{
    DBManager *dbm = [DBManager getInstance];
    
    /*
    for (Task *task in delList)
    {
        //printf("delete task %s - sdw id: %s\n", [task.name UTF8String], [task.sdwId UTF8String]);
    }
    */
    
    NSDictionary *delDict = [TaskManager getTaskDictBySDWID:delList];
    
    NSString *idList = nil;
    
	for (Task *task in delList)
	{
        if (task.sdwId != nil && ![task.sdwId isEqualToString:@""])
        {
            if (idList == nil)
            {
                idList = task.sdwId;
            }
            else 
            {
                idList = [NSString stringWithFormat:@"%@,%@", idList, task.sdwId];
            }
        }
    }
    
    if (idList != nil)
    {
        NSString *urlString=[NSString stringWithFormat:@"%@/api/tasks/%@.json?keyapi=%@",SDWSite,idList,self.sdwSection.key];
        
        //printf("delete tasks URL: %s\n", [urlString UTF8String]);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
        [request setURL:[NSURL URLWithString:urlString]]; 
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
        
        NSError *error; 
        NSURLResponse *response; 
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        [request release];
        
        if (urlData) 
        {
            //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            
            //printf("delete results:\n%s\n", [str UTF8String]);
            
            NSArray *result = [self getArrayResult:urlData];
            
            if (result == nil)
            {
                return;
            }
            
            for (NSDictionary *dict in result)
            {
                NSString *delId = [dict objectForKey:@"success"];
                
                if (delId != nil)
                {
                    Task *delTask = [delDict objectForKey:delId];
                    
                    if (delTask != nil)
                    {
                        if (cleanFromDB)
                        {
                            [delTask cleanFromDatabase:[dbm getDatabase]];
                        }
                        else 
                        {
                            delTask.sdwId = @"";
                            
                            [delTask updateSDWIDIntoDB:[dbm getDatabase]];
                            
                            [delTask deleteFromDatabase:[dbm getDatabase]];
                        }
                    }
                    
                }
            }
        }
    }
    
}


- (void) syncDeletedTasks
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *delList = [dbm getDeletedItems2Sync];
    
    if (delList.count > 0)
    {
        [self breakSync:delList command:CLEAN_TASK];
    }
}

- (void) syncExceptions:(Task *)task
{
    if (task.exceptions != nil) //sync exceptions
    {
        //printf("sync exceptions for re: %s\n", [task.name UTF8String]);
        
        NSMutableArray *excList = [NSMutableArray arrayWithCapacity:10];
        
        NSEnumerator *objEnum = [task.exceptions objectEnumerator];
        
        Task *exc;
        
        while ((exc = [objEnum nextObject]) != nil)
        {
            if (exc.type != TYPE_RE_DELETED_EXCEPTION && [exc.sdwId isEqualToString:@""])
            {
                //printf("sync exception %s - start: %s\n", [exc.name UTF8String], [[exc.startTime description] UTF8String]);
                [excList addObject:exc];
            }
        }
        
        if (excList.count > 0)
        {
            [self breakSync:excList command:ADD_TASK];
        }                        
    }
    
}

- (void)syncTasks 
{
    DBManager *dbm = [DBManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    [self syncDeletedTasks];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/tasks.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    //printf("getTasks: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("SDW get tasks return:\n%s\n", [str UTF8String]);
        
        NSMutableArray *taskList = [dbm getItems2Sync];
        
        //printf("*** begin item2Sync list\n");
        
        for (Task *task in taskList)
        {
            [task print];
        }
        
        //printf("*** end item2Sync list\n");
        
        NSDictionary *taskSyncDict = [TaskManager getTaskDictBySDWID:taskList];
        
        NSMutableDictionary *dupCategoryDict = [NSMutableDictionary dictionaryWithCapacity:10];

        if (self.dupCategoryList.count > 0)
        {
            for (NSNumber *prjNum in self.dupCategoryList)
            {
                NSMutableDictionary *taskNameDict = [NSMutableDictionary dictionaryWithCapacity:50];
                
                [dupCategoryDict setObject:taskNameDict forKey:prjNum];
            }
            
            for (Task *task in taskList)
            {
                NSMutableDictionary *taskNameDict = [dupCategoryDict objectForKey:[NSNumber numberWithInt:task.project]];
                
                if (taskNameDict != nil)
                {
                    [taskNameDict setObject:task forKey:task.name];
                }
            }
        }
        
        NSMutableArray *updateList = [NSMutableArray arrayWithCapacity:20];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            if ([dict objectForKey:@"id"] == nil)
            {
                continue;
            }
            
            Task *sdwTask = [self getSDWTask:dict];
            
            /*if ([sdwTask isEvent])
            {
                printf("mSD Event: %s\n", [sdwTask.name UTF8String]);
            }*/
            
            if (sdwTask.project == -1 || sdwTask == nil)
            {
                //task from hidden category -> not sync
                
                //printf("sdw task %s is from hidden project\n", [sdwTask.name UTF8String]);
                
                continue;
            }
            
            Task *task = [taskSyncDict objectForKey:sdwTask.sdwId];
            
            if (task != nil) //already sync
            {                
                NSComparisonResult compRes = [Common compareDate:task.updateTime withDate:sdwTask.updateTime];
                
                //printf("task: %s - sc time: %s, sdw time: %s\n",[task.name UTF8String], [[task.updateTime description] UTF8String], [[sdwTask.updateTime description] UTF8String]);
                
                if (compRes == NSOrderedAscending) //update SDW->SC
                {
                    BOOL taskChange = ([task isEvent] && [sdwTask isTask]) || ([task isTask] && [sdwTask isEvent]);
                    
                    if (taskChange)
                    {
                        if (![task.syncId isEqualToString:@""])
                        {
                            [task deleteFromDatabase:[dbm getDatabase]]; //to delete in other sources such as iCal/Toodledo
                            
                            task.sdwId = @"";
                            [task updateSDWIDIntoDB:[dbm getDatabase]];
                        }
                        else
                        {
                            [task cleanFromDatabase:[dbm getDatabase]];
                        }
                    }
                    
                    [self updateTask:task withSDWTask:sdwTask];
                    
                    if (taskChange)
                    {
                        //printf("Type Change -> insert SDW->SC: %s\n", [task.name UTF8String]);
                        
                        task.primaryKey = -1;
                        task.syncId = @"";
                        [task insertIntoDB:[dbm getDatabase]];
                    }
                    else
                    {
                        //printf("update SDW->SC: %s\n", [task.name UTF8String]);
                        
                        [task updateIntoDB:[dbm getDatabase]];
                    }
                    
                    if ([task isRE])
                    {
                        Task *delExc = [dbm getDeletedExceptionForRE:task.primaryKey];
                        
                        if (sdwTask.exceptions != nil && sdwTask.exceptions.count > 0)
                        {
                            Task *updateDelExc = [[sdwTask.exceptions objectEnumerator] nextObject];
                            
                            if (delExc == nil)
                            {
                                updateDelExc.primaryKey = -1;
                                updateDelExc.groupKey = task.primaryKey;
                                
                                [updateDelExc insertIntoDB:[dbm getDatabase]];
                            }
                            else 
                            {
                                delExc.repeatData = updateDelExc.repeatData;
                                [delExc updateRepeatDataIntoDB:[dbm getDatabase]];
                            }
                        }
                        else if (delExc != nil)
                        {
                            [delExc cleanFromDatabase:[dbm getDatabase]];
                        }
                    }
                    
                    BOOL alertChange = sdwTask.alerts.count > 0 || (task.alerts.count > 0 && sdwTask.alerts.count == 0);
                    
                    if (alertChange)
                    {
                        //sync alerts
                        
                        [[AlertManager getInstance] removeAllAlertsForTask:task];
                        
                        for (AlertData *alert in sdwTask.alerts)
                        {
                            alert.taskKey = task.primaryKey;
                            alert.primaryKey = -1;
                            
                            [alert insertIntoDB:[dbm getDatabase]];
                        }
                        
                        task.alerts = sdwTask.alerts;
                        
                        [[AlertManager getInstance] generateAlertsForTask:task];
                    }
                    
                }
                else if (compRes == NSOrderedDescending) //update SC->SDW
                {
                    //printf("update SC->SDW: %s\n", [task.name UTF8String]);
                    [updateList addObject:task];
                }

                [self syncExceptions:task];
                
                [taskList removeObject:task];
            } 
            else 
            {
                if (![self checkTaskCompletedInRange:sdwTask])
                {
                    continue; //don't sync task completed outside 2 weeks
                }
                
                BOOL taskCreation = YES;
                
                NSDictionary *taskNameDict = [dupCategoryDict objectForKey:[NSNumber numberWithInt:sdwTask.project]];
                
                if (taskNameDict != nil)
                {
                    //sdw Task is in suspected duplicated category
                    
                    Task *task = [taskNameDict objectForKey:sdwTask.name];
                    
                    if (task != nil)
                    {
                        BOOL duplicated = NO;
                        
                        if ([task isTask])
                        {
                            duplicated = [Common compareDate:task.startTime withDate:sdwTask.startTime] == NSOrderedSame &&
                                        [Common compareDate:task.deadline withDate:sdwTask.deadline] == NSOrderedSame &&
                                        task.duration == sdwTask.duration;
                        }
                        else
                        {
                            duplicated = [Common compareDate:task.startTime withDate:sdwTask.startTime] == NSOrderedSame &&
                            [Common compareDate:task.endTime withDate:sdwTask.endTime] == NSOrderedSame;                            
                        }
                        
                        if (duplicated)
                        {
                            //printf("task %s is duplication suspected\n", [task.name UTF8String]);
                            
                            task.sdwId = sdwTask.sdwId;
                            [task updateSDWIDIntoDB:[dbm getDatabase]];
                            
                            taskCreation = NO;
                            [taskList removeObject:task];
                        }
                    }
                    
                }
                
                if (taskCreation) 
                {
                    task = [[Task alloc] init];
                    
                    [self updateTask:task withSDWTask:sdwTask];
                    
                    //printf("insert SDW->SC: %s\n", [task.name UTF8String]);
                    
                    [task insertIntoDB:[dbm getDatabase]];
                    
                    if ([task isRE])
                    {
                        if (sdwTask.exceptions != nil && sdwTask.exceptions.count > 0)
                        {
                            Task *updateDelExc = [[sdwTask.exceptions objectEnumerator] nextObject];
                            
                            updateDelExc.primaryKey = -1;
                            updateDelExc.groupKey = task.primaryKey;
                            
                            [updateDelExc insertIntoDB:[dbm getDatabase]];
                        }                        
                    }
                    
                    if (sdwTask.alerts != nil)
                    {
                        //sync alerts
                        
                        [[AlertManager getInstance] removeAllAlertsForTask:task];
                        
                        for (AlertData *alert in sdwTask.alerts)
                        {
                            alert.taskKey = task.primaryKey;
                            alert.primaryKey = -1;
                            
                            [alert insertIntoDB:[dbm getDatabase]];
                        }
                        
                        task.alerts = sdwTask.alerts;
                        
                        [[AlertManager getInstance] generateAlertsForTask:task];
                    }
                    
                    [task release];                    
                }
            }
        }        
        
        if (updateList.count > 0)
        {
            [self breakSync:updateList command:UPDATE_TASK];
        }
        
        NSMutableArray *delList = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *removeList = [NSMutableArray arrayWithCapacity:5];
        
        for (Task *task in taskList)
        {
            if (task.sdwId != nil && ![task.sdwId isEqualToString:@""]) //task was deleted in SDW
            {
                [delList addObject:task];
            }
            else if (task.groupKey != -1)
            {
                //[taskList removeObject:task]; //RE exceptions will sync via root
                [removeList addObject:task];
            }
        }
        
        for (Task *task in removeList)
        {
            [taskList removeObject:task];
        }
        
        for (Task *task in delList)
        {
            [taskList removeObject:task];
            
            //[task cleanFromDatabase:[dbm getDatabase]];
            
            task.sdwId = @"";
            [task updateSDWIDIntoDB:[dbm getDatabase]];
            
            NSMutableArray *links = [tlm getLinks4Task:task.primaryKey];
            
            for (Link *link in links)
            {
                [link cleanFromDatabase:[dbm getDatabase]];
            }
            
            task.links = [NSMutableArray arrayWithCapacity:0];
            
            [task deleteFromDatabase:[dbm getDatabase]];
        }
        
        if (taskList.count > 0) //sync Tasks from SC
        {
            [self breakSync:taskList command:ADD_TASK];
        }

    }
}

#pragma mark Sync Order

- (NSDictionary *) toSDWTaskDict4Order:(Task *)task
{
    NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              task.sdwId,@"id",
                              [NSNumber numberWithInt:task.sequenceNo],@"order_number",
                              nil];
    
    return taskDict;
    
}

- (NSDictionary *) toSDWCategoryDict4Order:(Project *)project
{
    NSDictionary *prjDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              project.sdwId,@"id",
                              [NSNumber numberWithInt:project.sequenceNo],@"order_category",
                              nil];
    
    return prjDict;
    
}


- (Task *) getSDWTask4Order:(NSDictionary *) dict
{
    Task *ret = [[[Task alloc] init] autorelease];
    
    ret.sdwId = [[dict objectForKey:@"id"] stringValue];
    ret.sequenceNo = [[dict objectForKey:@"order_number"] intValue];
    ret.updateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"last_update"] intValue]];
    
    return ret;
    
}

- (void) updateOrder4Tasks:(NSArray *)taskList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/tasks/updates.json?keyapi=%@&fields=id,order_number,last_update",SDWSite,self.sdwSection.key];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"PUT"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *sdwTaskList = [NSMutableArray arrayWithCapacity:taskList.count];
    NSDictionary *taskDict = [TaskManager getTaskDictBySDWID:taskList];
    
    for (Task *task in taskList)
    {
        [sdwTaskList addObject:[self toSDWTaskDict4Order:task]];
        
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwTaskList options:0 error:&error];
    
    //NSString* body = [[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding];
    
    ////printf("update task body:\n%s\n", [body UTF8String]);
    
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("update task order results:\n%s\n", [str UTF8String]);
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Task *task = [taskDict objectForKey:sdwId];
                
                if (task != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    task.updateTime = dt;
                    [task enableExternalUpdate];
                    
                    [task modifyUpdateTimeIntoDB:[dbm getDatabase]];
                }
            }
        }        
    }
}

- (void) updateOrder4Categories:(NSArray *)prjList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/categories/updates.json?keyapi=%@&fields=id,order_number,last_update",SDWSite,self.sdwSection.key];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"PUT"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableArray *sdwPrjList = [NSMutableArray arrayWithCapacity:prjList.count];
    NSDictionary *prjDict = [ProjectManager getProjectDictBySDWID:prjList];
    
    for (Project *prj in prjList)
    {
        [sdwPrjList addObject:[self toSDWCategoryDict4Order:prj]];
        
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwPrjList options:0 error:&error];
    
    NSString* body = [[NSString alloc] initWithData:jsonBody encoding:NSUTF8StringEncoding];
    
    //printf("update project order body:\n%s\n", [body UTF8String]);
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("update project order results:\n%s\n", [str UTF8String]);
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Project *prj = [prjDict objectForKey:sdwId];
                
                if (prj != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    prj.updateTime = dt;
                    [prj enableExternalUpdate];
                    
                    [prj modifyUpdateTimeIntoDB:[dbm getDatabase]];
                }
            }
        }
    }
}


- (void) syncTaskOrder:(BOOL)fromSDW
{
    //printf("Sync Order from %s->%s\n", fromSDW?"SDW":"SD", fromSDW?"SD":"SDW");
    
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *taskList = [dbm getAllTasks];
    NSDictionary *taskSyncDict = [TaskManager getTaskDictBySDWID:taskList];
    
    if (fromSDW)
    {
        NSString *url = [NSString stringWithFormat:@"%@/api/tasks.json?keyapi=%@&fields=id,order_number,last_update&type=2",SDWSite,self.sdwSection.key];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]]; 
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
        
        NSError *error = nil;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [request release];
        
        if (error != nil)
        {
            self.errorDescription = error.localizedDescription;
            
            return;
        }
        
        if (urlData) 
        {
            NSArray *result = [self getArrayResult:urlData];
            
            if (result == nil)
            {
                return;
            }
            
            for (NSDictionary *dict in result)
            {
                Task *sdwTask = [self getSDWTask4Order:dict];
                
                Task *task = [taskSyncDict objectForKey:sdwTask.sdwId];
                
                if (task != nil) //already sync
                {
                    task.sequenceNo = sdwTask.sequenceNo;
                    task.updateTime = sdwTask.updateTime;
                    
                    [task enableExternalUpdate];
                    
                    [task updateSeqNoIntoDB:[dbm getDatabase]];
                }   
            }
        }
    }
    else 
    {
        [self breakSync:taskList command:UPDATE_TASK_ORDER];
    }
}

- (void) syncProjectOrder
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    [self breakSync:pm.projectList command:UPDATE_CATEGORY_ORDER];
}

#pragma mark Sync Links
- (Link *) getSDWLink:(NSDictionary *) dict
{
    DBManager *dbm = [DBManager getInstance];
    
    Link *ret = [[[Link alloc] init] autorelease];
    
    ret.sdwId = [[dict objectForKey:@"id"] stringValue];
    
    id root = [dict objectForKey:@"root_id"];
    id target = [dict objectForKey:@"target_id"];
    
    if (root == [NSNull null] || target == [NSNull null])
    {
        return nil;
    }
    
    NSString *rootId = [root stringValue];
    NSString *targetId = [target stringValue];
    
    ret.srcId = [dbm getKey4SDWId:rootId];
    ret.destId = [dbm getKey4SDWId:targetId];
    
    ret.updateTime = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"last_update"] intValue]]; 
    
    if (ret.srcId == -1 || ret.destId == -1)
    {
        ret = nil;
    }
    
    return ret;
}

- (NSDictionary *) toSDWLinkDict:(Link *)link
{
    DBManager *dbm = [DBManager getInstance];
    
    NSString *rootId = [dbm getSDWId4Key:link.srcId];
    NSString *targetId = [dbm getSDWId4Key:link.destId];
    
    //printf("find root/target for link : %d - root:[%d, %s] - target: [%d, %s]\n", link.primaryKey, link.srcId, [rootId UTF8String], link.destId, [targetId UTF8String]);
    
    NSDictionary *taskDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              link.sdwId,@"id",
                              rootId, @"root_id",
                              targetId, @"target_id",
                              [NSNumber numberWithInt:link.primaryKey], @"ref",                              
                              nil];
    
    if (rootId == nil || targetId == nil)
    {
        taskDict = nil;
    }
    
    return taskDict; 
}


- (void) updateLink:(Link *)link withSDWLink:(Link *)sdwLink
{
    link.sdwId = sdwLink.sdwId;
    link.srcId = sdwLink.srcId;
    link.destId = sdwLink.destId;
    
    link.updateTime = sdwLink.updateTime;
    
	if (link.primaryKey > -1)
	{
		[link enableExternalUpdate];		
	}        
}

- (void) addLinks:(NSArray *)linkList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/hyperlinks.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    //printf("add link url:%s\n", [urlString UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *sdwList = [NSMutableArray arrayWithCapacity:linkList.count];
    NSDictionary *linkDict = [TaskLinkManager getLinkDictByKey:linkList];
    
    for (Link *link in linkList)
    {
        NSDictionary *linkDict = [self toSDWLinkDict:link];
        
        if (linkDict == nil)
        {
            //not found root or target on SDW
            continue;
        }
        
        //printf("insert link SD->SDW: %d - src: %d - dest: %d\n", link.primaryKey, link.srcId, link.destId);
        
        [sdwList addObject:linkDict];
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwList options:0 error:&error];
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("add links return:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger key = [[dict objectForKey:@"ref"] intValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Link *link = [linkDict objectForKey:[NSNumber numberWithInt:key]];
                
                if (link != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    link.updateTime = dt;
                    link.sdwId = sdwId;
                    
                    [link updateSDWIDIntoDB:[dbm getDatabase]];
                }
            }
        }        
    }
}

- (void) updateLinks:(NSArray *)linkList
{
    DBManager *dbm = [DBManager getInstance];
    
	NSString *urlString=[NSString stringWithFormat:@"%@/api/hyperlinks/update.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
	[request setURL:[NSURL URLWithString:urlString]]; 
	[request setHTTPMethod:@"PUT"]; 
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSMutableArray *sdwLinkList = [NSMutableArray arrayWithCapacity:linkList.count];
    NSDictionary *linkDict = [TaskLinkManager getLinkDictBySDWID:linkList];
    
    for (Link *link in linkList)
    {
        [sdwLinkList addObject:[self toSDWLinkDict:link]];
        
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwLinkList options:0 error:&error];
    
    [request setHTTPBody:jsonBody];
	
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
            NSInteger lastUpdate = [[dict objectForKey:@"last_update"] intValue];
            
            if (sdwId != nil)
            {
                Link *link = [linkDict objectForKey:sdwId];
                
                if (link != nil)
                {
                    NSDate *dt = [NSDate dateWithTimeIntervalSince1970:lastUpdate];
                    
                    link.updateTime = dt;
                    [link enableExternalUpdate];
                    
                    [link modifyUpdateTimeIntoDB:[dbm getDatabase]];
                }
            }
        }        
    }
}


- (void) deleteLinks:(NSMutableArray *)delList
{
    //DBManager *dbm = [DBManager getInstance];
    
    NSDictionary *delDict = [TaskLinkManager getLinkDictBySDWID:delList];
    
    NSString *idList = nil;
    
	for (Link *link in delList)
	{
        if (link.sdwId != nil && ![link.sdwId isEqualToString:@""])
        {
            if (idList == nil)
            {
                idList = link.sdwId;
            }
            else 
            {
                idList = [NSString stringWithFormat:@"%@,%@", idList, link.sdwId];
            }
        }
    } 
    
    if (idList != nil)
    {
        NSString *urlString=[NSString stringWithFormat:@"%@/api/hyperlinks/%@.json?keyapi=%@",SDWSite,idList,self.sdwSection.key];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
        [request setURL:[NSURL URLWithString:urlString]]; 
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error = nil;
        NSURLResponse *response; 
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        [request release];
        
        if (error != nil)
        {
            self.errorDescription = error.localizedDescription;
            
            return;
        }
        
        if (urlData) 
        {
            NSArray *result = [self getArrayResult:urlData];
            
            if (result == nil)
            {
                return;
            }
            
            for (NSDictionary *dict in result)
            {
                NSString *delId = [dict objectForKey:@"success"];
                
                if (delId != nil)
                {
                    Link *delLink = [delDict objectForKey:delId];
                    
                    if (delLink != nil)
                    {
                        [delLink cleanFromDatabase];
                    }
                }
            }
        }
    }
}

- (void) syncDeletedLinks
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *delList = [dbm getDeletedLinks];
    
    if (delList.count > 0)
    {
        [self breakSync:delList command:DELETE_LINK];
    }
}

- (void) syncLinks 
{
    [self syncDeletedLinks];

    DBManager *dbm = [DBManager getInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/hyperlinks.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    //printf("getLinks: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];

    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("get links return:\n%s\n", [str UTF8String]);
        
        NSMutableArray *linkList = [dbm getAllLinks];
        
        NSDictionary *linkDict = [TaskLinkManager getLinkDictBySDWID:linkList];
        
        NSMutableArray *updateList = [NSMutableArray arrayWithCapacity:20];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            if ([dict objectForKey:@"id"] == nil)
            {
                continue;
            }
            
            Link *sdwLink = [self getSDWLink:dict];
            
            if (sdwLink == nil)
            {
                //no source or destination found
                continue;
            }
            
            //printf("sdw link id - %s, src: %d, dest: %d\n", [sdwLink.sdwId UTF8String], sdwLink.srcId, sdwLink.destId);
            
            Link *link = [linkDict objectForKey:sdwLink.sdwId];
            
            if (link != nil) //already sync
            {                
                NSComparisonResult compRes = [Common compareDate:link.updateTime withDate:sdwLink.updateTime];
                
                if (compRes == NSOrderedAscending) //update SDW->SC
                {
                    //printf("update Link SDW->SC: %s\n", [link.sdwId UTF8String]);
                    [self updateLink:link withSDWLink:sdwLink];
                    
                    [link updateIntoDB:[dbm getDatabase]];
                    
                }
                else if (compRes == NSOrderedDescending) //update SC->SDW
                {
                    //printf("update Link SC->SDW: %s\n", [link.sdwId UTF8String]);
                    
                    [updateList addObject:link];
                }
                
                [linkList removeObject:link];
            } 
            else 
            {
                link = [[Link alloc] init];
                
                [self updateLink:link withSDWLink:sdwLink];
                
                //printf("insert Link SDW->SC: %s\n", [link.sdwId UTF8String]);
                
                [link insertIntoDB:[dbm getDatabase]];
                
                [link release];                                    
            }            
        }
        
        if (updateList.count > 0)
        {
            [self breakSync:updateList command:UPDATE_LINK];
        }
        
        NSMutableArray *delList = [NSMutableArray arrayWithCapacity:5];
        
        for (Link *link in linkList)
        {
            if (link.sdwId != nil && ![link.sdwId isEqualToString:@""]) //link was deleted in SDW
            {
                [delList addObject:link];
            }
        }
        
        for (Link *link in delList)
        {
            [link cleanFromDatabase:[dbm getDatabase]];
            
            [linkList removeObject:link];
        }
        
        if (linkList.count > 0) //sync Tasks from SC
        {
            //printf("insert %d links SD->SDW\n", linkList.count);
            
            [self breakSync:linkList command:ADD_LINK];
        }
    }

}

- (void) get1wayLinks
{
    NSString *url = [NSString stringWithFormat:@"%@/api/hyperlinks.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    //printf("getLinks: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        DBManager *dbm = [DBManager getInstance];
        
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("get links return:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            Link *sdwLink = [self getSDWLink:dict];
            
            Link *link = [[Link alloc] init];
            
            [self updateLink:link withSDWLink:sdwLink];
            
            //printf("insert Link SDW->SC: %s\n", [link.sdwId UTF8String]);
            
            [link insertIntoDB:[dbm getDatabase]];
            
            [link release];            
        }
    }
}

- (void) push1wayLinks
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *linkList = [dbm getAllLinks];
 
    if (linkList.count > 0) //sync Tasks from SC
    {
        //printf("insert %d links SD->SDW\n", linkList.count);
        
        [self breakSync:linkList command:ADD_LINK];
    }
}

#pragma mark Synn Tags

- (void) syncDeletedTags
{
    TagDictionary *tagMgr = [TagDictionary getInstance];
    
    NSArray *tagIds = [[tagMgr.deletedTagDict objectEnumerator] allObjects];
    
    if (tagIds.count > 0)
    {
        NSString *list = [tagIds componentsJoinedByString:@","];
        
        NSString *urlString=[NSString stringWithFormat:@"%@/api/tags/%@.json?keyapi=%@",SDWSite,list,self.sdwSection.key];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *error = nil;
        NSURLResponse *response;
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        [request release];
        
        if (error != nil)
        {
            self.errorDescription = error.localizedDescription;
            
            return;
        }
        
        [tagMgr cleanDeletedTagList];
        
    }    
}

- (void) syncTags
{
    [self syncDeletedTags];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/tags.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    //printf("getTags: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("get Tags return:\n%s\n", [str UTF8String]);
        
        TagDictionary *tagMgr = [TagDictionary getInstance];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result != nil)
        {
            NSMutableArray *mySDTagList = [NSMutableArray arrayWithCapacity:50];
            
            for (NSDictionary *dict in result)
            {
                if ([dict valueForKey:@"id"])
                {
                    NSString *sdwId = [[dict valueForKey:@"id"] stringValue];
                    
                    if ([dict valueForKey:@"name"]) {
                        NSString *tag = [dict valueForKey:@"name"];
                        
                        [mySDTagList addObject:tag];
                        
                        //printf("add Tag SDW->SC: %s\n", [tag UTF8String]);
                        if (![tag isEqualToString:@""])
                        {
                            [tagMgr importTag:tag sdwId:sdwId];
                        }
                    }
                }
            }
            
            NSMutableDictionary *tagDict = [[NSMutableDictionary alloc] initWithDictionary:tagMgr.tagDict copyItems:YES];
            
            for (NSString *tag in mySDTagList)
            {
                [tagDict removeObjectForKey:tag];
            }
            
            NSArray *tags = [NSArray arrayWithArray:tagDict.allKeys];
            
            for (NSString *tag in tags)
            {
                NSString *tagId = [tagDict objectForKey:tag];
                
                if (![tagId isEqualToString:@""])
                {
                    //tag was deleted from mSD
                    
                    //[tagMgr.tagDict removeObjectForKey:tag];
                    
                    [tagMgr.tagDict setObject:@"" forKey:tag]; //clear sdw ID before deletion
                    [tagMgr deleteTag:tag];
                    
                    [tagDict removeObjectForKey:tag];
                }
            }
            
            [tagMgr saveDict];
            
            if (tagDict.allKeys.count > 0)
            {
                [self breakSync:tagDict.allKeys command:ADD_TAG];
            }
        }
        
    }
}

- (void) addTags:(NSArray *)tagList
{
	NSString *urlString=[NSString stringWithFormat:@"%@/api/tags.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    //printf("add tags url:%s\n", [urlString UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableArray *sdwList = [NSMutableArray arrayWithCapacity:tagList.count];
    
    for (NSString *tag in tagList)
    {
        //printf("insert tag SC->SDW: %s \n", [tag UTF8String]);
        
        NSDictionary *data = [NSDictionary dictionaryWithObject:tag forKey:@"name"];
        
        [sdwList addObject:data];
    }
    
    NSError *error = nil;
    NSURLResponse *response;
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:sdwList options:0 error:&error];
    
    NSString* body = [[NSString alloc] initWithData:jsonBody
                                           encoding:NSUTF8StringEncoding];
    
    //printf("add tag body:\n%s\n", [body UTF8String]);
    
    [request setHTTPBody:jsonBody];
    
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
	
    if (urlData)
    {
        NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("add tags return:\n%s\n", [str UTF8String]);
        
        TagDictionary *tagMgr = [TagDictionary getInstance];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            if ([dict objectForKey:@"id"] != nil)
            {
                NSString *sdwId = [[dict objectForKey:@"id"] stringValue];
                NSString *tag = [dict objectForKey:@"name"];
                
                //printf("add tag returns id:%s - tag:%s\n", [sdwId UTF8String], [tag UTF8String]);
                
                [tagMgr importTag:tag sdwId:sdwId];                
            }
        }
        
        [tagMgr saveDict];
    }

}

- (void) push1wayTags
{
    NSString *urlString=[NSString stringWithFormat:@"%@/api/tags/%@.json?keyapi=%@",SDWSite,@"0",self.sdwSection.key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error = nil;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("SDW delete all tags return:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result != nil && result.count == 1)
        {
            NSDictionary *dict = [result objectAtIndex:0];
            
            if ([dict objectForKey:@"success"] != nil)
            {
                NSMutableDictionary *tagDict = [[TagDictionary getInstance] tagDict];
                
                //[self breakSync:tagDict.objectEnumerator.allObjects command:ADD_TAG];
                [self breakSync:tagDict.allKeys command:ADD_TAG];
            }
        }
    }
}

- (void) get1wayTags
{
    NSString *url = [NSString stringWithFormat:@"%@/api/tags.json?keyapi=%@",SDWSite,self.sdwSection.key];
	
    //printf("getTags: %s\n", [url UTF8String]);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData)
    {
        TagDictionary *tagMgr = [TagDictionary getInstance];
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result != nil)
        {
            NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithCapacity:result.count];
            
            for (NSDictionary *dict in result)
            {
                if ([dict valueForKey:@"id"])
                {
                    NSString *sdwId = [[dict valueForKey:@"id"] stringValue];
                    
                    if ([dict valueForKey:@"name"]) {
                        NSString *tag = [dict valueForKey:@"name"];
                        
                        [tagDict setObject:sdwId forKey:tag];
                    }
                }
            }
            
            [tagMgr importTagDict:tagDict];
        }
    }
}

#pragma mark Auto Sync 1-way

- (void) sync1way4Links:(NSMutableArray *)linkList
{
    NSMutableArray *delList = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *addList = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *updateList = [NSMutableArray arrayWithCapacity:50];
    
    for (Link *link in linkList)
    {
        if (link.sdwId == nil || [link.sdwId isEqualToString:@""]) //new from SC
        {
            //printf("1-way sync - Add Link between source: %d and target: %d\n", link.srcId, link.destId);
            
            [addList addObject:link];
        }
        else 
        {
            if (link.status == LINK_STATUS_DELETED)
            {
                //printf("1-way sync - Delete Link between source: %d and target: %d\n", link.srcId, link.destId);
                
                [delList addObject:link];
            }
            else 
            {
                //printf("1-way sync - Update Link between source: %d and target: %d\n", link.srcId, link.destId);
                
                [updateList addObject:link];
            }
        }
    }  
    
    if (addList.count > 0)
    {
        [self breakSync:addList command:ADD_LINK];
    }
    
    if (updateList.count > 0)
    {
        [self breakSync:updateList command:UPDATE_LINK];
    }
    
    if (delList.count > 0)
    {
        [self breakSync:delList command:DELETE_LINK];
    }
}

- (void) sync1way4Items:(NSMutableArray *)itemList
{
    NSMutableArray *cleanList = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *delList = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *addList = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *updateList = [NSMutableArray arrayWithCapacity:50];
    
    for (Task *task in itemList)
    {
        NSString *sdwId = [self.scSDWMappingDict objectForKey:[NSNumber numberWithInt: task.project]];
        
        if (task.sdwId == nil || [task.sdwId isEqualToString:@""]) //new from SC
        {
            if (sdwId != nil)
            {
                //printf("1-way sync Add Task SD->SDW: %s\n", [task.name UTF8String]);
                [task print];
                
                [addList addObject:task];					
            }
        }
        else 
        {
            if (task.status == TASK_STATUS_DELETED)
            {
                //printf("1-way sync Clean Task SD->SDW: %s\n", [task.name UTF8String]);
                [cleanList  addObject:task];
            }
            else 
            {
                if (sdwId == nil) //calendar is changed in SC, not match TD folder -> delete in TD
                {
                    //printf("1-way sync Delete Task SD->SDW [Project change in SD]: %s\n", [task.name UTF8String]);
                    [task print];	
                    
                    [delList addObject:task];
                }
                else 
                {
                    //printf("1-way sync Update Task SD->SDW: %s \n", [task.name UTF8String]);
                    
                    [task print];	
                    
                    [updateList addObject:task];
                    
                }				
            }
        }
    }
    
    if (addList.count > 0)
    {
        [self breakSync:addList command:ADD_TASK];
    }
    
    if (updateList.count > 0)
    {
        [self breakSync:updateList command:UPDATE_TASK];
    }
    
    if (delList.count > 0)
    {
        [self breakSync:delList command:DELETE_TASK];
    }
    
    if (cleanList.count > 0)
    {
        [self breakSync:cleanList command:CLEAN_TASK];
    }    
}

- (void) sync1way
{
	@synchronized(self)
	{
		Settings *settings = [Settings getInstance];
		DBManager *dbm = [DBManager getInstance];
		
		NSDate *sdwLastSyncTime = settings.sdwLastSyncTime;
        
        //printf("mySD 1-way sync: query list from date: %s\n", [sdwLastSyncTime.description UTF8String]);
		
		NSMutableArray *itemList = [dbm getModifiedItems2Sync:sdwLastSyncTime];
		NSMutableArray *linkList = [dbm getModifiedLinks2Sync:sdwLastSyncTime];
        
        if (itemList.count == 0)
        {
            //printf("No Item to sync 1-way to mySD\n");
        }
		
        [self sync1way4Items:itemList];
        [self sync1way4Links:linkList];
	}
}

#pragma mark Manual Sync 1-way
- (void) push1way
{
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    self.sdwSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scSDWMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSString *urlString=[NSString stringWithFormat:@"%@/api/categories/%@.json?keyapi=%@",SDWSite,@"0",self.sdwSection.key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init]; 
    [request setURL:[NSURL URLWithString:urlString]]; 
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSError *error = nil;
    NSURLResponse *response; 
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        //printf("SDW delete all categories return:\n%s\n", [str UTF8String]);
        
        NSArray *result = [self getArrayResult:urlData];
        
        if (result != nil && result.count == 1)
        {
            NSDictionary *dict = [result objectAtIndex:0];
            
            if ([dict objectForKey:@"success"] != nil)
            {
                NSMutableArray *prjList = [NSMutableArray arrayWithArray: pm.projectList];
                
                if (prjList.count > 0) //push Projects from SC
                {
                    [self breakSync:prjList command:ADD_CATEGORY];
                }  
                
                [self push1waySetting];
                
                [self push1wayTags];
                
                NSMutableArray *taskList = [dbm getItems2Sync];
                
                if (taskList.count > 0) //push Tasks from SC
                {
                    [self breakSync:taskList command:ADD_TASK];
                }
                
                [self push1wayLinks];
            }
        }
    }
}

- (void) get1way
{
    ProjectManager *pm = [ProjectManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    self.sdwSCMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.scSDWMappingDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/categories.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"GET"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        self.errorDescription = error.localizedDescription;
        
        return;
    }
    
    if (urlData) 
    {
        NSArray *result = [self getArrayResult:urlData];
        
        if (result == nil)
        {
            return;
        }
        
        for (NSDictionary *dict in result)
        {
            Project *sdwCat = [self getSDWCategory:dict];
            
            if (sdwCat.type == 1) //Old CheckList style -> not sync
            {
                continue;
            }            
            
            Project *prj = [[Project alloc] init];
            
            prj.sdwId = sdwCat.sdwId;
            prj.source = CATEGORY_SOURCE_SDW;
            
            [self updateProject:prj withSDWCategory:sdwCat];
            
            //printf("create category %s in SD\n", [prj.name UTF8String]);
            
            [pm addProject:prj];
            
            [prj release];     
            
            [self.sdwSCMappingDict setObject:[NSNumber numberWithInt:prj.primaryKey] forKey:sdwCat.sdwId]; 
        }
        
        [self get1waySetting];
        
        [self get1wayTags];
        
        NSString *url = [NSString stringWithFormat:@"%@/api/tasks.json?keyapi=%@",SDWSite,self.sdwSection.key];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
        
        NSError *error = nil;
        NSURLResponse *response;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [request release];
        
        if (error != nil)
        {
            self.errorDescription = error.localizedDescription;
            
            return;
        }
        
        if (urlData) 
        {
            NSArray *result = [self getArrayResult:urlData];
            
            if (result == nil)
            {
                return;
            }
            
            for (NSDictionary *dict in result)
            {
                Task *sdwTask = [self getSDWTask:dict];
                
                if (sdwTask == nil)
                {
                    continue;
                }
               
                Task *task = [[Task alloc] init];
                
                [self updateTask:task withSDWTask:sdwTask];
                
                //printf("insert SDW->SC: %s\n", [task.name UTF8String]);
                
                [task insertIntoDB:[dbm getDatabase]];
                
                if ([task isRE])
                {
                    if (sdwTask.exceptions != nil && sdwTask.exceptions.count > 0)
                    {
                        Task *updateDelExc = [[sdwTask.exceptions objectEnumerator] nextObject];
                        
                        updateDelExc.primaryKey = -1;
                        updateDelExc.groupKey = task.primaryKey;
                        
                        [updateDelExc insertIntoDB:[dbm getDatabase]];
                    }                        
                }
                
                if (sdwTask.alerts != nil)
                {
                    //sync alerts
                    
                    [[AlertManager getInstance] removeAllAlertsForTask:task];
                    
                    for (AlertData *alert in sdwTask.alerts)
                    {
                        alert.taskKey = task.primaryKey;
                        alert.primaryKey = -1;
                        
                        [alert insertIntoDB:[dbm getDatabase]];
                    }
                    
                    task.alerts = sdwTask.alerts;
                    
                    [[AlertManager getInstance] generateAlertsForTask:task];
                }
                
                [task release];                 
                
            }            
        }
        
        [self get1wayLinks];
    }
}

#pragma mark Actions
- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex != 0) //not Cancel
	{
        if (buttonIndex == 1)
        {
            Settings *settings = [Settings getInstance];
            
            [settings enableMSDBackupHint:NO];
        }
    }
    /*else if (alertVw.tag == -11000)
    {
        if (buttonIndex == 1)
        {
            [self sync];
        }
        
        [self syncComplete];        
    }*/
}

#pragma mark Backup
- (BOOL) backup
{
    NSString *urlString=[NSString stringWithFormat:@"%@/api/backups.json?keyapi=%@",SDWSite,self.sdwSection.key];
    
    //printf("backup: %s\n", [urlString UTF8String]);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error=nil;
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error != nil)
    {
        //printf("network error: %d - %s\n", error.code, [error.localizedDescription UTF8String]);
        
        self.errorDescription = error.localizedDescription;
        
        return NO;
    }
    
    if (urlData)
    {
        NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        //printf("SDW backup return:\n%s\n", [str UTF8String]);
        
/*        NSDictionary *result = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableLeaves error:&error];
        
        NSString *errMsg = [result objectForKey:@"error"];
        
        if (errMsg != nil)
        {
            printf("SDW backup return error:\n%s\n", [errMsg UTF8String]);
            
            return NO;
        }
*/        
    }
    else
    {
        return NO;
    }
    
    return YES;
}

#pragma mark SDW Connectivity
- (NSString *) registerAccount:(NSString *)email
{
    NSString *errorMsg = nil;
    
    NSError *err = nil;

    NSData *dataAES = [[[NSData alloc] init] AES256EncryptedDataUsingKey:[NSString stringWithFormat:@"%@-%@",email,SDWAppRegId] error:&err];
    NSString *data = [[NSString alloc] initWithData:dataAES encoding:NSUTF8StringEncoding];

    NSString *url = [NSString stringWithFormat:@"%@/api/accounts.json",SDWSite];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *accountDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:data,@"data",SDP_Alias,@"alias", nil] forKey:@"account"];
    
    NSData *jsonBody = [NSJSONSerialization dataWithJSONObject:accountDict options:0 error:&err];
    
    [request setHTTPBody:jsonBody];
    
	NSError *error = nil;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        errorMsg = [[[error localizedDescription] copy] autorelease];
    }
    
    if (urlData) {
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            /*if ([result valueForKey:@"account"]) {
                //printf("SDW account created successfully!");
                return 0;
            }*/
            
            if ([result valueForKey:@"error"]) {
                //NSInteger errorId = [[dic valueForKey:@"error"] intValue];
                NSString *errDesc = [result valueForKey:@"error_description"];
                //printf("SDW account creation failed! - %s\n", [errDesc UTF8String]);
                
                errorMsg = [[errDesc copy] autorelease];
            }
        }
    }
   
    return errorMsg;
}

- (NSString *)createNewAccount:(NSString *)email passWord:(NSString *)pass 
{
    NSString *errorMsg = nil;
    
    NSString *sig = [Common md5:[NSString stringWithFormat:@"%@%@%@",email,pass,SDWAppRegId]];
    NSString *url = [NSString stringWithFormat:@"%@/api/users.json?username=%@&pass=%@&appreg=%@&sig=%@",SDWSite,email,pass,SDWAppRegId,sig];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil; 
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    
    if (error != nil)
    {
        errorMsg = [[[error localizedDescription] copy] autorelease];
    }
    
    if (urlData) {
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            if ([result valueForKey:@"account"]) {
                //printf("SDW account created successfully!");
                return 0;
            }
            
            if ([result valueForKey:@"error"]) {
                //NSInteger errorId = [[dic valueForKey:@"error"] intValue];
                NSString *errDesc = [result valueForKey:@"error_description"];
                //printf("SDW account creation failed! - %s\n", [errDesc UTF8String]);
                
                errorMsg = [[errDesc copy] autorelease];
            }            
        }
    }
    
    return errorMsg;
}

- (NSString *)getToken:(NSString *)email password:(NSString *)pass {
    NSString *sig = [Common md5:[NSString stringWithFormat:@"%@%@%@",email,pass,SDWAppRegId]];
    NSString *url = [NSString stringWithFormat:@"%@/api/token.json?username=%@&pass=%@&appreg=%@&sig=%@",SDWSite,email,pass,SDWAppRegId,sig];
    
    //printf("getToken: %s\n", [url UTF8String]);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
	
	NSError *error = nil; 
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];

    if (error != nil)
    {
        //printf("get Token error code %d - %s\n", error.code, [[error description] UTF8String]);
        
        /*if (error.code == -1004)
        {
            self.errorDescription = _wifiConnectionOffText;
        }*/
        
        self.errorDescription = error.localizedDescription;
    }

    
    if (urlData)
    {
        //NSString* str = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        //printf("getToken return:\n%s\n", [str UTF8String]);
        
        NSDictionary *result = [self getDictionaryResult:urlData];
        
        if (result != nil)
        {
            if ([result valueForKey:@"tokenapi"]) {
                NSString *str = [result valueForKey:@"tokenapi"];
                //printf("sdw token: %s\n", [str UTF8String]);
                
                return str;
            }
            
            if ([result valueForKey:@"error"]) {
                NSInteger errorId = [[result valueForKey:@"error"] intValue];
                
                if (errorId == 1 || errorId == 2)
                {
                    self.errorDescription = _sdwAccountInvalidText;
                }
                else
                {
                    self.errorDescription = _sdwSignupFailedText;
                }
                
                //self.errorDescription = [dic valueForKey:@"error_description"];
                
                //printf("get token failed: %s - %d!\n", [self.errorDescription UTF8String], errorId);
                return nil;
            }
        }
    }
    else 
    {
        //printf("get Token returns nil\n");
    }
    
    return nil;
}

+ (BOOL) refreshDeviceUUID
{
    SDWSync *instance = [SDWSync getInstance];
    
    //instance.sdwSection.deviceUUID = @"5d98db2f982eac44b1866b338d67e06b9b1402e3"; //iPod
    instance.sdwSection.deviceUUID = @"8514e08723d09662c8e023ffc4783435673238dd";//iPhone4
    
    return YES;
}

+ (NSString *) getDeviceUUID
{
    SDWSync *instance = [SDWSync getInstance];
    
    return instance.sdwSection.deviceUUID;
}

+ (NSInteger)checkUserValidity:(NSString*)username password:(NSString*)password
{
    NSString *urlString=[NSString stringWithFormat:@"%@/api/users/checkuser.json?username=%@&pass=%@",SDWSite,username,password];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
    [request setURL:[NSURL URLWithString:urlString]]; 
    [request setHTTPMethod:@"GET"]; 
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    NSError *error=nil; 
    NSURLResponse *response;
    NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        //printf("check validity error: %d - %s\n", error.code, [error.localizedDescription UTF8String]);
        
        return error.code;
    }
    
    NSDictionary *result = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:urlData options:NSJSONReadingMutableLeaves error:&error];
    
    NSInteger ret = 0;
    
    if ([result objectForKey:@"error"])
    {
        ret = [[result valueForKey:@"error"] intValue];
    }
    
    return ret;
}


+(id)getInstance
{
	if (_sdwSyncSingleton == nil)
	{
		_sdwSyncSingleton = [[SDWSync alloc] init];
	}
	
	return _sdwSyncSingleton;
}

+(void)free
{
	if (_sdwSyncSingleton != nil)
	{
		[_sdwSyncSingleton release];
		
		_sdwSyncSingleton = nil;
	}	
}

@end
