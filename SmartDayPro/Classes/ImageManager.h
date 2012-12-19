//
//  ImageManager.h
//  SmartCal
//
//  Created by MacBook Pro on 6/9/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageManager : NSObject {

	NSMutableDictionary *imageDict;
}

@property (nonatomic, retain) NSMutableDictionary *imageDict;

+(id)getInstance;
+(void)free;

- (UIImage *) getImageWithName:(NSString *)name;

@end
