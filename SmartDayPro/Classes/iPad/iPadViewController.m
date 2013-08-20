//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "iPadViewController.h"

#import "Common.h"
#import "FilterData.h"
#import "Task.h"
#import "Project.h"
#import "Comment.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "MovableView.h"

#import "ImageManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "MusicManager.h"
#import "CommentManager.h"

#import "CalendarViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"
#import "iPadSettingViewController.h"

#import "DetailViewController.h"
//#import "NoteDetailTableViewController.h"
#import "NoteDetailViewController.h"
#import "NoteContentViewController.h"
#import "ProjectEditViewController.h"

#import "SDNavigationController.h"

#import "SmartCalAppDelegate.h"

extern BOOL _isiPad;

extern SmartCalAppDelegate *_appDelegate;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

iPadViewController *_iPadViewCtrler;

@interface iPadViewController ()

@end

@implementation iPadViewController

@synthesize activeViewCtrler;
@synthesize detailNavCtrler;

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
        _iPadViewCtrler = self;
        
        inSlidingMode = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNewComments:)
                                                     name:@"NewCommentReceivedNotification" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     
    self.activeViewCtrler = nil;
    self.detailNavCtrler = nil;
    
    [super dealloc];
}

- (void) showCategory:(id) sender
{
    //[_iPadSDViewCtrler showCategory];
    [self.activeViewCtrler showCategory];
}

- (void) showTag:(id) sender
{
    //[_iPadSDViewCtrler showTag];
    [self.activeViewCtrler showTag];
}

- (void) showTimer:(id) sender
{
    //[_iPadSDViewCtrler showTimer];
    [self.activeViewCtrler showTimer];
}

- (void) deactivateSearchBar
{
    if (searchBar != nil && [searchBar isFirstResponder])
    {
        [searchBar resignFirstResponder];
        [self.activeViewCtrler hidePopover];
    }
}

- (void) showMenu:(id) sender
{
    //[_iPadSDViewCtrler showMenu];
    [self.activeViewCtrler showSettingMenu];
}

- (UIButton *) getTimerButton
{
    return timerButton;
}

- (void) refreshToolbar:(UIInterfaceOrientation)orientation
{
    /*if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
    {
        self.navigationItem.leftBarButtonItems = nil;
        
        searchBar = nil;
        timerButton = nil;
        tagButton = nil;
        eyeButton = nil;
        
        //[[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
    else if ([self.activeViewCtrler isKindOfClass:[iPadSmartDayViewController class]])*/
    {
        //[[self navigationController] setNavigationBarHidden:NO animated:YES];
        
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
        
        UIBarButtonItem *fixed40Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
        fixed40Item.width = 40;
        
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil
                                                                                   action:nil];
        fixedItem.width = UIInterfaceOrientationIsLandscape(orientation)?285:155;
        
        UIButton *settingButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:CGRectMake(0, 0, 40, 40)
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                              selector:@selector(showMenu:)
                                      normalStateImage:@"bar_setting.png"
                                    selectedStateImage:nil];
        
        UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
        
        eyeButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 40, 40)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(showCategory:)
                                  normalStateImage:@"bar_eye.png"
                                selectedStateImage:nil];
        
        UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
        
        tagButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 40, 40)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(showTag:)
                                  normalStateImage:@"bar_tag.png"
                                selectedStateImage:nil];
        
        UIBarButtonItem *tagButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tagButton];
        
        timerButton = [Common createButton:@""
                                buttonType:UIButtonTypeCustom
                                     frame:CGRectMake(0, 0, 40, 40)
                                titleColor:[UIColor whiteColor]
                                    target:self
                                  selector:@selector(showTimer:)
                          normalStateImage:@"bar_timer.png"
                        selectedStateImage:nil];
        
        UIBarButtonItem *timerButtonItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
        //searchBar.placeholder = _seekOrCreate;
        searchBar.translucent = YES;
        searchBar.delegate = self;
        /*
        UITextField *searchField = nil;
        for (UIView *subview in searchBar.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                searchField = (UITextField *)subview;
                break;
            }
        }
        if (searchField) {
            UIImage *image = [UIImage imageNamed: @"top_addnew.png"];
            UIImageView *iView = [[UIImageView alloc] initWithImage:image];
            searchField.leftView = iView;
            [iView release];  
        }
        */
        UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        [searchBar release];
        
        NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, fixedItem, timerButtonItem, flexItem, searchBarItem,nil];
        //NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, flexItem, searchBarItem,nil];
        
        [flexItem release];
        [fixedItem release];
        [fixed40Item release];
        [timerButtonItem release];
        [settingButtonItem release];
        [eyeButtonItem release];
        [tagButtonItem release];
        [searchBarItem release];
        
        self.navigationItem.leftBarButtonItems = items;
    }
}

