//
//  TaskLocationListViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 11/5/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TaskLocationListViewController.h"
#import "DBManager.h"
#import "Task.h"
#import "Location.h"
#import "LocationManager.h"
#import "ProjectManager.h"

#import "iPadSmartDayViewController.h"
#import "iPadViewController.h"

//extern iPadSmartDayViewController *_iPadSDViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation TaskLocationListViewController

//@synthesize taskLocationList;
@synthesize taskLocationArriveList;
@synthesize taskLocationLeaveList;
@synthesize arriveTitle;
@synthesize leaveTitle;

- (id) init
{
    if (self = [super init])
    {
        self.preferredContentSize = CGSizeMake(320,416);
        
        tapCount = 0;
        tapRow = -1;
        tapSection = -1;
    }
    
    return self;
}

- (void)dealloc
{
//    self.taskLocationList = nil;
    self.taskLocationArriveList = nil;
    self.taskLocationLeaveList = nil;
    self.arriveTitle = nil;
    self.leaveTitle = nil;
    
    [super dealloc];
}

- (void) refreshData
{
    DBManager *dbm = [DBManager getInstance];
    
    NSMutableArray *taskLocations = [dbm getCurrentTaskLocation];
    self.taskLocationArriveList = [NSMutableArray array];
    self.taskLocationLeaveList = [NSMutableArray array];
    
    for (Task *task in taskLocations) {
        if (task.locationAlert == LOCATION_ARRIVE) {
            [self.taskLocationArriveList addObject:task];
        } else {
            [self.taskLocationLeaveList addObject:task];
        }
    }
    
    [listTableView reloadData];
    
    NSMutableArray *locations = [[LocationManager getInstance] getAllLocation];
    
    NSMutableArray *arriveLocations = [NSMutableArray array];
    NSMutableArray *leaveLocations = [NSMutableArray array];
    
    for (Location *loc in locations) {
        
        if (loc.inside == LOCATION_ARRIVE) {
            [arriveLocations addObject:loc.name];
        } else if (loc.inside == LOCATION_LEAVE) {
            [leaveLocations addObject:loc.name];
        }
    }
    
    self.arriveTitle = [arriveLocations componentsJoinedByString:@", "];
    self.leaveTitle = [leaveLocations componentsJoinedByString:@", "];
    
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
    /*if (_isiPad)
     {
     frm.size.height = 440;
     }
     */
    frm.size.height = 416;
	
	UIView *contentView= [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1];
    
	self.view = contentView;
	[contentView release];
    
    listTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
    
	listTableView.delegate = self;
	listTableView.dataSource = self;
	listTableView.sectionHeaderHeight = 10;
    listTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:listTableView];
	[listTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 0) {
        return self.taskLocationArriveList.count;
    } else {
        return self.taskLocationLeaveList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.taskLocationArriveList.count == 0) {
        return 0.0;
    } else if (section == 1 && self.taskLocationLeaveList.count == 0) {
        return 0.0;
    }
    return 40;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        // get location arrive
        
        return [NSString stringWithFormat:_arriveAtText, self.arriveTitle];
    } else {
        return [NSString stringWithFormat:_leaveAtText, self.leaveTitle];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
   	/*else
     {
     for(UIView *view in cell.contentView.subviews)
     {
     if(view.tag >= 10000)
     {
     [view removeFromSuperview];
     }
     }
     }*/
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    if (indexPath.section == 0) {
        
        Task *task = [self.taskLocationArriveList objectAtIndex:indexPath.row];
        
        cell.textLabel.text = task.name;
        UIColor *textColor = [[ProjectManager getInstance] getProjectColor0:task.project];
        cell.textLabel.textColor = textColor;
        
    } else if (indexPath.section == 1) {
        
        Task *task = [self.taskLocationLeaveList objectAtIndex:indexPath.row];
        
        cell.textLabel.text = task.name;
        UIColor *textColor = [[ProjectManager getInstance] getProjectColor0:task.project];
        cell.textLabel.textColor = textColor;
    }
    
    return cell;
}

#pragma mark TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tapCount++;
    tapRow = indexPath.row;
    tapSection = indexPath.section;
    
    switch (tapCount)
    {
        case 1: //single tap
            [self performSelector:@selector(singleTap) withObject:nil afterDelay: .4];
            break;
        case 2: //double tap
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            
            [self performSelector:@selector(doubleTap) withObject: nil];
        }
            break;
        default:
            break;
    }
}

- (void) singleTap
{
    tapCount = 0;
    
    if (tapRow >= 0)
    {
    }
}

- (void) doubleTap
{
    tapCount = 0;
    
    if (tapRow >= 0 && tapSection >= 0)
    {
        NSMutableArray *lists[2] = {self.taskLocationArriveList, self.taskLocationLeaveList};
        
        Task *task = [lists[tapSection] objectAtIndex:tapRow];
        
        //[_iPadSDViewCtrler editItem:task inRect:CGRectMake(600, 0, 20, 10)];
        [_iPadViewCtrler deactivateSearchBar];
        [[AbstractActionViewController getInstance] hidePopover];
        [[AbstractActionViewController getInstance] editItem:task inView:nil];
    }
}
@end
