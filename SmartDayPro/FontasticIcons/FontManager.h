//
//  FontManager.h
//  Mood
//
//  Created by Tuan Pham on 2/28/16.
//  Copyright © 2016 Tuan Pham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FontasticIcons.h"

#define KSMARTDAY_FONTNAME @"smartday.ttf"

typedef enum {
    MoodFontIcon_None = 0x0000,
    MoodFontIcon_Cancel = 0x62,
    MoodFontIcon_Export = 0x64,
    MoodFontIcon_Next = 0x66,
    MoodFontIcon_Prev = 0x69,
    MoodFontIcon_CancelFull = 0x6c,
    MoodFontIcon_Check = 0xe038,
    MoodFontIcon_CheckFull = 0xe028,
    MoodFontIcon_Replace = 0xe036,
    MoodFontIcon_Trash = 0x77,
    MoodFontIcon_Down = 0x79,
    MoodFontIcon_Favorite = 0xe008,
    MoodFontIcon_Point = 0xe039,
    MoodFontIcon_Sticker = 0xe01d,
    MoodFontIcon_Facebook = 0xe007,
    MoodFontIcon_Calendar = 0xe000,
    MoodFontIcon_Flag = 0xe037,
    MoodFontIcon_Awesome = 0xe02e,
    MoodFontIcon_Ok = 0xe02b,
    MoodFontIcon_Happy = 0xe02d,
    MoodFontIcon_MEH = 0xe02c,
    MoodFontIcon_Sad = 0xe029,
    MoodFontIcon_Angry = 0xe02f,
    MoodFontIcon_Wind = 0xe023,
    MoodFontIcon_Clear  = 0xe01e,
    MoodFontIcon_Cloudy = 0xe001,
    MoodFontIcon_Flurries = 0xe024,
    MoodFontIcon_Hazy =  0xe00f,
    MoodFontIcon_MostlyCloudy = 0xe004,
    MoodFontIcon_MostlySunny = 0xe002,
    MoodFontIcon_PartlyCloudy = 0xe001,
    MoodFontIcon_PartlySunny = 0xe003,
    MoodFontIcon_Rain = 0xe017,
    MoodFontIcon_Sleet = 0xe018,
    MoodFontIcon_Snow = 0xe01a,
    MoodFontIcon_Sunny = 0xe01e,
    MoodFontIcon_Thunderstorm = 0xe00b,

} KMoodFontIcon;

typedef enum {
    FlowasticIcon_None = 0x0000,
    FlowasticIcon_Due = 0xe00f,
    FlowasticIcon_ArrowLeft = 0xe005,
    FlowasticIcon_ArrowRight = 0xe005
    
} KFlowasticIcon;


@interface FontManager : NSObject

+ (UIImage *)imageWithIconName:(NSString *)iconName andSize:(CGFloat )size;
+ (NSMutableAttributedString *)moodIconAttributeStringWithIconType:(KMoodFontIcon)iconType fontSize:(CGFloat)size;
+ (NSMutableAttributedString *)moodIconAttributeStringWithIconType:(KMoodFontIcon)iconType fontSize:(CGFloat)size color:(UIColor *)color;
+ (UIImage *)imageWithIconName:(NSString *)iconName andSize:(CGFloat )size iconColor:(UIColor *)iconColor;
+ (NSMutableDictionary *)flowasticIconAttributeStringWithFontSize:(CGFloat)size foregroundColor:(UIColor *)color withFontName:(NSString *)fontName;

#pragma mark - For FlowasticIcon
+ (NSMutableAttributedString *)flowasticIconAttributeStringWithIconType:(KFlowasticIcon)iconType fontSize:(CGFloat)size color:(UIColor *)color;
+ (UIImage *)flowasticImageWithIconName:(NSString *)iconName andSize:(CGFloat )size iconColor:(UIColor *)iconColor;
+ (NSMutableAttributedString *)attributeStringWithString:(NSString *)str fontSize:(CGFloat)size foregroundColor:(UIColor *)color;

@end