- (void) refreshFilterStatus
{
    if (tagButton != nil)
    {
        TaskManager *tm = [TaskManager getInstance];
        
        [tagButton setImage:[UIImage imageNamed:@"bar_tag.png"] forState:UIControlStateNormal];
        
        if (tm.filterData != nil && ![tm.filterData.tag isEqualToString:@""])
        {
            [tagButton setImage:[UIImage imageNamed:@"bar_tag_blue.png"] forState:UIControlStateNormal];            
        }
    }

    if (eyeButton != nil)
    {
        [eyeButton setImage:[UIImage imageNamed:@"bar_eye.png"] forState:UIControlStateNormal];

        BOOL checkInvisible = [[[ProjectManager getInstance] getInvisibleProjectDict] count] > 0;
        
        if (checkInvisible)
        {
            [eyeButton setImage:[UIImage imageNamed:@"bar_eye_blue.png"] forState:UIControlStateNormal];
        }
    }
}

-(void)changeSkin
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) editNoteContent:(Task *)note
{
    NoteContentViewController *ctrler = [[NoteContentViewController alloc] init];
    ctrler.note = note;
    
    SDNavigationController *navCtrler = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    
    [self presentViewController:navCtrler animated:YES completion:nil];
    
    [ctrler release];
    [navCtrler release];
}

- (void) editNoteDetail:(Task *)note
{
    /*
    if (self.detailNavCtrler != nil)
    {
        [self closeDetail];
    }
    */
    
    NoteDetailViewController *ctrler = [[NoteDetailViewController alloc] init];
    ctrler.note = note;
    
    if (self.detailNavCtrler != nil)
    {
        [self.detailNavCtrler initWithRootViewController:ctrler];
    }
    else
    {
        [self showDetail:ctrler];
    }
/*
    self.detailNavCtrler = [[[UINavigationController alloc] initWithRootViewController:ctrler] autorelease];
    
    CGRect frm = self.detailNavCtrler.view.frame;
    frm.size.width = 384;
    
    self.detailNavCtrler.view.frame = frm;
    self.detailNavCtrler.navigationBar.barStyle = UIBarStyleBlack;
    
    [detailView addSubview:self.detailNavCtrler.view];
    
    detailView.hidden = NO;
    [contentView bringSubviewToFront:detailView];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    
    // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
    [animation setDuration:kTransitionDuration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
*/
}

- (void) editProjectDetail:(Project *)project
{
    /*
    if (self.detailNavCtrler != nil)
    {
        [self closeDetail];
    }
    */
    
    ProjectEditViewController *ctrler = [[ProjectEditViewController alloc] init];
    ctrler.project = project;
    
    if (self.detailNavCtrler != nil)
    {
        [self.detailNavCtrler initWithRootViewController:ctrler];
    }
    else
    {
        [self showDetail:ctrler];
    }
    
    [ctrler release];
    
    /*
    self.detailNavCtrler = [[[UINavigationController alloc] initWithRootViewController:ctrler] autorelease];
    
    CGRect frm = self.detailNavCtrler.view.frame;
    frm.size.width = 384;
    
    self.detailNavCtrler.view.frame = frm;
    self.detailNavCtrler.navigationBar.barStyle = UIBarStyleBlack;
    
    [detailView addSubview:self.detailNavCtrler.view];
    
    detailView.hidden = NO;
    [contentView bringSubviewToFront:detailView];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    
    // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
    [animation setDuration:kTransitionDuration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];  
    */
}

-(void) editItemDetail:(Task *)item
{
    [self deactivateSearchBar];
    
    if ([item isNote])
    {
        [self editNoteDetail:item];
    }
    else
    {
        DetailViewController *ctrler = [[DetailViewController alloc] init];
        ctrler.task = item;
        
        if (self.detailNavCtrler != nil)
        {
            [self.detailNavCtrler initWithRootViewController:ctrler];
        }
        else
        {
            [self showDetail:ctrler];
        }
        
        [ctrler release];
        /*
        if (self.detailNavCtrler != nil)
        {
            [self closeDetail];
        }
        
        DetailViewController *ctrler = [[DetailViewController alloc] init];
        ctrler.task = item;
        
        self.detailNavCtrler = [[[UINavigationController alloc] initWithRootViewController:ctrler] autorelease];

        CGRect frm = self.detailNavCtrler.view.frame;
        frm.size.width = 384;
        
        self.detailNavCtrler.view.frame = frm;
        self.detailNavCtrler.navigationBar.barStyle = UIBarStyleBlack;
        
        [detailView addSubview:self.detailNavCtrler.view];
        
        detailView.hidden = NO;
        [contentView bringSubviewToFront:detailView];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromRight];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey]; 
        */
    }
}

