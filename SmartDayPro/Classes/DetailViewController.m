//
//  DetailViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>

#import "DetailViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Task.h"
#import "Project.h"
#import "AlertData.h"
#import "Comment.h"

#import "DBManager.h"
#import "ProjectManager.h"
#import "TagDictionary.h"
#import "TaskLinkManager.h"
#import "TaskManager.h"

#import "ContentView.h"
//#import "HPGrowingTextView.h"
#import "GrowingTextView.h"
#import "NoteView.h"

#import "DurationInputViewController.h"
#import "DateInputViewController.h"
#import "ProjectInputViewController.h"

#import "WWWTableViewController.h"
#import "RepeatTableViewController.h"
#import "TaskNoteViewController.h"
#import "TagEditViewController.h"
#import "TimerHistoryViewController.h"
#import "AlertListViewController.h"
#import "LinkViewController.h"
#import "PreviewViewController.h"
#import "CommentViewController.h"
#import "TimeZonePickerViewController.h"

#import "iPadViewController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"
#import "SmartDayViewController.h"

#import "HintModalViewController.h"
#import "LocationListViewController.h"
#import "Location.h"
#import "TaskLocationListViewController.h"

#import "FontManager.h"

#define HEIGHT_DEFAULT_CELL 40
#define PADDING_LEFT 15
#define WIDTH_RIGHT_BUTTON_CELL 40

//#import "NoteDetailTableViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

extern iPadViewController *_iPadViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

DetailViewController *_detailViewCtrler = nil;

@interface DetailViewController () {
    UIInterfaceOrientation _currentOrientation;
}

@end

@implementation DetailViewController

@synthesize task;
@synthesize taskCopy;
@synthesize previewViewCtrler;

@synthesize inputViewCtrler;

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
        self.inputViewCtrler = nil;
        self.previewViewCtrler = nil;
        
        showAll = _isiPad?YES:NO;
	}
	
	return self;
}

- (void)dealloc
{
	self.task = nil;
	self.taskCopy = nil;
    
    self.inputViewCtrler = nil;
    self.previewViewCtrler = nil;
    
    [titleTextView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (inputViewCtrler != nil) {
        [self showInputView:inputViewCtrler];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)changeSkin
{
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    //frm = CGRectInset(contentView.bounds, 5, 5);
    
    frm = contentView.bounds;
    frm.size.width -= 10;
    
    detailTableView.frame = frm;
    
    titleTextView.frame = CGRectMake(0, 0, frm.size.width-20-30, 30);
    
    //inputView.frame = CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300);
    
    frm = CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300);
    
    inputView.frame = frm;

}

- (void) refreshToolbar {
    UIButton *btnDone = [[UIButton alloc] init];
    [btnDone setTitle:_doneText forState:UIControlStateNormal];
    [btnDone setTitle:_doneText forState:UIControlStateSelected];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnDone addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    [btnDone release];
    
    self.navigationItem.leftBarButtonItem = doneItem;
    [doneItem release];
    
    if (self.task == nil || (self.task.primaryKey == -1 && self.task.original == nil))
    {
        self.navigationItem.rightBarButtonItems = nil;
        return;
    }
    
//    CGFloat iconSize = _isiPad ? 30 : 28;
    CGFloat iconSize = SIZE_ICON_TOPBAR;
    
    // Create Delete button
    UIImage *deleteImageIcon = [FontManager flowasticImageWithIconName:@"delete"
                                                               andSize:SIZE_ICON_TOPBAR
                                                             iconColor:[UIColor whiteColor]];
    
    UIButton *deleteButton = [Common createButtonWith:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, iconSize, iconSize)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(delete:)
                                 normalStateImage:deleteImageIcon
                               selectedStateImage:nil];

    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    // Create Copy button
    UIImage *copyImageIcon = [FontManager flowasticImageWithIconName:@"compy"
                                                               andSize:22
                                                             iconColor:[UIColor whiteColor]];
    
    UIButton *copyButton = [Common createButtonWith:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, iconSize, iconSize)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(copy:)
                                   normalStateImage:copyImageIcon
                                 selectedStateImage:nil];
    
    UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
    
    starButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(0, 0, iconSize, iconSize)
                                     titleColor:[UIColor whiteColor]
                                         target:self
                                       selector:@selector(star:)
                               normalStateImage:[self.taskCopy isStar]?@"menu_star_yellow.png":@"menu_star_white.png"
                             selectedStateImage:nil];
    
    UIBarButtonItem *starItem = [[UIBarButtonItem alloc] initWithCustomView:starButton];
    
    UIButton *deferButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, iconSize, iconSize)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(defer:)
                                normalStateImage:@"menu_defer_white.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *deferItem = [[UIBarButtonItem alloc] initWithCustomView:deferButton];
    
    UIButton *todayButton = [Common createButton:@""
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(0, 0, iconSize, iconSize)
                                      titleColor:[UIColor whiteColor]
                                          target:self
                                        selector:@selector(doToday:)
                                normalStateImage:@"menu_dotoday_white.png"
                              selectedStateImage:nil];
    
    UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithCustomView:todayButton];
    
    UIButton *markDoneButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, iconSize, iconSize)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(markDone:)
                                   normalStateImage:@"menu_done_white.png"
                                 selectedStateImage:nil];
    
    UIBarButtonItem *markDoneItem = [[UIBarButtonItem alloc] initWithCustomView:markDoneButton];
    
    // Create AirDrop button
    UIImage *airdropImageIcon = [FontManager flowasticImageWithIconName:@"airdrop"
                                                                andSize:SIZE_ICON_TOPBAR
                                                              iconColor:[UIColor whiteColor]];
    
    UIButton *airDropButton = [Common createButtonWith:@""
                                             buttonType:UIButtonTypeCustom
                                                 frame:CGRectMake(0, 0, iconSize, iconSize)
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                              selector:@selector(share2AirDrop:)
                                      normalStateImage:airdropImageIcon
                                    selectedStateImage:nil];
    
    UIBarButtonItem *airDropItem = [[UIBarButtonItem alloc] initWithCustomView:airDropButton];
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = _isiPad ? 10 : iconSize;
    
    NSMutableArray *items = [self.taskCopy isEvent]?[NSMutableArray arrayWithObjects:deleteItem, fixedItem, copyItem, fixedItem, nil]:([self.task isShared]?[NSMutableArray arrayWithObject:markDoneItem]:[NSMutableArray arrayWithObjects:deleteItem, fixedItem, copyItem, fixedItem, starItem, fixedItem, deferItem, fixedItem, todayItem, fixedItem, markDoneItem, nil]);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [items addObject:airDropItem];
    }
    
    self.navigationItem.rightBarButtonItems = items;
    
    [copyItem release];
    [deleteItem release];
    [starItem release];
    [deferItem release];
    [todayItem release];
    [markDoneItem release];
    [airDropItem release];
    [fixedItem release];
}

