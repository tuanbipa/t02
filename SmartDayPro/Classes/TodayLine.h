//
//  TodayLine.h
//  SmartPlan
//
//  Created by Trung Nguyen on 1/28/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TodayLine : UIView {
	BOOL horizontal;
	BOOL dashStyle;
    BOOL focusStyle;
	NSDate *date;
}

@property BOOL horizontal;
@property BOOL dashStyle;
@property BOOL focusStyle;
@property (nonatomic, copy) NSDate *date; 

@end
