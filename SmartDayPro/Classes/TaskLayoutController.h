//
//  TaskLayoutController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/1/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

@class TaskMovableController;

@interface TaskLayoutController : NSObject<UITableViewDelegate, UITableViewDataSource>
{

}

@property (nonatomic, assign) UITableView *listTableView;
@property (nonatomic, assign) TaskMovableController *movableCtrler;
@property (nonatomic, retain) NSMutableDictionary *taskDict;
@property (nonatomic, retain) NSArray *listKeys;

@property NSInteger layoutMode;//0:normal - 1:fast

- (void) layout;

@end