- (void) refreshData
{
	if (task.original != nil && ![task isREException]) //Calendar Task or REException
	{
        //printf("task original: %s\n", [[task.original name] UTF8String]);
        
		self.taskCopy = task.original;
    }
	else
	{
		self.taskCopy = task;
	}
    
	if ([self.taskCopy isEvent])
    {
        if ((self.taskCopy.startTime == nil || self.taskCopy.endTime == nil)) // new Event
        {
            self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:[NSDate date]];
            self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
            
        }
        else if ([task isREInstance])
        {
            NSTimeInterval reDuration = [task.original.endTime timeIntervalSinceDate:task.original.startTime];
            
            self.taskCopy.startTime = task.reInstanceStartTime;
            self.taskCopy.endTime = [task.reInstanceStartTime dateByAddingTimeInterval:reDuration];
        }
        else if (self.task.isSplitted)
        {
            Task *longEvent = [[Task alloc] initWithPrimaryKey:self.task.primaryKey database:[[DBManager getInstance] getDatabase]];
            
            self.taskCopy.startTime = longEvent.startTime;
            self.taskCopy.endTime = longEvent.endTime;
            
            [longEvent release];
        }
	}

    titleTextView.text = self.taskCopy.name;
    
    self.previewViewCtrler.item = self.taskCopy;
    
    [self.previewViewCtrler refreshData];
    
    [detailTableView reloadData];
    
    [self refreshToolbar];
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation) && _isiPad)
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + (_isiPad?2*44:44);
    
    frm.size.width = _isiPad?384:320;
    
    [self changeFrame:frm];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frm.size.height = frm.size.width - 20;
    }
    
    frm.size.width = _isiPad ? 384 : frm.size.width;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor clearColor];
	
	self.view = contentView;
	[contentView release];
    
    frm = CGRectInset(contentView.bounds, 5, 5);
    
    detailTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    detailTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
	detailTableView.delegate = self;
	detailTableView.dataSource = self;
    detailTableView.backgroundColor = [UIColor whiteColor];
	
	[contentView addSubview:detailTableView];
	[detailTableView release];
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300)];
    inputView.hidden = YES;
    
    [contentView addSubview:inputView];
    [inputView release];
    
	//titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width-20-30, 30)];
	titleTextView = [[GrowingTextView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width-20-30, 30)];
    //titleTextView.placeholder = _titleGuideText;
    
	//titleTextView.minNumberOfLines = 1;
	//titleTextView.maxNumberOfLines = 4;
    titleTextView.maxLineNumber = 4;
	//titleTextView.returnKeyType = UIReturnKeyDone; //just as an example
    titleTextView.textView.returnKeyType = UIReturnKeyDone; //just as an example
	//titleTextView.font = [UIFont systemFontOfSize:15.0f];
    titleTextView.font = [UIFont systemFontOfSize:15.0f];
	titleTextView.delegate = self;
    titleTextView.backgroundColor = [UIColor clearColor];
    
    self.previewViewCtrler = [[[PreviewViewController alloc] init] autorelease];
    
    // show comment when this is shared
    showComments = [[DBManager getInstance] countCommentsForItem:self.task.primaryKey];//[[[ProjectManager getInstance] getProjectByKey:self.task.project] isOwner];
    
    [self refreshData];
    
    [self changeSkin];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isiPad) {
        [self changeOrientation:_iPadViewCtrler.interfaceOrientation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _detailViewCtrler = self;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _detailViewCtrler = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:tag];
        }
		
		[self tagInputReset];
	}
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
    
	//tagInputTextField.placeholder = self.taskCopy.tag;
    tagInputTextField.placeholder = [self.taskCopy getCombinedTag];
	
	[tagInputTextField resignFirstResponder];
	
	TagDictionary *dict = [TagDictionary getInstance];
	
	int j = 0;
	
	NSDictionary *prjDict = [ProjectManager getProjectDictionaryByName];
	
	for (NSString *tag in [dict.presetTagDict allKeys])
	{
		[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
		[tagButtons[j] setTitleColor:COLOR_BORDER_TAG_OBJECT_DETAIL forState:UIControlStateNormal];
		[tagButtons[j] setEnabled:YES];
		
		Project *prj = [prjDict objectForKey:tag];
		
		if (prj != nil)
		{
			NSDictionary *tagDict = [TagDictionary getTagDict:prj.tag];
			
			if ([tagDict objectForKey:tag] != nil) //Project has the tag with the same name as Project name
			{
				[tagButtons[j] setTitleColor:[Common getColorByID:prj.colorId colorIndex:0]  forState:UIControlStateNormal];
			}
		}
		
		j++;
	}
	
	for (;j<9;j++)
	{
		[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
		
		[tagButtons[j] setEnabled:NO];
	}
}

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = [self.taskCopy getCombinedTag];
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) createLinkedNote:(Task *)note
{
    if (self.taskCopy != nil)
    {
        TaskLinkManager *tlm = [TaskLinkManager getInstance];
        
        NSInteger itemId = self.taskCopy.primaryKey;
        
        if (self.taskCopy.original != nil && ![self.taskCopy isREException])
        {
            itemId = self.taskCopy.original.primaryKey;
        }
        
        NSInteger linkId = [tlm createLink:itemId destId:note.primaryKey destType:ASSET_ITEM];
        
        if (linkId != -1)
        {
            [self.taskCopy.links insertObject:[NSNumber numberWithInteger:linkId] atIndex:0];
        }
        
        [self.previewViewCtrler refreshData];
    }
}

- (void) close
{
    if (_isiPad)
    {
        [_iPadViewCtrler closeDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) finishEdit
{
    [self growingTextViewDidEndEditing:titleTextView];
    
    UITableViewCell *cell = [detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UITextField *taskLocation = (UITextField * )[cell.contentView viewWithTag:10000+2];
    
    if (taskLocation != nil)
    {
        //[taskLocation resignFirstResponder];
        [self textFieldDidEndEditing:taskLocation];
    }
    
    BOOL checkChange = [self.task checkChange:self.taskCopy];
    
    if (![self.task isShared] && checkChange)
    {
        [[AbstractActionViewController getInstance] updateTask:self.task withTask:self.taskCopy];
        
        if (!_isiPad && self.navigationController.viewControllers.count - 2 > 0)
        {
            UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            
            if ([ctrler isKindOfClass:[TaskLocationListViewController class]])
            {
                [(TaskLocationListViewController *)ctrler refreshData];
            }
        }
    }
    
    if (self.previewViewCtrler != nil) {
        [self.previewViewCtrler finishEdit];
        [[AbstractActionViewController getInstance] refreshData];
    }
}
#pragma  mark Actions
- (void) done:(id) sender
{
    [self finishEdit];
    
    [self close];
}

- (void) delete:(id)sender
{
    [[AbstractActionViewController getInstance] deleteTask];
    
    [self close];
}

- (void) copy:(id)sender
{
    self.task = [[AbstractActionViewController getInstance] copyTask:self.task];
    
    [self refreshData];
    
    [detailTableView reloadData];
}

- (void) star:(id)sender
{
    /*
    if (self.task.primaryKey == -1)
    {
        self.taskCopy.status = (self.taskCopy.status == TASK_STATUS_NONE?TASK_STATUS_PINNED:TASK_STATUS_NONE);
        
        [starButton setImage:[UIImage imageNamed:(self.taskCopy.status == TASK_STATUS_PINNED?@"menu_star_yellow.png":@"menu_star_white.png")] forState:UIControlStateNormal];
    }
    else
    {
        [[AbstractActionViewController getInstance] starTask];
    
        [self close];
    }*/
    
    self.taskCopy.status = (self.taskCopy.status == TASK_STATUS_NONE?TASK_STATUS_PINNED:TASK_STATUS_NONE);
    
    [starButton setImage:[UIImage imageNamed:(self.taskCopy.status == TASK_STATUS_PINNED?@"menu_star_yellow.png":@"menu_star_white.png")] forState:UIControlStateNormal];

    if (self.task.primaryKey != -1)
    {
        [self done:nil];
    }
}

- (void) defer:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_deferText
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:_cancelText
                                              otherButtonTitles:_nextWeekText, _nextMonthText,nil];
    alertView.tag = -10000;
    [alertView show];
    [alertView release];
}

- (void) doToday:(id) sender
{
    [self finishEdit];
    
    [[AbstractActionViewController getInstance] moveTask2Top];
    
    [self close];
}

- (void) markDone:(id)sender
{
    [self finishEdit];
    
    [[AbstractActionViewController getInstance] markDoneTask];
    
    [self close];
}

- (void) share2AirDrop:(id) sender
{
    NSString *urlString = [[AbstractActionViewController getInstance] share2AirDropForDetailView];
    
    if ([urlString isEqualToString:@""])
        return;
    
     NSURL *url = [NSURL URLWithString:urlString];
     
     NSArray *activityItems = @[url];
     UIActivityViewController *activityController =
     [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];
     
     activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo];
     
     UIViewController *ctrler = (_isiPad?_iPadViewCtrler:_sdViewCtrler);
     
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && _isiPad) {
     activityController.popoverPresentationController.sourceView = ctrler.view;
     CGRect rect = ctrler.view.bounds;
     activityController.popoverPresentationController.sourceRect = CGRectMake(rect.size.width/4, rect.size.height, rect.size.width/2, rect.size.height/2);
     }
     
     [activityController setCompletionHandler:^(NSString *activityType, BOOL completed)
     {
     //finish your code when the user finish or dismiss...
         if (completed)
         {
             NSLog(@"airdrop done");
            [[AbstractActionViewController getInstance] clearActiveItems];
             [self finishEdit];
             [self close];
         }
         else
         {
             NSLog(@"airdrop cancelled");
         }
     }];
     
     [ctrler presentViewController:activityController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -10000 && buttonIndex != 0)
	{
        [self finishEdit];
        
        [[AbstractActionViewController getInstance] defer:buttonIndex];
        
        [self close];
    }
}

#pragma  mark Edit
- (void)editTitle:(id) sender
{
    [titleTextView resignFirstResponder];
    
	WWWTableViewController *ctrler = [[WWWTableViewController alloc] init];
	ctrler.task = self.taskCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void)editLocation: (id)sender
{
    if (_isiPad)
    {
        [_iPadViewCtrler editMapLocation:self.taskCopy];
    }
    else
    {
        [_sdViewCtrler editMapLocation:self.taskCopy];
    }
}

- (void)selectLocation: (id)sender
{
    LocationListViewController *ctrler = [[LocationListViewController alloc] init];
    ctrler.taskEdit = self.taskCopy;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    [ctrler release];
}

-(void) editDuration
{
    if (![self.task isShared])
    {
        DurationInputViewController *ctrler = [[DurationInputViewController alloc] initWithNibName:@"DurationInputViewController" bundle:nil];
        ctrler.task = self.taskCopy;
        
        [self showInputView:ctrler];
        
        [ctrler release];
    }
}

