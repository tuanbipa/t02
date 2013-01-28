//
//  TagDictionary.m
//  SmartCal
//
//  Created by MacBook Pro on 5/4/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "TagDictionary.h"

#import "Common.h"

TagDictionary *_tagDictSingleton = nil;

@implementation TagDictionary

@synthesize dictChanged;
@synthesize tagDict;
@synthesize deletedTagDict;
@synthesize presetTagDict;

- (id) init
{
	if (self = [super init])
	{
		tagDict = nil;
		
		presetTagDict = nil;
        
        deletedTagDict = nil;
		
		searchDict = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
		
		dictChanged = NO;		
	}
	
	return self;
}

- (void) dealloc 
{
    /*
	if (tagDict != nil)
	{
		[tagDict release];
	}

	if (presetTagDict != nil)
	{
		[presetTagDict release];
	}
    
    if (deletedTagDict != nil)
    {
        [deletedTagDict release];
    }
    */
    
    self.tagDict = nil;
    self.presetTagDict = nil;
    self.deletedTagDict = nil;
	
	[searchDict release];
	
	[super dealloc];
}

- (void) loadDict
{
	self.tagDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"TagDict.dat"]];
	
	if (self.tagDict == nil)
	{
		self.tagDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
    else
    {
        for (NSString *tag in self.tagDict.allKeys)
        {
            [self createSearchForTag:tag];
        }
    }
    
	self.presetTagDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"PresetTagDict.dat"]];
	
	if (self.presetTagDict == nil)
	{
		self.presetTagDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
    
	self.deletedTagDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Common getFilePath:@"DeletedTagDict.dat"]];
	
	if (self.deletedTagDict == nil)
	{
		self.deletedTagDict = [NSMutableDictionary dictionaryWithCapacity:2];
	}
}

- (void) saveDict
{
    if (dictChanged)
    {
        [self.tagDict writeToFile:[Common getFilePath:@"TagDict.dat"] atomically:YES];
        [self.presetTagDict writeToFile:[Common getFilePath:@"PresetTagDict.dat"] atomically:YES];
        [self.deletedTagDict writeToFile:[Common getFilePath:@"DeletedTagDict.dat"] atomically:YES];
    }
    
    dictChanged = NO;
}

- (void) loadDict_old
{
	// Get path to documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
														 NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		// Path to save array data
		NSString  *arrayPath = [[paths objectAtIndex:0] 
								stringByAppendingPathComponent:@"tagList"];
		
		// Read both back in new collections
		NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
		
		tagDict = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
		
		for (NSString *str in arrayFromFile)
		{
			[tagDict setObject:str forKey:str];
			
			[self createSearchForTag:str];
		}
		
		// Path to save array data
		arrayPath = [[paths objectAtIndex:0]
								stringByAppendingPathComponent:@"presetTagList"];
		
		// Read both back in new collections
		arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
		
		presetTagDict = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
		
		for (NSString *str in arrayFromFile)
		{
			[presetTagDict setObject:str forKey:str];
		}
        
		arrayPath = [[paths objectAtIndex:0]
                     stringByAppendingPathComponent:@"deletedTagList"];
		
		// Read both back in new collections
		arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
		
		deletedTagDict = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
		
		for (NSString *str in arrayFromFile)
		{
			[deletedTagDict setObject:str forKey:str];
		}
	}	
}

- (void) saveDict_old
{
	// Get path to documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
														 NSUserDomainMask, YES);
	if ([paths count] > 0 && dictChanged)
	{
		// Path to save array data
		NSString  *arrayPath = [[paths objectAtIndex:0] 
								stringByAppendingPathComponent:@"tagList"];
		
		NSArray *array = [tagDict allKeys];
						  
		// Write array
		[array writeToFile:arrayPath atomically:YES];
		
		arrayPath = [[paths objectAtIndex:0]
								stringByAppendingPathComponent:@"presetTagList"];
		
		array = [presetTagDict allKeys];
		
		// Write array
		[array writeToFile:arrayPath atomically:YES];
		
		arrayPath = [[paths objectAtIndex:0]
                     stringByAppendingPathComponent:@"deletedTagList"];
		
		array = [deletedTagDict allKeys];
		
		// Write array
		[array writeToFile:arrayPath atomically:YES];
	}
    
    dictChanged = NO;
}

- (void) createSearchForTag:(NSString *)tag
{
	for (int i=0; i<tag.length; i++)
	{
		NSRange range;
		
		range.location = 0;
		range.length = i+1;
					  
		NSString *str = [tag substringWithRange:range];
		
		NSMutableArray *list = [searchDict objectForKey:str];
		
		if (list == nil)
		{
			list = [NSMutableArray arrayWithCapacity:5];
			
			[searchDict setObject:list forKey:str];
		}
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:list forKeys:list];
        
        if ([dict objectForKey:tag] == nil)
        {
            [list addObject:tag];
        }
	}
}

- (void) removeSearchForTag:(NSString *)tag
{
	for (int i=0; i<tag.length; i++)
	{
		NSRange range;
		
		range.location = 0;
		range.length = i+1;
		
		NSString *str = [tag substringWithRange:range];
		
		NSMutableArray *list = [searchDict objectForKey:str];
		
		if (list != nil)
		{
			NSString *foundTag = nil;
			
			for (NSString *s in list)
			{
				if ([s isEqualToString:tag])
				{
					foundTag = s;
					break;
				}
			}
			
			if (foundTag != nil)
			{
				[list removeObject:foundTag];
			}
		}
	}
}


