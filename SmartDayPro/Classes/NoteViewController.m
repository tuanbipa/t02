//
//  NoteViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/21/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "NoteViewController.h"

#import "Common.h"
#import "Settings.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskManager.h"
#import "TaskLinkManager.h"
#import "Task.h"

#import "ContentView.h"
//#import "ContentTableView.h"
#import "ContentScrollView.h"
#import "TaskView.h"
#import "FocusView.h"

//#import "NoteDetailTableViewController.h"

#import "SmartDayViewController.h"
#import "AbstractSDViewController.h"
#import "iPadViewController.h"

#import "NoteLayoutController.h"
#import "NoteMovableController.h"

#import "CategoryViewController.h"
#import "PlannerViewController.h"
#import "PlannerMonthView.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;
extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize noteList;

@synthesize filterType;

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
        movableController = [[NoteMovableController alloc] init];
		
		noteLayoutCtrler = [[NoteLayoutController alloc] init];
        noteLayoutCtrler.movableController = movableController;

        self.filterType = NOTE_FILTER_ALL;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tabBarModeChanged:)
													 name:@"TabBarModeChangeNotification" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(calendarDayChange:)
													 name:@"CalendarDayChangeNotification" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [noteLayoutCtrler release];
    [movableController release];
    
    self.noteList = nil;
    
    [super dealloc];
}

-(void)refreshLayout
{
    [self cancelMultiEdit];
    
    [movableController unhighlight];
    [movableController reset];
	
	//[noteLayoutCtrler performSelector:@selector(layout) withObject:nil afterDelay:0];
    [noteLayoutCtrler layout];
    
    if ([[AbstractActionViewController getInstance] getActiveModule] == self) {
        // refresh multi edit bar
        [[AbstractActionViewController getInstance] hideMultiEditBar];
    }
}

- (void) loadAndShowList
{
    [self filter:self.filterType];
}

- (void) deselect
{
    //[self multiEdit:NO];
    [self cancelMultiEdit];
}

- (void) filter:(NSInteger)type
{
    BOOL filterChange = (self.filterType != type);
    
    self.filterType = type;
    
    //DBManager *dbm = [DBManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    NSDictionary *tagDict = [tm getFilterTagDict];
    NSDictionary *categoryDict = [tm getFilterCategoryDict];
    
    self.noteList = [NSMutableArray arrayWithCapacity:50];
    
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:50];
    
    switch (self.filterType)
    {
        case NOTE_FILTER_ALL:
            //list = [dbm getAllNotes];
            list = [tm getNoteList];
            break;
        case NOTE_FILTER_CURRENT:
            //list = [dbm getNotesByDate:tm.today];
            list = [tm getNoteListOnDate:tm.today];
            break;
        case NOTE_FILTER_WEEK:
            //list = [dbm getNotesByThisWeek];
            list = [tm getWeekNoteList];
            break;
    }
    
    for (Task *task in list)
    {
        BOOL filterIn = ([tm checkGlobalFilterIn:task tagDict:tagDict catDict:categoryDict]);
        
        if (filterIn)
        {
            task.listSource = SOURCE_NOTE;
            
            [self.noteList addObject:task];
        }
    }
    
    checkFocus = YES;
    
    focusIndex = -1;
    
    selectedIndex = -1;
    tapCount = 0;
    
    [self reconcileLinkCopy];
    
    [self refreshLayout];
    
    if (filterChange)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterChangeNotification" object:nil]; //refresh Detail view in sliding mode
    }
    
    //[listTableView reloadData];
}

- (void) reconcileLinkCopy
{
    if (_abstractViewCtrler.task2Link != nil && _abstractViewCtrler.task2Link.listSource == SOURCE_NOTE)
    {
        for (Task *task in self.noteList)
        {
            if (_abstractViewCtrler.task2Link.primaryKey == task.primaryKey)
            {
                _abstractViewCtrler.task2Link = task;
                
                break;
            }
        }
    }
}

- (void) changeSkin
{
    contentView.backgroundColor = COLOR_BACKGROUND_LIST_VIEW;
    
    //listTableView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    //listTableView.separatorColor = [UIColor lightGrayColor];
}

/*
- (void) editNote:(Task *)task
{
    NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
    ctrler.note = task;
    
    [_abstractViewCtrler.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}
*/

- (void) focus
{
    if (checkFocus)
    {
        int y = focusIndex*60;
        
        //listTableView.contentOffset = CGPointMake(0, y > 30?y-30:0);
    }
    
    checkFocus = NO;
}

- (void) enableActions:(BOOL)enable
{
	UIMenuController *menuCtrler = [UIMenuController sharedMenuController];

	if (enable)
	{
		//CGRect frm = CGRectMake(0, selectedIndex*60-listTableView.contentOffset.y, listTableView.bounds.size.width, 60);
        CGRect frm = CGRectZero;
        
        Task *task = [self getSelectedTask];
        
        NSInteger pk = (task.original != nil && ![task isREException]?task.original.primaryKey:task.primaryKey);

        //printf("selected note: %s - pk: %d\n", [task.name UTF8String], pk);
                
        contentView.actionType = ACTION_ITEM_EDIT;
        contentView.tag = pk;
        
		[contentView becomeFirstResponder];		
		[menuCtrler setTargetRect:frm inView:contentView];
		[menuCtrler setMenuVisible:YES animated:NO];
		
	}
	else 
	{
		[menuCtrler setMenuVisible:NO animated:YES];
	}	    
}

