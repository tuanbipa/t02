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

extern AbstractSDViewController *_abstractViewCtrler;

extern iPadViewController *_iPadViewCtrler;

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
- (void) changeFrame:(CGRect)frm
{
    Settings *settings = [Settings getInstance];
    
    contentView.frame = frm;
    
    listView.frame = CGRectMake(0, 40, frm.size.width, frm.size.height - (settings.tabBarAutoHide?0:40) - 40);
    listView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
    
    maskView.frame= CGRectMake(0, 40, frm.size.width, frm.size.height-40);
    
    UIView *quickAddPlaceHolder = [contentView viewWithTag:-30000];
    
    quickAddPlaceHolder.frame = CGRectMake(0, 0, frm.size.width, 40);
    
    quickAddTextField.frame = CGRectMake(10, 5, frm.size.width-50, 30);
    
    UIButton *moreButton = (UIButton *)[quickAddPlaceHolder viewWithTag:10000];
    
    moreButton.frame = CGRectMake(frm.size.width-35, 4, 30, 30);
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
    
    listView = [[ContentScrollView alloc] initWithFrame:CGRectMake(0, 40, frm.size.width, frm.size.height - (settings.tabBarAutoHide?0:40) - 40)];
    
    listView.backgroundColor = [UIColor clearColor];
    listView.delegate = self;
    
    [contentView addSubview:listView];
    [listView release];
    
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, frm.size.width, frm.size.height-40)];
    [contentView addSubview:maskView];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.hidden = YES;
    [maskView release];
    
    UIView *quickAddPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)];
	quickAddPlaceHolder.backgroundColor = [UIColor clearColor];
    quickAddPlaceHolder.tag = -30000;
	[contentView addSubview:quickAddPlaceHolder];
	[quickAddPlaceHolder release];
    
    quickAddTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, frm.size.width-50, 30)];
	quickAddTextField.delegate = self;
    quickAddTextField.tag = -1;
	quickAddTextField.borderStyle = UITextBorderStyleRoundedRect;
	quickAddTextField.keyboardType = UIKeyboardTypeDefault;
	quickAddTextField.returnKeyType = UIReturnKeyDone;
	quickAddTextField.font=[UIFont systemFontOfSize:16];
	quickAddTextField.placeholder = _quickAddNewProject;
    //[quickAddTextField addTarget:self action:@selector(quickAddDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[quickAddPlaceHolder addSubview:quickAddTextField];
	[quickAddTextField release];
	
	UIButton *moreButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(frm.size.width-35, 4, 30, 30)
                                     titleColor:nil
                                         target:self
                                       selector:@selector(saveAndMore:)
                               normalStateImage:@"addmore.png"
                             selectedStateImage:nil];
    moreButton.tag = 10000;
	
	[quickAddPlaceHolder addSubview:moreButton];
    
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

#pragma mark Multi Edit

- (void) multiDelete:(id)sender
{
	if ([[Settings getInstance] deleteWarning])
	{
        BOOL needConfirm = NO;
        
        for (UIView *view in listView.subviews)
        {
            if ([view isKindOfClass:[TaskView class]])
            {
                TaskView *tv = (TaskView *)view;
                
                if ([tv isMultiSelected])
                {
                    needConfirm = YES;
                    
                    break;
                }
            }
        }
        
        if (needConfirm)
        {
            NSString *msg = _itemDeleteText;
            NSInteger tag = -10000;
            
            UIAlertView *taskDeleteAlertView = [[UIAlertView alloc] initWithTitle:_itemDeleteTitle  message:msg delegate:self cancelButtonTitle:_cancelText otherButtonTitles:nil];
            
            taskDeleteAlertView.tag = tag;
            
            [taskDeleteAlertView addButtonWithTitle:_okText];
            [taskDeleteAlertView show];
            [taskDeleteAlertView release];
        }
	}
	else
	{
		[self doMultiDeleteTask];
	}
}

- (void) doMultiDeleteTask
{
    NSMutableArray *taskList = [NSMutableArray arrayWithCapacity:10];
    
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]] && [((TaskView *)view) isMultiSelected])
        {
            [taskList addObject:((TaskView *)view).task];
        }
    }
    
    if (taskList.count > 0)
    {
        [[TaskManager getInstance] deleteTasks:taskList];
        
        for (Task *task in taskList)
        {
            [self.list removeObject:task];
        }
    }
    
    [self multiEdit:NO];
    
    [self refreshLayout];
    
    /*if ([_abstractViewCtrler checkControllerActive:3])
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        
        if (ctrler.filterType == TYPE_NOTE)
        {
            [ctrler loadAndShowList];
        }
    }*/
    
    FocusView *focusView = [_abstractViewCtrler getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }
    
    [_abstractViewCtrler cancelEdit];
}

- (void) multiEdit:(BOOL)enabled
{
    //Settings *settings = [Settings getInstance];
    
    /*
     for (int i=0; i<self.noteList.count; i++)
     {
     UITableViewCell *cell = [listTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
     
     TaskView *taskView = (TaskView *) [cell.contentView viewWithTag:10000];
     
     [taskView multiSelect:enabled];
     }
     */
    for (UIView *view in listView.subviews)
    {
        if ([view isKindOfClass:[MovableView class]])
        {
            [(MovableView *) view multiSelect:enabled];
        }
    }
    
    /*editBarPlaceHolder.hidden = !enabled;
     
     CGFloat h = (settings.tabBarAutoHide?0:40) + (enabled?40:0);
     
     noteListView.frame = CGRectMake(0, enabled?40:0, contentView.bounds.size.width, contentView.bounds.size.height - h);*/
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
- (void) saveAndMore:(id) sender
{
	NSString *text = [quickAddTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    if (![quickAddTextField isFirstResponder])
    {
        [quickAddTextField becomeFirstResponder];
    }
	else if (![text isEqualToString:@""])
	{
        [_iPadViewCtrler.activeViewCtrler quickAddProject:text];
	}
    
    quickAddTextField.text = @"";
    quickAddTextField.tag = -2;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    maskView.hidden = NO;
    
    [_iPadViewCtrler.activeViewCtrler hideDropDownMenu];
        
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
            [_iPadViewCtrler.activeViewCtrler quickAddProject:text];
        }
        
        quickAddTextField.tag = -1;
    }
    
    quickAddTextField.text = @"";
    
    maskView.hidden = YES;
}

@end
