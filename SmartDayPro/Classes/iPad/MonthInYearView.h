//
//  MonthInYearView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 4/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthInYearView : UIView {
//    NSInteger month;
//    NSInteger year;
//    NSDate *monthDate;
    
    NSInteger todayCellIndex;
}
@property (nonatomic, retain) NSDate *monthDate;

- (void) initCalendar;//:(NSDate *)date;
- (void) refresh;
@end
