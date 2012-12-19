//
//  FilterData.h
//  SmartCal
//
//  Created by Trung Nguyen on 6/24/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FilterData : NSObject {
	NSString *taskName;
	NSString *tag;
	NSInteger typeMask;
	NSInteger projectMask;
    
    NSString *presetName;
    NSString *categories;
	
}

@property (nonatomic, copy) 	NSString *taskName;
@property (nonatomic, copy) 	NSString *tag;

@property NSInteger typeMask;
@property NSInteger projectMask;

@property (nonatomic, copy) 	NSString *presetName;
@property (nonatomic, copy) 	NSString *categories;

+ (BOOL) isEqual:(FilterData *)src toAnother:(FilterData *)dest;
+ (FilterData *) fromDictionary: (NSDictionary *) dict;

- (void) updateByFilterData:(FilterData *)another;
-(void) reset;

-(NSDictionary *) toDictionary;

@end
