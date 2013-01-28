//
//  TDKeyParser.h
//  SmartCal
//
//  Created by MacBook Pro on 10/4/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDKeyParser : NSObject<NSXMLParserDelegate> {

	NSString *key;
	NSString *error;
	NSInteger errorCode;
	
	NSMutableString *currentElementValue;
}

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *error;
@property NSInteger errorCode;

- (void)parseXML:(NSData *)xmlData;

@end
