//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "iPadSmartDayViewController.h"

#import "Common.h"
#import "Task.h"
#import "Settings.h"

#import "TaskManager.h"
#import "TimerManager.h"
#import "ImageManager.h"
#import "MenuMakerView.h"

#import "ContentView.h"
#import "MiniMonthView.h"
#import "MiniMonthHeaderView.h"
#import "FocusView.h"
#import "TaskView.h"
#import "PlanView.h"

#import "PageAbstractViewController.h"
#import "CalendarViewController.h"
#import "SmartListViewController.h"
#import "NoteViewController.h"
#import "CategoryViewController.h"

#import "TaskDetailTableViewController.h"
#import "NoteDetailTableViewController.h"
#import "ProjectEditViewController.h"
#import "PreviewViewController.h"

#import "CalendarSelectionTableViewController.h"
#import "iPadTagListViewController.h"
#import "MenuTableViewController.h"
#import "SeekOrCreateViewController.h"
#import "TimerViewController.h"

#import "SDNavigationController.h"

#import "PlannerViewController.h"

#import "iPadViewController.h"

extern BOOL _isiPad;

iPadViewController *_iPadViewCtrler;

@interface iPadSmartDayViewController ()

@end

@implementation iPadSmartDayViewController

@synthesize popoverCtrler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}

- (void) dealloc
{    
    self.popoverCtrler = nil;
    
    [super dealloc];
}

- (BOOL) checkControllerActive:(NSInteger)index
{
    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
    UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
    UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
    
    UIButton *taskModuleButton = (UIButton *)[taskHeaderView viewWithTag:21000];
    UIButton *noteModuleButton = (UIButton *)[noteHeaderView viewWithTag:21001];
    UIButton *projectModuleButton = (UIButton *)[projectHeaderView viewWithTag:21002];
    
    UIButton *buttons[4] = {nil, taskModuleButton, noteModuleButton, projectModuleButton};
    
    if (index == 0 || (index > 0 && buttons[index].selected))
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) checkRect:(CGRect)rect inModule:(NSInteger) inModule
{
    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
        
    UIView *moduleBorderView = (UIView *)[contentView viewWithTag:18000+inModule];
    
    CGRect frm = moduleBorderView.frame;
    
    if (frm.size.height == 0)
    {
        //module is collapsed
        
        frm = taskHeaderView.frame;
    }
    else
    {
        frm.origin.y -= 40;
        frm.size.height += 40;
    }
    
    return CGRectIntersectsRect(frm, rect);
    
}

- (void) refreshTaskFilterTitle
{
    UILabel *taskFilterLabel = (UILabel *)[contentView viewWithTag:24000];
  
    taskFilterLabel.text = [[TaskManager getInstance] getFilterTitle];
}

- (void) resizeModules
{
    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
    UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
    UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
    
    UIView *headerViews[3] = {taskHeaderView, noteHeaderView, projectHeaderView};
    
    UIButton *taskModuleButton = (UIButton *)[taskHeaderView viewWithTag:21000];
    UIButton *noteModuleButton = (UIButton *)[noteHeaderView viewWithTag:21001];
    UIButton *projectModuleButton = (UIButton *)[projectHeaderView viewWithTag:21002];
    
    UIButton *buttons[3] = {taskModuleButton, noteModuleButton, projectModuleButton};
    
    NSInteger expandNum = 0;
    
    for (int i=0; i<3; i++)
    {
        if (buttons[i].selected)
        {
            expandNum += 1;
        }
    }
    
    NSInteger moduleHeight = (expandNum == 0?0:(contentView.bounds.size.height-160)/expandNum);
    
    NSInteger y = 10;
    
    CGFloat w = contentView.bounds.size.width/2 - 10;
    
    for (int i=0; i<3; i++)
    {
        UIView *moduleBorderView = (UIView *)[contentView viewWithTag:18000+i];
        moduleBorderView.frame = !buttons[i].selected?CGRectZero:CGRectMake(w+20, y+40-5, w-10, moduleHeight + 5);
        
        UIImageView *headerImageView = (UIImageView *)[contentView viewWithTag:19000+i];
        headerImageView.frame = CGRectMake(w+20, y, w-10, 40);
        
        UIView *headerView = headerViews[i];
        
        headerView.frame = CGRectMake(w+20, y, w-10, 40);
        
        y += 40;
        
        //CGRect frm = !buttons[i].selected?CGRectZero:CGRectMake(w+20, y, w-10, moduleHeight);
        CGRect frm = !buttons[i].selected?CGRectMake(w+20, 0, w-10, 0):CGRectMake(w+20, y, w-10, moduleHeight);
        
        [viewCtrlers[i+1] changeFrame:frm];
        
        y += frm.size.height + 10;
        
        /*if (i==0)
        {
            //tasks module
            [viewCtrlers[i+1] refreshLayout];
        }
        else*/
        if (i != 0)
        {
            [viewCtrlers[i+1] loadAndShowList];
        }

    }
}

