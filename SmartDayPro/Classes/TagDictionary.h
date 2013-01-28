//
//  TagDictionary.h
//  SmartCal
//
//  Created by MacBook Pro on 5/4/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TagDictionary : NSObject {	
	NSMutableDictionary *tagDict;
	NSMutableDictionary *presetTagDict;
    NSMutableDictionary *deletedTagDict;
	
	NSMutableDictionary *searchDict;
	
	BOOL dictChanged;
}

@property (readonly) BOOL dictChanged;
@property (nonatomic, retain) NSMutableDictionary *tagDict;
@property (nonatomic, retain) NSMutableDictionary *presetTagDict;
@property (nonatomic, retain) NSMutableDictionary *deletedTagDict;

+ (NSString *) addTagToList:(NSString *)tagList tag:(NSString *)tag;
+ (NSDictionary *) getTagDict:(NSString *)tag;
+ (NSString *) createTagByDict:(NSDictionary *)tagDict;
+ (NSString *) updateTag:(NSString *)tag removeList:(NSString *)removeList addList:(NSString *)addList;

+(void)startup;
+(id) getInstance;
+(void) free;

- (void) loadDict;
- (void) saveDict;
- (void) createSearchForTag:(NSString *)tag;
- (void) removeSearchForTag:(NSString *)tag;
- (void) addTag:(NSString *)tagStr;
- (void) addTagFromList:(NSString *)tagList;
- (void) makePreset:(NSString *)tagStr preset:(BOOL) preset;
- (NSMutableArray *) findTags:(NSString *)str;
- (void)createInitialTagDictIfNeeded;
- (void) deleteTag:(NSString *)tag;
//- (void) importTagList:(NSArray *)tagList;
- (void) importTag:(NSString *)tagStr sdwId:(NSString *)sdwId;
- (void) importTagDict:(NSMutableDictionary *)tagDict;
- (void) cleanDeletedTagList;

@end
