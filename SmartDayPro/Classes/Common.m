//
//  Common.m
//  SmartPlan
//
//  Created by Huy Le on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "Common.h"
#import "Settings.h"

#import "ImageManager.h"
#import "Reachability.h"

extern BOOL _is24HourFormat;

static CGFloat _shadowColor[3] = {94.0/255, 120.0/255, 112.0/255};

static CGFloat _highlightBlueColor[3] = {90.0/255, 111.0/255, 140.0/255};

static CGFloat _project0Colors[3][3] = { {8.0/255, 126.0/255, 174.0/255}, {13.0/255, 151.0/255, 207.0/255}, {15.0/255, 161.0/255, 220.0/255} };
static CGFloat _project1Colors[3][3] = { {190.0/255, 109.0/255, 0.0/255}, {239.0/255, 148.0/255, 27.0/255}, {255.0/255, 160.0/255, 36.0/255} };
static CGFloat _project2Colors[3][3] = { {141.0/255, 111.0/255, 71.0/255}, {176.0/255, 147.0/255, 110.0/255}, {190.0/255, 162.0/255, 126.0/255} };
static CGFloat _project3Colors[3][3] = { {97.0/255, 139.0/255, 11.0/255}, {144.0/255, 196.0/255, 0.0/255}, {174.0/255, 255.0/255, 0.0/255} };
static CGFloat _project4Colors[3][3] = { {174.0/255, 159.0/255, 113.0/255}, {186.0/255, 171.0/255, 126.0/255}, {187.0/255, 172.0/255, 128.0/255} };
static CGFloat _project5Colors[3][3] = { {122.0/255, 54.0/255, 122.0/255}, {171.0/255, 86.0/255, 171.0/255}, {185.0/255, 95.0/255, 185.0/255} };
static CGFloat _project6Colors[3][3] = { {112.0/255, 87.0/255, 112.0/255}, {127.0/255,  99.0/255, 127.0/255}, {164.0/255, 137.0/255, 164.0/255} };
//{ {112.0/255, 87.0/255, 112.0/255}, {106.0/255, 14.0/255, 88.0/255}, {164.0/255, 137.0/255, 164.0/255} };
static CGFloat _project7Colors[3][3] = { {134.0/255, 90.0/255, 90.0/255}, {167.0/255, 128.0/255, 128.0/255}, {182.0/255, 145.0/255, 145.0/255} };

static CGFloat _project8Colors[3][3] = { {41.0/255, 82.0/255, 163.0/255}, {76.0/255, 117.0/255, 198.0/255}, {92.0/255, 133.0/255, 214.0/255} };
static CGFloat _project9Colors[3][3] = { {177.0/255, 68.0/255, 14.0/255}, {229.0/255, 106.0/255, 46.0/255},  {239.0/255, 114.0/255, 52.0/255} };
static CGFloat _project10Colors[3][3] = { {147.0/255, 147.0/255, 37.0/255}, {168.0/255, 169.0/255, 41.0/255}, {168.0/255, 168.0/255, 107.0/255} };
static CGFloat _project11Colors[3][3] = { {13.0/255, 120.0/255, 19.0/255}, {21.0/255, 189.0/255, 30.0/255},  {23.0/255, 211.0/255, 33.0/255} };
static CGFloat _project12Colors[3][3] = { {136.0/255, 136.0/255, 14.0/255}, {203.0/255, 203.0/255, 20.0/255}, {227.0/255, 227.0/255, 22.0/255} };
static CGFloat _project13Colors[3][3] = { {82.0/255, 41.0/255, 163.0/255}, {109.0/255, 61.0/255, 206.0/255}, {133.0/255, 92.0/255, 214.0/255} };
static CGFloat _project14Colors[3][3] = { {128.0/255, 101.0/255, 180.0/255}, {151.0/255, 126.0/255, 200.0/255}, {173.0/255, 150.0/255, 219.0/255} };
static CGFloat _project15Colors[3][3] = { {106.0/255, 106.0/255, 106.0/255}, {136.0/255, 136.0/255, 136.0/255}, {162.0/255, 161.0/255, 161.0/255} };

static CGFloat _project16Colors[3][3] = { {6.0/255, 6.0/255, 181.0/255}, {24.0/255, 24.0/255, 211.0/255}, {52.0/255, 52.0/255, 245.0/255} };
static CGFloat _project17Colors[3][3] = { {163.0/255, 41.0/255, 41.0/255}, {202.0/255, 80.0/255, 80.0/255}, {214.0/255, 92.0/255, 92.0/255} };
static CGFloat _project18Colors[3][3] = { {88.0/255, 65.0/255, 21.0/255}, {123.0/255, 91.0/255, 28.0/255},  {152.0/255, 112.0/255, 33.0/255} };
static CGFloat _project19Colors[3][3] = { {42.0/255, 105.0/255, 73.0/255}, {15.0/255, 139.0/255, 109.0/255}, {3.0/255, 150.0/255, 124.0/255} };
static CGFloat _project20Colors[3][3] = { {171.0/255, 139.0/255, 0.0/255}, {210.0/255, 177.0/255, 101.0/255}, {255.0/255, 212.0/255, 20.0/255} };
static CGFloat _project21Colors[3][3] = { {74.0/255, 113.0/255, 108.0/255}, {97.0/255, 139.0/255, 134.0/255}, {112.0/255, 168.0/255, 162.0/255} };
//{ {8.0/255, 126.0/255, 174.0/255}, {13.0/255, 151.0/255, 207.0/255}, {15.0/255, 161.0/255, 220.0/255} };
static CGFloat _project22Colors[3][3] = { {177.0/255, 54.0/255, 95.0/255}, {203.0/255, 100.0/255, 134.0/255}, {213.0/255, 118.0/255, 150.0/255} };
static CGFloat _project23Colors[3][3] = { {64.0/255, 63.0/255, 63.0/255}, {91.0/255, 91.0/255, 91.0/255}, {115.0/255, 115.0/255, 115.0/255} };

