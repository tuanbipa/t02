//
//  TDAccountParser.h
//  SmartCal
//
//  Created by MacBook Pro on 10/6/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDAccount;

@interface TDAccountParser : NSObject<NSXMLParserDelegate> {
	TDAccount *account;
	NSMutableString *currentElementValue;
	
	NSString *error;
}

@property (nonatomic, retain) TDAccount *account;

@property (nonatomic, copy) NSString *error;

- (void)parseXML:(NSData *)xmlData;

@end
