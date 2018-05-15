//
//  MoodFontIcon.m
//  Mood
//
//  Created by Tuan Pham on 2/28/16.
//  Copyright © 2016 Tuan Pham. All rights reserved.
//

#import "MoodFontIcon.h"
#import "FIFont.h"

@implementation MoodFontIcon

+ (FIFont *)font {
    return [FIFont fontWithResourcePath:@"moodfont.ttf"];
}

@end