- (void) editWhen:(id) sender
{
    if (![self.task isShared])
    {
        UIButton *btn = (UIButton *)sender;
        
        DateInputViewController *ctrler = [[DateInputViewController alloc] initWithNibName:@"DateInputViewController" bundle:nil];
        ctrler.task = self.taskCopy;
        ctrler.dateEdit = (btn.tag == 10300+8?TASK_EDIT_START:([self.taskCopy isTask]?TASK_EDIT_DEADLINE:TASK_EDIT_END));
        
        [self showInputView:ctrler];
        
        [ctrler release];
    }
}

- (void) editTimeZone:(id) sender
{
    TimeZonePickerViewController *ctrler = [[TimeZonePickerViewController alloc] init];
    ctrler.objectEdit = self.taskCopy;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void)editRepeat
{
    if ([self.taskCopy isREException])
    {
        return;
    }

    if (![self.task isShared])
    {
        RepeatTableViewController *ctrler = [[RepeatTableViewController alloc] init];
        ctrler.task = self.taskCopy;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}

- (void)editProject
{
    if (![self.task isShared])
    {
        ProjectInputViewController *ctrler = [[ProjectInputViewController alloc] init];
        ctrler.task = self.taskCopy;
        
        [self showInputView:ctrler];
        [ctrler release];
    }
}

- (void)editDescription
{
    if (![self.task isShared])
    {
        TaskNoteViewController *ctrler = [[TaskNoteViewController alloc] init];
        ctrler.task = self.taskCopy;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}

- (void) editTag:(id) sender
{
    if (![self.task isShared])
    {
        TagEditViewController *ctrler = [[TagEditViewController alloc] init];
        
        ctrler.objectEdit = self.taskCopy;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}

- (void)editAlert
{
    if (![self.task isShared])
    {
        AlertListViewController *ctrler = [[AlertListViewController alloc] init];
        ctrler.taskEdit = self.taskCopy;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}

- (void)editLink:(id)sender
{
    if (![self.task isShared])
    {
        LinkViewController *ctrler = [[LinkViewController alloc] init];
        
        Task *tmp = (self.taskCopy.original != nil && ![self.taskCopy isREException])?self.taskCopy.original:self.taskCopy;
        
        ctrler.task = tmp;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}

- (void) editAsset:(Task *)asset
{
    if (![self.task isShared])
    {
        DetailViewController *ctrler = [[DetailViewController alloc] init];
        ctrler.task = asset;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        
        [ctrler release];
    }
}

- (void) editComment
{
	CommentViewController *ctrler = [[CommentViewController alloc] init];
    ctrler.itemId = self.taskCopy.primaryKey;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) showTimerHistory
{
	TimerHistoryViewController *ctrler = [[TimerHistoryViewController alloc] init];
    ctrler.task = self.taskCopy;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) showAll
{
    showAll = YES;
    
    [detailTableView reloadData];
}

#pragma mark Refresh
- (void) refreshTitle
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:0 section:0];
    [self refreshAlert];
}

- (void) refreshDuration
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:1 section:0];
}

- (void) refreshProject
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:([self.taskCopy isTask] ? 2:1) section:0];
}

- (void) refreshWhen
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:3 section:0];
    
    [self refreshAlert];
}

- (void) refreshUntil
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:4 section:0];
}

- (void) refreshAlert
{
    if (showAll)
    {
        /*
        [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
        
        [Common reloadRowOfTable:detailTableView row:5 section:0];
    }
}

- (void) refreshDescription
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:6 section:0];
}

- (void) refreshTag
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:7 section:0];
}

- (void) refreshLink
{
    /*
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:showAll?([self.task isShared]?11:10):([self.task isShared]?7:6) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    */
    
    [Common reloadRowOfTable:detailTableView row:(showAll?(showComments?11:10):(showComments?7:6)) section:0];
    
}

- (void)refreshHeightForTableCell
{
    [detailTableView beginUpdates];
    [detailTableView endUpdates];
}

#pragma mark Input Views
-(void) showInputView:(UIViewController *)ctrler
{
    [titleTextView.textView resignFirstResponder];
    
    [self.inputViewCtrler willMoveToParentViewController:nil];
    [[inputView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.inputViewCtrler removeFromParentViewController];
    
    self.inputViewCtrler = ctrler;
    
    [self addChildViewController:self.inputViewCtrler];
    
    ctrler.view.frame = inputView.bounds;
    
    [inputView addSubview:ctrler.view];
    
    [ctrler didMoveToParentViewController:self];
    
    inputView.hidden = NO;
    
    [contentView bringSubviewToFront:inputView];

	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
}

- (void) closeInputView
{
    if (self.inputViewCtrler != nil)
    {
        [self.inputViewCtrler.view removeFromSuperview];
        
        inputView.hidden = YES;
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        self.inputViewCtrler = nil;
    }
}

#pragma mark Actions
+ (ABPeoplePickerNavigationController *)sharedPeoplePicker {
    static ABPeoplePickerNavigationController *_sharedPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPicker = [[ABPeoplePickerNavigationController alloc] init];
    });
    
    return _sharedPicker;
}

- (void) selectContact:(id) sender
{
	ABPeoplePickerNavigationController *contactList = [DetailViewController sharedPeoplePicker];
	contactList.peoplePickerDelegate = self;
    
    contactList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [_isiPad?_iPadViewCtrler:_sdViewCtrler presentViewController:contactList animated:YES completion:^{
        _currentOrientation = [_isiPad?_iPadViewCtrler:_sdViewCtrler interfaceOrientation];
    }];
    
	//[contactList release];
}

- (void) changeADE:(id)sender {
//    UISegmentedControl *segment = (UISegmentedControl *)sender;
//    self.taskCopy.type = (segment.selectedSegmentIndex == 0? TYPE_ADE: TYPE_EVENT);
    
    UISwitch *switchADE = (UISwitch *)sender;
    
    self.taskCopy.type = switchADE.on ? TYPE_ADE : TYPE_EVENT;
	
    self.taskCopy.timeZoneId = [Settings findTimeZoneID:[NSTimeZone defaultTimeZone]];
    
    if (self.taskCopy.type == TYPE_ADE)
    {
		self.taskCopy.startTime = [Common clearTimeForDate:self.taskCopy.startTime];
        self.taskCopy.endTime = [Common getEndDate:self.taskCopy.endTime];
        self.taskCopy.alerts = [NSMutableArray arrayWithCapacity:0];
        
        self.taskCopy.timeZoneId = 0;
    }
    else
    {
        TaskManager *tm = [TaskManager getInstance];
        
        self.taskCopy.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
        self.taskCopy.endTime = [Common dateByAddNumSecond:3600 toDate:self.taskCopy.startTime];
    }
    
    [self refreshWhen];
}

