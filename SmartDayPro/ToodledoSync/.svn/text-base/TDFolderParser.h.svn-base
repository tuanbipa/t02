//
//  TDFolderParser.h
//  SmartCal
//
//  Created by MacBook Pro on 9/30/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDFolder;

@interface TDFolderParser : NSObject<NSXMLParserDelegate> {

	NSMutableArray *folders;
	
	TDFolder *folder;
	NSMutableString *currentElementValue;
	
	NSString *error;
}

@property (nonatomic, retain) NSMutableArray *folders;
@property (nonatomic, retain) TDFolder *folder;

@property (nonatomic, copy) NSString *error;

- (void)parseXML:(NSData *)xmlData;

@end
