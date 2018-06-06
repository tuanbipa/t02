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
#import "iPadViewController.h"
#import "PlannerViewController.h"

#define HEIGHT_QUICK_ADD_VIEW 40

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@interface CategoryViewController ()<UITextFieldDelegate, UIScrollViewDelegate>

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
    if ([[AbstractActionViewController getInstance] checkControllerActive:3])
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

- (void)changeSkin {
    contentView.backgroundColor = COLOR_BACKGROUND_LIST_VIEW;
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
                Task *topTask = [dbm getTopTaskForPlan:prj.primaryKey excludeFutureTasks:NO];
                
                //printf("top task: %s - prj: %s\n",[topTask.name UTF8String], [prj.name UTF8String]);
                
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
}

-(void)refreshLayout
{
    [self cancelMultiEdit];
    
    [movableController unhighlight];
	
    [movableController reset];
	
	//[layoutController performSelector:@selector(layout) withObject:nil afterDelay:0];
    [layoutController layout];
    
    if ([[AbstractActionViewController getInstance] getActiveModule] == self) {
        // refresh multi edit bar
        [[AbstractActionViewController getInstance] hideMultiEditBar];
    }
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
        
        Task *topTask = [dbm getTopTaskForPlan:prjKey excludeFutureTasks:NO];
        
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
    for (NSObject *obj in self.list)
    {
        if ([obj isKindOfClass:[Task class]])
        {
            Task *task = (Task *) obj;
            
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
}

-(void) stopQuickAdd
{
	[quickAddTextField resignFirstResponder];
    
    maskView.hidden = YES;
}

-(void) cancelQuickAdd
{
    quickAddTextField.text = @"";
    
    [self stopQuickAdd];
}

#pragma mark Views

- (MovableView *)getFirstMovableView
{
    MovableView *ret = nil;
    
    if (self.list.count > 0)
    {
        NSObject *firstItem = [self.list objectAtIndex:0];

        for (UIView *view in listView.subviews)
        {
            if ([view isKindOfClass:[TaskView class]] && ((TaskView *)view).task == firstItem)
            {
                ret = view;
                break;
            }
            else if ([view isKindOfClass:[PlanView class]] && ((PlanView *)view).project == firstItem)
            {
                ret = view;
                break;
            }
        }

    }
    
    return ret;
}

- (MovableView *) getMovableView4Item:(NSObject *)item
{
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]] && ((TaskView *)view).task == item)
        {
            return view;
        }
        else if ([view isKindOfClass:[PlanView class]] && ((PlanView *)view).project == item)
        {
            return view;
        }
    }
    
    return nil;
}

- (void)changeFrame:(CGRect)frm {
    Settings *settings = [Settings getInstance];
    contentView.frame = frm;
    
    CGRect frame = contentView.bounds;
    frame.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frame.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);
    
    listView.frame = frame;
    listView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
    
    maskView.frame = CGRectMake(0, 40, frm.size.width, frm.size.height-40);
    
    UIView *quickAddPlaceHolder = [contentView viewWithTag:-30000];
    
    quickAddPlaceHolder.frame = CGRectMake(0, 0, frm.size.width, 35);
    
    quickAddTextField.frame = CGRectMake(8, 0, frm.size.width, HEIGHT_QUICK_ADD_VIEW);
    
    UIButton *moreButton = (UIButton *)[quickAddPlaceHolder viewWithTag:10000];
    
    moreButton.frame = CGRectMake(frm.size.width-35, 4, 30, 30);
}

- (void)loadView {
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    frm.size.height += [Common heightTabbar];
    
    Settings *settings = [Settings getInstance];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
    self.view = contentView;
    [contentView release];

    frm = contentView.bounds;
    frm.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frm.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);
    
    listView = [[ContentScrollView alloc] initWithFrame:frm];
    listView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);
    listView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
    
    listView.backgroundColor = [UIColor clearColor];
    listView.delegate = self;
    
    [contentView addSubview:listView];
    [listView release];
    
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, frm.size.width, frm.size.height-40)];
    [contentView addSubview:maskView];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.hidden = YES;
    [maskView release];
    
    UIView *quickAddPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, HEIGHT_QUICK_ADD_VIEW)];
	quickAddPlaceHolder.backgroundColor = [[Common getColorByID:0 colorIndex:0] colorWithAlphaComponent:0.2];
    quickAddPlaceHolder.tag = -30000;
	[contentView addSubview:quickAddPlaceHolder];
	[quickAddPlaceHolder release];
    
    quickAddTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, frm.size.width, HEIGHT_QUICK_ADD_VIEW)];
	quickAddTextField.delegate = self;
    quickAddTextField.tag = -1;
	quickAddTextField.borderStyle = UITextBorderStyleNone;
	quickAddTextField.keyboardType = UIKeyboardTypeDefault;
	quickAddTextField.returnKeyType = UIReturnKeyDone;
	quickAddTextField.font=[UIFont systemFontOfSize:16];
	quickAddTextField.placeholder = _quickAddNewProject;
    //[quickAddTextField addTarget:self action:@selector(quickAddDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[quickAddPlaceHolder addSubview:quickAddTextField];
	[quickAddTextField release];
	
    /*
	UIButton *moreButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(frm.size.width-35, 4, 30, 30)
                                     titleColor:nil
                                         target:self
                                       selector:@selector(saveAndMore:)
                               normalStateImage:@"addmore.png"
                             selectedStateImage:nil];
    moreButton.tag = 10000;
	
	[quickAddPlaceHolder addSubview:moreButton];*/
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deselect];
    [self cancelMultiEdit];
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

- (void)tabBarModeChanged:(NSNotification *)notification {
    Settings *settings = [Settings getInstance];
    
    CGRect frm = contentView.bounds;
    frm.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frm.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);
    
    listView.frame = frm;
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

#pragma mark Multi Edit

- (NSMutableArray *) getMultiEditList
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:10];
    
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                [ret addObject:tv.task];
            }
        }
    }
    
    return ret;
}

- (void) enableMultiEdit:(BOOL)enabled
{
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *) view;
            Task *task = tv.task;
            tv.checkEnable = enabled && ![task isShared];
            [tv refresh];
        }
    }
}

- (void) cancelMultiEdit
{
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[MovableView class]])
        {
            [(MovableView *) view multiSelect:NO];
        }
    }
    
    [[AbstractActionViewController getInstance] hideMultiEditBar];
    [Common refreshNavigationbarForEditMode];
}

#pragma mark Alert delegate

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
        [self doMultiDeleteTask];
	}
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    maskView.hidden = NO;
    
    [[AbstractActionViewController getInstance] hideDropDownMenu];
        
	return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    quickAddTextField.tag = 1;
    
	[self stopQuickAdd];
	
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (quickAddTextField.tag == 1)
    {
        NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (![text isEqualToString:@""])
        {
            if ([[ProjectManager getInstance] checkExistingProjectName:text excludeProject:-1])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_categoryNameExistsText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
                [alertView show];
                [alertView release];
            }
            else
            {
                [[AbstractActionViewController getInstance] quickAddProject:text];
            }
        }
        
        quickAddTextField.tag = -1;
    }
    
    quickAddTextField.text = @"";
    
    maskView.hidden = YES;
}

@end