#pragma mark Task Cell Creation
- (void)createTitleCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    cell.accessoryType = UITableViewCellAccessoryNone;

    // Update OriginX for Title field
    CGRect frameTitle = titleTextView.frame;
    frameTitle.origin.x = 12;
    frameTitle.size.width = detailTableView.frame.size.width - frameTitle.origin.x - WIDTH_RIGHT_BUTTON_CELL;
    titleTextView.frame = frameTitle;
    titleTextView.tag = baseTag;
    titleTextView.text = self.taskCopy.name;
    [cell.contentView addSubview:titleTextView];
    
    // Infor button
    UIImage *infoImageIcon = [FontManager flowasticImageWithIconName:@"info"
                                                             andSize:SIZE_ICON_ON_CELL
                                                           iconColor:COLOR_ICON_OBJECT_DETAIL];
    
    CGRect editFrame = CGRectMake(detailTableView.frame.size.width - WIDTH_RIGHT_BUTTON_CELL, 0, WIDTH_RIGHT_BUTTON_CELL, 34);
    UIButton *editTitleButton = [Common createButtonWith:nil
                                              buttonType:UIButtonTypeCustom
                                                   frame:editFrame
                                              titleColor:nil
                                                  target:self
                                                selector:@selector(editTitle:)
                                        normalStateImage:infoImageIcon
                                      selectedStateImage:nil];
    editTitleButton.tag = baseTag + 3;
    [cell.contentView addSubview:editTitleButton];

    // Separator line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleTextView.bounds.size.height, detailTableView.frame.size.width, 0.5)];
    lineView.backgroundColor = COLOR_LINE;
    [cell.contentView addSubview:lineView];
    [lineView release];
    
    CGFloat originY = titleTextView.bounds.size.height + lineView.frame.size.height;
    
    // Label @
    UILabel *atLable = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, originY, 25, HEIGHT_DEFAULT_CELL)];
    atLable.textColor = COLOR_TEXT_OBJECT_DETAIL;
    atLable.textAlignment = NSTextAlignmentLeft;
    atLable.text = @"@";
    [cell.contentView addSubview:atLable];
    [atLable release];
    
	// Add Location field
    NSInteger taskLocationOriginX = PADDING_LEFT + atLable.frame.size.width;
	UITextField *taskLocation = [[UITextField alloc] initWithFrame:CGRectMake(taskLocationOriginX, originY, detailTableView.frame.size.width - taskLocationOriginX - WIDTH_RIGHT_BUTTON_CELL*3, HEIGHT_DEFAULT_CELL)];
	taskLocation.font=[UIFont systemFontOfSize:16];
	taskLocation.textColor=[UIColor blackColor];
	taskLocation.keyboardType=UIKeyboardTypeDefault;
	taskLocation.returnKeyType = UIReturnKeyDone;
    taskLocation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_addLocationFromText
                                                                    attributes:@{NSForegroundColorAttributeName:COLOR_ICON_OBJECT_DETAIL}];
	taskLocation.textAlignment=NSTextAlignmentLeft;
	taskLocation.backgroundColor=[UIColor clearColor];
	taskLocation.clearButtonMode=UITextFieldViewModeWhileEditing;
	//taskLocation.enabled=NO;
	taskLocation.delegate=self;
	taskLocation.tag = baseTag + 2;
	taskLocation.text = self.taskCopy.location;
    
	[cell.contentView addSubview:taskLocation];
	[taskLocation release];

    // Location list button
    UIImage *locationImageIcon = [FontManager flowasticImageWithIconName:@"location"
                                                             andSize:SIZE_ICON_ON_CELL
                                                           iconColor:COLOR_ICON_OBJECT_DETAIL];
    
    CGRect locationFrame = CGRectMake(detailTableView.frame.size.width - 3*WIDTH_RIGHT_BUTTON_CELL, taskLocation.frame.origin.y, WIDTH_RIGHT_BUTTON_CELL, HEIGHT_DEFAULT_CELL);
    UIButton *locationButton = [Common createButtonWith:nil
                                            buttonType:UIButtonTypeCustom
                                                 frame:locationFrame
                                            titleColor:nil
                                                target:self
                                              selector:@selector(selectLocation:)
                                      normalStateImage:locationImageIcon
                                    selectedStateImage:nil];
    locationButton.tag = baseTag + 4;
    [cell.contentView addSubview:locationButton];
    
    // Contact button
    UIImage *contactImageIcon = [FontManager flowasticImageWithIconName:@"contact"
                                                                 andSize:SIZE_ICON_ON_CELL
                                                               iconColor:COLOR_ICON_OBJECT_DETAIL];
    
    CGRect contactFrame = CGRectMake(detailTableView.frame.size.width - 2*WIDTH_RIGHT_BUTTON_CELL, taskLocation.frame.origin.y, WIDTH_RIGHT_BUTTON_CELL, HEIGHT_DEFAULT_CELL);
    UIButton *contactButton = [Common createButtonWith:nil
                                                 buttonType:UIButtonTypeCustom
                                                      frame:contactFrame
                                                 titleColor:nil
                                                     target:self
                                                   selector:@selector(selectContact:)
                                           normalStateImage:contactImageIcon
                                         selectedStateImage:nil];
    contactButton.tag = baseTag + 1;
    [cell.contentView addSubview:contactButton];
    
    // Map button
    UIImage *mapImageIcon = [FontManager flowasticImageWithIconName:@"map"
                                                                andSize:SIZE_ICON_ON_CELL
                                                              iconColor:COLOR_ICON_OBJECT_DETAIL];
    
    CGRect mapFrame = CGRectMake(detailTableView.frame.size.width - WIDTH_RIGHT_BUTTON_CELL, taskLocation.frame.origin.y, WIDTH_RIGHT_BUTTON_CELL, HEIGHT_DEFAULT_CELL);
    UIButton *editLocationButton = [Common createButtonWith:nil
                                                 buttonType:UIButtonTypeCustom
                                                      frame:mapFrame
                                                 titleColor:nil
                                                     target:self
                                                   selector:@selector(editLocation:)
                                           normalStateImage:mapImageIcon
                                         selectedStateImage:nil];
	
	editLocationButton.tag = baseTag + 5;
	[cell.contentView addSubview:editLocationButton];
    
    // Infor of location
//    Location *location = [[Location alloc] initWithPrimaryKey:self.taskCopy.locationID database:[[DBManager getInstance] getDatabase]];
//    if (location.primaryKey > 0 && [self.taskCopy.location isEqualToString:location.address]) {
//        taskLocation.text = location.address;
//        self.taskCopy.location = location.address;
//    }
//    else {
//        self.taskCopy.locationID = 0;
//        self.task.locationID = 0;
//    }
//    [location release];
}

- (void) createDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = _durationText;
    //cell.textLabel.textColor = [UIColor grayColor];
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.detailTextLabel.text = [Common getDurationString:self.taskCopy.duration];
    //cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void)createProjectCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = _projectText;
    cell.textLabel.textColor = [UIColor blackColor];

	ProjectManager *pm = [ProjectManager getInstance];
	Project *prj = [pm getProjectByKey:self.taskCopy.project];
    
    cell.detailTextLabel.text = prj.name;
    cell.detailTextLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
}

- (void)createADECell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = COLOR_BACKGROUND_HEADER_MINI_MONTH;
    cell.textLabel.text = _allDayText;
    cell.textLabel.textColor = [UIColor blackColor];
     
//    NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
//    UISegmentedControl *adeSegmentedCtrl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
//    adeSegmentedCtrl.frame = CGRectMake(detailTableView.bounds.size.width-110, 5, 100, 30);
//    [adeSegmentedCtrl addTarget:self action:@selector(changeADE:) forControlEvents:UIControlEventValueChanged];
//    adeSegmentedCtrl.selectedSegmentIndex = ([self.taskCopy isADE]?0:1);
//
//    [cell.contentView addSubview:adeSegmentedCtrl];
//    [adeSegmentedCtrl release];
    
    UISwitch *adeSwitch = [[UISwitch alloc] init];
    [adeSwitch addTarget:self action:@selector(changeADE:) forControlEvents:UIControlEventValueChanged];
    [adeSwitch setOn:([self.taskCopy isADE] ? YES : NO) animated:YES];
    
    cell.accessoryView = adeSwitch;
    [adeSwitch release];
}

- (void) createStartDueCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.backgroundColor = [UIColor colorWithRed:223.0/255 green:223.0/255 blue:223.0/255 alpha:1];

    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.text = _startText;
    startLabel.textColor = [UIColor grayColor];
    startLabel.font = [UIFont systemFontOfSize:16];
    
    startLabel.tag = baseTag;
    
    [cell.contentView addSubview:startLabel];
    [startLabel release];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40, self.taskCopy.startTime == nil?70:(_isiPad?40:35), 30)];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.text = self.taskCopy.startTime == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.startTime]];
    dayLabel.textColor = [UIColor darkGrayColor];
    dayLabel.font = [UIFont boldSystemFontOfSize:_isiPad?28:24];
    
    dayLabel.tag = baseTag+1;
    
    [cell.contentView addSubview:dayLabel];
    [dayLabel release];
    
    UILabel *wkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(_isiPad?50:40, 35, 200, 20)];
    wkdayLabel.backgroundColor = [UIColor clearColor];
    wkdayLabel.text = self.taskCopy.startTime == nil?@"":[Common getFullWeekdayString:self.taskCopy.startTime];
    wkdayLabel.textColor = [UIColor darkGrayColor];
    wkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    wkdayLabel.tag = baseTag+2;
    
    [cell.contentView addSubview:wkdayLabel];
    [wkdayLabel release];
    
    UILabel *monYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(_isiPad?50:40, 55, 200, 20)];
    monYearLabel.backgroundColor = [UIColor clearColor];
    monYearLabel.text = self.taskCopy.startTime == nil?@"":[Common getMonthYearString:self.taskCopy.startTime];
    monYearLabel.textColor = [UIColor darkGrayColor];
    monYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    monYearLabel.tag = baseTag+3;
    
    [cell.contentView addSubview:monYearLabel];
    [monYearLabel release];
    
    CGFloat xMargin = detailTableView.bounds.size.width/2;
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(xMargin, 5, 1, 70)];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    
    [cell.contentView addSubview:separatorView];
    [separatorView release];
    
    UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(xMargin+5, 10, 100, 20)];
    dueLabel.backgroundColor = [UIColor clearColor];
    dueLabel.text = _dueText;
    dueLabel.textColor = [UIColor grayColor];
    dueLabel.font = [UIFont systemFontOfSize:16];
    
    dueLabel.tag = baseTag+4;
    
    [cell.contentView addSubview:dueLabel];
    [dueLabel release];
    
    UILabel *dueDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(xMargin+5, 40, self.taskCopy.deadline == nil?70:(_isiPad?40:35), 30)];
    dueDayLabel.backgroundColor = [UIColor clearColor];
    dueDayLabel.textAlignment = NSTextAlignmentRight;
    dueDayLabel.text = self.taskCopy.deadline == nil? _noneText:[NSString stringWithFormat:@"%d",[Common getDay:self.taskCopy.deadline]];
    dueDayLabel.textColor = [UIColor darkGrayColor];
    dueDayLabel.font = [UIFont boldSystemFontOfSize:_isiPad?28:24];
    
    dueDayLabel.tag = baseTag+5;
    
    [cell.contentView addSubview:dueDayLabel];
    [dueDayLabel release];
    
    UILabel *dueWkdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(xMargin+(_isiPad?50:40), 35, 200, 20)];
    dueWkdayLabel.backgroundColor = [UIColor clearColor];
    dueWkdayLabel.text = self.taskCopy.deadline == nil?@"":[Common getFullWeekdayString:self.taskCopy.deadline];
    dueWkdayLabel.textColor = [UIColor darkGrayColor];
    dueWkdayLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueWkdayLabel.tag = baseTag+6;
    
    [cell.contentView addSubview:dueWkdayLabel];
    [dueWkdayLabel release];
    
    UILabel *dueMonYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(xMargin+(_isiPad?50:40), 55, 200, 20)];
    dueMonYearLabel.backgroundColor = [UIColor clearColor];
    dueMonYearLabel.text = self.taskCopy.deadline == nil?@"":[Common getMonthYearString:self.taskCopy.deadline];
    dueMonYearLabel.textColor = [UIColor darkGrayColor];
    dueMonYearLabel.font = [UIFont boldSystemFontOfSize:15];
    
    dueMonYearLabel.tag = baseTag+7;
    
    [cell.contentView addSubview:dueMonYearLabel];
    [dueMonYearLabel release];
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    startButton.frame = CGRectMake(0, 0, xMargin, 80);
    startButton.backgroundColor = [UIColor clearColor];
    startButton.tag = baseTag + 8;
    [startButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:startButton];
    
    UIButton *dueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    dueButton.frame = CGRectMake(xMargin, 0, xMargin, 80);
    dueButton.backgroundColor = [UIColor clearColor];
    dueButton.tag = baseTag + 9;
    [dueButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:dueButton];
}