- (void) showDetail:(UIViewController *)ctrler
{
//    self.detailNavCtrler = [[[UINavigationController alloc] initWithRootViewController:ctrler] autorelease];
    self.detailNavCtrler = [[[SDNavigationController alloc] initWithRootViewController:ctrler] autorelease];
    
    CGRect frm = self.detailNavCtrler.view.frame;
    frm.size.width = 384;
    
    self.detailNavCtrler.view.frame = frm;
    self.detailNavCtrler.navigationBar.barStyle = UIBarStyleBlack;
    
    [detailView addSubview:self.detailNavCtrler.view];
    
    detailView.hidden = NO;
    [contentView bringSubviewToFront:detailView];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    
    // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
    [animation setDuration:kTransitionDuration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
}

- (void) closeDetail
{
    if (self.detailNavCtrler != nil)
    {
        if (inSlidingMode)
        {
            [self slideView:NO];
        }
        
        [self.detailNavCtrler.view removeFromSuperview];
        
        detailView.hidden = YES;
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromLeft];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        self.detailNavCtrler = nil;
    }
}

- (void)receiveNewComments:(NSNotification *)notification
{
    NSMutableArray *list = [notification.userInfo objectForKey:@"CommentList"];

    printf("\n\n New Comment List\n");
    
    /*
    for (Comment *comment in list)
    {
        printf("[%s - %s] %s\n", [comment.firstName UTF8String], [comment.lastName UTF8String], [comment.content UTF8String]);
    }*/
    
    if (list.count > 0)
    {
        CommentManager *cmdM = [CommentManager getInstance];
        [cmdM notify:list];
    }
}

#pragma mark View

- (void) showLandscapeView
{
    /*
    if (_iPadSDViewCtrler != nil)
    {
        [_iPadSDViewCtrler showTaskModule:NO];
    }*/
    
    if (_iPadSDViewCtrler != nil)
    {
        [_iPadSDViewCtrler showModuleOff];
    }
    
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }
        
    PlannerViewController *ctrler = [[PlannerViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    [contentView addSubview:self.activeViewCtrler.view];

    [ctrler refreshTaskFilterTitle];
    
    [self refreshToolbar:UIInterfaceOrientationLandscapeLeft];
}

- (void) showPortraitView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }

    self.activeViewCtrler = _iPadSDViewCtrler;
    
    [contentView addSubview:self.activeViewCtrler.view];
    
    if (_iPadSDViewCtrler != nil)
    {
        //[_iPadSDViewCtrler showTaskModule:YES];
        [_iPadSDViewCtrler showTaskModule];
    }

    [_iPadSDViewCtrler refreshTaskFilterTitle];
    
    [self refreshToolbar:UIInterfaceOrientationPortrait];
}

- (void) slideAndShowDetail
{
    /*
    PageAbstractViewController *ctrler = nil;
    
    if ([self.activeViewCtrler checkControllerActive:1])
    {
        ctrler = [self.activeViewCtrler getSmartListViewController];
    }
    else if ([self.activeViewCtrler checkControllerActive:2])
    {
        ctrler = [self.activeViewCtrler getNoteViewController];
    }
    else if ([self.activeViewCtrler checkControllerActive:3])
    {
        ctrler = [self.activeViewCtrler getCategoryViewController];
    }
    */
    
    PageAbstractViewController *ctrler = [self.activeViewCtrler getActiveModule];
    
    if (ctrler != nil)
    {
        MovableView *firstView = [ctrler getFirstMovableView];
        
        if (firstView != nil)
        {
            NSObject *obj = nil;
            
            if ([firstView isKindOfClass:[TaskView class]])
            {
                obj = ((TaskView *) firstView).task;
            }
            else if ([firstView isKindOfClass:[PlanView class]])
            {
                obj = ((PlanView *) firstView).project;
            }
            
            [self slideView:YES];
            
            firstView = [self.activeViewCtrler getActiveView4Item:obj];
            
            [firstView singleTouch];
        }
    }
}

