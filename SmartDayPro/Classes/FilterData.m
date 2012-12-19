//
//  FilterData.m
//  SmartCal
//
//  Created by Trung Nguyen on 6/24/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "FilterData.h"


@implementation FilterData

@synthesize taskName;
@synthesize tag;
@synthesize typeMask;
@synthesize projectMask;
@synthesize presetName;
@synthesize categories;

- (id)init
{
	if (self = [super init])
	{
		[self reset];
	}
	
	return self;
}

- (id) copyWithZone:(NSZone*) zone{
	FilterData *copy = [[FilterData alloc] init];
	
	copy.taskName = taskName;
	copy.tag = tag;
	copy.typeMask = typeMask;
	copy.projectMask = projectMask;
    
    copy.presetName = presetName;
    copy.categories = categories;

	return copy;
}

- (void) updateByFilterData:(FilterData *)another
{
	self.taskName = another.taskName;
	self.tag = another.tag;
	self.typeMask = another.typeMask;
	self.projectMask = another.projectMask;
    
    self.presetName = another.presetName;
    self.categories = another.categories;
}

-(void) reset
{
	self.taskName = @"";
	self.tag = @"";
	self.typeMask = 0;
	self.projectMask = 0;
    
    self.presetName = @"";
    self.categories = @"";
}

-(NSDictionary *) toDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
                         self.presetName, @"Preset",
                         self.categories, @"Categories",
                         self.taskName, @"Title",
                         self.tag, @"Tag",
                         [NSNumber numberWithInt:self.typeMask], @"Type", nil];
}

- (void)dealloc 
{
	self.taskName = nil;
	self.tag = nil;
    
    self.presetName = nil;
    self.categories = nil;
	
    [super dealloc];	
}

+ (BOOL) isEqual:(FilterData *)src toAnother:(FilterData *)dest
{
	if (src != nil && dest != nil)
	{
		return [src.taskName isEqualToString:dest.taskName] &&
			[src.tag isEqualToString:dest.tag] &&
			src.typeMask == dest.typeMask &&
			src.projectMask == dest.projectMask &&
            [src.categories isEqualToString:dest.categories];
	}
	else if (src == nil && dest == nil)
	{
		return YES;
	}
	
	return NO;
}

+ (FilterData *) fromDictionary: (NSDictionary *) dict
{
    FilterData *ret = [[FilterData alloc] init];
    
    ret.presetName = [dict objectForKey:@"Preset"];
    ret.categories = [dict objectForKey:@"Categories"];
    ret.taskName = [dict objectForKey:@"Title"];
    ret.tag = [dict objectForKey:@"Tag"];
    ret.typeMask = [[dict objectForKey:@"Type"] intValue];
    
    return [ret autorelease];
}



@end