- (void)createStartEndCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = COLOR_BACKGROUND_HEADER_MINI_MONTH;
    Settings *settings = [Settings getInstance];
    CGFloat yMargin = 0;
    NSDate *startTime = self.taskCopy.startTime;
    NSDate *endTime = self.taskCopy.endTime;
    NSInteger widthDisclosureIcon = 30;

    if (settings.timeZoneSupport && [self.taskCopy isNormalEvent]) {
        
        // Time Zone label
        UILabel *tzLabel=[[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, 0, 80, HEIGHT_DEFAULT_CELL)];
        tzLabel.tag = baseTag + 10;
        tzLabel.text = _timeZone;
        tzLabel.backgroundColor = [UIColor clearColor];
        tzLabel.font = [UIFont systemFontOfSize:16];
        tzLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:tzLabel];
        [tzLabel release];
        
        NSInteger originXTimeZone = tzLabel.frame.origin.x + tzLabel.frame.size.width;
        CGRect frameTimeZoneValue = CGRectMake(originXTimeZone, 0, detailTableView.frame.size.width - originXTimeZone - widthDisclosureIcon, HEIGHT_DEFAULT_CELL);
        UILabel *tzValueLabel = [[UILabel alloc] initWithFrame:frameTimeZoneValue];
        tzValueLabel.tag = baseTag + 11;
        tzValueLabel.textAlignment = NSTextAlignmentRight;
        tzValueLabel.textColor = COLOR_TEXT_OBJECT_DETAIL;
        tzValueLabel.font = [UIFont systemFontOfSize:16];
        tzValueLabel.backgroundColor = [UIColor clearColor];
        tzValueLabel.text = [Settings getTimeZoneDisplayNameByID: self.taskCopy.timeZoneId];
        [cell.contentView addSubview:tzValueLabel];
        [tzValueLabel release];
        
        // Disclosure icon
        UIImage *imageArrowRight = [FontManager flowasticImageWithIconName:@"arrow-right"
                                                                   andSize:14
                                                                 iconColor:hexColor(0xD1D1D6)];
        
        NSInteger originXDisclosureIcon = detailTableView.frame.size.width - widthDisclosureIcon;
        CGRect frameDisclosureIcon = CGRectMake(originXDisclosureIcon, 0, widthDisclosureIcon, HEIGHT_DEFAULT_CELL);
        UIImageView *detailImgView = [[UIImageView alloc] initWithFrame:frameDisclosureIcon];
        detailImgView.image = imageArrowRight;
        detailImgView.contentMode = UIViewContentModeCenter;
        detailImgView.tag = baseTag + 12;
        [cell.contentView addSubview:detailImgView];
        [detailImgView release];
        
        // Separator Line
        UIView *tzSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT_DEFAULT_CELL, detailTableView.frame.size.width, 0.5)];
        tzSeparatorView.backgroundColor = COLOR_LINE;
        [cell.contentView addSubview:tzSeparatorView];
        [tzSeparatorView release];
        
        // TimeZone edit button
        CGRect frm = CGRectZero;
        frm.size.width = detailTableView.frame.size.width;
        frm.size.height = HEIGHT_DEFAULT_CELL;
        
        UIButton *tzEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tzEditButton.frame = frm;
        tzEditButton.tag = baseTag + 13;
        [tzEditButton addTarget:self action:@selector(editTimeZone:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:tzEditButton];

        
        startTime = [Common convertDate:startTime
                           fromTimeZone:[NSTimeZone defaultTimeZone]
                             toTimeZone:[Settings getTimeZoneByID:self.taskCopy.timeZoneId]];
        
        endTime = [Common convertDate:endTime
                         fromTimeZone:[NSTimeZone defaultTimeZone]
                           toTimeZone:[Settings getTimeZoneByID:self.taskCopy.timeZoneId]];
        
        yMargin = HEIGHT_DEFAULT_CELL;
    }
    
    NSInteger heightStartEndLabel = 20;
    NSInteger heightDayNumber = 40;
    
    // Start label
    CGFloat widthStartLabel = detailTableView.frame.size.width/2 - PADDING_LEFT;
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, yMargin + 10, widthStartLabel, heightStartEndLabel)];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.textAlignment = NSTextAlignmentLeft;
    startLabel.text = _startText;
    startLabel.textColor = COLOR_TEXT_OBJECT_DETAIL;
    startLabel.font = [UIFont systemFontOfSize:16];
    startLabel.tag = baseTag;
    [cell.contentView addSubview:startLabel];
    [startLabel release];
    
    // Day number of Start label
    UIFont *fontDayNumber = [UIFont systemFontOfSize:40 weight:UIFontWeightThin];
    NSString *dayNumberString = startTime == nil? _noneText:[NSString stringWithFormat:@"%ld",[Common getDay:startTime]];
    CGSize widthDayNumberString = [Common sizeWithString:dayNumberString andFont:fontDayNumber];
    CGRect frameDayLabel = CGRectMake(PADDING_LEFT, startLabel.frame.origin.y + startLabel.frame.size.height, widthDayNumberString.width, heightDayNumber);
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:frameDayLabel];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.textColor = COLOR_ICON_TABBAR_SEL;
    dayLabel.font = fontDayNumber;
    dayLabel.tag = baseTag + 1;
    dayLabel.text = dayNumberString;
    [cell.contentView addSubview:dayLabel];
    [dayLabel release];
    
    // Date string of Start
    NSString *dayStr = (startTime == nil?@"":([self.taskCopy isADE]?[Common getFullWeekdayString:startTime]:(_isiPad?[Common getFullWeekdayString:startTime]:[Common getFullDateString4:startTime])));

    CGFloat originXWkdayLabel = dayLabel.frame.origin.x + dayLabel.frame.size.width;
    CGFloat originYWkdayLabel = dayLabel.frame.origin.y + 2;
    CGFloat widthWkdayLabel = detailTableView.frame.size.width/2 - dayLabel.frame.origin.x - dayLabel.frame.size.width;
    CGRect frameWkdayLabel = CGRectMake(originXWkdayLabel, originYWkdayLabel, widthWkdayLabel, heightStartEndLabel);
    UILabel *wkdayLabel = [[UILabel alloc] initWithFrame:frameWkdayLabel];
    wkdayLabel.backgroundColor = [UIColor clearColor];
    wkdayLabel.text = dayStr;
    wkdayLabel.textColor = [UIColor blackColor];
    wkdayLabel.font = [UIFont systemFontOfSize:15];
    wkdayLabel.tag = baseTag+2;
    [cell.contentView addSubview:wkdayLabel];
    [wkdayLabel release];
    
    // Time string of Start
    NSString *timeStr = startTime == nil?@"":([self.taskCopy isADE]?[Common getMonthYearString:startTime]:(_isiPad?[NSString stringWithFormat:@"%@, %@",[Common getMonthYearString:startTime], [Common getTimeString:startTime]]:[Common getTimeString:startTime]));
    
    CGFloat originXMonYearLabel = dayLabel.frame.origin.x + dayLabel.frame.size.width;
    CGFloat originYMonYearLabel = wkdayLabel.frame.origin.y + wkdayLabel.frame.size.height - 4;
    CGFloat widthMonYearLabel = detailTableView.frame.size.width/2 - originXMonYearLabel;
    
    CGRect frameMonYearLabel = CGRectMake(originXMonYearLabel, originYMonYearLabel, widthMonYearLabel, heightStartEndLabel);
    UILabel *monYearLabel = [[UILabel alloc] initWithFrame:frameMonYearLabel];
    monYearLabel.backgroundColor = [UIColor clearColor];
    monYearLabel.text = timeStr;
    monYearLabel.textColor = [UIColor blackColor];
    monYearLabel.font = [UIFont systemFontOfSize:15];
    monYearLabel.tag = baseTag+3;
    [cell.contentView addSubview:monYearLabel];
    [monYearLabel release];
    
    // Separator Line
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(detailTableView.bounds.size.width/2, yMargin, 0.5, 80)];
    separatorView.backgroundColor = COLOR_LINE;
    [cell.contentView addSubview:separatorView];
    [separatorView release];
    
    // End label
    CGFloat widthDueLabel = detailTableView.frame.size.width/2 - PADDING_LEFT;
    UILabel *dueLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailTableView.bounds.size.width/2 + PADDING_LEFT, yMargin + 10, widthDueLabel, heightStartEndLabel)];
    dueLabel.backgroundColor = [UIColor clearColor];
    dueLabel.text = _endText;
    dueLabel.textColor = COLOR_TEXT_OBJECT_DETAIL;
    dueLabel.font = [UIFont systemFontOfSize:16];
    dueLabel.tag = baseTag+4;
    [cell.contentView addSubview:dueLabel];
    [dueLabel release];
    
    // Due day of End
    NSString *dueDayNumberString = endTime == nil? _noneText:[NSString stringWithFormat:@"%ld",[Common getDay:endTime]];
    CGFloat widthDueDayNumberString = endTime == nil ? 70 : [Common sizeWithString:dueDayNumberString andFont:fontDayNumber].width;
    
    CGRect frameDueDayLabel = CGRectMake(detailTableView.bounds.size.width/2 + PADDING_LEFT, dueLabel.frame.origin.y + startLabel.frame.size.height, widthDueDayNumberString, heightDayNumber);
    
    UILabel *dueDayLabel = [[UILabel alloc] initWithFrame:frameDueDayLabel];
    dueDayLabel.backgroundColor = [UIColor clearColor];
    dueDayLabel.textAlignment = NSTextAlignmentRight;
    dueDayLabel.text = dueDayNumberString;
    dueDayLabel.textColor = COLOR_ICON_TABBAR_SEL;
    dueDayLabel.font = fontDayNumber;
    dueDayLabel.tag = baseTag+5;
    [cell.contentView addSubview:dueDayLabel];
    [dueDayLabel release];
    
    // Date string of End
    dayStr = (endTime == nil?@"":([self.taskCopy isADE]?[Common getFullWeekdayString:endTime]:(_isiPad?[Common getFullWeekdayString:endTime]:[Common getFullDateString4:endTime])));
    
    CGFloat originXDueWkdayLabel = dueDayLabel.frame.origin.x + dueDayLabel.frame.size.width;
    CGFloat originYDueWkdayLabel = dueDayLabel.frame.origin.y + 2;
    CGFloat widthDueWkdayLabel = detailTableView.frame.size.width - originXDueWkdayLabel;
    CGRect frameDueWkdayLabel = CGRectMake(originXDueWkdayLabel, originYDueWkdayLabel, widthDueWkdayLabel, heightStartEndLabel);

    UILabel *dueWkdayLabel = [[UILabel alloc] initWithFrame:frameDueWkdayLabel];
    dueWkdayLabel.backgroundColor = [UIColor clearColor];
    dueWkdayLabel.text = dayStr;
    dueWkdayLabel.textColor = [UIColor blackColor];
    dueWkdayLabel.font = [UIFont systemFontOfSize:15];
    dueWkdayLabel.tag = baseTag+6;
    [cell.contentView addSubview:dueWkdayLabel];
    [dueWkdayLabel release];
    
    // Time string of End
    timeStr = endTime == nil?@"":([self.taskCopy isADE]?[Common getMonthYearString:endTime]:(_isiPad?[NSString stringWithFormat:@"%@, %@",[Common getMonthYearString:endTime], [Common getTimeString:endTime]]:[Common getTimeString:endTime]));
    
    CGFloat originXDueMonYearLabel = dueDayLabel.frame.origin.x + dueDayLabel.frame.size.width;
    CGFloat originYDueMonYearLabel = dueWkdayLabel.frame.origin.y + dueWkdayLabel.frame.size.height - 4;
    CGFloat widthDueMonYearLabel = detailTableView.frame.size.width - originXDueMonYearLabel;
    
    UILabel *dueMonYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(originXDueMonYearLabel, originYDueMonYearLabel, widthDueMonYearLabel, heightStartEndLabel)];
    dueMonYearLabel.backgroundColor = [UIColor clearColor];
    dueMonYearLabel.text = timeStr;
    dueMonYearLabel.textColor = [UIColor blackColor];
    dueMonYearLabel.font = [UIFont systemFontOfSize:15];
    dueMonYearLabel.tag = baseTag+7;
    [cell.contentView addSubview:dueMonYearLabel];
    [dueMonYearLabel release];
    
    // Start button tap
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(0, yMargin, detailTableView.frame.size.width/2, 80);
    startButton.backgroundColor = [UIColor clearColor];
    startButton.tag = baseTag + 8;
    [startButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:startButton];

    // Due button tap
    UIButton *dueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dueButton.frame = CGRectMake(detailTableView.frame.size.width/2 + 0.5, yMargin, detailTableView.frame.size.width/2, 80);
    dueButton.backgroundColor = [UIColor clearColor];
    dueButton.tag = baseTag + 9;
    [dueButton addTarget:self action:@selector(editWhen:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:dueButton];
}

