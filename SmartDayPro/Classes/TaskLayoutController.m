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
#import "ContentPullTableView.h"

#import "TaskMovableController.h"

//#import "AbstractSDViewController.h"
#import "SmartListViewController.h"
#import "iPadViewController.h"


//extern AbstractSDViewController *_abstractViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation TaskLayoutController

@synthesize listTableView;
@synthesize movableCtrler;
@synthesize taskDict;
@synthesize listKeys;

@synthesize layoutMode;

- (id) init
{
    if (self = [super init])
    {
        self.taskDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.listKeys = [NSArray array];
        
        self.layoutMode = 0;
    }
    
    return  self;
}

- (void) dealloc
{
    self.taskDict = nil;
    self.listKeys = nil;
    
    [super dealloc];
}

- (void) refresh
{
    [listTableView reloadData];
}

- (void) layout
{
    TaskManager *tm = [TaskManager getInstance];
    
    NSMutableArray *tasks = [tm getDisplayList];

    //NSLog(@"task layout %d ...", tasks.count);
    
    self.taskDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSDate *dt = nil;
    
    NSInteger c = 0;
    
    for (Task *task in tasks)
    {
        if (self.layoutMode == 1 && c == MAX_FAST_SCHEDULE_TASKS)
        {
            //NSLog(@"task layout fast end");
            break;
        }
        
        if (tm.taskTypeFilter == TASK_FILTER_DONE)
        {
            dt = [Common clearTimeForDate:task.completionTime];
            
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
                dt = [Common clearTimeForDate:task.smartTime];
                
                NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
                
                [list addObject:task];
                
                [self.taskDict setObject:list forKey:dt];
            }
        }
        
        c++;
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
    return TASK_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return section==0?0:20;
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
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
    else if ([Common daysBetween:key sinceDate:[Common dateByAddNumDay:7 toDate:[NSDate date]]] == 0)
    {
        NSDate *dt = [Common dateByAddNumDay:6 toDate:[NSDate date]];
                      
        dayStr = [NSString stringWithFormat:@"%@ %@", _AfterText, [Common getDayLineString:dt]];
    }
    
    return dayStr;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    headerView.backgroundColor = [UIColor grayColor];
    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(5, 0, tableView.bounds.size.width - 10, 20);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    //label.shadowColor = [UIColor grayColor];
    //label.shadowOffset = CGSizeMake(-1.0, 1.0);
    //label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    [headerView addSubview:label];
    
    return headerView;
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
        taskView.checkEnable = !_iPadViewCtrler.inSlidingMode && ![task isShared];
        taskView.showDue = (tm.taskTypeFilter == TASK_FILTER_DUE);
        taskView.showFlag = (tm.taskTypeFilter == TASK_FILTER_TOP);
        taskView.showDuration = (tm.taskTypeFilter == TASK_FILTER_LONG || tm.taskTypeFilter == TASK_FILTER_SHORT);
        [taskView refreshStarImage];
        [taskView refreshCheckImage];
        [taskView enableMove:![task checkMustDo] && tm.taskTypeFilter != TASK_FILTER_DONE];
        
        taskView.movableController = self.movableCtrler;
        
        if (task.isMultiEdit)
        {
            [taskView multiSelect:YES];
        }
        
        [cell.contentView addSubview:taskView];
        [taskView release];
    }
    
    return cell;
}

#pragma mark Scrolling Overrides
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[ContentPullTableView class]])
    {
        ContentPullTableView *pullTableView = (ContentPullTableView *) scrollView;
        
        [pullTableView scrollViewWillBeginDragging];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[ContentPullTableView class]])
    {
        ContentPullTableView *pullTableView = (ContentPullTableView *) scrollView;
        
        [pullTableView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if ([scrollView isKindOfClass:[ContentPullTableView class]])
    {
        ContentPullTableView *pullTableView = (ContentPullTableView *) scrollView;
        
        [pullTableView scrollViewDidEndDragging];
    }
}


@end
