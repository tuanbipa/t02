//
//  CategoryViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/25/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "CategoryViewController.h"

#import "Common.h"
#import "Settings.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "Task.h"
#import "Project.h"

#import "ContentView.h"
#import "ContentScrollView.h"
#import "TaskView.h"
#import "PlanView.h"

#import "CategoryMovableController.h"
#import "CategoryLayoutController.h"

#import "ProjectEditViewController.h"

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@interface CategoryViewController ()

@end

@implementation CategoryViewController

@synthesize list;
@synthesize filterType;
@synthesize showDone;
@synthesize listView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        movableController = [[CategoryMovableController alloc] init];
        
        layoutController = [[CategoryLayoutController alloc] init];
        layoutController.movableController = movableController;
        
        self.showDone = NO;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tabBarModeChanged:)
													 name:@"TabBarModeChangeNotification" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    self.list = nil;
    
    [movableController release];
    
    [layoutController release];
    
    [super dealloc];
}

- (void) reconcileItem:(Task *)item
{
    if ([_abstractViewCtrler checkControllerActive:3])
    {
        //comment out: when convert a task into event, it does not match filter type anymore
        /*if (([item isNote] && self.filterType == TYPE_NOTE) ||
            ([item isTask] && self.filterType == TYPE_TASK) ||
            ([item isEvent] && self.filterType == TYPE_EVENT))*/
        {
            [self loadAndShowList];
        }
    }
}

- (void) changeSkin
{
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
}

-(void)expandProject:(Project *)prj
{
	prj.isExpanded = !prj.isExpanded;
    
    [_abstractViewCtrler deselect];
    
    [self loadAndShowList];
}

- (void) reconcileLinkCopy
{
    if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.listSource == SOURCE_CATEGORY)
    {
        for (NSObject *obj in self.list)
        {
            if ([obj isKindOfClass:[Task class]] && _abstractViewCtrler.task2Link.primaryKey == [obj primaryKey])
            {
                _abstractViewCtrler.task2Link = obj;
                
                break;
            }
        }
    }
    
}

- (void) loadAndShowList
{
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
 
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            //view.tag = tm.taskDummy;
            ((TaskView *)view).task = tm.taskDummy;
        }
    }
    
    CGFloat h = 0;
    
    NSDictionary *tagDict = [tm getFilterTagDict];
    NSDictionary *categoryDict = [tm getFilterCategoryDict];
    
	self.list = [NSMutableArray arrayWithCapacity:pm.projectList.count + 10];
    
	for (Project *prj in pm.projectList)
	{
        if (prj.status != PROJECT_STATUS_INVISIBLE)
        {
            [self.list addObject:prj];
            
            h += 40;
            
			if (prj.isExpanded)
			{
                Task *topTask = [dbm getTopTaskForPlan:prj.primaryKey];
                
				NSMutableArray *activeTasks = [dbm getItems:self.filterType inPlan:prj.primaryKey];

                if (self.showDone && self.filterType == TYPE_TASK)
                {
                    NSMutableArray *doneTasks = [dbm getDoneTasks4Plan:prj.primaryKey];
                    
                    if (doneTasks.count > 0)
                    {
                        [doneTasks addObjectsFromArray:activeTasks];
                        
                        activeTasks = doneTasks;
                    }
                }
                                
                for (Task *task in activeTasks)
                {
                    if ([tm checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict])
                    {
                        if (task.primaryKey == topTask.primaryKey)
                        {
                            task.isTop = YES;
                        }
                        
                        [self.list addObject:task];
                        
                        h += TASK_HEIGHT;
                        
                        if ([task isRE])
                        {
                            Task *firstInstance = [[TaskManager getInstance] findRTInstance:task fromDate:task.startTime];
                            
                            task.startTime = firstInstance.startTime;
                            task.endTime = firstInstance.endTime;

                        }
                    }
                }
			}
            
        }
	}  
    
    [self reconcileLinkCopy];
    
    [self refreshView];
    
    //listTableView.contentSize = CGSizeMake(listTableView.bounds.size.width, h + listTableView.bounds.size.height/2);
    
    listView.contentSize = CGSizeMake(listView.bounds.size.width, h + listView.bounds.size.height/2);
}