- (void)createRepeatUntilCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    if ([self.task isAssignedToAssignee] || [self.task isAcceptByAssignee]) {
        cell.accessoryType = UITableViewCellSelectionStyleNone;
    }
    
	cell.textLabel.text = _repeatUntilText;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [self.taskCopy getRepeatDisplayString];
    cell.detailTextLabel.textColor = COLOR_ICON_OBJECT_DETAIL;
}

- (void)createAlertCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    AlertData *alert = ([self.taskCopy isTask] && self.taskCopy.deadline == nil? nil: (self.taskCopy.alerts.count > 0?[self.taskCopy.alerts objectAtIndex:0]:nil));
    
	cell.textLabel.text = _alertText;
    cell.textLabel.textColor = [UIColor blackColor];
    
    //cell.textLabel.textColor = [UIColor grayColor];
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
	
    /*cell.detailTextLabel.text = alert == nil?_noneText:[alert getAbsoluteTimeString:self.taskCopy];
    //cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    //cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
    
    if ([self.taskCopy isTask] && self.taskCopy.locationAlert > 0 && self.taskCopy.locationAlertID > 0) {
        NSString *alertStr = @"";
        if (self.taskCopy.locationAlert == LOCATION_ARRIVE) {
            alertStr = _whenArriveText;
        } else {
            alertStr = _whenLeaveText;
        }
        
        Location *loc = [[Location alloc] initWithPrimaryKey:self.taskCopy.locationAlertID database:[[DBManager getInstance] getDatabase]];
        
        alertStr = [NSString stringWithFormat:alertStr, loc.name];
        cell.detailTextLabel.text = alertStr;
    }*/
    
    BOOL hasLocationAlert = ([self.taskCopy isTask] && self.taskCopy.locationAlert != LOCATION_NONE && self.taskCopy.locationAlertID > 0) ||
        ([self.taskCopy isEvent] && self.taskCopy.locationAlert != LOCATION_NONE && [[self.taskCopy.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0);
    
    if (alert != nil || hasLocationAlert) {
        
        CGRect frm = CGRectZero;
        frm.size = CGSizeMake(30, 30);
        frm.origin = CGPointMake(detailTableView.frame.size.width - 40, (cell.frame.size.height - 30)/2);
        
        if (alert != nil) {
            
            UIImage *infoImageIcon = [FontManager flowasticImageWithIconName:@"alert"
                                                                     andSize:SIZE_ICON_ON_CELL
                                                                   iconColor:COLOR_TEXT_OBJECT_DETAIL];
            
            // show bell icon
            UIImageView *bellIcon = [[UIImageView alloc] initWithImage:infoImageIcon];
            bellIcon.contentMode = UIViewContentModeCenter;
            frm.origin.x -= frm.size.width;
            frm.origin.y = 0;
            frm.size.height = 40;
            bellIcon.frame = frm;
            
            [cell.contentView addSubview:bellIcon];
            [bellIcon release];
        }
        
        if (hasLocationAlert) {
            
            // show location icon
            UIImageView *locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_location.png"]];
            frm.origin.x -= frm.size.width;
            locationIcon.frame = frm;
            
            [cell.contentView addSubview:locationIcon];
            [locationIcon release];
        }
    } else {
        
        cell.detailTextLabel.text = _noneText;
        cell.detailTextLabel.textColor = COLOR_TEXT_OBJECT_DETAIL;
    }
}

- (void)createDescriptionCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
	cell.textLabel.text = _descriptionText;
    cell.textLabel.textColor = [UIColor blackColor];
	
    cell.detailTextLabel.text = self.taskCopy.note == nil?@"":self.taskCopy.note;
    cell.detailTextLabel.textColor = COLOR_TEXT_OBJECT_DETAIL;
}

