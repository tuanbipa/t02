//
//  ContactManager.h
//  SmartPlan
//
//  Created by Huy Le on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContactManager : NSObject {
	NSArray *contactList;
	NSArray	*contactDisplayList;
	NSArray	*locationDisplayListByName;
	NSArray	*locationDisplayListByContact;	
	NSArray	*indexContactLetters;
}

@property (nonatomic, retain) 	NSArray *contactList; 
@property (nonatomic, retain) 	NSArray *contactDisplayList;
@property (nonatomic, retain) 	NSArray *locationDisplayListByName;
@property (nonatomic, retain) 	NSArray *locationDisplayListByContact; 
@property (nonatomic, retain) 	NSArray *indexContactLetters; 

+(id)getInstance;
+(void)free;

- (NSArray *) getContactList;
- (NSArray *) getContactDisplayList;
- (NSArray *)getLocationDisplayList:(BOOL)isSortByName;


@end
