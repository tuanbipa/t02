//
//  LocationManager.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;

@interface LocationManager : NSObject
{
    
}

+(id)getInstance;
+(void)free;

- (NSMutableArray*)getAllLocation;
- (void)saveLocation: (Location*) location;
@end
