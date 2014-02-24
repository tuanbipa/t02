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
#import "Settings.h"
#import "FilterData.h"
#import "Task.h"
#import "Project.h"
#import "Comment.h"

#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"
#import "MovableView.h"
#import "GuideWebView.h"

#import "ImageManager.h"
#import "TaskManager.h"
#import "ProjectManager.h"
#import "MusicManager.h"
#import "CommentManager.h"
#import "DBManager.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"
#import "iPadSettingViewController.h"

#import "DetailViewController.h"
#import "TaskReadonlyDetailViewController.h"
//#import "NoteDetailTableViewController.h"
#import "NoteDetailViewController.h"
#import "NoteContentViewController.h"
#import "ProjectEditViewController.h"

#import "SDNavigationController.h"

#import "SmartCalAppDelegate.h"
#import "MapLocationViewController.h"

#import "GuruViewController.h"

//extern BOOL _isiPad;

extern BOOL _detailHintShown;

extern SmartCalAppDelegate *_appDelegate;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

iPadViewController *_iPadViewCtrler;

@interface iPadViewController ()

@end

@implementation iPadViewController

@synthesize activeViewCtrler;
@synthesize detailNavCtrler;

@synthesize inSlidingMode;
@synthesize selectedModuleIndex;

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
        
        self.selectedModuleIndex = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNewComments:)
                                                     name:@"NewCommentReceivedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshUnreadComments:)
                                                     name:@"CommentUpdateNotification" object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChange:)
                                                     name:@"FilterChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"GeoLocationUpdateNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"TaskCreatedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshGeoTaskLocation:)
                                                     name:@"TaskChangeNotification" object:nil];
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

- (void) showUnreadComments:(id) sender
{
    [self.activeViewCtrler showUnreadCommentsWithCGRect:((UIButton*)sender).frame];
}

- (void) showGeoTaskLocation:(id) sender
{
    UIButton *bt = (UIButton*)sender;
    [self.activeViewCtrler showGeoTaskLocationWithCGRect:bt.frame];
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
        searchBar.text = @"";
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
        //fixedItem.width = UIInterfaceOrientationIsLandscape(orientation)?285:155;
        fixedItem.width = UIInterfaceOrientationIsLandscape(orientation)?195:65;
        
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
        
        // task location =========================
        taskLocationButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, 40, 40)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(showGeoTaskLocation:)
                                 normalStateImage:@"bar_location.png"
                               selectedStateImage:nil];
        taskLocationButton.hidden = YES;
        
        taskLocationLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 20, 15)];
        taskLocationLable.font = [UIFont boldSystemFontOfSize:12];
        taskLocationLable.textColor = [UIColor whiteColor];
        taskLocationLable.textAlignment = NSTextAlignmentCenter;
        //taskLocationLable.tag = 10000;
        taskLocationLable.text = @"0";
        taskLocationLable.layer.cornerRadius = 3;
        taskLocationLable.backgroundColor = [Colors redButton];
        
        [taskLocationButton addSubview:taskLocationLable];
        [taskLocationLable release];
        
        UIBarButtonItem *taskLocationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:taskLocationButton];
        // end task location
        
        timerButton = [Common createButton:@""
                                buttonType:UIButtonTypeCustom
                                     frame:CGRectMake(0, 0, 40, 40)
                                titleColor:[UIColor whiteColor]
                                    target:self
                                  selector:@selector(showTimer:)
                          normalStateImage:@"bar_timer.png"
                        selectedStateImage:nil];
        
        commentButton = [Common createButton:@""
                                buttonType:UIButtonTypeCustom
                                     frame:CGRectMake(0, 0, 40, 40)
                                titleColor:[UIColor whiteColor]
                                    target:self
                                  selector:@selector(showUnreadComments:)
                          normalStateImage:@"bar_comments.png"
                        selectedStateImage:nil];
        commentButton.hidden = YES;
        
        //commentButton.layer.cornerRadius = 4;
        //commentButton.layer.borderColor = [[Colors redButton] CGColor];
        //commentButton.layer.borderWidth = 1;
        
        UILabel *commentBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 20, 15)];
        commentBadgeLabel.font = [UIFont boldSystemFontOfSize:12];
        commentBadgeLabel.textColor = [UIColor whiteColor];
        commentBadgeLabel.textAlignment = NSTextAlignmentCenter;
        commentBadgeLabel.tag = 10000;
        commentBadgeLabel.layer.cornerRadius = 3;
        commentBadgeLabel.backgroundColor = [Colors redButton];

        [commentButton addSubview:commentBadgeLabel];
        [commentBadgeLabel release];
        
        UIBarButtonItem *commentButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
        
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
        searchBar.placeholder = _seekOrCreate;
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
        
        //NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, fixed40Item, commentButtonItem, fixedItem, timerButtonItem, flexItem, searchBarItem,nil];
        NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, fixed40Item, taskLocationButtonItem, fixedItem, timerButtonItem, fixed40Item, commentButtonItem, flexItem, searchBarItem,nil];
        //NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, flexItem, searchBarItem,nil];
        
        [flexItem release];
        [fixedItem release];
        [fixed40Item release];
        [timerButtonItem release];
        [settingButtonItem release];
        [eyeButtonItem release];
        [tagButtonItem release];
        [searchBarItem release];
        [commentButtonItem  release];
        [taskLocationButtonItem release];
        
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
    /*
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }*/
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