static CGFloat _project24Colors[3][3] = { {0.0/255, 52.0/255, 105.0/255}, {0.0/255, 65.0/255, 129.0/255}, {4.0/255, 83.0/255, 162.0/255} };
static CGFloat _project25Colors[3][3] = { {81.0/255, 28.0/255, 22.0/255}, {103.0/255, 41.0/255, 35.0/255}, {118.0/255, 51.0/255, 44.0/255} };
static CGFloat _project26Colors[3][3] = { {62.0/255, 39.0/255, 17.0/255}, {114.0/255, 80.0/255, 46.0/255}, {145.0/255, 104.0/255, 63.0/255} };
static CGFloat _project27Colors[3][3] = { {32.0/255, 101.0/255, 36.0/255}, {47.0/255, 143.0/255, 51.0/255}, {56.0/255, 175.0/255, 63.0/255} };
static CGFloat _project28Colors[3][3] = { {141.0/255, 120.0/255, 31.0/255}, {168.0/255, 144.0/255, 62.0/255}, {186.0/255, 161.0/255, 51.0/255} };
static CGFloat _project29Colors[3][3] = { {27.0/255, 136.0/255, 122.0/255}, {45.0/255, 196.0/255, 176.0/255}, {51.0/255, 215.0/255, 193.0/255} };
static CGFloat _project30Colors[3][3] = { {88.0/255, 57.0/255, 72.0/255}, {100.0/255, 69.0/255, 84.0/255}, {110.0/255, 79.0/255, 94.0/255} };
static CGFloat _project31Colors[3][3] = { {2.0/255, 2.0/255, 2.0/255}, {47.0/255, 47.0/255, 47.0/255},{76.0/255, 76.0/255, 76.0/255} };


void addRoundedRectToPath(CGContextRef context, CGRect rect,
							  float ovalWidth,float ovalHeight)

{
    float fw, fh;
	
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
	
    CGContextSaveGState(context);// 2
    CGContextBeginPath(context);
	
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
						   CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
	
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1.2);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1.2);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1.2);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1.2); // 11
    CGContextClosePath(context);// 12
	
    CGContextRestoreGState(context);// 13
}

void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
						  float ovalHeight)
{
	//    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
    CGContextStrokePath(context);
}

void gradientRoundedRect(CGContextRef context, CGRect rect, float ovalWidth,
							float ovalHeight, CGFloat components[], CGFloat locations[], size_t num_locations)
{
    CGContextSaveGState(context);// 2
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
	
	CGContextClip(context);
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.origin.x;
	myStartPoint.y = rect.origin.y;
	myEndPoint.x = rect.origin.x;
	myEndPoint.y = rect.origin.y + rect.size.height;
	
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);	
	
    CGContextRestoreGState(context);// 13
	CGGradientRelease(myGradient);
}

void gradientRect(CGContextRef context, CGRect rect, CGFloat components[], CGFloat locations[], size_t num_locations)
{
    CGContextSaveGState(context);// 2
    //addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
	
	CGContextAddRect(context, rect);
	
	CGContextClip(context);	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	//myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	myColorspace = CGColorSpaceCreateWithName(CFSTR("kCGColorSpaceGenericRGB"));
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = rect.origin.x;
	myStartPoint.y = rect.origin.y;
	myEndPoint.x = rect.origin.x;
	myEndPoint.y = rect.origin.y + rect.size.height;
	
	CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);	
	
    CGContextRestoreGState(context);// 13
	CGGradientRelease(myGradient);
	
}

void fillRoundedRect (CGContextRef context, CGRect rect,
					  float ovalWidth, float ovalHeight)

{
    addRoundedRectToPath(context, rect, ovalWidth, ovalHeight);
    CGContextFillPath(context);
}

@implementation Common