/*
- (void) editItem:(Task *)item
{
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SDNavigationController class]])
    {
        if ([item isNote])
        {
            NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
            ctrler.note = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
        else
        {
            TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
            
            ctrler.task = item;
            
            [self.popoverCtrler.contentViewController pushViewController:ctrler animated:YES];
            [ctrler release];
        }
    }
    else
    {
        [super editItem:item];
    }
}

- (void) editItem:(Task *)item inView:(TaskView *)inView
{
    UIViewController *editCtrler = nil;
    
    if ([item isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        
        ctrler.note = item;
        
        editCtrler = ctrler;
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = item;
        
        editCtrler = ctrler;
    }
	
    if (editCtrler != nil)
    {
        SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
        [editCtrler release];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        
        [navController release];
        
        CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:item.listSource == SOURCE_CALENDAR || item.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];

    }
}

- (void) editProject:(Project *)project inView:(PlanView *)inView
{
    ProjectEditViewController *editCtrler = [[ProjectEditViewController alloc] init];
    editCtrler.project = project;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:editCtrler];
    [editCtrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [inView.superview convertRect:inView.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    
}

- (void) starTaskInView:(TaskView *)taskView
{
    [super starTaskInView:taskView];
    
    SmartListViewController *slViewCtrler = [self getSmartListViewController];
    
    [slViewCtrler setNeedsDisplay];
    
    CategoryViewController *catViewCtrler = [self getCategoryViewController];
    
    [catViewCtrler setNeedsDisplay];
}
*/
- (void) addTask
{
    [[self getSmartListViewController] cancelQuickAdd];
    
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
    Task *task = [[[Task alloc] init] autorelease];
    
    TaskManager *tm = [TaskManager getInstance];
    
	switch (tm.taskTypeFilter)
	{
		case TASK_FILTER_PINNED:
		{
			task.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			task.deadline = [NSDate date];
		}
			break;
	}
	
	ctrler.task = task;
	
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    UIButton *addTaskButton = (UIButton *)[contentView viewWithTag:22000];
	
	CGRect frm = [addTaskButton.superview convertRect:addTaskButton.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void) addNote
{
	NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
    
    Task *note = [[[Task alloc] init] autorelease];
    note.type = TYPE_NOTE;
    note.listSource = SOURCE_NOTE;
	
	ctrler.note = note;
	
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    UIButton *addNoteButton = (UIButton *)[contentView viewWithTag:22001];
	
	CGRect frm = [addNoteButton.superview convertRect:addNoteButton.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void) addProject
{
	ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
    
    Project *prj = [[[Project alloc] init] autorelease];
	
	ctrler.project = prj;
	
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    UIButton *addProjectButton = (UIButton *)[contentView viewWithTag:22002];
	
	CGRect frm = [addProjectButton.superview convertRect:addProjectButton.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}


- (void) enableActions:(BOOL)enable onView:(TaskView *)view
{
    BOOL showPopover = activeView != view;
    
    [super enableActions:enable onView:view];
    
    if (showPopover)
    {
        PreviewViewController *ctrler = [[PreviewViewController alloc] init];
        ctrler.item = view.task;
        
        SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
        [ctrler release];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
        
        UIButton *timerButton = [_iPadViewCtrler getTimerButton];
        
        if (timerButton != nil)
        {
            self.popoverCtrler.passthroughViews = [NSArray arrayWithObjects:timerButton,view,nil];
        }
        
        [navController release];
        
        CGRect frm = [view.superview convertRect:view.frame toView:contentView];
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:view.task.listSource == SOURCE_CALENDAR || view.task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
        
    }
}

- (void) scrollToDate:(NSDate *)date
{
    [super scrollToDate:date];
    
    [self.focusView refreshData];
}

- (void) deselect
{
    [super deselect];
    
    [_iPadViewCtrler deactivateSearchBar];
    
    if (self.popoverCtrler != nil)
    {
        [self.popoverCtrler dismissPopoverAnimated:YES];
        
        self.popoverCtrler = nil;
    }
}

- (void) showCategory
{
    [self hidePopover];
    
    CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    
    CGRect frm = CGRectMake(100, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) showTag
{
    [self hidePopover];
    
    iPadTagListViewController *ctrler = [[iPadTagListViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(180, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}

- (void) showTimer
{
    TimerManager *timer = [TimerManager getInstance];

    Task *task = [self getActiveTask];
    
    if (task.original != nil && ![task isREException])
    {
        task = task.original;
    }
    
    [[task retain] autorelease];
    
    [self deselect];
    
    if (task != nil && [task isTask])
    {
        if (![timer checkActivated:task])
        {
            timer.taskToActivate = task;
        }
        
        //[self deselect];
    }
    else
    {
        Settings *settings = [Settings getInstance];
        
        Task *todo = [[[Task alloc] init] autorelease];
        
        todo.project = settings.taskDefaultProject;
        todo.name = _newItemText;
        todo.listSource = SOURCE_TIMER;
        
        timer.taskToActivate = todo;
    }

    TimerViewController *ctrler = [[TimerViewController alloc] init];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
    
    [ctrler release];
    
    CGRect frm = CGRectMake(370, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];    
}

- (void) showMenu
{
    MenuTableViewController *ctrler = [[MenuTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
	[self.popoverCtrler setPopoverContentSize:CGSizeMake(250, 210)]; 
    
    [ctrler release];
    
    CGRect frm = CGRectMake(40, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) applyFilter
{
    [super applyFilter];
    
    [self hidePopover];
    
    [_iPadViewCtrler refreshFilterStatus];
}

#pragma mark Seek&Create
- (void) showSeekOrCreate:(NSString *)text
{
    if (self.popoverCtrler != nil && ![self.popoverCtrler isPopoverVisible])
    {
        [self.popoverCtrler dismissPopoverAnimated:YES];
        
        self.popoverCtrler = nil;
    }
    
    if (self.popoverCtrler != nil && [self.popoverCtrler.contentViewController isKindOfClass:[SeekOrCreateViewController class]])
    {
        if ([text isEqualToString:@""])
        {
            [self.popoverCtrler dismissPopoverAnimated:YES];
        }
        else
        {
            SeekOrCreateViewController *ctrler = (SeekOrCreateViewController *) self.popoverCtrler.contentViewController;
            
            [ctrler search:text];
        }
    }
    else if (![text isEqualToString:@""])
    {
        [self.popoverCtrler dismissPopoverAnimated:NO];
        
        SeekOrCreateViewController *ctrler = [[SeekOrCreateViewController alloc] init];
        
        [ctrler search:text];
        
        self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:ctrler] autorelease];
        [self.popoverCtrler setPopoverContentSize:CGSizeMake(320, 440)];
        
        [ctrler release];
        
        CGRect frm = CGRectMake(600, 0, 20, 10);
        
        [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void) createItem:(NSInteger)index title:(NSString *)title
{
    [self.popoverCtrler dismissPopoverAnimated:NO];
    
    Task *task = [[[Task alloc] init] autorelease];
    task.name = title;
    
    UIViewController *ctrler = nil;
    
    switch (index)
    {
        case 0:
        {
            task.type = TYPE_TASK;
            
            TaskManager *tm = [TaskManager getInstance];
            
            switch (tm.taskTypeFilter)
            {
                case TASK_FILTER_PINNED:
                {
                    task.status = TASK_STATUS_PINNED;
                }
                    break;
                case TASK_FILTER_DUE:
                {
                    task.deadline = [NSDate date];
                }
                    break;
            }
            
            TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
            taskCtrler.task = task;
            
            ctrler = taskCtrler;
        }
            break;
        case 1:
        {
            task.type = TYPE_EVENT;
            
            TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
            taskCtrler.task = task;
            
            ctrler = taskCtrler;
        }
            break;
        case 2:
        {
            task.type = TYPE_NOTE;
            task.listSource = SOURCE_NOTE;
            task.note = title;
            
            NoteDetailTableViewController *noteCtrler = [[NoteDetailTableViewController alloc] init];
            noteCtrler.note = task;
            
            ctrler = noteCtrler;
            
        }
            break;
    }
	
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    CGRect frm = CGRectMake(600, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

/*
- (void) editItem:(Task *)task inRect:(CGRect)inRect
{
    [self.popoverCtrler dismissPopoverAnimated:NO];
    
    UIViewController *ctrler = nil;
    
    if ([task isNote])
    {
        NoteDetailTableViewController *noteCtrler = [[NoteDetailTableViewController alloc] init];
        noteCtrler.note = task;
        
        ctrler = noteCtrler;
    }
    else
    {
        TaskDetailTableViewController *taskCtrler = [[TaskDetailTableViewController alloc] init];
        taskCtrler.task = task;
        
        ctrler = taskCtrler;
    }
    
	SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
	[ctrler release];
	
	self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
	
	[navController release];
    
    //CGRect frm = CGRectMake(600, 0, 20, 10);
    
    [self.popoverCtrler presentPopoverFromRect:inRect inView:contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
*/

#pragma mark Actions
- (void) expand:(id) sender
{
    /*
    if (activeView != nil)
    {
        [activeView doSelect:NO];
        
        activeView = nil;
    }
    */
    [self deselect];
    
    UIButton *button = (UIButton *)sender;
    
    button.selected = !button.selected;
    
    UIImageView *imgView = (UIImageView *) [button viewWithTag:21010];
    
    imgView.image = [UIImage imageNamed:button.selected?@"expand.png":@"collapse.png"];
    
    if (button.tag == 21000 && button.selected)
    {
        //expand task module -> hide quick add
        SmartListViewController *ctrler = [self getSmartListViewController];
        
        [ctrler hideQuickAdd];
    }
    
    [self resizeModules];
}

- (void) add:(id)sender
{
    UIButton *button = (UIButton *) sender;
    
    switch (button.tag)
    {
        case 22000:
            [self addTask];
            break;
        case 22001:
            [self addNote];
            break;
        case 22002:
            [self addProject];
            break;
    }
}

- (void) filter:(id) sender
{
    UIButton *button = (UIButton *) sender;
    
/*    if (!optionView.hidden)
    {
        [self hideDropDownMenu];
    }
*/
    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
    UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
    UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
    
    UIView *modules[3] = {taskHeaderView, noteHeaderView, projectHeaderView};
    
    UIView *moduleView = modules[button.tag - 23000];
    
    CGRect moduleFrm = [moduleView.superview convertRect:moduleView.frame toView:contentView];
    
    UIButton *expandedButton = (UIButton *) [moduleView viewWithTag:21000+button.tag-23000];
    
    if (optionView.tag != button.tag)
    {
        if ([optionView superview] != nil)
        {
            [optionView removeFromSuperview];
            
            optionView = nil;
        }

        if (expandedButton.selected)
        {
            switch (button.tag - 23000)
            {
                case 0:
                {
                    [self createTaskOptionView];
                }
                    break;
                case 1:
                {
                    [self createNoteOptionView];
                }
                    
                    break;
                case 2:
                {
                    [self createProjectOptionView];
                }
                    break;
            }
            
            CGRect frm = optionView.frame;
            
            frm.origin.x = moduleFrm.origin.x + moduleFrm.size.width - 60;
            frm.origin.y = moduleFrm.origin.y + moduleFrm.size.height;
            
            optionView.frame = frm;
            
            optionView.tag = button.tag;
            
            [self showOptionMenu];
            
            //optionView.tag = -1;
        }
    }
    else if (!optionView.hidden)
    {
        [self hideDropDownMenu];
    }
    else
    {
        CGRect frm = optionView.frame;
        
        frm.origin.x = moduleFrm.origin.x + moduleFrm.size.width - 60;
        frm.origin.y = moduleFrm.origin.y + moduleFrm.size.height;
        
        optionView.frame = frm;
        
        optionView.tag = button.tag;
        
        [self showOptionMenu];
    }
}

- (void) showDone:(id) sender
{
    projectShowDoneButton.selected = !projectShowDoneButton.selected;
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    ctrler.showDone = projectShowDoneButton.selected;
    
    [ctrler loadAndShowList];
}

- (void) startMultiEdit:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    int index = btn.tag - 25000;
    
    if (index == 0)
    {
        SmartListViewController *ctrler = [self getSmartListViewController];
        
        [ctrler multiEdit:YES];
    }
    else if (index == 1)
    {
        NoteViewController *ctrler = [self getNoteViewController];
        
        [ctrler multiEdit:YES];
    }
}

#pragma mark Filter
- (NSString *) showProjectWithOption:(id)sender
{
    NSString *title = [super showProjectWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24002];
    
    filterLabel.text = title;
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    projectShowDoneButton.hidden = (ctrler.filterType != TYPE_TASK);
    projectShowDoneButton.selected = ctrler.showDone;
    
    return title;
}

- (NSString *) showTaskWithOption:(id)sender
{
    NSString *title = [super showTaskWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    filterLabel.text = title;
    
    return title;
}

- (NSString *) showNoteWithOption:(id)sender
{
    NSString *title = [super showNoteWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24001];
    
    filterLabel.text = title;
    
    return title;
}

#pragma mark Filter Menu

- (void) showOptionMenu
{
    BOOL menuVisible = !optionView.hidden;
    
    //[self deselect];
    
    if (!menuVisible)
	{
		optionView.hidden = NO;
		[contentView  bringSubviewToFront:optionView];
		
		//[Common animateGrowViewFromPoint:CGPointMake(160,0) toPoint:CGPointMake(160, optionView.bounds.size.height/2) forView:optionView];
        [Common animateGrowViewFromPoint:optionView.frame.origin toPoint:CGPointMake(optionView.frame.origin.x, optionView.frame.origin.y + optionView.bounds.size.height/2) forView:optionView];
	}
}

-(void) createTaskOptionView
{
	optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
    UIImageView *allImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	allImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_all.png"];
	[optionView addSubview:allImageView];
	[allImageView release];
	
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	allLabel.text = _allText;
	allLabel.textColor = [UIColor whiteColor];
	allLabel.backgroundColor = [UIColor clearColor];
	allLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:allLabel];
	[allLabel release];
	
	UIButton *allButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 22, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showTaskWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	allButton.titleLabel.font=[UIFont systemFontOfSize:18];
	allButton.tag = TASK_FILTER_ALL;
	[optionView addSubview:allButton];
    
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	starImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_star.png"];
	[optionView addSubview:starImageView];
	[starImageView release];
	
    UILabel *starLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	starLabel.text = _starText;
	starLabel.textColor = [UIColor whiteColor];
	starLabel.backgroundColor = [UIColor clearColor];
	starLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:starLabel];
	[starLabel release];
	
	UIButton *starButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 57, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	starButton.titleLabel.font=[UIFont systemFontOfSize:18];
    starButton.tag = TASK_FILTER_PINNED;
	[optionView addSubview:starButton];
    
    UIImageView *gtdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	gtdImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_gtd.png"];
	[optionView addSubview:gtdImageView];
	[gtdImageView release];
	
	UILabel *gtdLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	gtdLabel.text = _gtdoText;
	gtdLabel.textColor = [UIColor whiteColor];
	gtdLabel.backgroundColor = [UIColor clearColor];
	gtdLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:gtdLabel];
	[gtdLabel release];
	
	UIButton *gtdButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 92, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showTaskWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	gtdButton.titleLabel.font=[UIFont systemFontOfSize:18];
    gtdButton.tag = TASK_FILTER_TOP;
	[optionView addSubview:gtdButton];
    
    UIImageView *dueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 130, 20, 20)];
	dueImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_due.png"];
	[optionView addSubview:dueImageView];
	[dueImageView release];
	
	UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	dueLabel.text = _dueText;
	dueLabel.textColor = [UIColor whiteColor];
	dueLabel.backgroundColor = [UIColor clearColor];
	dueLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:dueLabel];
	[dueLabel release];
	
	UIButton *dueButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 127, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showTaskWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	dueButton.titleLabel.font=[UIFont systemFontOfSize:18];
    dueButton.tag = TASK_FILTER_DUE;
	[optionView addSubview:dueButton];
    
    UIImageView *startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 165, 20, 20)];
	startImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_start.png"];
	[optionView addSubview:startImageView];
	[startImageView release];
	
	UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 162, 120, 25)];
	startLabel.text = _startText;
	startLabel.textColor = [UIColor whiteColor];
	startLabel.backgroundColor = [UIColor clearColor];
	startLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:startLabel];
	[startLabel release];
	
	UIButton *startButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 162, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showTaskWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	startButton.titleLabel.font=[UIFont systemFontOfSize:18];
    startButton.tag = TASK_FILTER_ACTIVE;
	[optionView addSubview:startButton];
    
    UIImageView *doneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 200, 20, 20)];
	doneImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_done.png"];
	[optionView addSubview:doneImageView];
	[doneImageView release];
	
	UILabel *doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 197, 120, 25)];
	doneLabel.text = _doneText;
	doneLabel.textColor = [UIColor whiteColor];
	doneLabel.backgroundColor = [UIColor clearColor];
	doneLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:doneLabel];
	[doneLabel release];
	
	UIButton *doneButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 197, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showTaskWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	doneButton.titleLabel.font=[UIFont systemFontOfSize:18];
    doneButton.tag = TASK_FILTER_DONE;
	[optionView addSubview:doneButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    
    [menu release];
}