- (void)createTagCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag {
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSInteger height = 30;
    
    // Tag label
	UILabel *tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT, 0, WIDTH_RIGHT_BUTTON_CELL, height)];
	tagLabel.tag = baseTag;
	tagLabel.text=_tagText;
	tagLabel.backgroundColor=[UIColor clearColor];
	tagLabel.font=[UIFont systemFontOfSize:16];
	tagLabel.textColor = [UIColor blackColor];
	[cell.contentView addSubview:tagLabel];
	[tagLabel release];
	
    // Tag input field
    NSInteger originX = PADDING_LEFT + tagLabel.frame.size.width;
    CGRect frameTagInput = CGRectMake(originX, 0, detailTableView.frame.size.width - originX - WIDTH_RIGHT_BUTTON_CELL, height);
	tagInputTextField = [[UITextField alloc] initWithFrame:frameTagInput];
	tagInputTextField.tag = baseTag + 1;
	tagInputTextField.textAlignment=NSTextAlignmentLeft;
	tagInputTextField.backgroundColor=[UIColor clearColor];
	tagInputTextField.textColor = [Colors darkSteelBlue];
	tagInputTextField.font=[UIFont systemFontOfSize:15];
	tagInputTextField.placeholder=_tagGuideText;
	tagInputTextField.keyboardType=UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tagInputTextField.delegate = self;
	[cell.contentView addSubview:tagInputTextField];
	[tagInputTextField release];
    
    // Info button
    UIImage *infoImageIcon = [FontManager flowasticImageWithIconName:@"info"
                                                             andSize:SIZE_ICON_ON_CELL
                                                           iconColor:COLOR_ICON_OBJECT_DETAIL];
    
    NSInteger originXTagDetailBtn = tagInputTextField.frame.origin.x + tagInputTextField.frame.size.width;
    CGRect frameTagDetailBtn = CGRectMake(originXTagDetailBtn, 0, WIDTH_RIGHT_BUTTON_CELL, height);
    UIButton *tagDetailButton = [Common createButtonWith:nil
                                              buttonType:UIButtonTypeCustom
                                                   frame:frameTagDetailBtn
                                              titleColor:nil
                                                  target:self
                                                selector:@selector(editTag:)
                                        normalStateImage:infoImageIcon
                                      selectedStateImage:nil];
    tagDetailButton.tag = baseTag + 2;
    [cell.contentView addSubview:tagDetailButton];
    
//    UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    tagDetailButton.frame = CGRectMake(detailTableView.bounds.size.width - 30, 0, 25, 25);
//    tagDetailButton.tag = baseTag + 2;
//    [tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.contentView addSubview:tagDetailButton];
    
    /*
    UIButton *tagEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frm = detailTableView.bounds;
    frm.size.height = 30;
    
    tagEditButton.frame = frm;
    tagEditButton.tag = baseTag + 2;
    [tagEditButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:tagEditButton];
    */
    
    CGFloat w = (detailTableView.bounds.size.width - 50)/3;
	for (int i=0; i<9; i++) {
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@""
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(mod*(w + 10) + 10, div*30 + 30, w, 25)
										titleColor:[UIColor darkGrayColor]
											target:self
										  selector:@selector(selectTag:)
								  normalStateImage:nil
								selectedStateImage:nil];
		tagButton.tag = baseTag + 3 +i;
        
        tagButton.titleLabel.font = [UIFont systemFontOfSize:14];
        tagButton.layer.borderWidth = 1;
        tagButton.layer.borderColor = COLOR_BORDER_TAG_OBJECT_DETAIL.CGColor;
        tagButton.layer.cornerRadius = 6;
		
		[cell.contentView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
    
	[self tagInputReset];
}

- (void) createTimerHistoryCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _timerHistoryText;
    //cell.textLabel.textColor = [UIColor grayColor];
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
}

- (void) createLinkCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    CGRect frm = self.previewViewCtrler.view.frame;
    
    frm.origin.x = 10;
    frm.size.width = detailTableView.bounds.size.width-10;
    
    [self.previewViewCtrler changeFrame:frm];
    
    [cell.contentView addSubview:self.previewViewCtrler.view];
}

- (void) createDeleteCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.backgroundColor = [UIColor redColor];
    
    CGRect frm = CGRectZero;
    frm.size.width = detailTableView.bounds.size.width;
    
    frm.size.height = 40;
    
	UILabel *deleteLabel = [[UILabel alloc] initWithFrame:frm];
	deleteLabel.tag = baseTag;
	deleteLabel.text = _deleteText;
	deleteLabel.backgroundColor = [UIColor clearColor];
	deleteLabel.font = [UIFont boldSystemFontOfSize:16];
	deleteLabel.textColor = [UIColor whiteColor];
    deleteLabel.textAlignment = NSTextAlignmentCenter;
	
	[cell.contentView addSubview:deleteLabel];
	[deleteLabel release];
}

- (void) createShowMoreCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag

{
    cell.accessoryType = UITableViewCellAccessoryNone;
    //cell.contentView.backgroundColor = [UIColor blueColor];
    
    CGRect frm = CGRectZero;
    frm.size.width = detailTableView.bounds.size.width;
    
    frm.size.height = 40;
    
	UILabel *showMoreLabel = [[UILabel alloc] initWithFrame:frm];
	showMoreLabel.tag = baseTag;
	showMoreLabel.text = _showMoreText;
	showMoreLabel.backgroundColor = [UIColor clearColor];
	showMoreLabel.font = [UIFont italicSystemFontOfSize:16];
	showMoreLabel.textColor = [Colors darkSlateGray];
    showMoreLabel.textAlignment = NSTextAlignmentCenter;
	
	[cell.contentView addSubview:showMoreLabel];
	[showMoreLabel release];

}

- (void) createCommentCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    DBManager *dbm = [DBManager getInstance];
    
    //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text = _conversationsText;
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [dbm countCommentsForItem:self.taskCopy.primaryKey]];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.task == nil)
    {
        return 0;
    }
    
    NSInteger count = (showAll?11:7);
    
    if (self.taskCopy.primaryKey == -1)
    {
        count -= 2; //don't show Assets
    }
    
    /*
    if ([self.task isShared])
    {
        count = count + 1; //conversation cell
    }
    */
    
    if (showComments) {
        count += 1;
    }
    
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        //CGFloat h = [titleTextView getHeight];
        CGFloat h = titleTextView.bounds.size.height;
        
        //printf("title height: %f\n", h);
        
        return h + 40;
    }
    else if (indexPath.row == 2 && [self.task isManual])
    {
        return 0;
    }
    else if (indexPath.row == 3) //start/due
    {
        //return [self.taskCopy isEvent]?120:80;
        
        Settings *settings = [Settings getInstance];
        
        if (settings.timeZoneSupport && [self.taskCopy isNormalEvent])
        {
            return 120;
        }
        
        return 80;
    }
    else if (indexPath.row == 7) //tag
    {
        return 120;
    }
    else if (indexPath.row == 8 && [self.taskCopy isEvent]) // timer history of Event
    {
        return 0;
    }
    else if ((showAll && indexPath.row == (showComments?11:10)) || (!showAll && indexPath.row == (showComments?7:6))) //asset list
    {
        CGFloat h = [self.previewViewCtrler getHeight];
        
        return h;
    }

    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3 && tableView == detailTableView)
    {
        cell.backgroundColor = [UIColor colorWithRed:223.0/255 green:223.0/255 blue:223.0/255 alpha:1];
    }
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];

    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
    
    //printf("index row: %d\n", indexPath.row);

    switch (indexPath.row)
    {
        case 0:
            [self createTitleCell:cell baseTag:10000];
            break;
        case 1:
            if ([self.taskCopy isTask])
            {
                [self createDurationCell:cell baseTag:10100];
            }
            else
            {
                [self createProjectCell:cell baseTag:10100];
            }
            break;
        case 2:
            if ([self.taskCopy isTask])
            {
                [self createProjectCell:cell baseTag:10200];
            }
            else
            {
                if ([self.task isManual]) {
                    cell.hidden = YES;
                } else {
                    [self createADECell:cell baseTag:10200];
                }
            }
            break;
        case 3:
            if ([self.taskCopy isTask])
            {
                [self createStartDueCell:cell baseTag:10300];
            }
            else
            {
                [self createStartEndCell:cell baseTag:10300];
            }
            break;
        case 4:
            if (showAll)
            {
                [self createRepeatUntilCell:cell baseTag:10400];
            }
            else
            {
                [self createShowMoreCell:cell baseTag:10400];
            }
            break;
        case 5:
            if (showAll)
            {
                [self createAlertCell:cell baseTag:10500];
            }
            else
            {
                if (showComments)
                {
                    [self createCommentCell:cell baseTag:10500];
                }
                else
                {
                    cell.textLabel.text = _assetsText;
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                /*else
                {
                    [self createLinkCell:cell baseTag:10500];
                }*/
            }
            break;
        case 6:
            if (showAll)
            {
                [self createDescriptionCell:cell baseTag:10600];
            }
            else
            {
                if (showComments)
                {
                    cell.textLabel.text = _assetsText;
                    cell.textLabel.textColor = [UIColor blackColor];
                }
                else
                {
                    [self createLinkCell:cell baseTag:10600];
                }
            }
            /*else
            {
                [self createLinkCell:cell baseTag:10600];
            }*/
            break;
        case 7:
            if (showAll)
            {
                [self createTagCell:cell baseTag:10700];
            }
            else
            {
                [self createLinkCell:cell baseTag:10700];
            }
            break;
        case 8:
            if ([self.task isEvent]) {
                cell.hidden = YES;
            } else {
                [self createTimerHistoryCell:cell baseTag:10800];
            }
            break;
        case 9:
            if (showComments)
            {
                [self createCommentCell:cell baseTag:10900];
            }
            else
            {
                //[self createLinkCell:cell baseTag:10900];
                cell.textLabel.text = _assetsText;
                cell.textLabel.textColor = [UIColor blackColor];
            }
            break;
        case 10:
            //[self createLinkCell:cell baseTag:11000];
            if (showComments)
            {
                cell.textLabel.text = _assetsText;
                cell.textLabel.textColor = [UIColor blackColor];
            }
            else
            {
                [self createLinkCell:cell baseTag:11000];
            }
            break;
        case 11:
            [self createLinkCell:cell baseTag:11000];
            break;
            
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
            if ([self.taskCopy isTask])
            {
                [self editDuration];
            }
            else
            {
                [self editProject];
            }
            break;
        case 2:
            if ([self.taskCopy isTask])
            {
                [self editProject];
            }
            break;
        case 4:
            if (showAll)
            {
                if ([self.task isAssignedToAssignee] || [self.task isAcceptByAssignee]) {
                    break;
                }
                [self editRepeat];
            }
            else
            {
                [self showAll];
            }
            break;
        case 5:
            if (showAll)
            {
                [self editAlert];
            }
            else if (showComments)
            {
                [self editComment];
            }
            else
            {
                [self editLink:nil];
            }
            break;
        case 6:
            if (showAll)
            {
                [self editDescription];
            }
            else
            {
                [self editLink:nil];
            }
            break;
        case 8:
            [self showTimerHistory];
            break;
        case 9:
            if (showComments)
            {
                [self editComment];
            }
            else
            {
                [self editLink:nil];
            }
            break;
        case 10:
            [self editLink:nil];
            break;
    }
}