+ (UIButton *)createButton:(NSString *)title 
				buttonType:(UIButtonType)buttonType
					 frame:(CGRect)frame
				titleColor:(UIColor *)titleColor
					target:(id)target
				  selector:(SEL)selector
		  normalStateImage:(NSString *)normalStateImage
		selectedStateImage:(NSString*)selectedStateImage
{
	UIButton *button = [UIButton buttonWithType:buttonType];
	button.frame = frame;
	[button setTitle:title forState:UIControlStateNormal];
	button.titleLabel.font=[UIFont boldSystemFontOfSize:14];
	if(titleColor!=nil){
		[button setTitleColor:titleColor  forState:UIControlStateNormal];
	}else {
		[button setTitleColor:[UIColor brownColor]  forState:UIControlStateNormal];		
	}
	
	button.backgroundColor = [UIColor clearColor];
	if(normalStateImage !=nil && ![normalStateImage isEqual:@""]){
		//[button setBackgroundImage:[UIImage imageNamed:normalStateImage] forState:UIControlStateNormal];
		[button setBackgroundImage:[[ImageManager getInstance] getImageWithName:normalStateImage] forState:UIControlStateNormal];
	}
	
	if(selectedStateImage !=nil && ![selectedStateImage isEqual:@""]){
		//[button setBackgroundImage:[UIImage imageNamed:selectedStateImage] forState:UIControlStateSelected];
		[button setBackgroundImage:[[ImageManager getInstance] getImageWithName:selectedStateImage] forState:UIControlStateSelected];
	}
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+ (NSString *)getDurationString:(NSInteger)value
{
	NSString *ret=nil;
	NSInteger hours=value/3600;
	NSInteger mins=(value-hours*3600)/60;
    
    if (hours == 0)
    {
		//ret = [NSString stringWithFormat:@"%d %@",mins,mins==1?@"min":@"mins"];
        ret = [NSString stringWithFormat:@"%d %@",mins,mins==1?_minText:_minsText];
	}
    else if (mins == 0)
    {
        //ret = [NSString stringWithFormat:@"%d %@",hours,hours==1?@"hour":@"hours"];
        ret = [NSString stringWithFormat:@"%d %@",hours,hours==1?_hourText:_hoursText];
    }
    else
    {
        //ret= [NSString stringWithFormat:@"%d %@, %d %@",hours,hours==1?@"hour":@"hours",mins,mins==1?@"min":@"mins"];
        ret= [NSString stringWithFormat:@"%d %@, %d %@",hours,hours==1?_hourText:_hoursText,mins,mins==1?_minText:_minsText];
    }

    
	return ret;
}

+ (NSString *)getTimerDurationString:(NSInteger)value
{
	
	NSInteger days = value/(3600*24);
	NSInteger hours = (value - days*3600*24)/3600;
	NSInteger mins = (value - days*3600*24 - hours*3600)/60;
	NSInteger secs = (value - days*3600*24 - hours*3600 - mins*60);
	
	return [NSString stringWithFormat:@"%dd %d:%d:%d", days, hours, mins, secs];
}

+ (UIColor *) getColorByID: (int) colorID colorIndex:(int) colorIndex
{
	CGFloat r = 0, g = 0, b = 0;

	switch (colorID)
	{
		case 0:
		{
			r = _project0Colors[colorIndex][0];
			g = _project0Colors[colorIndex][1];
			b = _project0Colors[colorIndex][2];
		}
			break;
		case 1:
		{
			r = _project1Colors[colorIndex][0];
			g = _project1Colors[colorIndex][1];
			b = _project1Colors[colorIndex][2];			
		}			
			break;
		case 2:
		{
			r = _project2Colors[colorIndex][0];
			g = _project2Colors[colorIndex][1];
			b = _project2Colors[colorIndex][2];			
		}			
			break;
		case 3:
		{
			r = _project3Colors[colorIndex][0];
			g = _project3Colors[colorIndex][1];
			b = _project3Colors[colorIndex][2];			
		}			
			break;
		case 4:
		{
			r = _project4Colors[colorIndex][0];
			g = _project4Colors[colorIndex][1];
			b = _project4Colors[colorIndex][2];			
		}			
			break;
		case 5:
		{
			r = _project5Colors[colorIndex][0];
			g = _project5Colors[colorIndex][1];
			b = _project5Colors[colorIndex][2];			
		}			
			break;
		case 6:
		{
			r = _project6Colors[colorIndex][0];
			g = _project6Colors[colorIndex][1];
			b = _project6Colors[colorIndex][2];			
		}			
			break;
		case 7:
		{
			r = _project7Colors[colorIndex][0];
			g = _project7Colors[colorIndex][1];
			b = _project7Colors[colorIndex][2];			
		}			
			break;
		case 8:
		{
			r = _project8Colors[colorIndex][0];
			g = _project8Colors[colorIndex][1];
			b = _project8Colors[colorIndex][2];			
		}			
			break;
		case 9:
		{
			r = _project9Colors[colorIndex][0];
			g = _project9Colors[colorIndex][1];
			b = _project9Colors[colorIndex][2];			
		}			
			break;
		case 10:
		{
			r = _project10Colors[colorIndex][0];
			g = _project10Colors[colorIndex][1];
			b = _project10Colors[colorIndex][2];			
		}			
			break;
		case 11:
		{
			r = _project11Colors[colorIndex][0];
			g = _project11Colors[colorIndex][1];
			b = _project11Colors[colorIndex][2];			
		}			
			break;
		case 12:
		{
			r = _project12Colors[colorIndex][0];
			g = _project12Colors[colorIndex][1];
			b = _project12Colors[colorIndex][2];			
		}			
			break;
		case 13:
		{
			r = _project13Colors[colorIndex][0];
			g = _project13Colors[colorIndex][1];
			b = _project13Colors[colorIndex][2];			
		}			
			break;
		case 14:
		{
			r = _project14Colors[colorIndex][0];
			g = _project14Colors[colorIndex][1];
			b = _project14Colors[colorIndex][2];			
		}			
			break;
		case 15:
		{
			r = _project15Colors[colorIndex][0];
			g = _project15Colors[colorIndex][1];
			b = _project15Colors[colorIndex][2];			
		}			
			break;
		case 16:
		{
			r = _project16Colors[colorIndex][0];
			g = _project16Colors[colorIndex][1];
			b = _project16Colors[colorIndex][2];			
		}			
			break;
		case 17:
		{
			r = _project17Colors[colorIndex][0];
			g = _project17Colors[colorIndex][1];
			b = _project17Colors[colorIndex][2];			
		}			
			break;
		case 18:
		{
			r = _project18Colors[colorIndex][0];
			g = _project18Colors[colorIndex][1];
			b = _project18Colors[colorIndex][2];			
		}			
			break;
		case 19:
		{
			r = _project19Colors[colorIndex][0];
			g = _project19Colors[colorIndex][1];
			b = _project19Colors[colorIndex][2];			
		}			
			break;
		case 20:
		{
			r = _project20Colors[colorIndex][0];
			g = _project20Colors[colorIndex][1];
			b = _project20Colors[colorIndex][2];			
		}			
			break;
		case 21:
		{
			r = _project21Colors[colorIndex][0];
			g = _project21Colors[colorIndex][1];
			b = _project21Colors[colorIndex][2];			
		}			
			break;
		case 22:
		{
			r = _project22Colors[colorIndex][0];
			g = _project22Colors[colorIndex][1];
			b = _project22Colors[colorIndex][2];			
		}			
			break;
		case 23:
		{
			r = _project23Colors[colorIndex][0];
			g = _project23Colors[colorIndex][1];
			b = _project23Colors[colorIndex][2];			
		}			
			break;
		case 24:
		{
			r = _project24Colors[colorIndex][0];
			g = _project24Colors[colorIndex][1];
			b = _project24Colors[colorIndex][2];			
		}			
			break;
		case 25:
		{
			r = _project25Colors[colorIndex][0];
			g = _project25Colors[colorIndex][1];
			b = _project25Colors[colorIndex][2];			
		}			
			break;
		case 26:
		{
			r = _project26Colors[colorIndex][0];
			g = _project26Colors[colorIndex][1];
			b = _project26Colors[colorIndex][2];			
		}			
			break;
		case 27:
		{
			r = _project27Colors[colorIndex][0];
			g = _project27Colors[colorIndex][1];
			b = _project27Colors[colorIndex][2];			
		}			
			break;
		case 28:
		{
			r = _project28Colors[colorIndex][0];
			g = _project28Colors[colorIndex][1];
			b = _project28Colors[colorIndex][2];			
		}			
			break;
		case 29:
		{
			r = _project29Colors[colorIndex][0];
			g = _project29Colors[colorIndex][1];
			b = _project29Colors[colorIndex][2];			
		}			
			break;
		case 30:
		{
			r = _project30Colors[colorIndex][0];
			g = _project30Colors[colorIndex][1];
			b = _project30Colors[colorIndex][2];			
		}			
			break;
		case 31:
		{
			r = _project31Colors[colorIndex][0];
			g = _project31Colors[colorIndex][1];
			b = _project31Colors[colorIndex][2];			
		}			
			break;
	}
	
	return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *) getGoalColor: (int) goal colorIndex:(int) colorIndex
{
	CGFloat r = 0, g = 0, b = 0;
	
	switch (goal)
	{
		case 0:
		{
			r = _project6Colors[colorIndex][0];
			g = _project6Colors[colorIndex][1];
			b = _project6Colors[colorIndex][2];			
		}
			break;
		case 1:
		{
			r = _project11Colors[colorIndex][0];
			g = _project11Colors[colorIndex][1];
			b = _project11Colors[colorIndex][2];			
		}			
			break;
		case 2:
		{
			r = _project12Colors[colorIndex][0];
			g = _project12Colors[colorIndex][1];
			b = _project12Colors[colorIndex][2];			
		}			
			break;
		case 3:
		{
			r = _project13Colors[colorIndex][0];
			g = _project13Colors[colorIndex][1];
			b = _project13Colors[colorIndex][2];			
		}			
			break;
		case 4:
		{
			r = _project14Colors[colorIndex][0];
			g = _project14Colors[colorIndex][1];
			b = _project14Colors[colorIndex][2];			
		}			
			break;
		case 5:
		{
			r = _project15Colors[colorIndex][0];
			g = _project15Colors[colorIndex][1];
			b = _project15Colors[colorIndex][2];			
		}			
			break;
	}
	
	return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIColor *) getShadowColor
{
	return [UIColor colorWithRed:_shadowColor[0] green:_shadowColor[1] blue:_shadowColor[2] alpha:0.6];
}

+ (UIColor *) getHighlightColor
{
	return [UIColor colorWithRed:_highlightBlueColor[0] green:_highlightBlueColor[1] blue:_highlightBlueColor[2] alpha:1];
}

+ (NSComparisonResult)compareDate:(NSDate*) date1 withDate:(NSDate*) date2
{
    if (date1 == nil && date2 == nil)
    {
        return NSOrderedSame;
    }
    
    NSTimeInterval ti1 = (date1 == nil? -1:[date1 timeIntervalSince1970]);
    
    NSTimeInterval ti2 = (date2 == nil? -1:[date2 timeIntervalSince1970]);
    
    if (ti2 > ti1)
    {
        return NSOrderedAscending;
    }
    else if (ti2 < ti1)
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

+ (NSComparisonResult)compareDateNoTime:(NSDate*) date1 withDate:(NSDate*) date2
{
    if (date1 == nil && date2 == nil)
    {
        return NSOrderedSame;
    }
    
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	unsigned flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
	
	NSDateComponents *comps1 = [gregorian components:flags fromDate:date1];
	NSDateComponents *comps2 = [gregorian components:flags fromDate:date2];
    
    NSComparisonResult ret = NSOrderedSame;
	
	if ([comps2 year] > [comps1 year])
	{
		ret = NSOrderedAscending;
	}
	else if ([comps2 year] < [comps1 year])
	{
		ret = NSOrderedDescending;
	}
	else if ([comps2 month] > [comps1 month])
	{
		ret = NSOrderedAscending;		
	}
	else if ([comps2 month] < [comps1 month])
	{
		ret = NSOrderedDescending;		
	}
	else if ([comps2 day] > [comps1 day])
	{
		ret = NSOrderedAscending;		
	}
	else if ([comps2 day] < [comps1 day])
	{
		ret = NSOrderedDescending;
	}
    
    return ret; 
}

+ (NSDate *) dateByWeekday:(NSInteger)wkday
{
    NSDate *dt = [NSDate date];
    
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:dt];
    
    [comps setWeekday:wkday];
    
	return [gregorian dateFromComponents:comps];
}

+ (NSDate *) dateByAddNumYear:(NSInteger)argYear toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:argYear];
	[offset setMonth:0];
	[offset setDay:0];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:0];	
	NSDate *newDate = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];
	return newDate;
}