-(void) createNoteOptionView
{
	optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
    UIImageView *allImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	allImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_all.png"];
	[optionView addSubview:allImageView];
	[allImageView release];
	
    UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	allLabel.text = _allText;
	allLabel.textColor = [UIColor whiteColor];
	allLabel.backgroundColor = [UIColor clearColor];
	allLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:allLabel];
	[allLabel release];
	
	UIButton *allButton=[Common createButton:@""
                                  buttonType:UIButtonTypeCustom
                                       frame:CGRectMake(0, 22, 160, 30)
                                  titleColor:nil
                                      target:self
                                    selector:@selector(showNoteWithOption:)
                            normalStateImage:nil
                          selectedStateImage:nil];
	allButton.titleLabel.font=[UIFont systemFontOfSize:18];
	allButton.tag = NOTE_FILTER_ALL;
	[optionView addSubview:allButton];
    
    UIImageView *todayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	todayImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_day.png"];
	[optionView addSubview:todayImageView];
	[todayImageView release];
	
    UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	//todayLabel.text = _todayText;
    todayLabel.text = _currentText;
	todayLabel.textColor = [UIColor whiteColor];
	todayLabel.backgroundColor = [UIColor clearColor];
	todayLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:todayLabel];
	[todayLabel release];
	
	UIButton *todayButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 57, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showNoteWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	todayButton.titleLabel.font=[UIFont systemFontOfSize:18];
    todayButton.tag = NOTE_FILTER_CURRENT;
	[optionView addSubview:todayButton];
    
    UIImageView *weekImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	weekImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_week.png"];
	[optionView addSubview:weekImageView];
	[weekImageView release];
	
    UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
    weekLabel.text = _thisWeekText;
	weekLabel.textColor = [UIColor whiteColor];
	weekLabel.backgroundColor = [UIColor clearColor];
	weekLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:weekLabel];
	[weekLabel release];
	
	UIButton *weekButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 92, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showNoteWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	weekButton.titleLabel.font=[UIFont systemFontOfSize:18];
    weekButton.tag = NOTE_FILTER_WEEK;
	[optionView addSubview:weekButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
}

