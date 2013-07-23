//
//  TaskLayoutController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/1/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TaskLayoutController.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"

#import "TaskView.h"

#import "TaskMovableController.h"

#import "AbstractSDViewController.h"
#import "SmartListViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation TaskLayoutController

@synthesize listTableView;
@synthesize movableCtrler;
@synthesize taskDict;
@synthesize listKeys;

- (id) init
{
    if (self = [super init])
    {
        self.taskDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.listKeys = [NSArray array];
    }
    
    return  self;
}

- (void) dealloc
{
    self.taskDict = nil;
    self.listKeys = nil;
    
    [super dealloc];
}

- (void) layout
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSMutableArray *list = [tm getDisplayList];
    
    self.taskDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSDate *dt = nil;
    
    for (Task *task in list)
    {
        if (dt != nil && [Common daysBetween:dt sinceDate:task.smartTime] == 0)
        {
            NSMutableArray *list = [self.taskDict objectForKey:dt];
            
            if (list == nil)
            {
                list = [NSMutableArray arrayWithCapacity:10];
                
                [self.taskDict setObject:list forKey:dt];
            }
            
            [list addObject:task];
        }
        else
        {
            dt = task.smartTime;
            
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
            
            [list addObject:task];
            
            [self.taskDict setObject:list forKey:dt];
        }
    }
    
    self.listKeys = [self.taskDict.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    self.movableCtrler.listTableView = self.listTableView;
    
    [self.listTableView reloadData];
}

- (void) setListTableView:(UITableView *)tableView
{
    listTableView = tableView;
    listTableView.delegate = self;
    listTableView.dataSource = self;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return self.listKeys.count+1;
    return self.listKeys.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*if (section == 0)
    {
        return 1;
    }*/
    
    //NSDate *key = [self.listKeys objectAtIndex:section-1];
    NSDate *key = [self.listKeys objectAtIndex:section];
    
	NSArray *list = [self.taskDict objectForKey:key];
    
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return section==0?0:20;
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /*if (section == 0)
    {
        return @"";
    }*/
    
    //NSDate *key = [self.listKeys objectAtIndex:section-1];
    NSDate *key = [self.listKeys objectAtIndex:section];
    
    NSString *dayStr = [Common getDayLineString:key];
    
    NSString *weekdays[7] = {_sundayText, _mondayText, _tuesdayText, _wednesdayText, _thursdayText, _fridayText, _saturdayText};
    
    NSInteger wkday = [Common getWeekday:key];
    
    if ([Common daysBetween:key sinceDate:[NSDate date]] == 0)
    {
        dayStr = [NSString stringWithFormat:@"%@ - %@", _todayText, weekdays[wkday-1]];
        
    }
    else if ([Common daysBetween:key sinceDate:[Common dateByAddNumDay:1 toDate:[NSDate date]]] == 0)
    {
        dayStr = [NSString stringWithFormat:@"%@ - %@", _tomorrowText, weekdays[wkday-1]];
    }
    
    return dayStr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    /*if (indexPath.section == 0)
    {
        SmartListViewController *ctrler = [_abstractViewCtrler getSmartListViewController];
        
        [cell.contentView addSubview:ctrler.quickAddPlaceHolder];
        
        UITextField *quickAddTextField = [ctrler.quickAddPlaceHolder.subviews objectAtIndex:0];
        
        if (quickAddTextField.tag == -2)
        {
            //quick add more
            [quickAddTextField becomeFirstResponder];
        }
    }
    else*/
    {
        //NSDate *key = [self.listKeys objectAtIndex:indexPath.section-1];
        NSDate *key = [self.listKeys objectAtIndex:indexPath.section];
        
        NSArray *list = [self.taskDict objectForKey:key];
        
        TaskManager *tm = [TaskManager getInstance];
        
        Task *task = [list objectAtIndex:indexPath.row];
        
        CGRect frm = CGRectZero;
        //frm.origin.y = 0;
        //frm.origin.x = 0;
        
        frm.size.width = tableView.bounds.size.width;
        frm.size.height = TASK_HEIGHT;
        
        TaskView *taskView = [[TaskView alloc] initWithFrame:frm];
        taskView.tag = -10000;
        taskView.listStyle = YES;
        
        task.listSource = SOURCE_SMARTLIST;
        taskView.task = task;
        taskView.starEnable = (task.status != TASK_STATUS_DONE && ![task isShared]);
        taskView.showDue = (tm.taskTypeFilter == TASK_FILTER_DUE);
        taskView.showFlag = (tm.taskTypeFilter == TASK_FILTER_TOP);
        taskView.showDuration = (tm.taskTypeFilter == TASK_FILTER_LONG || tm.taskTypeFilter == TASK_FILTER_SHORT);
        [taskView refreshStarImage];
        //[taskView refreshCheckImage];
        [taskView enableMove:![task checkMustDo] && tm.taskTypeFilter != TASK_FILTER_DONE];
        
        taskView.movableController = self.movableCtrler;
        
        [cell.contentView addSubview:taskView];
        [taskView release];
    }
    
    return cell;
}

@end