+ (NSDate *) dateByAddNumMonth:(NSInteger)argMonth toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:0];
	[offset setMonth:argMonth];
	[offset setDay:0];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:0];	
	NSDate *newDate = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];
	return newDate;
}

+ (NSDate *) dateByAddNumDay:(NSInteger)argDay toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:0];
	[offset setMonth:0];
	[offset setDay:argDay];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:0];	
	NSDate *newDate = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];
	return newDate;
}

+ (NSDate *) dateByAddNumSecond:(NSInteger)argSecond toDate:(NSDate *)argDate
{
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	[offset setYear:0];
	[offset setMonth:0];
	[offset setDay:0];
	[offset setHour:0];
	[offset setMinute:0];
	[offset setSecond:argSecond];	
	
	NSDate *newDate = [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:offset toDate:argDate options:0];
	[offset release];

	return newDate;
}

+ (NSDate *) dateByRoundMinute:(NSInteger)increment toDate:(NSDate *)argDate
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *comps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:argDate];

	NSInteger minute = comps.minute + (increment - 1);
	
	if (minute > 60)
	{
		comps.hour += 1;
		comps.minute = 0;
	}
	else 
	{
		comps.minute = (minute / increment) * increment;
	}
	
	comps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:comps];

	return ret;
}

+ (NSDate *)copyTimeFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *frcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:fromDate];
	NSDateComponents *tocomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:toDate];
	
	tocomps.hour = frcomps.hour;
	tocomps.minute = frcomps.minute;
	tocomps.second = frcomps.second;

	NSDate *ret = [gregorian dateFromComponents:tocomps];
	
	return ret;	
}