#pragma mark GrowingTextView Delegate
- (void)growingTextView:(GrowingTextView *)growingTextView didChangeHeight:(float)height
{
    //printf("reload \n");
    self.taskCopy.name = growingTextView.text;
    
    BOOL isFirstResponder = [titleTextView.textView isFirstResponder];
    
    /*
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    [Common reloadRowOfTable:detailTableView row:0 section:0];
    
    if (isFirstResponder)
    {
        [titleTextView.textView becomeFirstResponder];
    }
}

- (BOOL)growingTextViewShouldReturn:(GrowingTextView *)growingTextView
{
    return NO;
}

- (BOOL)growingTextViewShouldBeginEditing:(GrowingTextView *)growingTextView
{
    [self closeInputView];
    
    return YES;
}

- (void)growingTextViewDidEndEditing:(GrowingTextView *)growingTextView;
{
    NSString *text = [titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.taskCopy.name = text;
}

#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	//[peoplePicker dismissModalViewControllerAnimated:YES];
    [peoplePicker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (peoplePicker.interfaceOrientation != _currentOrientation) {
            if (_isiPad) {
                [_iPadViewCtrler changeOrientation:peoplePicker.interfaceOrientation];
            } else {
                [_sdViewCtrler changeOrientation:peoplePicker.interfaceOrientation];
            }
        }
    }];
    peoplePicker.peoplePickerDelegate = nil;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self didSelectPerson:person fromPicker:peoplePicker];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
							  identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    [self didSelectPerson:person fromPicker:peoplePicker];
}

- (void)didSelectPerson:(ABRecordRef)person fromPicker:(ABPeoplePickerNavigationController *)peoplePicker {
    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
    
    if (firstName==nil && lastName==nil && company==nil){
        firstName=(CFStringRef)_nonameText;
        lastName=(CFStringRef)@" ";
        company=(CFStringRef)@" ";
    }else{
        if(firstName==nil) {
            firstName=(CFStringRef) @" ";
        }
        if(lastName==nil){
            lastName=(CFStringRef)@" ";
        }
        if(company==nil){
            company=(CFStringRef)@" ";
        }
        
    }
    
    NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    NSString *contactComName=[NSString stringWithFormat:@"%@",company];
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
        contactName=contactComName;
    }
    
    self.taskCopy.contactName=contactName;
    
    //get PHONE NUMBER from contact
    NSString *phoneNumber=@"";
    ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if(ABMultiValueGetCount(phoneEmailValue)>0){
        phoneNumber=@"";
        
        for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
            CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
            CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
            
            if(label==nil){
                label=(CFStringRef)@" ";
            }
            
            if(phoneNo==nil){
                phoneNo=(CFStringRef)@" ";
            }
            phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
        }
        
    }
    if (phoneEmailValue != NULL) {
        CFRelease(phoneEmailValue);
    }
    self.taskCopy.contactPhone=phoneNumber;
    
    NSString *contactAddress=nil;
    //get first address for this contact
    ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
    
    if(ABMultiValueGetCount(multiValue)>0){
        
        //get all address from the contact
        CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
        CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
        CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
        CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);
        CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
        CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
        
        if (dict != NULL) {
            CFRelease(dict);
        }
        
        if(street!=nil){
            contactAddress=[NSString stringWithFormat:@"%@",street];
        }else {
            contactAddress=@"";
        }
        
        if(city!=nil){
            if(street!=nil){
                NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
                contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
            }else{
                NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
                contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
            }
        }
        
        if(country!=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
        if(state !=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
        if(zip !=nil){
            if(![contactAddress isEqualToString:@""]){
                NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
                contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
            }else{
                NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
                contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
            }
        }
        
    }else {
        contactAddress=@"";
    }
    
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
    contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
    
    if (multiValue != NULL) {
        CFRelease(multiValue);
    }
    
    self.taskCopy.location=contactAddress;
    
    //get email address from contact
    NSString *emailAddress=@"";
    ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(ABMultiValueGetCount(multiEmailValue)>0){
        CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
        
        if(emailAddr==nil){
            emailAddr=(CFStringRef)@" ";
        }
        emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
    }
    
    if (multiEmailValue != NULL) {
        CFRelease(multiEmailValue);
    }
    self.taskCopy.contactEmail=emailAddress;
    
    if ([self.taskCopy.name isEqualToString:@""])
    {
        self.taskCopy.name = [NSString stringWithFormat:@"%@ %@", _meetText, self.taskCopy.contactName];
        
        titleTextView.text = self.taskCopy.name;
    }
    
    // remove the controller
    //[self dismissViewControllerAnimated:YES completion:NULL];
    UIViewController *ctrler = peoplePicker.presentingViewController;
    [ctrler dismissViewControllerAnimated:YES completion:^{
        [self refreshTitle];
    }];
    
    /*
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     
     [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
    
    //[Common reloadRowOfTable:detailTableView row:0 section:0];
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 10000) //edit title
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
		self.taskCopy.name = text;
	}
	else if (textField.tag == 10000 + 2) //edit location
    {
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if (![text isEqualToString:self.taskCopy.location]) {
            // reset locationID if change location text
            self.taskCopy.locationID = 0;
        }
        
        if ([self.taskCopy isEvent] && [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] <= 0) {
            
            self.taskCopy.locationAlert = LOCATION_NONE;
            // reload alert cell
            [self refreshAlert];
        }
        
        self.taskCopy.location = text;
    }
    else if (textField.tag == 10700 + 1) //edit tag
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
            if (![self checkExistingTag:text])
            {
                self.taskCopy.tag = [TagDictionary addTagToList:self.taskCopy.tag tag:text];
            }
		}
		
		[self tagInputReset];
	}
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 10000) //edit title
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		UITableViewCell *cell = [detailTableView cellForRowAtIndexPath:indexPath];
		
		UIButton *editTitleButton = (UIButton *) [cell.contentView viewWithTag:10002];
		editTitleButton.enabled = NO;
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 10700 + 1) // edit tag
	{
		NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
		
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSArray *tags = [dict findTags:s];
		
		int j = 0;
		
		for (NSString *tag in tags)
		{
			[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:YES];
			j++;
			
			if (j == 8)
			{
				break;
			}
		}
		
		for (;j<9;j++)
		{
			[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:NO];
		}		
	}
	
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, abs(MIN(kbSize.width, kbSize.height)), 0);
        [detailTableView setContentInset:edgeInsets];
        [detailTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [detailTableView setContentInset:edgeInsets];
        [detailTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

@end