- (Task *) getSelectedTask
{
    if (selectedIndex != -1)
    {
        return [self.noteList objectAtIndex:selectedIndex];
    }
}

- (void) refreshView
{
    [self setNeedsDisplay];
}

-(void)setNeedsDisplay
{
    //[listTableView reloadData];
	for (UIView *view in noteListView.subviews)
	{
        if ([view isKindOfClass:[TaskView class]]) {
            [((TaskView *)view) refresh];
        }
	}
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    for (Task *task in self.noteList)
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

- (void) reconcileItem:(Task *)item
{
    if ([item isNote] && [[AbstractActionViewController getInstance] checkControllerActive:2])
    {
        [self loadAndShowList];
    }
}

- (void) quickAddNote:(id)sender
{
    [[[AbstractActionViewController getInstance] getActiveModule] cancelMultiEdit];
    
    TaskManager *tm = [TaskManager getInstance];
    
    Task *note = [[Task alloc] init];
    
    note.type = TYPE_NOTE;
    note.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
    
    if (_isiPad)
    {
        [_iPadViewCtrler editNoteContent:note];
    }
    else
    {
        [_sdViewCtrler editNoteContent:note];
    }
    [note release];
}

#pragma mark Multi Edit

- (NSMutableArray *) getMultiEditList
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:10];
    
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *)view;
            
            if ([tv isMultiSelected])
            {
                [list addObject:tv.task];
            }
        }
    }

    return list;
}

- (void) cancelMultiEdit
{
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *) view;

            [tv multiSelect:NO];
        }
    }
    
    [self updateEditModeForAllTaskObject:NO];
    [[AbstractActionViewController getInstance] hideMultiEditBar];
    [Common refreshNavigationbarForEditMode];
}

- (void) enableMultiEdit:(BOOL)enabled
{
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]])
        {
            TaskView *tv = (TaskView *) view;
            tv.checkEnable = enabled && ![tv.task isShared];
            [tv refresh];
        }
    }
    
}

/*
- (void) multiEdit:(BOOL)enabled
{
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[MovableView class]])
        {
            [(MovableView *) view multiSelect:enabled];
        }
    }
}

- (void) cancelMultiEdit:(id) sender
{
    [self multiEdit:NO];
}

- (void) multiDelete:(id)sender
{
	if ([[Settings getInstance] deleteWarning])
	{
        BOOL needConfirm = NO;
        
        for (UIView *view in noteListView.subviews)
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
        
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]] && [((TaskView *)view) isMultiSelected])
        {
            [taskList addObject:((TaskView *)view).task];
        }
    }
    
    if (taskList.count > 0)
    {
        [[TaskManager getInstance] deleteTasks:taskList];
        
        for (Task *note in taskList)
        {
            [self.noteList removeObject:note];
        }
    }
    
    [self multiEdit:NO];

    [self refreshLayout];
    
    if ([_abstractViewCtrler checkControllerActive:3])
    {
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        
        if (ctrler.filterType == TYPE_NOTE)
        {
            [ctrler loadAndShowList];
        }
    }
    
    FocusView *focusView = [_abstractViewCtrler getFocusView];
    
    if (focusView != nil && [focusView checkExpanded])
    {
        [focusView refreshData];
    }

    AbstractActionViewController *ctrler = [AbstractActionViewController getInstance];
    if ([ctrler isKindOfClass:[PlannerViewController class]]) {
        PlannerMonthView *plannerMonthView = (PlannerMonthView*)[ctrler getPlannerMonthCalendarView];
        [plannerMonthView refreshOpeningWeek: nil];
    }
    [ctrler cancelEdit];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
        [self doMultiDeleteTask];
	}
}
*/