+ (NSDate *)clearTimeForDate:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];

	dtcomps.hour = 0;
	dtcomps.minute = 0;
	dtcomps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:dtcomps];
	
	return ret;	
}

+ (NSDate *)getEndDate:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	dtcomps.hour = 23;
	dtcomps.minute = 59;
	//dtcomps.second = 60;
    dtcomps.second = 59;
	
	//return [gregorian dateFromComponents:dtcomps];
	NSDate *ret = [gregorian dateFromComponents:dtcomps];
	
	return ret;		
}

+ (NSDate *)dateNoDST:(NSDate *)date
{
	return [Common dateByAddNumSecond:[[NSTimeZone defaultTimeZone] daylightSavingTimeOffsetForDate:date] toDate:date];
}

+ (NSInteger) getSecondsFromTimeZoneID:(NSInteger)tzID
{
    if (tzID == 0)
    {
        return [[NSTimeZone defaultTimeZone] secondsFromGMT];
    }
    
    NSInteger ret = abs(tzID)%128;
    
    NSInteger min = ret%8;
    
    NSInteger hour = (ret-min)/8;
    
    ret = hour*3600 + (min==7?7*60:min*15*60);
    
    return tzID>0?ret:-ret;
}

+ (NSInteger) createTimeZoneIDByOffset:(NSInteger) offset
{
    NSInteger hour = abs(offset)/3600;
    
    NSInteger minute = ((abs(offset)-hour*3600))/60;
    
    NSInteger mod = minute;
    
    switch (minute)
    {
        case 15:
            mod = 1;
            break;
        case 30:
            mod = 2;
            break;
        case 45:
            mod = 3;
            break;
    }
    
    NSInteger tzId = hour*8 + mod;
    
    return offset<0?-tzId:tzId;
}

+ (NSDate *)toDBDate:(NSDate *)localDate
{
	NSInteger dstOffset = [[NSTimeZone defaultTimeZone] daylightSavingTimeOffset] - [[NSTimeZone defaultTimeZone] daylightSavingTimeOffsetForDate:localDate];
	
	NSInteger gmtSeconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
    //NSInteger gmtSeconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
	
	NSDate *dbDate = [localDate dateByAddingTimeInterval:gmtSeconds-dstOffset];
	
	////////printf("To DB: local - %s, dst:%d, gmt - %s\n", [[localDate description] UTF8String], dstOffset, [[dbDate description] UTF8String]);
 	
	return dbDate;
}

+ (NSDate *)fromDBDate:(NSDate *)dbDate
{
	//NSInteger gmtSeconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSInteger gmtSeconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
	
	NSDate *localDate = [dbDate dateByAddingTimeInterval:-gmtSeconds];
	
	NSInteger dstOffset = [[NSTimeZone defaultTimeZone] daylightSavingTimeOffset] - [[NSTimeZone defaultTimeZone] daylightSavingTimeOffsetForDate:localDate];
	
	//NSTimeInterval timeZoneOffset = dstOffset;
	
	//localDate = [localDate dateByAddingTimeInterval:timeZoneOffset];
	
	////////printf("From DB: gmt - %s, dst:%d, local - %s, local dst:%f\n", [[dbDate description] UTF8String], dstOffset, [[localDate description] UTF8String], [[NSTimeZone defaultTimeZone] daylightSavingTimeOffsetForDate:localDate]);
	
	return [localDate dateByAddingTimeInterval:dstOffset];
}

+ (NSInteger)daysBetween:(NSDate *)dt1 sinceDate:(NSDate *)dt2 
{
    if (dt1 == nil)
    {
        dt1 = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (dt2 == nil)
    {
        dt2 = [NSDate dateWithTimeIntervalSince1970:0];
    }
/*
    //dt2: since Date
    NSDate *minDate = [dt1 compare:dt2]==NSOrderedAscending?dt1:dt2;
    
    NSDate *endDate = (minDate == dt1?[Common clearTimeForDate:dt1]:[Common getEndDate:dt1]);
    NSDate *startDate = (minDate == dt1?[Common getEndDate:dt2]:[Common clearTimeForDate:dt2]);
    
    return ([endDate timeIntervalSinceDate:startDate]+1)/24/60/60;
*/
    
    /*NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
    NSUInteger dayOfYear1 = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:dt1];
    NSUInteger dayOfYear2 = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:dt2];
    
    return dayOfYear1 - dayOfYear2;*/
    
    // clear time first
    dt1 = [self clearTimeForDate:dt1];
    dt2 = [self clearTimeForDate:dt2];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:dt2
                                                          toDate:dt1
                                                         options:0];
    return components.day;
}

