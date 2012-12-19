//
//  SDWSetting.m
//  SmartCal
//
//  Created by Left Coast Logic on 3/13/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "SDWSetting.h"

@implementation SDWSetting

@synthesize timezone;

- (void) dealloc
{
    self.timezone = nil;
    
    [super dealloc];
}

@end