-(void) createProjectOptionView
{
	optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 120, 140)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
	optionImageView.alpha = 0.9;
	[optionView addSubview:optionImageView];
	[optionImageView release];
    
	//UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
    UIImageView *taskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
	taskImageView.image = [[ImageManager getInstance] getImageWithName:@"newTask.png"];
	[optionView addSubview:taskImageView];
	[taskImageView release];
	
	//UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
	taskLabel.text = _tasksText;
	taskLabel.textColor = [UIColor whiteColor];
	taskLabel.backgroundColor = [UIColor clearColor];
	taskLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:taskLabel];
	[taskLabel release];
	
	UIButton *taskButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                          //frame:CGRectMake(0, 57, 160, 30)
                                        frame:CGRectMake(0, 22, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showProjectWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	taskButton.titleLabel.font=[UIFont systemFontOfSize:18];
	taskButton.tag = 0;
	[optionView addSubview:taskButton];
    
	//UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 25, 20, 20)];
    UIImageView *eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, 20, 20)];
	eventImageView.image = [[ImageManager getInstance] getImageWithName:@"newEvent.png"];
	[optionView addSubview:eventImageView];
	[eventImageView release];
	
	//UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, 120, 25)];
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	eventLabel.text = _eventsText;
	eventLabel.textColor = [UIColor whiteColor];
	eventLabel.backgroundColor = [UIColor clearColor];
	eventLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:eventLabel];
	[eventLabel release];
	
	UIButton *eventButton=[Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                           //frame:CGRectMake(0, 22, 160, 30)
                                         frame:CGRectMake(0, 57, 160, 30)
                                    titleColor:nil
                                        target:self
                                      selector:@selector(showProjectWithOption:)
                              normalStateImage:nil
                            selectedStateImage:nil];
	eventButton.titleLabel.font=[UIFont systemFontOfSize:18];
    eventButton.tag = 1;
	[optionView addSubview:eventButton];
    
    UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 95, 20, 20)];
	noteImageView.image = [[ImageManager getInstance] getImageWithName:@"newNote.png"];
	[optionView addSubview:noteImageView];
	[noteImageView release];
	
	UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 92, 120, 25)];
	noteLabel.text = _notesText;
	noteLabel.textColor = [UIColor whiteColor];
	noteLabel.backgroundColor = [UIColor clearColor];
	noteLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:noteLabel];
	[noteLabel release];
	
	UIButton *noteButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 92, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showProjectWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	noteButton.titleLabel.font=[UIFont systemFontOfSize:18];
    noteButton.tag = 2;
	[optionView addSubview:noteButton];
    
    MenuMakerView *menu = [[MenuMakerView alloc] initWithFrame:optionView.bounds];
    menu.menuPoint = menu.bounds.size.width/2;
    
    optionImageView.image = [Common takeSnapshot:menu size:menu.bounds.size];
    [menu release];
}