+ (NSInteger)timeIntervalNoDST:(NSDate *)date sinceDate:(NSDate *)sinceDate
{
    if (date == nil || sinceDate == nil)
    {
        return 0;
    }
    
	return [[Common dateNoDST:date] timeIntervalSinceDate:[Common dateNoDST:sinceDate]];
}

+ (NSDate *)getFirstWeekDate:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];

	NSInteger weekday = [dtcomps weekday];
	
	dtcomps.hour = 0;
	dtcomps.minute = 0;
	dtcomps.second = 0;
	
	date = [gregorian dateFromComponents:dtcomps];
	
	if (mondayAsWeekStart && weekday == 1) //Sunday
	{
		weekday += 7; 
	}	
	
	return [Common dateByAddNumDay:-weekday+(mondayAsWeekStart?2:1) toDate:date];
}

+ (NSDate *)getLastWeekDate:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	
	NSInteger weekday = [dtcomps weekday];
	
	dtcomps.hour = 23;
	dtcomps.minute = 59;
	dtcomps.second = 60;
	
	date = [gregorian dateFromComponents:dtcomps];
	
	if (mondayAsWeekStart && weekday == 1) //Sunday
	{
		weekday += 7; 
	}		
	
	return [Common dateByAddNumDay:-weekday+(mondayAsWeekStart?8:7) toDate:date];
}

+ (NSDate *)getEndWeekDate:(NSDate *)startTime withWeeks:(NSInteger)weeks mondayAsWeekStart:(BOOL)mondayAsWeekStart
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];

	NSDate *endTime = [Common dateByAddNumDay:(weeks > 0?7*weeks-1:0) toDate:startTime];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:endTime];
	
	NSInteger weekday = [dtcomps weekday];
	
	dtcomps.hour = 23;
	dtcomps.minute = 59;
	dtcomps.second = 59;
		
	//startTime = [Common dateByAddNumDay:-(weekday -1)+6 toDate:[gregorian dateFromComponents:dtcomps]];
	startTime = [Common dateByAddNumDay:-weekday+(mondayAsWeekStart?8:7) toDate:[gregorian dateFromComponents:dtcomps]];
	
	////////printf("getEndWeekDate:%s - return: %s\n", [[endTime description] UTF8String], [[startTime description] UTF8String]);
	
	return startTime;
}

+ (NSDate *)getFirstMonthDate:(NSDate *)startTime
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:startTime];
	dtcomps.day = 1;
	dtcomps.hour = 0;
	dtcomps.minute = 0;
	dtcomps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:dtcomps];
	
	return ret;			
}

+ (NSDate *)getFirstYearDate:(NSDate *)startTime
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:startTime];
	dtcomps.day = 1;
    dtcomps.month = 1;
	dtcomps.hour = 0;
	dtcomps.minute = 0;
	dtcomps.second = 0;
	
	NSDate *ret = [gregorian dateFromComponents:dtcomps];
	
	return ret;
}

+ (NSDate *)getEndMonthDate:(NSDate *)startTime withMonths:(NSInteger) months
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDate *endTime = [Common dateByAddNumMonth:months toDate:startTime];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:endTime];
	dtcomps.day = 1;
	dtcomps.hour = 0;
	dtcomps.minute = 0;
	dtcomps.second = 0;
	
	NSDate *dt = [gregorian dateFromComponents:dtcomps];
	
	return [Common dateByAddNumSecond:-1 toDate:dt];	
}

+ (NSInteger)getMonth:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	return dtcomps.month;
}

+ (NSInteger)getDay:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	return dtcomps.day;
}

+ (NSInteger)getHour:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
	
	return dtcomps.hour;
}

+ (NSInteger)getMinute:(NSDate *)date
{
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	
	NSDateComponents *dtcomps = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];

	return dtcomps.minute;
}

+ (NSInteger)getWeekday:(NSDate *)date
{
	if (date==nil) return 0;
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];

	NSInteger wd = [dayComponents weekday];
	return wd;
}

+ (NSInteger)getWeekday:(NSDate *)date timeZoneID:(NSInteger)timeZoneID
{
	if (date==nil) return 0;
    
    NSInteger secs = [Common getSecondsFromTimeZoneID:timeZoneID] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
    
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:[date dateByAddingTimeInterval:secs]];
    
	NSInteger wd = [dayComponents weekday];
	return wd;
}


+ (NSInteger)getWeekdayOrdinal:(NSDate *)date
{
   	if (date==nil) return 0;
	NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents *dayComponents =[gregorian components:NSWeekdayOrdinalCalendarUnit fromDate:date];
	NSInteger wdo = [dayComponents weekdayOrdinal];

	return wdo;
}

+ (NSInteger) getWeeksInMonth:(NSDate *)date
{
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate *lastMonthDate = [Common getEndMonthDate:date withMonths:1];
    
	NSDateComponents *comps = [gregorian components:NSWeekOfMonthCalendarUnit fromDate:lastMonthDate];
    
    return comps.weekOfMonth;
}

