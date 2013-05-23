//
//  TimeSlotView.h
//  iVo
//
//  Created by Left Coast Logic on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimeSlotView : UIView<UIGestureRecognizerDelegate> {
	//NSDate *time;
	
	BOOL isHighLighted;
}

- (TimeSlotView *) hitTestRec: (CGRect) rec;
- (void) highlight;
- (void) unhighlight;

//@property (nonatomic, copy) 	NSDate *time;

@property NSInteger timeSegment; //value is hour*64 + minute

- (NSDate *) getTime;

+ (CGSize) calculateTimePaneSize;

@end
