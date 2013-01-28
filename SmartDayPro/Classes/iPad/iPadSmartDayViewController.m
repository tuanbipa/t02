//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "iPadSmartDayViewController.h"

#import "Common.h"
#import "Task.h"

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

#import "SDNavigationController.h"

#import "PlannerViewController.h"

extern BOOL _isiPad;

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

- (void) hidePopover
{
	if (self.popoverCtrler != nil && [self.popoverCtrler isPopoverVisible])
	{
		[self.popoverCtrler dismissPopoverAnimated:NO];
	}
	
}

- (void) resizeModules
{
    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
    UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
    UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
    
    UIView *headerViews[3] = {taskHeaderView, noteHeaderView, projectHeaderView};
    
    UIButton *taskModuleButton = (UIButton *)[taskHeaderView viewWithTag:21000];
    UIButton *noteModuleButton = (UIButton *)[noteHeaderView viewWithTag:21000];
    UIButton *projectModuleButton = (UIButton *)[projectHeaderView viewWithTag:21000];
    
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
        UIView *headerView = headerViews[i];
        
        headerView.frame = CGRectMake(w+20, y, w-10, 40);
        
        y += 40;
        
        CGRect frm = !buttons[i].selected?CGRectZero:CGRectMake(w+20, y, w-10, moduleHeight);
        
        [viewCtrlers[i+1] changeFrame:frm];
        
        y += frm.size.height + 10;
        
        if (i>=1)
        {
            [viewCtrlers[i+1] loadAndShowList];
        }
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

- (void) addTask
{
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
    Task *task = [[[Task alloc] init] autorelease];
	
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
    [super enableActions:enable onView:view];
    
    PreviewViewController *ctrler = [[PreviewViewController alloc] init];
    ctrler.item = view.task;
    
    SDNavigationController *navController = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    [ctrler release];
    
    self.popoverCtrler = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
    
    [navController release];
    
    CGRect frm = [view.superview convertRect:view.frame toView:contentView];
    
    [self.popoverCtrler presentPopoverFromRect:frm inView:contentView permittedArrowDirections:view.task.listSource == SOURCE_CALENDAR || view.task.listSource == SOURCE_FOCUS?UIPopoverArrowDirectionLeft:UIPopoverArrowDirectionRight animated:YES];
}

- (void) scrollToDate:(NSDate *)date
{
    [super scrollToDate:date];
    
    [self.focusView refreshData];
}

- (void) deselect
{
    [super deselect];
    
    if (self.popoverCtrler != nil)
    {
        [self.popoverCtrler dismissPopoverAnimated:YES];
        
        self.popoverCtrler = nil;
    }
}

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
    
    UIImageView *imgView = (UIImageView *) [button viewWithTag:21001];
    
    imgView.image = [UIImage imageNamed:button.selected?@"expand.png":@"collapse.png"];
    
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
    
    if (!optionView.hidden)
    {
        [self hideDropDownMenu];
    }
    
    if ([optionView superview] != nil)
    {
        [optionView removeFromSuperview];
    }
    
    if (optionView.tag != button.tag)
    {
        UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
        UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
        UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
        
        UIView *modules[3] = {taskHeaderView, noteHeaderView, projectHeaderView};
        
        UIView *moduleView = modules[button.tag - 23000];
        
        CGRect moduleFrm = [moduleView.superview convertRect:moduleView.frame toView:contentView];
        
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
    }
    
    optionView.tag = -1;
}

#pragma mark Filter
- (NSString *) showProjectWithOption:(id)sender
{
    NSString *title = [super showProjectWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24002];
    
    filterLabel.text = title;
    
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
	optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 100)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 100)];
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
	todayImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_today.png"];
	[optionView addSubview:todayImageView];
	[todayImageView release];
	
    UILabel *todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 57, 120, 25)];
	todayLabel.text = _todayText;
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
    todayButton.tag = NOTE_FILTER_TODAY;
	[optionView addSubview:todayButton];
    
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
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    self.view = contentView;

    CGFloat w = frm.size.width/2-10;
    
    UIView *leftDecoView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, w, frm.size.height-10)];
    leftDecoView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    [contentView addSubview:leftDecoView];
    [leftDecoView release];

    UIView *rightDecoView = [[UIView alloc] initWithFrame:CGRectMake(w+15, 5, w, frm.size.height-10)];
    rightDecoView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    [contentView addSubview:rightDecoView];
    [rightDecoView release];

    CalendarViewController *ctrler = [self getCalendarViewController];
    
    [ctrler changeFrame:CGRectMake(5, 0, w-5, frm.size.height)];
    
    [contentView addSubview:ctrler.view];
    
	miniMonthView = [[MiniMonthView alloc] initWithFrame:CGRectMake(10, 10, _isiPad?48*7+MINI_MONTH_WEEK_HEADER_WIDTH:46*7, 48 + MINI_MONTH_HEADER_HEIGHT + 6)];
	
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
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(w+20, 10 + 50*i, w-10, 40)];
        headView.backgroundColor = [UIColor darkGrayColor];
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
        expandButton.tag = 21000;
        
        [headView addSubview:expandButton];
        
        UIImageView *expandImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
        expandImgView.tag = 21001;
        
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
        filterSeparatorView.backgroundColor = [UIColor lightGrayColor];
        
        [headView addSubview:filterSeparatorView];
        [filterSeparatorView release];
        
        UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(headView.bounds.size.width-180, 5, 100, 30)];
        filterLabel.backgroundColor = [UIColor clearColor];
        filterLabel.textAlignment =  NSTextAlignmentRight;
        filterLabel.textColor = [UIColor lightGrayColor];
        filterLabel.font = [UIFont boldSystemFontOfSize:16];
        filterLabel.tag = 24000+i;
        filterLabel.text = filters[i];
        
        [headView addSubview:filterLabel];
        [filterLabel release];
        
    }
    
    for (int i=1;i<4;i++)
    {
        UIView *view = viewCtrlers[i].view;
        
        view.frame = CGRectZero;
        view.clipsToBounds = YES;
        
        [contentView addSubview:view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
