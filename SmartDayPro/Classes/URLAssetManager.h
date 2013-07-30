//
//  URLAssetManager.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLAssetManager : NSObject

- (NSInteger) createURL:(NSString *)value;
- (void) updateURL:(NSInteger)pk value:(NSString *)value;
- (void) deleteURL:(NSInteger)pk cleanDB:(BOOL)cleanDB;
- (NSString *) getURLValue:(NSInteger)pk;
- (BOOL) checkCleanable:(NSInteger)pk;

+(id)getInstance;
+(void)free;

@end
