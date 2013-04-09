//
//  EKReminderSync.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/3/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <EventKit/EventKit.h>
#import <Foundation/Foundation.h>

@interface EKReminderSync : NSObject
{
	NSMutableDictionary *scEKMappingDict;
	NSMutableDictionary *ekSCMappingDict;
	
	EKEventStore *eventStore;
	
	NSInteger syncMode;
    
    NSMutableArray *createList;
    
    EKSource *ekSourceLocal;
    EKSource *ekSourceiCloud;
    
    BOOL reminderFetchInProgress;
	
	NSCondition *reminderFetchCond;
}

@property (nonatomic, retain) 	NSMutableDictionary *scEKMappingDict;
@property (nonatomic, retain) 	NSMutableDictionary *ekSCMappingDict;

@property (nonatomic, retain) NSMutableArray *dupCategoryList;

@property (nonatomic, retain) 	EKEventStore *eventStore;

@property NSInteger syncMode;

-(void)initBackgroundSync;
-(void)initBackgroundAuto1WaySync;
-(void)initBackgroundAuto2WaySync;

+ (BOOL) checkEKReminderAccessEnabled;
+(id)getInstance;
+(void)free;

@end