- (void) addTag:(NSString *)tagStr
{
	NSString *tagId = [tagDict objectForKey:tagStr];
	
	if (tagId == nil)
	{
		//[tagDict setObject:tagStr forKey:tagStr];
        [self.tagDict setObject:@"" forKey:tagStr];
		
		[self createSearchForTag:tagStr];
		 
		dictChanged = YES;
	}
}

- (void) addTagFromList:(NSString *)tagList
{
	NSArray *parts = [tagList componentsSeparatedByString:@","];
	
	for (NSString *s in parts)
	{
		if (![s isEqualToString:@""])
		{
			[self addTag:s];
		}
	}	
}

- (void) makePreset:(NSString *)tagStr preset:(BOOL) preset
{
	if (preset)
	{
		if ([[presetTagDict allKeys] count] < 9)
		{
			//[presetTagDict setObject:tagStr forKey:tagStr];
            [presetTagDict setObject:@"" forKey:tagStr];
		}
	}
	else 
	{
		[presetTagDict removeObjectForKey:tagStr];
	}

	dictChanged = YES;
}

- (NSMutableArray *) findTags:(NSString *)str
{
	return [searchDict objectForKey:str];
}

- (void)createInitialTagDictIfNeeded {
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"TagDict.dat"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TagDict.dat"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}		
	}
	
	writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"PresetTagDict.dat"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PresetTagDict.dat"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}		
	}	
}

- (void) deleteTag:(NSString *)tag
{
    NSString *tagId = [tagDict objectForKey:tag];
    
    if (tagId != nil && ![tagId isEqualToString:@""])
    {
        [deletedTagDict setObject:tagId forKey:tag];
    }
    
	[tagDict removeObjectForKey:tag];
	[presetTagDict removeObjectForKey:tag];
    	
	[self removeSearchForTag:tag];
	
	dictChanged = YES;
}

/*
- (void) importTagList:(NSArray *)tagList
{
    [tagDict removeAllObjects];
    
    for (NSString *tag in tagList)
    {
        [self addTag:tag];
    }
    
    [self saveDict];
}
*/

- (void) importTag:(NSString *)tagStr sdwId:(NSString *)sdwId
{
    [self.tagDict setObject:sdwId forKey:tagStr];
    
    [self createSearchForTag:tagStr];
    
    dictChanged = YES;
}

- (void) importTagDict:(NSMutableDictionary *)tagDictParam
{
    [self.presetTagDict removeAllObjects];
    [self.deletedTagDict removeAllObjects];
    [searchDict removeAllObjects];
    
    self.tagDict = tagDictParam;
    
    for (NSString *tag in self.tagDict.allKeys)
    {
        [self createSearchForTag:tag];
    }

    [self saveDict];
}

- (void) cleanDeletedTagList
{
    [deletedTagDict removeAllObjects];
    
    [self.deletedTagDict writeToFile:[Common getFilePath:@"DeletedTagDict.dat"] atomically:YES];
}


#pragma mark Public Methods

+ (NSString *) addTagToList:(NSString *)tagList tag:(NSString *)tag
{
	[[TagDictionary getInstance] addTag:tag];

    NSString *allTag = tag;
    
    if (![tagList isEqualToString:@""])
    {
        allTag = [NSString stringWithFormat:@"%@%@", tagList, [allTag isEqualToString:@""]?@"":[NSString stringWithFormat:@",%@",allTag]];
    }    
	
    return allTag;
}

+ (NSDictionary *) getTagDict:(NSString *)tag
{
	NSArray *parts = [tag componentsSeparatedByString:@","];

	return [NSDictionary dictionaryWithObjects:parts forKeys:parts];
}

+ (NSString *) createTagByDict:(NSDictionary *)tagDict
{
	NSArray *tags = [tagDict allKeys];
	
	NSString *tag = @"";
	
	for (NSString *part in tags)
	{
		if ([tag isEqualToString:@""])
		{
			tag = part;
		}
		else 
		{
			tag = [tag stringByAppendingFormat:@",%@", part];
		}
	}

	return tag;
}

+ (NSString *) updateTag:(NSString *)tagParam removeList:(NSString *)removeList addList:(NSString *)addList
{
	NSMutableDictionary *tagDict = [NSMutableDictionary dictionaryWithDictionary:[TagDictionary getTagDict:tagParam]];
	
	NSArray *parts = [removeList componentsSeparatedByString:@","];
	
	for (NSString *part in parts)
	{
		NSString *tag = [tagDict objectForKey:part];
		
		if (tag != nil)
		{
			[tagDict removeObjectForKey:part];
		}
	}
	
	parts = [addList componentsSeparatedByString:@","];
	
	for (NSString *part in parts)
	{
		if (![part isEqualToString:@""])
		{
			[tagDict setObject:part forKey:part];
		}
	}
	
	return [TagDictionary createTagByDict:tagDict];
}

+(void)startup
{
	TagDictionary *tdict = [TagDictionary getInstance];
	
	[tdict createInitialTagDictIfNeeded];
	
	[tdict loadDict];
}

+(id) getInstance
{
	if (_tagDictSingleton == nil)
	{
		_tagDictSingleton = [[TagDictionary alloc] init];
	}
	
	return _tagDictSingleton;
}

+(void) free
{
	if (_tagDictSingleton != nil)
	{
		[_tagDictSingleton release];
		
		_tagDictSingleton = nil;
	}
}


@end
