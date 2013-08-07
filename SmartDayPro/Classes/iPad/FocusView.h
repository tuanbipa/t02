//
//  FocusView.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/12/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface FocusView : UIView
{
    UIScrollView *contentView;
    
    UILabel *titleLabel;
    //UIButton *zoomButton;
}

@property (nonatomic, retain) NSMutableArray *adeList;
@property (nonatomic, retain) NSMutableArray *dueList;
@property (nonatomic, retain) NSMutableArray *noteList;

@property (nonatomic, retain) NSMutableArray *doneList;

- (void) refreshData;
- (void) refreshView;
-(void) setNeedsDisplay;
- (void) reconcileLinks:(NSDictionary *)dict;
- (void) reloadAlert4Task:(NSInteger)taskId;

- (BOOL) checkExpanded;
- (void) reconcileItem:(Task *)item;

@end