+ (NSInteger) getWeeksInMonth:(NSDate *)date mondayAsWeekStart:(BOOL)mondayAsWeekStart
{
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
    NSDate *lastMonthDate = [Common getEndMonthDate:date withMonths:1];
    
	NSDateComponents *comps = [gregorian components:NSWeekOfMonthCalendarUnit fromDate:lastMonthDate];
    
    NSInteger weeks = comps.weekOfMonth;
    if (mondayAsWeekStart) {
        NSDateComponents *compsLastMon = [gregorian components:NSWeekdayCalendarUnit fromDate:lastMonthDate];
        NSDate *firstMonthDate = [Common getFirstMonthDate:lastMonthDate];
        NSDateComponents *compsFirstMon = [gregorian components:NSWeekdayCalendarUnit fromDate:firstMonthDate];
        if ([compsLastMon weekday] == 1 && [compsFirstMon weekday] != 1) {
            // the end month is Sunday
            weeks--;
        } else if ([compsLastMon weekday] != 1 && [compsFirstMon weekday] == 1) {
            weeks++;
        }
    }
    
    //return comps.weekOfMonth;
    return weeks;
}

+ (NSInteger) getWeekOfYear:(NSDate *)date
{
    if (date == nil)
    {
        return 0;
    }
    
    NSCalendar *gregorian = [NSCalendar autoupdatingCurrentCalendar];
    
	NSDateComponents *comps = [gregorian components:NSWeekOfYearCalendarUnit fromDate:date];
    
    return comps.weekOfYear;
}

+ (BOOL)isWeekend:(NSDate *)date
{
	NSInteger wd = [Common getWeekday:date];
	
	return (wd == 1) || (wd == 7);
}

+ (NSDate *) getDateByFullString:(NSString *)strDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	
	//return [dateFormatter dateFromString:strDate];
	NSDate *ret = [dateFormatter dateFromString:strDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSDate *) getDateByFullString2:(NSString *)strDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
	
	//return [dateFormatter dateFromString:strDate];
	NSDate *ret = [dateFormatter dateFromString:strDate];
	
	[dateFormatter release];
	
	return ret;	
}

+ (NSDate *) getDateByString:(NSString *)strDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	//return [dateFormatter dateFromString:strDate];
	NSDate *ret = [dateFormatter dateFromString:strDate];
	
	[dateFormatter release];
	
	return ret;	
}

+ (NSString *) getShortDateString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MM/dd"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getFullDateString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setDateFormat:@"yyyy/MM/dd"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getFullDateString2:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	
//	return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getFullDateString3:(NSDate *)argDate
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
	
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSString *) getFullDateString4:(NSDate *)argDate
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE, MMM yyyy"];
	
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSString *) getFullDateTimeString:(NSDate *)argDate
{
    /*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
	
	[dateFormatter setDateFormat:@"EEE, MMM dd, yyyy hh:mm a"];

	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
    */
    
    NSString *dateStr = [self getFullDateString3:argDate];
    NSString *timeStr = [self getTimeString:argDate];
    
    return [NSString stringWithFormat:@"%@ %@", dateStr, timeStr];
}

+ (NSString *) getFullDateTimeString2:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
	
}

+ (NSString *) getCalendarDateString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE MMM dd, yyyy"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
	
}

+ (NSString *) getFullTimeString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"hh:mm:ss"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
	
}

+(NSString *)time12FromTime24:(NSString *)time24String
{
	NSDateFormatter *testFormatter = [[NSDateFormatter alloc] init];
	int hour = [[time24String substringToIndex:2] intValue];
	int minute = [[time24String substringFromIndex:3] intValue];
    
	NSString *result = [NSString stringWithFormat:@"%02d:%02d %@", hour > 12?(hour % 12):hour, minute, hour >= 12 ? [testFormatter PMSymbol] : [testFormatter AMSymbol]];
	[testFormatter release];
	return result;
}

+ (NSString *) get24TimeString:(NSDate *)argDate
{
    /*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

	[dateFormatter setDateFormat:@"HH:mm"];
	
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
    */
    
	NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString* time = [dateFormatter stringFromDate:argDate];
	[dateFormatter release];
    
	if (time.length > 5) {
		NSRange range;
		range.location = 3;
		range.length = 2;
		int hour = [[time substringToIndex:2] intValue];
		NSString *minute = [time substringWithRange:range];
		range = [time rangeOfString:@"AM"];
		if (range.length==0)
			hour += 12;
		time = [NSString stringWithFormat:@"%02d:%@", hour, minute];
	}
    
	return time;    
}

+ (NSString *) getTimeString:(NSDate *)argDate
{
    /*
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"hh:mm a"];
	
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
    */
    
    NSString *ret = [self get24TimeString:argDate];
    
    if (!_is24HourFormat)
    {
        ret = [self time12FromTime24:ret];
    }
	
    return ret;
}

+ (NSString *) getShortTimeString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"hh:mm a"];
	
	NSString *timeStr = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	timeStr = [timeStr stringByReplacingOccurrencesOfString:@" AM" withString:@"a"];
	timeStr = [timeStr stringByReplacingOccurrencesOfString:@" PM" withString:@"p"];
	
	return timeStr;
}

+ (NSString *) getDateTimeString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
	
}

+ (NSString *) getMonthYearString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MMM yyyy"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
}

+ (NSString *) getFullMonthYearString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MMMM yyyy"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSString *) getMonthDayString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MMM dd"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getDayLineString:(NSDate *)argDate
{
	NSString *wkdays[7] = {_sundayText, _mondayText, _tuesdayText, _wednesdayText, _thursdayText, _fridayText, _saturdayText};
	
	int wkday = [Common getWeekday:argDate] - 1;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MMM dd"];
	
	NSString *ret = [NSString stringWithFormat:@"%@, %@", wkdays[wkday], [dateFormatter stringFromDate:argDate]];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getMonthString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"MMM"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;	
	
}

