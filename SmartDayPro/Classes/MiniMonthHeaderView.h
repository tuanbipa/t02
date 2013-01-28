//
//  MiniMonthHeaderView.h
//  SmartCal
//
//  Created by MacBook Pro on 4/11/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MiniMonthHeaderView : UIView {

    UIButton *selectedButton;
    UILabel *titleLabel;
}

- (NSInteger) getMWMode;
- (void) changeMWMode:(NSInteger)mode;

@end
