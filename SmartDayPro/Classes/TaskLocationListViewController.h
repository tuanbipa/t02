//
//  TaskLocationListViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 11/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskLocationListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *listTableView;
    
    NSInteger tapCount;
    NSInteger tapRow;
    NSInteger tapSection;
}

//@property (nonatomic, retain) NSMutableArray *taskLocationList;
@property (nonatomic, retain) NSMutableArray *taskLocationArriveList;
@property (nonatomic, retain) NSMutableArray *taskLocationLeaveList;
@property (nonatomic, retain) NSString *arriveTitle;
@property (nonatomic, retain) NSString *leaveTitle;
@end