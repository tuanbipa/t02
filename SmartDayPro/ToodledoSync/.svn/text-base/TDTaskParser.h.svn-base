//
//  TDTaskParser.h
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDTask;

@interface TDTaskParser : NSObject<NSXMLParserDelegate> {

	NSMutableArray *tasks;
	
	TDTask *task;
	NSMutableString *currentElementValue;
	
	NSString *error;
	NSInteger errorCode;
	
	BOOL forDeletion;
}

@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) TDTask *task;
@property (nonatomic, copy) NSString *error;
@property NSInteger errorCode;

@property BOOL forDeletion;

- (void)parseXML:(NSData *)xmlData;

@end
