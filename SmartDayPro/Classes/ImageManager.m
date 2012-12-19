//
//  ImageManager.m
//  SmartCal
//
//  Created by MacBook Pro on 6/9/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "ImageManager.h"

ImageManager *_imSingleton = nil;

@implementation ImageManager

@synthesize imageDict;

- (id) init
{
	if (self = [super init])
	{
		self.imageDict = [NSMutableDictionary dictionaryWithCapacity:50];
	}
	
	return self;
}

- (void)dealloc 
{
	//////printf("Image Manager dealloc\n");
	self.imageDict = nil; 
	
	[super dealloc];
}

- (UIImage *) getImageWithName:(NSString *)name
{
	UIImage *image = [imageDict objectForKey:name];
	
	if (image == nil)
	{
		NSString *imagePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], name];
		image = [UIImage imageWithContentsOfFile:imagePath];
		[self.imageDict setObject:image forKey:name];		
	}
	
	return image;
}

#pragma mark Public Methods

+(id)getInstance
{
	if (_imSingleton == nil)
	{
		_imSingleton = [[ImageManager alloc] init];
	}
	
	return _imSingleton;
}

+(void)free
{
	if (_imSingleton != nil)
	{
		[_imSingleton release];
		
		_imSingleton = nil;
	}
}

@end
