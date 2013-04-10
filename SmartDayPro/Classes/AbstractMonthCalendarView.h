//
//  AbstractMiniMonthView.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 4/10/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbstractMonthCalendarView : UIView

- (void) refreshADEView;
- (void) refresh;
- (void) refreshCellByDate:(NSDate *)date;

@end
