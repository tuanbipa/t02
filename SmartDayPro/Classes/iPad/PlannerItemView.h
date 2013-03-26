//
//  PlannerItemView.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovableView.h"

@class Task;

@interface PlannerItemView : MovableView {
    
    UIImageView *checkImageView;
    UIView *checkView;
	
	BOOL checkEnable;
    BOOL transparent;
}

@property BOOL checkEnable;
@property BOOL starEnable;
@property BOOL transparent;

@property BOOL listStyle;

@property (nonatomic, retain) Task *task;

- (void) refresh;
- (void) refreshCheckImage;
@end