#pragma mark View

- (void) loadView
{
    CGRect frm = [Common getFrame];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    //contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    contentView.backgroundColor = [UIColor clearColor];
    
    self.view = contentView;

    CGFloat w = frm.size.width/2-10;
    
    UIImageView *leftDecoView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, w, frm.size.height-10)];
    leftDecoView.image = [UIImage imageNamed:@"module_bg.png"];
    //leftDecoView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    [contentView addSubview:leftDecoView];
    [leftDecoView release];

    UIImageView *rightDecoView = [[UIImageView alloc] initWithFrame:CGRectMake(w+15, 5, w, frm.size.height-10)];
    //rightDecoView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    rightDecoView.image = [UIImage imageNamed:@"module_bg.png"];
    [contentView addSubview:rightDecoView];
    [rightDecoView release];

    CalendarViewController *ctrler = [self getCalendarViewController];
    
    [ctrler changeFrame:CGRectMake(5, 10, w-5, frm.size.height-20)];
    
    [contentView addSubview:ctrler.view];
    
	//miniMonthView = [[MiniMonthView alloc] initWithFrame:CGRectMake(10, 10, _isiPad?48*7+MINI_MONTH_WEEK_HEADER_WIDTH:46*7, 48 + MINI_MONTH_HEADER_HEIGHT + 6)];

	miniMonthView = [[MiniMonthView alloc] initWithFrame:CGRectMake(10, 10, _isiPad?48*7+MINI_MONTH_WEEK_HEADER_WIDTH:46*7, 48 + MINI_MONTH_HEADER_HEIGHT)];
	
	[contentView addSubview:miniMonthView];
	[miniMonthView release];
    
    //[miniMonthView.headerView changeMWMode:0];
    
    focusView = [[FocusView alloc] initWithFrame:_isiPad?CGRectMake(10, miniMonthView.bounds.origin.y + miniMonthView.bounds.size.height, w-10, 40):CGRectZero];
    focusView.hidden = !_isiPad;
    
    [contentView addSubview:focusView];
    [focusView release];

    NSString *titles[3] = {_tasksText, _notesText, _projectsText};
    NSString *filters[3] = {_allText, _allText, _tasksText};
    
    for (int i=0; i<3; i++)
    {
        UIView *moduleBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        moduleBorderView.layer.borderWidth = 1;
        moduleBorderView.layer.cornerRadius = 5;
        moduleBorderView.layer.borderColor = [[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1] CGColor];
        moduleBorderView.tag = 18000+i;
        
        [contentView addSubview:moduleBorderView];
        [moduleBorderView release];
        
        
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(w+20, 10 + 50*i, w-10, 40)];
        headerImageView.image = [UIImage imageNamed:@"module_header.png"];
        headerImageView.tag = 19000+i;
        
        [contentView addSubview:headerImageView];
        [headerImageView release];
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(w+20, 10 + 50*i, w-10, 40)];
        //headView.backgroundColor = [UIColor darkGrayColor];
        headView.backgroundColor = [UIColor clearColor];
        headView.tag = 20000+i;
        
        [contentView addSubview:headView];
        [headView release];
        
        UIButton *expandButton = [Common createButton:@""
                                               buttonType:UIButtonTypeCustom
                                                    frame:CGRectMake(0, 0, 40, 40)
                                               titleColor:[UIColor whiteColor]
                                                   target:self
                                                 selector:@selector(expand:)
                                         normalStateImage:nil
                                       selectedStateImage:nil];
        expandButton.tag = 21000+i;
        
        [headView addSubview:expandButton];
        
        UIImageView *expandImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
        expandImgView.tag = 21010;
        
        expandImgView.image = [UIImage imageNamed:@"collapse.png"];
        
        [expandButton addSubview:expandImgView];
        [expandImgView release];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 100, 25)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = titles[i];
        
        [headView addSubview:label];
        [label release];
        
        UIButton *addButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(headView.bounds.size.width-35, 5, 30, 30)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(add:)
                                     normalStateImage:@"module_add.png"
                                   selectedStateImage:nil];
        addButton.tag = 22000+i;
        
        [headView addSubview:addButton];
        
        UIButton *filterButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(headView.bounds.size.width-70, 5, 30, 30)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(filter:)
                                     normalStateImage:nil
                                   selectedStateImage:nil];
        filterButton.tag = 23000+i;
        [headView addSubview:filterButton];
        
        
        UIImageView *filterImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
        
        filterImgView.image = [UIImage imageNamed:@"arrow_down.png"];
        
        [filterButton addSubview:filterImgView];
        [filterImgView release];
        
        UIView *filterSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(headView.bounds.size.width-70, 5, 1, 30)];
        filterSeparatorView.backgroundColor = [UIColor whiteColor];
        
        [headView addSubview:filterSeparatorView];
        [filterSeparatorView release];
        
        UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(headView.bounds.size.width-180, 5, 100, 30)];
        filterLabel.backgroundColor = [UIColor clearColor];
        filterLabel.textAlignment =  NSTextAlignmentRight;
        filterLabel.textColor = [UIColor whiteColor];
        filterLabel.font = [UIFont boldSystemFontOfSize:16];
        filterLabel.tag = 24000+i;
        filterLabel.text = filters[i];
        
        [headView addSubview:filterLabel];
        [filterLabel release];
        
        if (i==0 || i==1)
        {
            UIButton *taskMultiEditButton = [Common createButton:@"Edit"
                                              buttonType:UIButtonTypeCustom
                                                   frame:CGRectMake(160, 10, 60, 20)
                                              titleColor:[UIColor whiteColor]
                                                  target:self
                                                selector:@selector(startMultiEdit:)
                                        normalStateImage:nil
                                      selectedStateImage:nil];
            taskMultiEditButton.tag = 25000+i;
            taskMultiEditButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            
            [headView addSubview:taskMultiEditButton];
        }
        else if (i==2)
        {
            projectShowDoneButton = [Common createButton:@""
                                               buttonType:UIButtonTypeCustom
                                                    frame:CGRectMake(180, 10, 20, 20)
                                               titleColor:[UIColor whiteColor]
                                                   target:self
                                                 selector:@selector(showDone:)
                                         normalStateImage:@"module_hidedone.png"
                                       selectedStateImage:@"module_showdone.png"];
            
            CategoryViewController *ctrler = [self getCategoryViewController];
            projectShowDoneButton.selected = ctrler.showDone;
            
            [headView addSubview:projectShowDoneButton];
        }
        
    }
    
    for (int i=1;i<4;i++)
    {
        UIView *view = viewCtrlers[i].view;
        
        view.frame = CGRectZero;
        view.clipsToBounds = YES;

        [contentView addSubview:view];
    }
}