- (void) editMapLocation:(Task *)task
{
    MapLocationViewController *ctrler = [[MapLocationViewController alloc] init];
    ctrler.task = task;
    
    SDNavigationController *navCtrler = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    
    [self presentViewController:navCtrler animated:YES completion:nil];
    
    [ctrler release];
    [navCtrler release];
}

- (void) editNoteDetail:(Task *)note
{
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
}

- (void) editProjectDetail:(Project *)project
{
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
}

-(void) editItemDetail:(Task *)item
{
    [self deactivateSearchBar];
    
    if ([item isNote])
    {
        [self editNoteDetail:item];
    }
    else if ([item isShared])
    {
        TaskReadonlyDetailViewController *ctrler = [[TaskReadonlyDetailViewController alloc] init];
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
    
    if ([ctrler isKindOfClass:[DetailViewController class]] || [ctrler isKindOfClass:[TaskReadonlyDetailViewController class]] || [ctrler isKindOfClass:[NoteDetailViewController class]])
    {
        [self performSelector:@selector(popupDetailHint) withObject:nil afterDelay:0.5];
    }
}

- (void) closeDetail
{
    [self popdownDetailHint];
    
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

- (void) hint: (id) sender
{
    _detailHintShown = YES;
    
	Settings *settings = [Settings getInstance];
    
    NSInteger tag = [(UIButton *)sender tag];
	
	if (tag == 10001) //Don't Show
	{
		[settings enableDetailHint:NO];
	}
    
    [self popdownDetailHint];

}

-(UIView *) createDetailHintView
{
    CGRect frm = detailView.bounds;
	UIView *view = [[[UIView alloc] initWithFrame:frm] autorelease];
	view.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	
    frm.size.height -= 40;
    
	GuideWebView *hintLabel = [[GuideWebView alloc] initWithFrame:frm];
    hintLabel.backgroundColor = [UIColor clearColor];
    
    NSArray* availableLocalizations = [[NSBundle mainBundle] localizations];
    NSArray* userPrefered = [NSBundle preferredLocalizationsFromArray:availableLocalizations forPreferences:[NSLocale preferredLanguages]];
    
    NSString *localization = [userPrefered objectAtIndex:0];
    
    NSString *hintFile = @"detail_hint_";
    
    if ([localization isEqualToString:@"ja"] || [localization isEqualToString:@"de"])
    {
        hintFile = [hintFile stringByAppendingString:localization];
    }
    else // else is EN
    {
        hintFile = [hintFile stringByAppendingString:@"en"];
    }
    
	[hintLabel loadHTMLFile:hintFile extension:@"htm"];
	
	[view addSubview:hintLabel];
	
	[hintLabel release];
	
	UIButton *hintOKButton = [Common createButton:_okText
									  buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(frm.size.width - 110, frm.size.height + 5, 100, 30)
									  titleColor:[Colors blueButton]
										  target:self
										selector:@selector(hint:)
								normalStateImage:nil
							  selectedStateImage:nil];
	hintOKButton.tag = 10000;
    
    hintOKButton.layer.cornerRadius = 4;
    hintOKButton.layer.borderWidth = 1;
    hintOKButton.layer.borderColor = [[Colors blueButton] CGColor];
    
    CGSize sz = [_dontShowText sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];
	
	UIButton *hintDontShowButton =[Common createButton:_dontShowText
											buttonType:UIButtonTypeCustom
                                                 //frame:CGRectMake(10, frm.size.height + 5, 100, 30)
                                                 frame:CGRectMake(10, frm.size.height + 5, sz.width + 20, 30)											titleColor:[Colors blueButton]
												target:self
											  selector:@selector(hint:)
									  normalStateImage:nil
									selectedStateImage:nil];
	hintDontShowButton.tag = 10001;
    
    hintDontShowButton.layer.cornerRadius = 4;
    hintDontShowButton.layer.borderWidth = 1;
    hintDontShowButton.layer.borderColor = [[Colors blueButton] CGColor];
	
	[view addSubview:hintOKButton];
	
	[view addSubview:hintDontShowButton];
    
    return view;
}

- (void) popupDetailHint
{
    Settings *settings = [Settings getInstance];
    
    if (settings.detailHint && !_detailHintShown)
    {
        hintView = [self createDetailHintView];
        
        [detailView addSubview:hintView];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFromTop];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
    }
}

- (void) popdownDetailHint
{
    if (hintView != nil && [hintView superview])
    {
        [hintView removeFromSuperview];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [detailView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        hintView = nil;
    }
}

#pragma mark Notification

- (void)receiveNewComments:(NSNotification *)notification
{
    NSMutableArray *list = [notification.userInfo objectForKey:@"CommentList"];

    printf("\n\n New Comment List\n");
    
    /*
    for (Comment *comment in list)
    {
        printf("[%s - %s] %s\n", [comment.firstName UTF8String], [comment.lastName UTF8String], [comment.content UTF8String]);
    }*/
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (list.count > 0 && app.applicationState == UIApplicationStateBackground)
    {
        CommentManager *cmdM = [CommentManager getInstance];
        [cmdM notify:list];
    }
}

- (void)refreshUnreadComments:(NSNotification *)notification
{
    DBManager *dbm = [DBManager getInstance];
    
    NSInteger count = [dbm countUnreadComments];
    
    //NSLog(@"unread comment count: %d", count);
    
    dispatch_async(dispatch_get_main_queue(),^ {
        //[commentButton setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal];
        commentButton.hidden = (count == 0);
        UILabel *badgeLabel = (UILabel *)[commentButton viewWithTag:10000];
        badgeLabel.text = count > 99? @"...":[NSString stringWithFormat:@"%d", count];
    });
}

- (void)refreshGeoTaskLocation:(NSNotification *)notification
{
    DBManager *dbm = [DBManager getInstance];
    NSInteger count = [dbm countTasksAtCurrentLocation];
    dispatch_async(dispatch_get_main_queue(),^ {

        taskLocationButton.hidden = (count == 0);
        taskLocationLable.text = count > 99? @"...":[NSString stringWithFormat:@"%d", count];
    });
}

- (void)filterChange:(NSNotification *)notification
{
    if (self.inSlidingMode)
    {
        //update detail view if in sliding mode
        
        PageAbstractViewController *ctrler = [self.activeViewCtrler getActiveModule];
        
        if (ctrler != nil)
        {
            MovableView *firstView = [ctrler getFirstMovableView];
            
            if (firstView != nil)
            {
                [firstView singleTouch];
            }
            else
            {
                [self editItemDetail:nil];
            }
        }
    }
}

#pragma mark View

- (void) showGuruIsWhatsNew:(BOOL)whatsNew
{
    GuruViewController *ctrler = [[GuruViewController alloc] init];
    ctrler.whatsNew = whatsNew;
    
    [self presentViewController:ctrler animated:YES completion:nil];
    
    [ctrler release];
}

- (void) removeActiveView
{
    BOOL modalVisible = (self.presentedViewController != nil);
    
    //printf("modal is show: %s\n", modalVisible?"YES":"NO");
    
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
        
        if (modalVisible)
        {
            [self.activeViewCtrler viewWillDisappear:NO];
            [self.activeViewCtrler viewDidDisappear:NO];
        }
    }
}

- (void) showLandscapeView
{
    if (_iPadSDViewCtrler != nil)
    {
        [_iPadSDViewCtrler showModuleOff];
    }
    
    [self removeActiveView];
    
    PlannerViewController *ctrler = [[PlannerViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    [contentView addSubview:self.activeViewCtrler.view];

    [ctrler refreshTaskFilterTitle];
    
    [self refreshToolbar:UIInterfaceOrientationLandscapeLeft];

}

- (void) showPortraitView
{
    [self removeActiveView];

    self.activeViewCtrler = _iPadSDViewCtrler;
    
    [contentView addSubview:self.activeViewCtrler.view];
    
    [_iPadSDViewCtrler refreshTaskFilterTitle];
    
    [[_iPadSDViewCtrler getCalendarViewController] refreshFrame];
    
    [self refreshToolbar:UIInterfaceOrientationPortrait];
}

- (void) slideAndShowDetail
{
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
    
    for (int i=1;i<4;i++)
    {
        [[self.activeViewCtrler getModuleAtIndex:i] enableMultiEdit:!inSlidingMode];
    }
}

- (void) changeFrame:(CGRect) frm
{
    contentView.frame = frm;

    frm.size.width = 384;
    
    frm.origin.x = contentView.bounds.size.width - frm.size.width;
    frm.origin.y = 0;
    
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
    
    //frm.origin.y = 20;
    frm.size.height -= 20 + 44;
    
    [self changeFrame:frm];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
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
    
    [self refreshFilterStatus];
 
    [self.activeViewCtrler showModuleByIndex:self.selectedModuleIndex];
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
    
    [_iPadSDViewCtrler loadView];
    
    //[self showPortraitView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    firstTimeLoad = YES;
    
    [self changeSkin];
    
    [self changeOrientation:self.interfaceOrientation];
    
    [self refreshFilterStatus];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    Settings *settings = [Settings getInstance];
    
    if (settings.guruHint && firstTimeLoad)
    {
        [self showGuruIsWhatsNew:NO];
    } else if (settings.whatsNewHint) {
        [self showGuruIsWhatsNew:YES];
        settings.whatsNewHint = NO;
    }
    
    firstTimeLoad = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self changeOrientation:self.interfaceOrientation];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[[self.activeViewCtrler getCalendarViewController] stopQuickAdd];
    CalendarViewController *ctrler = [[AbstractActionViewController getInstance] getCalendarViewController];
    
    [ctrler stopQuickAdd];
    
    PageAbstractViewController *activeCtrler = [[AbstractActionViewController getInstance] getActiveModule];
    
    [activeCtrler cancelMultiEdit];
}

-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.activeViewCtrler dismissViewControllerAnimated:NO completion:nil];
    
    [self closeDetail];
    
    [_appDelegate dismissAllAlertViews];
    
    [self changeOrientation:toInterfaceOrientation];
    
    //[[[AbstractActionViewController getInstance] getSmartListViewController] refreshLayout];
    
    [self refreshUnreadComments:nil];
    
    [self refreshGeoTaskLocation:nil];
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