-(void)refreshLayout
{
    [movableController unhighlight];
	
    [movableController reset];
	
	[layoutController performSelector:@selector(layout) withObject:nil afterDelay:0];
}

- (void) refreshView
{
    [self refreshLayout];
}

-(void)setNeedsDisplay
{
    for (UIView *view in self.listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            [(TaskView *)view refresh];
        }
        else
        {
            [view setNeedsDisplay];
        }
    }
}

- (void) enableActions:(BOOL)enable
{
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];
    
	if (enable)
	{
		//CGRect frm = CGRectMake(0, selectedIndex*60-listTableView.contentOffset.y, listTableView.bounds.size.width, 60);

		CGRect frm = CGRectMake(0, selectedIndex*60-listView.contentOffset.y, listView.bounds.size.width, 60);
        
        contentView.actionType = ACTION_ITEM_EDIT;
        
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:frm inView:contentView];
		[menuCtrler setMenuVisible:YES animated:YES];
		
	}
	else 
	{
		[menuCtrler setMenuVisible:NO animated:YES];
	}	    
}

- (void) markDoneTask:(Task *)task
{
    NSInteger prjKey = task.project;
    
    //[[TaskManager getInstance] garbage:task];
        
    if (![task isRT])
    {
        [list removeObject:task];
    }
    
    if (self.filterType == TYPE_TASK)
    {
        if (self.showDone)
        {
            [self loadAndShowList];
            
            return;
        }
        
        DBManager *dbm = [DBManager getInstance];
        
        Task *topTask = [dbm getTopTaskForPlan:prjKey];
        
        for (NSObject *obj in self.list)
        {
            if ([obj isKindOfClass:[Task class]])
            {
                Task *tmp = (Task *)obj;
                
                if (tmp.project == prjKey && tmp.primaryKey == topTask.primaryKey)
                {
                    tmp.isTop = YES;
                    
                    break;
                }
            }
        }        
    }
    
    [self refreshView];
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    for (Task *task in self.list)
    {
        if (task.original == nil || [task isREException])
        {
            if (task.primaryKey == taskId)
            {
                task.alerts = [[DBManager getInstance] getAlertsForTask:task.primaryKey];
                
                break;
            }
        }
    }
}

#pragma mark Views
- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    listView.frame = contentView.bounds;
    listView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    Settings *settings = [Settings getInstance];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
    
    self.view = contentView;
    [contentView release];
    
    listView = [[ContentScrollView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, frm.size.height - (settings.tabBarAutoHide?0:40))];
    
    listView.backgroundColor = [UIColor clearColor];
    listView.delegate = self;
    
    [contentView addSubview:listView];
    [listView release];
    
    layoutController.viewContainer = listView;
    
    [self changeSkin];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAndShowList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Notification

- (void)tabBarModeChanged:(NSNotification *)notification
{
    CGSize sz = [Common getScreenSize];
    
    Settings *settings = [Settings getInstance];
    
    listView.frame = CGRectMake(0, 0, sz.width, sz.height - (settings.tabBarAutoHide?0:40));
}

#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    for (NSObject *obj in self.list)
    {
        if ([obj isKindOfClass:[Task class]])
        {
            Task *task = (Task *) obj;
            
            if (task.original == nil || [task isREException])
            {
                if (task.primaryKey == sourceId)
                {
                    task.links = [tlm getLinkIds4Task:sourceId];
                }
                else if (task.primaryKey == destId)
                {
                    task.links = [tlm getLinkIds4Task:destId];
                }
            }
        }
    }
}

#pragma mark UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_abstractViewCtrler deselect];
}

@end
