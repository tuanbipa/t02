//
//  FontManager.m
//  Mood
//
//  Created by Tuan Pham on 2/28/16.
//  Copyright © 2016 Tuan Pham. All rights reserved.
//

#import "FontManager.h"


@implementation FontManager


+ (UIImage *)imageWithIconName:(NSString *)iconName andSize:(CGFloat )size{
    return [self imageWithIconName:iconName andSize:size iconColor:[UIColor whiteColor]];
}

+ (UIImage *)imageWithIconName:(NSString *)iconName andSize:(CGFloat )size iconColor:(UIColor *)iconColor{
    FIIcon *icon = [MoodFontIcon iconWithName:iconName];
    UIImage *image = [icon imageWithBounds:CGRectMake(0, 0, size, size) color:iconColor];
    return image;
}

+ (NSMutableAttributedString *)moodIconAttributeStringWithIconType:(KMoodFontIcon)iconType fontSize:(CGFloat)size {
    return [self moodIconAttributeStringWithIconType:iconType fontSize:size color:[UIColor whiteColor]];
}

+ (NSMutableAttributedString *)moodIconAttributeStringWithIconType:(KMoodFontIcon)iconType fontSize:(CGFloat)size color:(UIColor *)color{
    NSMutableDictionary *attrDict = [self flowasticIconAttributeStringWithFontSize:size foregroundColor:color withFontName:@"moodfont"];
    NSString *title = [NSString stringWithFormat:@"%C", (unichar)iconType];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:title attributes:attrDict];
    
    return attrStr;
}

+ (NSMutableDictionary *)flowasticIconAttributeStringWithFontSize:(CGFloat)size foregroundColor:(UIColor *)color withFontName:(NSString *)fontName{
    UIFont *font = [UIFont fontWithName:fontName size:size];
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];
    [attrs setObject:font forKey:NSFontAttributeName];
    [attrs setObject:color forKey:NSForegroundColorAttributeName];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    
    [attrs setObject:style forKey:NSParagraphStyleAttributeName];
    
    return attrs;
}
@end