#pragma mark Views
- (MovableView *)getFirstMovableView
{
    MovableView *ret = nil;
    
    if (self.noteList.count > 0)
    {
        Task *firstNote = [self.noteList objectAtIndex:0];
        
        for (UIView *view in noteListView.subviews)
        {
            if ([view isKindOfClass:[TaskView class]] && ((TaskView *)view).task == firstNote)
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
    for (UIView *view in noteListView.subviews)
    {
        if ([view isKindOfClass:[TaskView class]] && ((TaskView *)view).task == item)
        {
            return view;
        }
    }
    
    return nil;
}

- (void) changeFrame:(CGRect)frm
{
    Settings *settings = [Settings getInstance];
    
    contentView.frame = frm;
    
    CGRect rec = editBarPlaceHolder.frame;
    
    rec.size.width = frm.size.width;
    
    editBarPlaceHolder.frame = rec;
    
    UIToolbar *editToolbar = (UIToolbar *)[editBarPlaceHolder viewWithTag:10000];
    editToolbar.frame = editBarPlaceHolder.bounds;
    
    frm = contentView.bounds;
    frm.size.height = 35;
    
    emptyNoteButton.frame = frm;
    
    frm = contentView.bounds;
    frm.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frm.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);

    noteListView.frame = frm;
}

-(void) createEditBar
{
	editBarPlaceHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.bounds.size.width, 40)];
	editBarPlaceHolder.backgroundColor = [UIColor clearColor];
	editBarPlaceHolder.hidden = YES;
	
	[contentView addSubview:editBarPlaceHolder];
	[editBarPlaceHolder release];
	
	UIToolbar *editToolbar = [[UIToolbar alloc] initWithFrame:editBarPlaceHolder.bounds];
	editToolbar.barStyle = UIBarStyleBlack;
    editToolbar.tag = 10000;
	
	[editBarPlaceHolder addSubview:editToolbar];
	[editToolbar release];
    
	UIButton *cancelButton = [Common createButton:_cancelText
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 5, 80, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(cancelMultiEdit:)
                                 normalStateImage:@"hide_btn.png"
                               selectedStateImage:nil];
	
	UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
		
	UIButton *deleteButton = [Common createButton:_deleteText
									   buttonType:UIButtonTypeCustom
											frame:CGRectMake(0, 5, 80, 30)
									   titleColor:[UIColor whiteColor]
										   target:self
										 selector:@selector(multiDelete:)
								 normalStateImage:@"delete_btn.png"
							   selectedStateImage:nil];
	
	UIBarButtonItem *deleteButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
	
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
								  target:nil
								  action:nil];
	
	NSArray *items = [NSArray arrayWithObjects:spaceItem, cancelButtonItem, spaceItem, deleteButtonItem, spaceItem, nil];
	
    [cancelButtonItem release];
	[deleteButtonItem release];
	[spaceItem release];
	
	[editToolbar setItems:items animated:NO];
}

- (void)loadView {
    Settings *settings = [Settings getInstance];
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    frm.size.height += [Common heightTabbar];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    //[contentView enableSwipe];
    
    self.view = contentView;
    [contentView release];
    
    frm = contentView.bounds;
    frm.size.height = HEIGHT_QUICK_ADD_VIEW;
    
	emptyNoteButton = [Common createButton:_tapToAddNote
                                buttonType:UIButtonTypeCustom
                                     frame:frm
                                titleColor:COLOR_TEXT_PLACEHOLDER
                                    target:self
                                  selector:@selector(quickAddNote:)
                          normalStateImage:nil
                        selectedStateImage:nil];

    emptyNoteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    emptyNoteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    emptyNoteButton.titleLabel.font=[UIFont systemFontOfSize:FONT_SIZE_PLACEHOLDER];
    emptyNoteButton.backgroundColor = [Common colorDefaultProject];
    [contentView addSubview:emptyNoteButton];
    
    frm = contentView.bounds;
    frm.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frm.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);

    noteListView = [[ContentScrollView alloc] initWithFrame:frm];
    noteListView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
    noteListView.contentInset = UIEdgeInsetsMake(-4, 0, 0, 0);

	noteListView.scrollEnabled = YES;
	noteListView.delegate = self;
	noteListView.scrollsToTop = NO;
	noteListView.showsVerticalScrollIndicator = YES;
	noteListView.directionalLockEnabled = YES;
	
	[contentView addSubview:noteListView];
	[noteListView release];
        
    noteLayoutCtrler.viewContainer = noteListView;
    
    [self createEditBar];
    
    [self changeSkin];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self initData];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_abstractViewCtrler deselect];
}

#pragma mark Notification

- (void)tabBarModeChanged:(NSNotification *)notification {
    Settings *settings = [Settings getInstance];
    
    CGRect frm = contentView.bounds;
    frm.origin.y = HEIGHT_QUICK_ADD_VIEW;
    frm.size.height -= HEIGHT_QUICK_ADD_VIEW + (settings.tabBarAutoHide ? 0 : [Common heightTabbar]);

    noteListView.frame = frm;
}

- (void)calendarDayChange:(NSNotification *)notification
{
    //refresh Notes if filter is Current
    
    if (self.filterType == NOTE_FILTER_CURRENT)
    {
        [self loadAndShowList];
    }
}

#pragma mark Links
- (void) reconcileLinks:(NSDictionary *)dict
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int sourceId = [[dict objectForKey:@"LinkSourceID"] intValue];
    int destId = [[dict objectForKey:@"LinkDestID"] intValue];
    
    for (Task *task in self.noteList)
    {
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

#pragma mark - Edit Mode
- (void)updateEditModeForAllTaskObject:(BOOL)editmode {
    for (id task in self.noteList) {
        if ([task isKindOfClass:[Task class]]) {
            Task *value = (Task *)task;
            value.isMultiEdit = editmode;
        }
    }
    
    [self setNeedsDisplay];
}


@end
