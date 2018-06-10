//
//  ViewFilterMenu.h
//  SmartDayPro
//
//  Created by Tuan Pham on 6/10/18.
//  Copyright © 2018 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterObject.h"
#import "Common.h"

@protocol ViewFilterMenuDelegage <NSObject>

@optional
- (void)didSelectFilterWithFilterType:(NSInteger)filterType atScreen:(TaskListSource)screen;

@end

@interface ViewFilterMenu : UIView
@property (nonatomic, retain) NSArray *listFilters;
@property (assign, nonatomic) id<ViewFilterMenuDelegage> viewFilterMenuDelegage;

- (instancetype)initWithFrame:(CGRect)frame andCurrentScreen:(TaskListSource)screen;

@end