+ (NSString *) getDayString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"dd"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;		
}

+ (NSString *) getFullWeekdayString:(NSDate *)argDate
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEEE"];
	
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSString *) getWeekdayString:(NSDate *)argDate
{
	//NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"EEE"];
	
	//return [dateFormatter stringFromDate:argDate];
	NSString *ret = [dateFormatter stringFromDate:argDate];
	
	[dateFormatter release];
	
	return ret;
}

+ (NSString *) getNoteTitle:(NSString *)content
{
    NSRange searchRange;
    
    searchRange.location = 0;
    searchRange.length = content.length;
    
    NSRange range = [content rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:searchRange];
    
    if (range.location != NSNotFound)
    {
        searchRange.length = range.location;
    }
    
    NSString *firstLine = [[content substringWithRange:searchRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [[firstLine componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%C%C",0x2705,0x274E]]] componentsJoinedByString:@""];
}

+ (NSString *) toTime12String:(NSString *)time24String
{
	NSArray *parts = [time24String componentsSeparatedByString:@":"];
	NSInteger hour = [[parts objectAtIndex:0] intValue];
	NSInteger min = [[parts objectAtIndex:1] intValue];
	
	NSString *ampm = (hour >= 12? @"PM":@"AM");
	if (hour > 12)
	{
		hour -= 12;
	}
	
	return [NSString stringWithFormat:@"%02d:%02d %@",hour, min, ampm];
}

+ (NSString *)convertWorkingTimeString:(NSString *)time24String
{
	if (!_is24HourFormat)
	{
		return [Common toTime12String:time24String];
	}
	
	return time24String;
}

+ (CGSize) getTimeSize: (CGFloat) size
{
	NSString *am12 = @"12:00 AM";
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:size];
	
	return [am12 sizeWithFont:font];
}

+ (CGSize) getScreenSize
{
    CGSize sz = [[UIScreen mainScreen] bounds].size;
    
    sz.height -= 20 + 44;
    
    return sz;
}

+ (CGRect) getFrame
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    return frm;
}

+ (CGFloat) getKeyboardHeight
{
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")?217:200;
}

+ (UIImage *) takeSnapshot:(UIView *)view size:(CGSize) size
{
    /*
	UIGraphicsBeginImageContext(size); 
	[view.layer renderInContext:UIGraphicsGetCurrentContext()]; 
	
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext(); 
	
	UIGraphicsEndImageContext(); 
    */
    
    // destination size is half of self (self is a UIView)

    CGFloat scaleX = size.width/view.bounds.size.width;
    CGFloat scaleY = size.height/view.bounds.size.height;
    
    // make the destination context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    // apply the scale to dest context
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scaleX, scaleY);
    
    // render self into dest context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // grab the resulting UIImage
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return img;
}

+ (void) linkAppStore
{
	NSString *bodyStr = [NSString stringWithFormat:@"http://leftcoastlogic.com/sp/appstore"];
	NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];	
}

+ (void) sortList:(NSMutableArray *)list byKey:(NSString *)key ascending:(BOOL)ascending
{
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key  ascending: ascending];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
	
	[list sortUsingDescriptors:sortDescriptors];
	
	[descriptor release];	
}

+ (NSArray *) getSortedList:(NSArray *)list byKey:(NSString *)key ascending:(BOOL)ascending
{
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key  ascending: ascending];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
	
	[descriptor release];
	
	return [list sortedArrayUsingDescriptors:sortDescriptors];
}

+ (NSInteger) countLines:(NSString *)text boundWidth:(CGFloat)boundWidth withFont:(UIFont *)withFont
{
    //CGSize maximumSize = CGSizeMake(boundWidth-8, 100000);
    CGSize maximumSize = CGSizeMake(boundWidth-10, 100000);
    
    CGSize expectedSize = [text sizeWithFont:withFont
                              constrainedToSize:maximumSize
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat lineHeight = [withFont lineHeight];
    
    NSInteger lines = expectedSize.height/lineHeight;
    
    return lines;
}

+ (void)animateGrowViewFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint forView:(UIView *)theView 
{
	// Pulse the view by scaling up, then move the view to under the finger.
	CGAffineTransform transform = CGAffineTransformMakeScale(0.1, 0.1);
	theView.transform = transform;
	theView.center=fromPoint;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	transform = CGAffineTransformMakeScale(1, 1);
	theView.transform = transform;
	theView.center =toPoint;
	[UIView commitAnimations];
}


+ (void)animateShrinkView:(UIView *)theView toPosition:(CGPoint) thePosition target:(id)target shrinkEnd:(SEL)selector
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate: target];
	[UIView setAnimationDidStopSelector:selector];
	
	theView.center = thePosition;
	
	CGAffineTransform transform = CGAffineTransformMakeScale(0.1, 0.1);
	theView.transform = transform;
	[UIView commitAnimations];	
}

+ (BOOL)checkWiFiAvailable
{
	Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];	
	
	BOOL result = NO;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = YES;	
	} 
	
	return result;
	
}

+ (BOOL)validateEmail:(NSString *)candidate 
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:candidate];
}

+(NSString *)md5:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	NSString *ret= [NSString stringWithFormat:
					@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
					result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
					result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
					];
	return ret;
}

+ (NSString *)getFilePath: (NSString *) path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:path];
}

+ (void) reloadRowOfTable:(UITableView *)tableView row:(NSInteger)row section:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    //NSInteger rows = [tableView numberOfRowsInSection:section];
    
    //printf("scroll to row: %d - rows: %d\n", row, rows);
    
    if (![tableView.indexPathsForVisibleRows containsObject:indexPath])
    {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
