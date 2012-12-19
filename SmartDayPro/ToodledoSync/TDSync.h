//
//  TDSync.h
//  SmartCal
//
//  Created by MacBook Pro on 10/5/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
	SYNC_COMMAND_ADD,
	SYNC_COMMAND_UPDATE,
	SYNC_COMMAND_DELETE,
	SYNC_COMMAND_CLEAN
} TDSyncCommand;


@class TDAccount;
@class TDSyncSection;

@interface TDSync : NSObject {

	NSMutableDictionary *tdTaskDict;
	NSMutableArray *tdDeletedTaskList;
	
	NSMutableDictionary *tdSCMappingDict;
	NSMutableDictionary *scTDMappingDict;
    
    NSMutableArray *dupCategoryList;
	
	TDAccount *account;
	int nFetch;
	int nPlanFetch;
	BOOL noMapping;
	
	NSInteger syncMode;
	BOOL sync1WayPending;
	BOOL sync2WayPending;
	
	TDSyncSection *syncSection;
	NSString *lastError;
}

@property (nonatomic, retain) NSMutableDictionary *tdTaskDict;
@property (nonatomic, retain) NSMutableArray *tdDeletedTaskList;

@property (nonatomic, retain) NSMutableDictionary *tdSCMappingDict;
@property (nonatomic, retain) NSMutableDictionary *scTDMappingDict;
@property (nonatomic, retain) NSMutableArray *dupCategoryList;
@property (nonatomic, retain) NSMutableDictionary *tdArchivedDict;

@property (nonatomic, retain) TDAccount *account;

@property NSInteger syncMode;

@property (nonatomic, retain) TDSyncSection *syncSection;
@property (nonatomic, copy) NSString *lastError;

- (void)resetSyncSection;
- (void)fetchUserId;
- (void) checkSyncComplete;
- (void) checkCleanFolderComplete;
- (void) sync;

-(void)initBackgroundSync;
-(void)initBackground1WaySync;
-(void)initBackgroundAuto2WaySync;
- (void)initBackground1WayTD2SDSync;

+(id)getInstance;
+(void)free;
+ (NSString *) encodeString:(NSString *)str;
+ (NSString *) convertString:(NSString *)str;
@end
