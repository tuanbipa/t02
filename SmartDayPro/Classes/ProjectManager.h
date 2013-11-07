//
//  ProjectManager.h
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Project;

@interface ProjectManager : NSObject {
	NSMutableArray *projectList;
    
	NSMutableDictionary *eventIconList;
	NSMutableDictionary *adeIconList;
	NSMutableDictionary *taskIconList;
	NSMutableDictionary *noteIconList;
    NSMutableDictionary *anchoredIconList;

    /*
    NSMutableDictionary *squareIconList;
    NSMutableDictionary *roundedSquareIconList;
    NSMutableDictionary *circleIconList;
    NSMutableDictionary *rectangleIconList;
    NSMutableDictionary *listIconList;
    NSMutableDictionary *taskIconList;
    */
	
	NSMutableDictionary *cascadeDictionary;
}

@property (nonatomic, retain) NSMutableArray *projectList;

@property (nonatomic, retain) NSMutableDictionary *eventIconList;
@property (nonatomic, retain) NSMutableDictionary *adeIconList;
@property (nonatomic, retain) NSMutableDictionary *taskIconList;
@property (nonatomic, retain) NSMutableDictionary *noteIconList;
@property (nonatomic, retain) NSMutableDictionary *anchoredIconList;

/*
@property (nonatomic, retain) NSMutableDictionary *squareIconList;
@property (nonatomic, retain) NSMutableDictionary *roundedSquareIconList;
@property (nonatomic, retain) NSMutableDictionary *circleIconList;
@property (nonatomic, retain) NSMutableDictionary *rectangleIconList;
@property (nonatomic, retain) NSMutableDictionary *listIconList;
*/

@property (nonatomic, retain) NSMutableDictionary *cascadeDictionary;

+(id)getInstance;
+(void)startup;
+ (BOOL) checkListStyle:(NSInteger) prjKey projectDict:(NSMutableDictionary *)projectDict;
+ (NSDictionary *) getProjectDictById:(NSArray *)projectList;
+ (NSDictionary *) getProjectDictionaryByName;
+ (NSDictionary *) getProjectDictByName:(NSArray *)projectList;
+ (NSDictionary *) getProjectDictBySDWID:(NSArray *)projectList;
+ (NSDictionary *) getProjectDictByTaskSyncID:(NSArray *)projectList;
+ (NSDictionary *) getProjectDictByEventSyncID:(NSArray *)projectList;
+ (NSDictionary *) getProjectDictByReminderSyncID:(NSArray *)projectList;
+(void)free;

-(void)makeIcon:(Project *)prj;
- (UIImage *) getEventIcon:(NSInteger)key;
- (UIImage *) getADEIcon:(NSInteger)key;
- (UIImage *) getNoteIcon:(NSInteger)key;
- (UIImage *) getTaskIcon:(NSInteger)key;
- (UIImage *) getAnchoredIcon:(NSInteger)key;
- (void) resetSyncIds;
- (void) resetSDWIds;
- (NSMutableArray *) getCascadeList;
- (NSMutableArray *) sortAndGetCascadeList;
- (void) sortCascadeTasksForProject:(NSInteger)prjKey;
- (void) initProjectList:(NSMutableArray *)list;
-(void) addProject:(Project *)project;
-(void) copyProject:(Project *)project;
-(void)deleteProject:(Project *)prj cleanFromDB:(BOOL)cleanFromDB;
- (void) resolveTagChange:(Project *)prj tag:(NSString *)tag;
- (void) changeOrder:(Project *)srcPrj destPrj:(Project *)destPrj;
-(void)changeProjectType:(Project *)prj type:(NSInteger)type;
-(void)changeProjectName:(Project *)prj name:(NSString *)name;
- (BOOL) checkListStyle:(NSInteger)prjKey;
- (BOOL) checkTransparent:(NSInteger)prjKey;
- (NSMutableArray *) getTransparentProjectList;
- (NSMutableArray *) getVisibleProjectList;
- (NSMutableDictionary *) getInvisibleProjectDict;
- (NSMutableDictionary *) getVisibleProjectDict;
- (NSString *) stringOfInvisibleProjectList;
- (NSArray *) getProjectList;
- (Project *) getProjectAtIndex:(NSInteger)index;
- (Project *) getProjectByKey:(NSInteger)key;
- (NSString *) getProjectNameByKey:(NSInteger)key;
- (NSString *) getProjectTagByKey:(NSInteger)key;
- (NSInteger) getProjectColorID:(NSInteger) key;
- (UIColor *) getProjectColor0:(NSInteger) key;
- (UIColor *) getProjectColor1:(NSInteger) key;
- (UIColor *) getProjectColor2:(NSInteger) key;
- (void) sortProjectList;
- (NSString *) getMappingList: (BOOL)forTask;
- (NSInteger) getSuggestColorId;
- (BOOL) checkExistingProjectName:(NSString *)name excludeProject:(NSInteger)excludeProject;
- (Project *) findProjectByName:(NSString *)name;

#pragma mark Locations Support
- (void)resetLocationID:(NSInteger)locationID;
@end