- (void) slideView:(BOOL)enabled
{
    if (inSlidingMode && enabled)
    {
        return;
    }
        
    if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
    {
        [((PlannerViewController *) self.activeViewCtrler) showPlannerOff:enabled];
    }
    
    CGRect frm = self.activeViewCtrler.view.frame;
    
    CGFloat slideWidth = 384;
    
    frm = CGRectOffset(frm, enabled?-slideWidth:slideWidth, 0);
    
    self.activeViewCtrler.view.frame = frm;
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    
    if (enabled)
    {
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromRight];
    }
    else
    {
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromLeft];
    }
    // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
    [animation setDuration:kTransitionDuration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [self.activeViewCtrler.view.layer addAnimation:animation forKey:kInfoViewAnimationKey];
    
    inSlidingMode = enabled;
}

- (void) changeFrame:(CGRect) frm
{
    contentView.frame = frm;

    frm.size.width = 384;
    
    frm.origin.x = contentView.bounds.size.width - frm.size.width;
    
    detailView.frame = frm;
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 44;
    
    [self changeFrame:frm];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [_iPadSDViewCtrler loadView];
        
        [self showLandscapeView];
        
        if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
        {
            PlannerViewController *ctrler = (PlannerViewController *) self.activeViewCtrler;
            
            [ctrler viewWillAppear:NO];
        }
    }
    else
    {
        [self showPortraitView];
    }
    
    [self.activeViewCtrler resetMovableContentView];
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    //contentView.backgroundColor = [UIColor darkGrayColor];
    contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern_dark.png"]];
    
    self.view = contentView;
    
    frm.size.width = 384;
    
    frm.origin.x = contentView.bounds.size.width - frm.size.width;
    
    detailView = [[UIView alloc] initWithFrame:frm];
    detailView.hidden = YES;
    
    [contentView addSubview:detailView];
    
    //[self showPortraitView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self changeSkin];
    
    [self changeOrientation:self.interfaceOrientation];
    
    /*
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        [_iPadSDViewCtrler loadView];
        
        [self showLandscapeView];
        
        if ([self.activeViewCtrler isKindOfClass:[PlannerViewController class]])
        {
            PlannerViewController *ctrler = (PlannerViewController *) self.activeViewCtrler;
            
            [ctrler viewWillAppear:NO];
        }
    }
    else
    {
        [self showPortraitView];
    }*/
    
    [self refreshFilterStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[[_iPadSDViewCtrler getCalendarViewController] stopQuickAdd];
    [[self.activeViewCtrler getCalendarViewController] stopQuickAdd];
}

-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self closeDetail];
    
    [_appDelegate dismissAllAlertViews];
    
    /*
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
        
        [self showLandscapeView];
    }
    else
    {
        frm.size = sz;
        
        [self showPortraitView];
    }
    
    contentView.frame = frm;
    
    frm.size.width = 384;
    
    frm.origin.x = contentView.bounds.size.width - frm.size.width;
    
    detailView.frame = frm;
    */
    
    [self changeOrientation:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) quickCreate:(NSString *)text
{
    NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (str.length > 2)
    {
        NSString *prefix = [str substringToIndex:2];
        
        BOOL taskPrefix = [prefix isEqualToString:@"#t"];
        BOOL eventPrefix = [prefix isEqualToString:@"#e"];
        BOOL notePrefix = [prefix isEqualToString:@"#n"];
        
        if (taskPrefix || eventPrefix || notePrefix)
        {
            str = [[str substringFromIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSInteger type = eventPrefix?TYPE_EVENT:(notePrefix?TYPE_NOTE:TYPE_TASK);
            
            [self.activeViewCtrler quickAddItem:str type:type defer:DO_ANYTIME];
            
            return YES;
        }
    }
    
    return NO;
}

- (void) search:(NSString *)text
{
    NSString *str = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (str.length > 1 && [str characterAtIndex:0] == '#')
    {
        NSInteger n = 1;
        
        if (str.length > 1 && ([str characterAtIndex:1] == 't' || [str characterAtIndex:1] == 'e' || [str characterAtIndex:1] == 'n'))
        {
            n = 2;
        }
        
        str = [[text substringFromIndex:n] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    //[_iPadSDViewCtrler showSeekOrCreate:str];
    [self.activeViewCtrler showSeekOrCreate:str];
}

#pragma mark UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //[_iPadSDViewCtrler hideDropDownMenu];
    [self.activeViewCtrler hideDropDownMenu];
    
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self search:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

- (BOOL) searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        //printf("return \n");
        
        if ([self quickCreate:searchBar.text])
        {
            searchBar.text = @"";
            [searchBar resignFirstResponder];
            
            //[_iPadSDViewCtrler showSeekOrCreate:@""];//dismiss
            [self.activeViewCtrler showSeekOrCreate:@""];//dismiss
            
            return NO;
        }
    }
    
    return YES;
}


@end
