//
//  CoreData.h
//  SmartOrganizer
//
//  Created by Nang Le Van on 5/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Setting;
@class Calendar;
@class SPadTask;
@class List;
@class Reachability;
@class SLTaskView;
@class EKSync;
@class ToodleSync;
@class SDWSync;

@interface MigrationData : NSObject {

	Setting *currentSetting;
	NSMutableArray	*allTasksEventsAdes;
	NSMutableArray	*calendarList;
    NSMutableArray  *notesList;
    NSMutableArray  *hyperNotesList;

	NSDate			*today;
}

@property(nonatomic,retain) NSDate			*today;

-(void)checkAndMigrateData;

@end