- (void) showTaskModule:(BOOL)enabled
{
    SmartListViewController *ctrler = [self getSmartListViewController];
    
    UIView *view = ctrler.view;
    
    if (!enabled)
    {
        if (view.superview != nil)
        {
            //[ctrler clearLayout];
            
            [view removeFromSuperview];
        }
    }
    else if (view.superview != contentView)
    {
        if (view.superview != nil)
        {
            //[ctrler clearLayout];
            
            [view removeFromSuperview];
        }
        
        view.frame = CGRectZero;
        view.clipsToBounds = YES;
        
        [contentView addSubview:view];
        
        UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
        UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
        UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
        
        UIButton *taskModuleButton = (UIButton *)[taskHeaderView viewWithTag:21000];
        UIButton *noteModuleButton = (UIButton *)[noteHeaderView viewWithTag:21001];
        UIButton *projectModuleButton = (UIButton *)[projectHeaderView viewWithTag:21002];
        
        UIButton *buttons[3] = {taskModuleButton, noteModuleButton, projectModuleButton};
        
        NSInteger expandNum = 0;
        
        for (int i=0; i<3; i++)
        {
            if (buttons[i].selected)
            {
                expandNum += 1;
            }
        }
        
        NSInteger moduleHeight = (expandNum == 0?0:(contentView.bounds.size.height-160)/expandNum);
        
        CGFloat w = contentView.bounds.size.width/2 - 10;
        
        CGRect frm = !taskModuleButton.selected?CGRectMake(w+20, 0, w-10, 0):CGRectMake(w+20, 50, w-10, moduleHeight);
        
        [ctrler resetMovableController:NO];
        
        [ctrler setMovableContentView:self.contentView];
        
        [ctrler changeFrame:frm];
        
        [ctrler performSelector:@selector(refreshLayout) withObject:nil afterDelay:0.1];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deselect];
}

/*
-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        PlannerViewController *ctrler = [[PlannerViewController alloc] init];
        
        [self presentViewController:ctrler animated:YES completion:NULL];
    }
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
