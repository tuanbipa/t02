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

//extern BOOL _isiPad;

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
        selectedModuleButton = nil;
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
    /*
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
    
    return NO;*/
    
    if (index == 0)
    {
        return YES;
    }
    
    if (selectedModuleButton != nil && (selectedModuleButton.tag-31000+1) == index)
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
        
        UIView *actionView = (UIButton *)[headerViews[i] viewWithTag:30000+i];
        
        actionView.hidden = !buttons[i].selected;
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
        
        if (i==0)
        {
            //tasks module
            [viewCtrlers[i+1] refreshLayout];
        }
        else if (i != 0)
        {
            [viewCtrlers[i+1] loadAndShowList];
        }
        
    }
}

- (void) addTask
{
    [[self getSmartListViewController] cancelQuickAdd];
    
	TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
    
    Task *task = [[[Task alloc] init] autorelease];
    
    TaskManager *tm = [TaskManager getInstance];
    Settings *settings = [Settings getInstance];
    
    task.startTime = [settings getWorkingStartTimeForDate:tm.today];
    
	switch (tm.taskTypeFilter)
	{
		case TASK_FILTER_STAR:
		{
			task.status = TASK_STATUS_PINNED;
		}
			break;
		case TASK_FILTER_DUE:
		{
			task.deadline = [settings getWorkingEndTimeForDate:tm.today];
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
    
    TaskManager *tm = [TaskManager getInstance];
    
    Task *note = [[[Task alloc] init] autorelease];
    note.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
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

- (void) applyFilter
{
    [super applyFilter];
    
    [self hidePopover];
    
    [_iPadViewCtrler refreshFilterStatus];
}

#pragma mark Actions
- (void) expand:(id) sender
{
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

    UIView *taskHeaderView = (UIView *)[contentView viewWithTag:20000];
    UIView *noteHeaderView = (UIView *)[contentView viewWithTag:20001];
    UIView *projectHeaderView = (UIView *)[contentView viewWithTag:20002];
    
    UIView *modules[3] = {taskHeaderView, noteHeaderView, projectHeaderView};
    
    //UIView *moduleView = modules[button.tag - 23000];
    UIView *moduleView = (UIView *)[contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    CGRect moduleFrm = [moduleView.superview convertRect:moduleView.frame toView:contentView];
    
    //UIButton *expandedButton = (UIButton *) [moduleView viewWithTag:21000+button.tag-23000];
    UIButton *expandedButton = (UIButton *) [moduleView viewWithTag:21000+button.tag-23000];
    
    //if (optionView.tag != button.tag)
    if (optionView.tag != selectedModuleButton.tag)
    {
        if ([optionView superview] != nil)
        {
            [optionView removeFromSuperview];
            
            optionView = nil;
        }

        //if (expandedButton.selected)
        {
            //switch (button.tag - 23000)
            switch (selectedModuleButton.tag - 31000)
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
    [self deselect];
    
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

- (void) showModuleOff
{
    if (selectedModuleButton != nil)
    {
        UIView *moduleView = [contentView viewWithTag:33000];
        
        if (selectedModuleButton != nil)
        {
            [[moduleView.subviews lastObject] removeFromSuperview];
        }
        
        selectedModuleButton.selected = NO;
        
        //selectedModuleButton.backgroundColor = [UIColor grayColor];

        selectedModuleButton = nil;
    }
}

- (void) showModuleByIndex:(NSInteger)index
{
    //index: 0-Task, 1-Note, 2-Project
    UIButton *button = (UIButton *) [contentView viewWithTag:31000+index];
    
    if (selectedModuleButton != nil)
    {
        UIView *moduleView = [contentView viewWithTag:33000];
        [[moduleView.subviews lastObject] removeFromSuperview];
        
        selectedModuleButton = nil;
    }
    
    [self showModule:button];
    
    PageAbstractViewController *ctrler = [self getModuleAtIndex:index+1];
    
    [ctrler refreshLayout];
}

- (void) showTaskModule
{
    /*
    UIButton *taskButton = (UIButton *) [contentView viewWithTag:31000];
    
    [self showModule:taskButton];
    
    [[self getSmartListViewController] refreshLayout];
    */
    
    [self showModuleByIndex:0];
}

- (void) showModule:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (selectedModuleButton != btn)
    {
        UIView *moduleView = [contentView viewWithTag:33000];
        
        if (selectedModuleButton != nil)
        {
            [[moduleView.subviews lastObject] removeFromSuperview];
        }
        
        _iPadViewCtrler.selectedModuleIndex = btn.tag - 31000;
        
        //PageAbstractViewController *ctrler = viewCtrlers[_iPadViewCtrler.selectedModuleIndex + 1];
        
        PageAbstractViewController *ctrler = [self getModuleAtIndex:_iPadViewCtrler.selectedModuleIndex + 1];
        
        [ctrler changeFrame:moduleView.bounds];
        
        [moduleView addSubview:ctrler.view];
        
        selectedModuleButton.selected = NO;
        
        //selectedModuleButton.backgroundColor = [UIColor grayColor];
        
        selectedModuleButton = btn;
        
        selectedModuleButton.selected = YES;
        
        //selectedModuleButton.backgroundColor = [UIColor cyanColor];
        
        [self refreshHeaderView];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChangeNotification" object:nil]; //refresh Detail view in sliding mode

    }
}

/*
- (void)multiMarkDone: (id) sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiDone:sender];
}

- (void)multiMoveTop: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiMoveTop:sender];
}

- (void)multiDefer: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiDefer:sender];
}

- (void)multiMarkStar: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr multiMarkStar:sender];
}

- (void)multiDelete: (id) sender
{
    switch (selectedModuleButton.tag - 31000) {
        case 0:
        {
            SmartListViewController *ctrlr = [self getSmartListViewController];
            [ctrlr multiDelete: sender];
        }
            break;
            
        case 1:
        {
            NoteViewController *ctrlr = [self getNoteViewController];
            [ctrlr multiDelete: sender];
        }
            break;
            
        case 2:
        {
            CategoryViewController *ctrlr = [self getCategoryViewController];
            [ctrlr multiDelete:sender];
        }
            break;
    }
}

- (void)createLink: (id)sender
{
    SmartListViewController *ctrlr = [self getSmartListViewController];
    [ctrlr createLink:sender];
    [self cancelEdit];
}
*/

#pragma mark Filter
- (NSString *) showProjectWithOption:(id)sender
{
    
    /*NSString *title = [super showProjectWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24002];
    
    filterLabel.text = title;
    
    CategoryViewController *ctrler = [self getCategoryViewController];
    
    projectShowDoneButton.hidden = (ctrler.filterType != TYPE_TASK);
    projectShowDoneButton.selected = ctrler.showDone;*/
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    segmented.tag = segmented.selectedSegmentIndex;
    [super showProjectWithOption:segmented];
    
    return title;
}

- (NSString *) showTaskWithOption:(id)sender
{
    /*NSString *title = [super showTaskWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24000];
    
    filterLabel.text = title;*/
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    switch (segmented.selectedSegmentIndex) {
        case 0:
            segmented.tag = TASK_FILTER_ALL;
            break;
            
        case 1:
            segmented.tag = TASK_FILTER_STAR;
            break;
            
        case 2:
            segmented.tag = TASK_FILTER_TOP;
            break;
            
        case 3:
            segmented.tag = TASK_FILTER_DUE;
            break;
            
        case 4:
            //segmented.tag = TASK_FILTER_ACTIVE;
            segmented.tag = TASK_FILTER_LONG;
            break;
            
        case 5:
            //segmented.tag = TASK_FILTER_DONE;
            segmented.tag = TASK_FILTER_SHORT;
            break;
            
        default:
            break;
    }
    [super showTaskWithOption:segmented];
    
    return title;
}

- (NSString *) showNoteWithOption:(id)sender
{
    /*NSString *title = [super showNoteWithOption:sender];
    
    UILabel *filterLabel = (UILabel *)[contentView viewWithTag:24001];
    
    filterLabel.text = title;*/
    
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    NSString *title = [segmented titleForSegmentAtIndex:segmented.selectedSegmentIndex];
    
    switch (segmented.selectedSegmentIndex) {
        case 0:
            segmented.tag = NOTE_FILTER_ALL;
            break;
            
        case 1:
            segmented.tag = NOTE_FILTER_CURRENT;
            break;
            
        case 2:
            segmented.tag = NOTE_FILTER_WEEK;
            break;
    }
    [super showNoteWithOption:segmented];
    
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

- (void)createTaskOptionFilter
{
    UIView *headerView = (UIView *)[contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    NSArray *itemArray = [NSArray arrayWithObjects: _allText, _starText, _gtdoText, _dueText, _longText, _shortText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = headerView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (headerView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    // customizing appearance
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIColor grayColor], UITextAttributeTextColor,
                                          //[UIColor blackColor], UITextAttributeTextShadowColor,
                                          //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                          nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showTaskWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    NSString *title = [[TaskManager getInstance] getFilterTitle];
    for (int i = 0; i < filterSegmentedControl.numberOfSegments; i++) {
        NSString *segmentText = [filterSegmentedControl titleForSegmentAtIndex:i];
        if (title == segmentText) {
            filterSegmentedControl.selectedSegmentIndex = i;
            break;
        }
    }
    
    [headerView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
    
    // create edit bar
    UIView *editBarView = [[UIView alloc] initWithFrame:headerView.bounds];
    editBarView.tag = TAG_VIEW_EDIT_BAR;
    editBarView.hidden = YES;
    [headerView addSubview:editBarView];
    
    /*UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_PAD, 0, 10, editBarView.frame.size.height)];
    countLabel.tag = TAG_VIEW_COUNT_LABEL;
    countLabel.text = @"0";
    countLabel.hidden = YES;
    [editBarView addSubview:countLabel];

    [countLabel release];*/
    selectedCounter = 0;

    /*UILabel *selectedLable = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x + countLabel.frame.size.width + SPACE_PAD, 0, 70, editBarView.frame.size.height)];
    selectedLable.text = _selectedText;
    [editBarView addSubview:selectedLable];*/
    
    CGFloat width = editBarView.frame.size.width/6;
    CGFloat space = (width - 30) / 2;
    
    // 1, done button
    UIButton *doneButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(space, 5, 30, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(multiMarkDone:)
                               normalStateImage:@"menu_done.png"
                             selectedStateImage:nil];
    [editBarView addSubview:doneButton];
    
    // 2, move top button
    UIButton *moveTopButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(width + space, 5, 30, 30)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                          selector:@selector(multiMoveTop:)
                               normalStateImage:@"menu_dotoday.png"
                             selectedStateImage:nil];
    [editBarView addSubview:moveTopButton];
    
    // 3, defer button
    UIButton *deferButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(width*2 + space, 5, 30, 30)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(multiDefer:)
                                  normalStateImage:@"menu_defer.png"
                                selectedStateImage:nil];
    [editBarView addSubview:deferButton];
    
    // 4, mark star button
    UIButton *markStarButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(width*3 + space, 5, 30, 30)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(multiMarkStar:)
                                normalStateImage:@"menu_star.png"
                              selectedStateImage:nil];
    [editBarView addSubview:markStarButton];
    
    // 5, copy link button
    UIButton *copyLinkButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(width*4 + space, 5, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(createLink:)
                                   normalStateImage:@"menu_copylink.png"
                                 selectedStateImage:nil];
    [copyLinkButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"menu_copylink_idle.png"] forState:UIControlStateDisabled];
    copyLinkButton.tag = TAG_VIEW_COPY_BUTTON;
    [editBarView addSubview:copyLinkButton];
    
    // 6 paste link button
    /*UIButton *pasteLinkButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(width*5 + space, 5, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(multiMarkDone:)
                                   normalStateImage:@"menu_pastelink.png"
                                 selectedStateImage:nil];
    [editBarView addSubview:pasteLinkButton];*/
    
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(width*5 + space, 5, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(multiDelete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    [editBarView addSubview:deleteButton];
    
    [editBarView release];
    
    // check show edit bar or filter view
    //SmartListViewController *ctrler = [self getSmartListViewController];
    //filterSegmentedControl.hidden = ctrler.isMultiMode;
    //editBarView.hidden = !ctrler.isMultiMode;
}

- (void) createNoteOptionFilter
{
    UIView *headerView = (UIView *)[contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    NSArray *itemArray = [NSArray arrayWithObjects: _allText, _selectedText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = headerView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (headerView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor grayColor], UITextAttributeTextColor,
                                                    //[UIColor blackColor], UITextAttributeTextShadowColor,
                                                    //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showNoteWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    NoteViewController *ctrler = [self getNoteViewController];
    filterSegmentedControl.selectedSegmentIndex = ctrler.filterType;
    
    [headerView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
    
    // create edit bar ========================
    UIView *editBarView = [[UIView alloc] initWithFrame:headerView.bounds];
    editBarView.tag = TAG_VIEW_EDIT_BAR;
    editBarView.hidden = YES;
    [headerView addSubview:editBarView];
    
    // count label
    /*UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_PAD, 0, 10, editBarView.frame.size.height)];
    countLabel.tag = TAG_VIEW_COUNT_LABEL;
    countLabel.text = @"0";
    countLabel.hidden = YES;
    [editBarView addSubview:countLabel];
    
    [countLabel release];*/
    selectedCounter = 0;
    
    // delete button
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(editBarView.frame.size.width - 30 - SPACE_PAD, 5, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(multiDelete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    [editBarView addSubview:deleteButton];
    
    [editBarView release];
}

- (void)createProjectOptionFilter
{
    UIView *headerView = (UIView *)[contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    NSArray *itemArray = [NSArray arrayWithObjects: _tasksText, _eventsText, _notesText, _anchoredText, nil];
    
    filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    CGRect frm = headerView.bounds;
    frm.size.height -= 10;
    frm.origin.y = (headerView.frame.size.height - frm.size.height)/2;
    filterSegmentedControl.frame = frm;
    
    filterSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    filterSegmentedControl.selectedSegmentIndex = 0;
    filterSegmentedControl.tintColor = [UIColor colorWithRed:237.0/250 green:237.0/250 blue:237.0/250 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIColor grayColor], UITextAttributeTextColor,
                                                    //[UIColor blackColor], UITextAttributeTextShadowColor,
                                                    //[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    UIColor *selectedColor = [UIColor colorWithRed:5.0/255 green:80.0/255 blue:185.0/255 alpha:1];
    [filterSegmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    selectedColor, UITextAttributeTextColor,
                                                    nil] forState:UIControlStateSelected];
    
    [filterSegmentedControl addTarget:self action:@selector(showProjectWithOption:) forControlEvents:UIControlEventValueChanged];
    
    // set selected
    CategoryViewController *ctrler = [self getCategoryViewController];
    switch (ctrler.filterType) {
        case TYPE_TASK:
            filterSegmentedControl.selectedSegmentIndex = 0;
            break;
            
        case TYPE_EVENT:
            filterSegmentedControl.selectedSegmentIndex = 1;
            break;
        
        case TYPE_NOTE:
            filterSegmentedControl.selectedSegmentIndex = 2;
            break;
            
        case TASK_FILTER_PINNED:
            filterSegmentedControl.selectedSegmentIndex = 3;
            break;
    }
    
    [headerView addSubview:filterSegmentedControl];
    [filterSegmentedControl release];
    
    // create edit bar ========================
    UIView *editBarView = [[UIView alloc] initWithFrame:headerView.bounds];
    editBarView.tag = TAG_VIEW_EDIT_BAR;
    editBarView.hidden = YES;
    [headerView addSubview:editBarView];
    
    // count label
    /*UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SPACE_PAD, 0, 10, editBarView.frame.size.height)];
    countLabel.tag = TAG_VIEW_COUNT_LABEL;
    countLabel.text = @"0";
    countLabel.hidden = YES;
    [editBarView addSubview:countLabel];
    
    [countLabel release];*/
    selectedCounter = 0;
    
    // delete button
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(editBarView.frame.size.width - 30 - SPACE_PAD, 5, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(multiDelete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    [editBarView addSubview:deleteButton];
    
    [editBarView release];
}

-(void) createTaskOptionView
{
	optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    //optionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 240)];
    //optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 280)];
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
    starButton.tag = TASK_FILTER_STAR;
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
    
    // scheduled filert
    /*UIImageView *scheduledImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 235, 20, 20)];
	scheduledImageView.image = [[ImageManager getInstance] getImageWithName:@"filter_start.png"];
	[optionView addSubview:scheduledImageView];
	[scheduledImageView release];
	
	UILabel *scheduledLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 232, 120, 25)];
	scheduledLabel.text = _anchoredText;
	scheduledLabel.textColor = [UIColor whiteColor];
	scheduledLabel.backgroundColor = [UIColor clearColor];
	scheduledLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:scheduledLabel];
	[scheduledLabel release];
	
	UIButton *scheduledButton=[Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 232, 160, 30)
                                        titleColor:nil
                                            target:self
                                          selector:@selector(showTaskWithOption:)
                                  normalStateImage:nil
                                selectedStateImage:nil];
	scheduledButton.titleLabel.font=[UIFont systemFontOfSize:18];
    scheduledButton.tag = TASK_FILTER_PINNED;
	[optionView addSubview:scheduledButton];*/
    // end scheduled filter
    
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
	//optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 120, 140)];
    optionView = [[UIView alloc] initWithFrame:CGRectMake(160, 0, 120, 175)];
	optionView.hidden = YES;
	optionView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:optionView];
	[optionView release];
	
	//optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
    optionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 175)];
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
    
    // anchor
    UIImageView *anchorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 130, 20, 20)];
	anchorImageView.image = [[ImageManager getInstance] getImageWithName:@"newTask.png"];
	[optionView addSubview:anchorImageView];
	[anchorImageView release];
	
	UILabel *anchorLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 127, 120, 25)];
	anchorLabel.text = _anchoredText;
	anchorLabel.textColor = [UIColor whiteColor];
	anchorLabel.backgroundColor = [UIColor clearColor];
	anchorLabel.font=[UIFont systemFontOfSize:18];
	[optionView addSubview:anchorLabel];
	[anchorLabel release];
	
	UIButton *anchorButton=[Common createButton:@""
                                   buttonType:UIButtonTypeCustom
                                        frame:CGRectMake(0, 127, 160, 30)
                                   titleColor:nil
                                       target:self
                                     selector:@selector(showProjectWithOption:)
                             normalStateImage:nil
                           selectedStateImage:nil];
	anchorButton.titleLabel.font=[UIFont systemFontOfSize:18];
    anchorButton.tag = 3;
	[optionView addSubview:anchorButton];
    // end anchor
    
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
    //NSString *filters[3] = {_allText, _allText, _tasksText};
    
    NSString *normalImages[3] = {@"tab_tasks.png", @"tab_notes.png", @"tab_projects.png"};
    NSString *selectedImages[3] = {@"tab_tasks_selected.png", @"tab_notes_selected.png", @"tab_projects_selected.png"};
    
    CGFloat btnWidth = (w-10)/3;
    
    //printf("button width: %f\n", btnWidth);
    
    UIButton *taskButton = nil;
    CGFloat btnHeight = 78;
    for (int i=0; i<3; i++)
    {
        UIButton *moduleButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(w+20 + i*btnWidth, 10, btnWidth, btnHeight)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(showModule:)
                                     normalStateImage:normalImages[i]
                                   selectedStateImage:selectedImages[i]];
        //moduleButton.backgroundColor = [UIColor grayColor]
        ;
        //[moduleButton setTitle:titles[i] forState:UIControlStateNormal];
        moduleButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        moduleButton.tag = 31000+i;
        
        [contentView addSubview:moduleButton];
        
        //UILabel *moduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 100, 30)];
        UILabel *moduleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, btnWidth, 30)];
        moduleLabel.backgroundColor = [UIColor clearColor];
        moduleLabel.textColor = [UIColor blackColor];
        moduleLabel.font = [UIFont boldSystemFontOfSize:14];
        moduleLabel.textAlignment = NSTextAlignmentCenter;
        moduleLabel.text = titles[i];
        
        [moduleButton addSubview:moduleLabel];
        [moduleLabel release];
        
        if (i != 2)
        {
            UIView *moduleSeparator = [[UIView alloc] initWithFrame:CGRectMake(w+20 + (i+1)*btnWidth - 1, 10, 1, btnHeight)];
            moduleSeparator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        
            [contentView addSubview:moduleSeparator];
            [moduleSeparator release];
        }
        
        if (i==0)
        {
            taskButton = moduleButton;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(w+20, 10 + btnHeight, w-10, 40)];
    //headerView.backgroundColor = [UIColor brownColor];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.tag = TAG_VIEW_HEADER_VIEW;
    
    [contentView addSubview:headerView];
    [headerView release];
    
    UIView *moduleView = [[UIView alloc] initWithFrame:CGRectMake(w+20, 10 + btnHeight + headerView.frame.size.height, w-10, frm.size.height - (20 + btnHeight + headerView.frame.size.height))];
    //moduleView.backgroundColor = [UIColor greenColor];
    moduleView.backgroundColor = [UIColor clearColor];
    moduleView.tag = 33000;
    
    [contentView addSubview:moduleView];
    [moduleView release];
    
    [self createMultiEditBar];
}

-(void) createMultiEditBar
{
    UIView *headerView = [contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    multiEditBar = [[UIToolbar alloc] initWithFrame:headerView.frame];
    multiEditBar.hidden = YES;
    
    [contentView addSubview:multiEditBar];
    [multiEditBar release];
    
    multiCount = 0;
}

/*
- (void)refreshEditBarViewWithCheck: (BOOL) check
{
    BOOL firstCheck = selectedCounter == 0;
    
    selectedCounter = check ?  ++selectedCounter : --selectedCounter;
    
    UIView *editBarView = (UIView *)[contentView viewWithTag:TAG_VIEW_EDIT_BAR];

    if (selectedCounter > 0) {
        editBarView.hidden = NO;
        filterSegmentedControl.hidden = YES;
    } else {
        editBarView.hidden = YES;
        filterSegmentedControl.hidden = NO;
    }
    
    UIButton *copyLinkButton = (UIButton*)[contentView viewWithTag:TAG_VIEW_COPY_BUTTON];
    copyLinkButton.enabled = (selectedCounter == 2);
    
    if (firstCheck) {
        switch (selectedModuleButton.tag - 31000)
        {
            case 0:
            {
                SmartListViewController *ctrler = [self getSmartListViewController];
                
                [ctrler multiEdit:YES];
                //[ctrler hideQuickAdd];
            }
                break;
            case 1:
            {
                NoteViewController *ctrler = [self getNoteViewController];
                
                [ctrler multiEdit:YES];
            }
                
                break;
            case 2:
            {
                CategoryViewController *ctrler = [self getCategoryViewController];
                
                [ctrler multiEdit:YES];
            }
                break;
        }
    } else if (selectedCounter == 0) {
        switch (selectedModuleButton.tag - 31000)
        {
            case 0:
            {
                SmartListViewController *ctrler = [self getSmartListViewController];
                
                [ctrler multiEdit:NO];
            }
                break;
            case 1:
            {
                NoteViewController *ctrler = [self getNoteViewController];
                
                [ctrler multiEdit:NO];
            }
                
                break;
            case 2:
            {
                CategoryViewController *ctrler = [self getCategoryViewController];
                
                [ctrler multiEdit:NO];
            }
                break;
        }
    }
}

- (void)cancelEdit
{
    selectedCounter = 0;
    
    UIView *editBarView = (UIView *)[contentView viewWithTag:TAG_VIEW_EDIT_BAR];
    editBarView.hidden = YES;
    filterSegmentedControl.hidden = NO;
}
*/

- (void) refreshHeaderView
{
    UIView *headerView = (UIView *)[contentView viewWithTag:TAG_VIEW_HEADER_VIEW];
    
    for (UIView *view in headerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    switch (selectedModuleButton.tag - 31000)
    {
        case 0:
        {
            [self createTaskOptionFilter];
        }
            break;
            
        case 1:
            [self createNoteOptionFilter];
            break;
            
        case 2:
            [self createProjectOptionFilter];
            break;
    }
}

- (void) refreshHeaderView_old
{
    UIView *headerView = (UIView *)[contentView viewWithTag:32000];
    
    for (UIView *view in headerView.subviews)
    {
        [view removeFromSuperview];
    }
    
    NSString *filters[3] = {_allText, _allText, _tasksText};
   
    UIButton *addButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(headerView.bounds.size.width-35, 5, 30, 30)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(add:)
                              normalStateImage:@"module_add.png"
                            selectedStateImage:nil];
    addButton.tag = 22000;
    
    [headerView addSubview:addButton];
    
    UIButton *filterButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                              frame:CGRectMake(headerView.bounds.size.width-70, 5, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(filter:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
    filterButton.tag = 23000;
    [headerView addSubview:filterButton];
    
    UIImageView *filterImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
    
    filterImgView.image = [UIImage imageNamed:@"arrow_down.png"];
    
    [filterButton addSubview:filterImgView];
    [filterImgView release];
    
    UIView *filterSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(headerView.bounds.size.width-70, 5, 1, 30)];
    filterSeparatorView.backgroundColor = [UIColor whiteColor];
    
    [headerView addSubview:filterSeparatorView];
    [filterSeparatorView release];
    
    UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerView.bounds.size.width-180, 5, 100, 30)];
    filterLabel.backgroundColor = [UIColor clearColor];
    filterLabel.textAlignment =  NSTextAlignmentRight;
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.font = [UIFont boldSystemFontOfSize:16];
    filterLabel.tag = 24000;
    filterLabel.text = filters[selectedModuleButton.tag-31000];
    
    [headerView addSubview:filterLabel];
    [filterLabel release];
    
    // hide option filter
    optionView.hidden = YES;
    
    [self refreshTaskFilterTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //[self resizeModules];
    UIButton *taskButton = (UIButton *)[contentView viewWithTag:31000];
    
    if (taskButton != nil)
    {
        //[self showModule:taskButton];
        [self performSelector:@selector(showModule:) withObject:taskButton afterDelay:0];
    }
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
