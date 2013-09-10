//
//  PreviewViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PreviewViewController.h"

#import "Common.h"
#import "Task.h"
#import "URLAsset.h"

#import "ProjectManager.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "TaskLinkManager.h"
#import "TimerManager.h"

#import "ContentView.h"
#import "NoteView.h"
#import "GuideWebView.h"

#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"

#import "iPadSmartDayViewController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"

#import "SDNavigationController.h"
#import "NoteDetailTableViewController.h"
#import "DetailViewController.h"
#import "iPadViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;
extern DetailViewController *_detailViewCtrler;
extern iPadViewController *_iPadViewCtrler;

//extern iPadSmartDayViewController *_iPadSDViewCtrler;

PreviewViewController *_previewCtrler;

@interface PreviewViewController ()

@end

@implementation PreviewViewController

@synthesize item;
@synthesize linkList;

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
    if (self = [super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
        
        tapCount = 0;
        tapRow = -1;
        selectedIndex = 0;
        
        hasNote = NO;
        
        noteChange = NO;
        noteLinkCreated = NO;
        
        /*
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteBeginEdit:)
													 name:@"NoteBeginEditNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteFinishEdit:)
													 name:@"NoteFinishEditNotification" object:nil];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteTap:)
													 name:@"NoteTapNotification" object:nil];
        
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.item = nil;
    
    self.linkList = nil;
    
    [super dealloc];
}

- (void) refreshData
{
    selectedIndex = -1;
    hasNote = NO;
    
    if (self.item != nil)
    {
        Task *previewItem = (self.item.original != nil && ![self.item isREException]?self.item.original:self.item);
        
        TaskLinkManager *tlm = [TaskLinkManager getInstance];
        DBManager *dbm = [DBManager getInstance];
        TaskManager *tm = [TaskManager getInstance];
        
        self.linkList = [NSMutableArray arrayWithCapacity:previewItem.links.count];
        
        NSInteger index = 0;
        
        for (NSNumber *num in previewItem.links)
        {
            NSInteger linkedId = [tlm getLinkedId4Task:previewItem.primaryKey linkId:[num intValue]];
            
            NSInteger linkedAssetType = [tlm getLinkedAssetType4Task:previewItem.primaryKey linkId:[num intValue]];
            
            if (linkedAssetType == ASSET_URL)
            {
                URLAsset *urlAsset = [[URLAsset alloc] initWithPrimaryKey:linkedId database:[dbm getDatabase]];
                
                [self.linkList addObject:urlAsset];
                [urlAsset release];
            }
            else 
            {
                Task *itm = [[Task alloc] initWithPrimaryKey:linkedId database:[dbm getDatabase]];
                itm.listSource = SOURCE_PREVIEW;
                
                [self.linkList addObject:itm];
                [itm release];
                
                if ([itm isRE])
                {
                    Task *firstInstance = [tm findRTInstance:itm fromDate:itm.startTime];
                    
                    itm.startTime = firstInstance.startTime;
                    itm.endTime = firstInstance.endTime;
                    
                }
                
                if ([itm isNote])
                {
                    hasNote = YES;
                    /*
                     if (expandedNoteIndex == -1)
                     {
                     expandedNoteIndex = index;
                     }*/
                    
                    selectedIndex = 0;
                }
            }
            
            index ++;
        }
    }
    
    [linkTableView reloadData];
}

- (void) changeFrame:(CGRect) frm
{
    contentView.frame = frm;
    
    frm = contentView.bounds;
    
    linkTableView.frame = frm;
    
    [linkTableView reloadData];
}

- (CGFloat) getHeight
{
    CGFloat rowH = 0;
    
    NSInteger rows = self.linkList.count;
    
    if (!hasNote && ![self.item isNote]) //don't show empty Note for Note
    {
        rows += 1;
    }
    
    for (int i=0;i<rows;i++)
    {
        NSInteger index = selectedIndex;
        
        if (!hasNote && ![self.item isNote])
        {
            if (index > 0)
            {
                index -= 1;
            }
        }
        
        if (i == selectedIndex && index >= 0)
        {
            NSObject *asset = [self.linkList objectAtIndex:index];
            
            rowH += ![asset isKindOfClass:[URLAsset class]]?170:40;
        }
        else
        {
            rowH += 40;
        }
    }
    
    return rowH;
    
}

/*
- (void) editTask:(Task *)task
{
    if ([task isNote])
    {
        NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
        ctrler.note = task;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
    else
    {
        TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
        
        ctrler.task = task;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];
    }
}
*/

- (void) singleTap
{
    tapCount = 0;
 
/*
    if (!hasNote)
    {
        tapRow -= 1;
    }
    
    if (tapRow >= 0)
    {
        Task *item = [self.linkList objectAtIndex:tapRow];
        
        if ([item isNote])
        {
            if (expandedNoteIndex != -1)
            {
                NSIndexPath *previousPath = [NSIndexPath indexPathForRow:expandedNoteIndex inSection:0];
                
                expandedNoteIndex = -1;
                
                [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            expandedNoteIndex = tapRow;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:expandedNoteIndex inSection:0];
            
            [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        else
        {
            if (expandedNoteIndex != -1)
            {
                NSIndexPath *previousPath = [NSIndexPath indexPathForRow:expandedNoteIndex inSection:0];
                
                expandedNoteIndex = -1;
                
                [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            expandedNoteIndex = -1;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tapRow inSection:0];
            
            [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
*/
    
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    
    selectedIndex = tapRow;
    
    [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:idxPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    idxPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    
    [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:idxPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) markNoteChange
{
    noteChange = YES;
}

- (void) doubleTap
{
    tapCount = 0;
    
    if (!hasNote && ![self.item isNote])
    {
        tapRow -= 1;
    }
    
    if (tapRow >= 0)
    {
        Task *itemEdit = [self.linkList objectAtIndex:tapRow];
    
        /*
        if (_plannerViewCtrler != nil)
        {
            [_plannerViewCtrler editItem:item];
        }
        else if (_abstractViewCtrler != nil)
        {
            [_abstractViewCtrler editItem:item];
        }*/
        
        [_iPadViewCtrler.activeViewCtrler editItem:itemEdit];
    }
}

- (void) createLinkedNote:(NSString *)text
{
    DBManager *dbm = [DBManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    Task *note = [[Task alloc] init];
    
    note.type = TYPE_NOTE;
    note.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
    note.note = text;
    note.name = [Common getNoteTitle:text];
    
    [note insertIntoDB:[dbm getDatabase]];
    
    NSInteger itemId = self.item.primaryKey;
    
    if (self.item.original != nil && ![self.item isREException])
    {
        itemId = self.item.original.primaryKey;
    }
    
    NSInteger linkId = [tlm createLink:itemId destId:note.primaryKey destType:ASSET_ITEM];
    
    if (linkId != -1)
    {
        [self.linkList insertObject:note atIndex:0];
    }
    
    noteView.note = note;
    
    [note release];
    
    noteLinkCreated = YES;
    hasNote = YES;
    
    //expandedNoteIndex = 0;
    
    [linkTableView reloadData];
}

- (void) editNoteContent
{
    TaskManager *tm = [TaskManager getInstance];
    Task *note = [[[Task alloc] init] autorelease];
    note.type = TYPE_NOTE;
    note.listSource = SOURCE_PREVIEW;
    note.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
        
    NSInteger index = selectedIndex;
    
    if (!hasNote)
    {
        if (selectedIndex != 0)
        {
            tapRow = 0;
            
            [self singleTap];
            
            index -= 1;
        }
        else
        {
            index = -1;
        }
    }
    
    if (index != -1)
    {
        Task *asset = [self.linkList objectAtIndex:index];
        
        if ([asset isNote])
        {
            note = asset;
        }
    }
    
    //printf("note: %s\n", [note.note UTF8String]);
    
    /*
    NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
    ctrler.note = noteView.note;
    
    SDNavigationController *navCtrler = [[SDNavigationController alloc] initWithRootViewController:ctrler];
    
    UIViewController *mainCtrler = (_plannerViewCtrler != nil?_plannerViewCtrler:_abstractViewCtrler);
    
    [mainCtrler presentViewController:navCtrler animated:YES completion:nil];
    
    [navCtrler release];
    
    [ctrler release];
    */
    
    [_iPadViewCtrler editNoteContent:note];
}

#pragma mark Notification
- (void) noteBeginEdit:(NSNotification *)notification
{
    /*
    if (UIInterfaceOrientationIsLandscape(_abstractViewCtrler.interfaceOrientation))
    {
        noteFrm = noteView.frame;
        CGRect frm = noteFrm;
        
        //frm.size.height = 220 - expandedNoteIndex*40;
        frm.size.height = 220 - selectedIndex*40;
        
        [noteView changeFrame:frm];
        
        nextButton.frame = CGRectMake(frm.size.width - 30, frm.size.height/2-30, 30, 30);
    }
    */
    
    if (!hasNote && selectedIndex != 0)
    {
        tapRow = 0;
        
        [self singleTap];
    }
}

/*
- (void) noteFinishEdit:(NSNotification *)notification
{
    if (UIInterfaceOrientationIsLandscape(_abstractViewCtrler.interfaceOrientation))
    {
        contentView.frame = CGRectMake(0, 0, 320, 416);
        
        [noteView changeFrame:noteFrm];
        
        nextButton.frame = CGRectMake(noteFrm.size.width - 30, noteFrm.size.height/2-30, 30, 30);        
    }
    
    if (!hasNote)
    {
        NSString *text = [noteView getNoteText];
        
        if (![text isEqualToString:@""])
        {
            [self createLinkedNote:text];
        }        
    }
    else
    {
        DBManager *dbm = [DBManager getInstance];
        
        [noteView.note updateIntoDB:[dbm getDatabase]];
        
        [self markNoteChange];
    }
}
*/

- (void) noteTap:(NSNotification *)notification
{
    [self editNoteContent];
}

/*
- (void) noteDoubleTap:(NSNotification *)notification
{
    if (noteView.note != nil)
    {
        //[_iPadSDViewCtrler editItem:noteView.note];
        if (_plannerViewCtrler != nil)
        {
            [_plannerViewCtrler editItem:noteView.note];
        }
        else if (_abstractViewCtrler != nil)
        {
            [_abstractViewCtrler editItem:noteView.note];
        }
    }
}
*/
#pragma mark Actions
- (void) quickAddNote:(id)sender
{
    TaskManager *tm = [TaskManager getInstance];
    
    Task *note = [[Task alloc] init];
    
    note.type = TYPE_NOTE;
    note.startTime = [Common dateByRoundMinute:15 toDate:tm.today];
    
    [_iPadViewCtrler editNoteContent:note];
    
    [note release];
}

- (void) editItem:(id) sender
{
    [noteView finishEdit];
    
    //[_iPadSDViewCtrler editItem:self.item];
    if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler editItem:item];
    }
    else if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editItem:item];
    }
}

- (void) showTimer:(id) sender
{
    //[_iPadSDViewCtrler showTimer];
    
    if ([_abstractViewCtrler isKindOfClass:[iPadSmartDayViewController class]])
    {
        [(iPadSmartDayViewController *)_abstractViewCtrler showTimer];
    }
}

- (void) editNote:(id)sender
{
    [noteView cancelEdit];
    
    if (noteView.note != nil)
    {
        if (_plannerViewCtrler != nil)
        {
            [_plannerViewCtrler editItem:noteView.note];
        }
        else if (_abstractViewCtrler != nil)
        {
            [_abstractViewCtrler editItem:noteView.note];
        }        
    }
}

- (void) jump:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    Task *asset = (Task *) btn.tag;
    
    [_abstractViewCtrler jumpToDate:asset.startTime];
}

- (void) editAsset:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    Task *asset = (Task *) btn.tag;
    
    if (_detailViewCtrler != nil)
    {
        [_detailViewCtrler editAsset:asset];
    }
}

#pragma mark View

- (void) loadView
{
    CGRect frm = CGRectMake(0, 0, 320, 416);
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
    /*
	UIButton *nameButton = [Common createButton:self.item.name
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(10, 0, frm.size.width-40, 40)
										titleColor:[UIColor blackColor]
											target:self
										  selector:@selector(editItem:)
								  normalStateImage:nil
								selectedStateImage:nil];
    nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [contentView addSubview:nameButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    nextButton.frame = CGRectMake(frm.size.width - 30, 2, 30, 30);
    [nextButton addTarget:self action:@selector(editItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:nextButton];
    
    UIImageView *linkBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 33, 320, 27)];
    linkBGView.image = [UIImage imageNamed:@"category_header.png"];
    
    [contentView addSubview:linkBGView];
    [linkBGView release];

    UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 300, 20)];
    linkLabel.backgroundColor = [UIColor clearColor];
    linkLabel.font = [UIFont boldSystemFontOfSize:16];
    linkLabel.text = _linksText;
    
    [contentView addSubview:linkLabel];
    [linkLabel release];
    
    UIImageView *separatorImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ade_separator.png"]];
    separatorImgView.frame = CGRectMake(0, linkBGView.frame.origin.y + linkBGView.frame.size.height - 4, 320, 4);
    
    [contentView addSubview:separatorImgView];
    [separatorImgView release];
    */
    
    frm = contentView.bounds;

    /*
    frm.origin.y += 60;
    frm.size.height -= 60;
    */
    
    linkTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    linkTableView.backgroundColor = [UIColor clearColor];
    linkTableView.separatorColor = [UIColor clearColor];
    linkTableView.delegate = self;
    linkTableView.dataSource = self;
    
    [contentView addSubview:linkTableView];
    [linkTableView release];
    
    /*
    frm = contentView.bounds;
    frm.size.height -= 30;
    frm.origin.y = 30;
    
    NoteView *noteView = [[NoteView alloc] initWithFrame:frm];
    
    [contentView addSubview:noteView];
    [noteView release];*/
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //expandedNoteIndex = -1;
    
	// Do any additional setup after loading the view.    

    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.item isTask] && ![self.item isDone] && _plannerViewCtrler == nil)
    {
        UIButton *timerButton = [Common createButton:@""
                                          buttonType:UIButtonTypeCustom
                                               frame:CGRectMake(0, 0, 40, 40)
                                          titleColor:[UIColor whiteColor]
                                              target:self
                                            selector:@selector(showTimer:)
                                    normalStateImage:@"timer_item.png"
                                  selectedStateImage:nil];
        
        UIBarButtonItem *timerButtonItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
        
        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
        
        NSArray *items = [NSArray arrayWithObjects:flexItem, timerButtonItem, flexItem, nil];
        
        [timerButtonItem release];
        [flexItem release];
        
        self.navigationItem.leftBarButtonItems = items;
    }
    
    _previewCtrler = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (noteChange || noteLinkCreated)
    {
        if (_plannerViewCtrler != nil)
        {
            [_plannerViewCtrler reconcileItem:noteView.note reSchedule:NO];
        }
        else
        {
            [_abstractViewCtrler reconcileItem:noteView.note reSchedule:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteChangeNotification" object:nil]; //to auto-sync mSD
    }

    _previewCtrler = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Cell Creation
- (void) createEmptyNoteCell:(UITableViewCell *)cell expanded:(BOOL)expanded
{
    /*CGRect frm = CGRectMake(0, 0, linkTableView.bounds.size.width, 0);
    
    frm.size.height = expanded?170:40;
    
    noteView = [[NoteView alloc] initWithFrame:frm];
    
    noteView.editEnabled = NO;
    noteView.touchEnabled = YES;
    
    [cell.contentView addSubview:noteView];
    [noteView release];*/
    
    CGRect frm = CGRectMake(0, 0, linkTableView.bounds.size.width, 40);
    
	UIButton *emptyNoteButton = [Common createButton:_tapToAddNote
                                buttonType:UIButtonTypeCustom
                                     frame:frm
                                titleColor:[UIColor lightGrayColor]
                                    target:self
                                  selector:@selector(quickAddNote:)
                          normalStateImage:nil
                        selectedStateImage:nil];
    emptyNoteButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noteBG_full.png"]];
    
    [cell.contentView addSubview:emptyNoteButton];
}

- (void) createNoteCell:(UITableViewCell *)cell asset:(Task *)asset expanded:(BOOL)expanded
{
    if (expanded)
    {
        CGRect frm = CGRectMake(0, 0, linkTableView.bounds.size.width, 0);
        
        frm.size.height = 170;
        
        noteView = [[NoteView alloc] initWithFrame:frm];
        
        //noteView.editEnabled = YES;
        noteView.editEnabled = NO;
        noteView.touchEnabled = YES;
        
        noteView.note = asset;
        
        //printf("note content: %s\n", [noteView.note.note UTF8String]);
        
        [cell.contentView addSubview:noteView];
        [noteView release];
        
        return;
    }
    
    ProjectManager *pm = [ProjectManager getInstance];
    UIColor *color = [pm getProjectColor0:asset.project];
    
    cell.contentView.backgroundColor = [color colorWithAlphaComponent:0.2];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [pm getNoteIcon:asset.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 13, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-75, 10, 70, 20)];
    dateLabel.textColor = color;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.text = [Common getFullDateString2:asset.startTime];
    
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    CGFloat rightWidth = dateLabel.bounds.size.width + 10;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, w-30-rightWidth, 20)];
    titleLabel.textColor = color;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = asset.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
}

- (void) createEventCell:(UITableViewCell *)cell asset:(Task *)asset expanded:(BOOL)expanded
{
    ProjectManager *pm = [ProjectManager getInstance];
    UIColor *color = [pm getProjectColor0:asset.project];
    
    cell.contentView.backgroundColor = [color colorWithAlphaComponent:0.2];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [asset isManual]?[pm getAnchoredIcon:asset.project]:[pm getEventIcon:asset.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 13, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    CGFloat rightWidth = expanded?0:([asset isADE]?70:90);
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, w-30-rightWidth-10, 20)];
    titleLabel.textColor = color;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = asset.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];

    if (expanded)
    {
        UILabel *allDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 80, 20)];
        allDayLabel.textColor = color;
        allDayLabel.backgroundColor = [UIColor clearColor];
        allDayLabel.textAlignment = NSTextAlignmentLeft;
        allDayLabel.font = [UIFont systemFontOfSize:14];
        allDayLabel.text = _allDayText;
        
        [cell.contentView addSubview:allDayLabel];
        [allDayLabel release];

        UILabel *allDayValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 35, w-100, 20)];
        allDayValueLabel.textColor = color;
        allDayValueLabel.backgroundColor = [UIColor clearColor];
        allDayValueLabel.textAlignment = NSTextAlignmentRight;
        allDayValueLabel.font = [UIFont systemFontOfSize:14];
        allDayValueLabel.text = [asset isADE]?_yesText:_noText;
        
        [cell.contentView addSubview:allDayValueLabel];
        [allDayValueLabel release];    

        UILabel *projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 80, 20)];
        projectLabel.textColor = color;
        projectLabel.backgroundColor = [UIColor clearColor];
        projectLabel.textAlignment = NSTextAlignmentLeft;
        projectLabel.font = [UIFont systemFontOfSize:14];
        projectLabel.text = _projectText;
        
        [cell.contentView addSubview:projectLabel];
        [projectLabel release];
        
        UILabel *projectValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, w-100, 20)];
        projectValueLabel.textColor = color;
        projectValueLabel.backgroundColor = [UIColor clearColor];
        projectValueLabel.textAlignment = NSTextAlignmentRight;
        projectValueLabel.font = [UIFont systemFontOfSize:14];
        projectValueLabel.text = [pm getProjectNameByKey:asset.project];
        
        [cell.contentView addSubview:projectValueLabel];
        [projectValueLabel release];
        
        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 80, 20)];
        startLabel.textColor = color;
        startLabel.backgroundColor = [UIColor clearColor];
        startLabel.textAlignment = NSTextAlignmentLeft;
        startLabel.font = [UIFont systemFontOfSize:14];
        startLabel.text = _startText;
        
        [cell.contentView addSubview:startLabel];
        [startLabel release];
        
        UILabel *startValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 85, w-100, 20)];
        startValueLabel.textColor = color;
        startValueLabel.backgroundColor = [UIColor clearColor];
        startValueLabel.textAlignment = NSTextAlignmentRight;
        startValueLabel.font = [UIFont systemFontOfSize:14];
        startValueLabel.text = [asset isADE]?[Common getFullDateString:asset.startTime]:[Common getFullDateTimeString:asset.startTime];
        
        [cell.contentView addSubview:startValueLabel];
        [startValueLabel release];
        
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 80, 20)];
        endLabel.textColor = color;
        endLabel.backgroundColor = [UIColor clearColor];
        endLabel.textAlignment = NSTextAlignmentLeft;
        endLabel.font = [UIFont systemFontOfSize:14];
        endLabel.text = _endText;
        
        [cell.contentView addSubview:endLabel];
        [endLabel release];
        
        UILabel *endValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 110, w-100, 20)];
        endValueLabel.textColor = color;
        endValueLabel.backgroundColor = [UIColor clearColor];
        endValueLabel.textAlignment = NSTextAlignmentRight;
        endValueLabel.font = [UIFont systemFontOfSize:14];
        endValueLabel.text = [asset isADE]?[Common getFullDateString:asset.endTime]:[Common getFullDateTimeString:asset.endTime];
        
        [cell.contentView addSubview:endValueLabel];
        [endValueLabel release];
        
        UIButton *jumpButton = [Common createButton:_jumpText
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(10, 135, 60, 30)
                                         titleColor:[Colors blueButton]
                                             target:self
                                           selector:@selector(jump:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        jumpButton.tag = asset;
        
        jumpButton.titleLabel.font = [UIFont systemFontOfSize:14];
        //jumpButton.backgroundColor = [UIColor lightGrayColor];
        jumpButton.layer.cornerRadius = 5;
        jumpButton.layer.borderWidth = 1;
        jumpButton.layer.borderColor = [[Colors blueButton] CGColor];
        
        [cell.contentView addSubview:jumpButton];
        
        UIButton *editButton = [Common createButton:_editText
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(w-70, 135, 60, 30)
                                         titleColor:[Colors blueButton]
                                             target:self
                                           selector:@selector(editAsset:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        editButton.tag = asset;
        
        editButton.titleLabel.font = [UIFont systemFontOfSize:14];
        //editButton.backgroundColor = [UIColor lightGrayColor];
        editButton.layer.cornerRadius = 5;
        editButton.layer.borderWidth = 1;
        editButton.layer.borderColor = [[Colors blueButton] CGColor];
        
        [cell.contentView addSubview:editButton];
    }
    else
    {
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-rightWidth-5, 2, rightWidth, 20)];
        dateLabel.textColor = color;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textAlignment = NSTextAlignmentRight;
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.text = [Common getFullDateString2:asset.startTime];
        
        [cell.contentView addSubview:dateLabel];
        [dateLabel release];
        
        NSString *str = [asset isADE]?[Common getFullDateString2:asset.endTime]:[NSString stringWithFormat:@"%@ - %@", [Common getShortTimeString:asset.startTime], [Common getShortTimeString:asset.endTime]];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-rightWidth-5, 18, rightWidth, 20)];
        timeLabel.textColor = color;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.text = str;
        
        [cell.contentView addSubview:timeLabel];
        [timeLabel release];
    }
}

- (void) createTaskCell:(UITableViewCell *)cell asset:(Task *)asset expanded:(BOOL)expanded
{
    ProjectManager *pm = [ProjectManager getInstance];
    UIColor *color = [pm getProjectColor0:asset.project];
    
    cell.contentView.backgroundColor = [color colorWithAlphaComponent:0.2];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [pm getTaskIcon:asset.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 10, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, w-40-5, 20)];
    titleLabel.textColor = color;    
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = asset.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
    
    if (expanded)
    {
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 80, 20)];
        durationLabel.textColor = color;
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentLeft;
        durationLabel.font = [UIFont systemFontOfSize:14];
        durationLabel.text = _durationText;
        
        [cell.contentView addSubview:durationLabel];
        [durationLabel release];
        
        UILabel *durationValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 35, w-100, 20)];
        durationValueLabel.textColor = color;
        durationValueLabel.backgroundColor = [UIColor clearColor];
        durationValueLabel.textAlignment = NSTextAlignmentRight;
        durationValueLabel.font = [UIFont systemFontOfSize:14];
        durationValueLabel.text = [Common getDurationString:asset.duration];
        
        [cell.contentView addSubview:durationValueLabel];
        [durationValueLabel release];
        
        UILabel *projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 80, 20)];
        projectLabel.textColor = color;
        projectLabel.backgroundColor = [UIColor clearColor];
        projectLabel.textAlignment = NSTextAlignmentLeft;
        projectLabel.font = [UIFont systemFontOfSize:14];
        projectLabel.text = _projectText;
        
        [cell.contentView addSubview:projectLabel];
        [projectLabel release];
        
        UILabel *projectValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, w-100, 20)];
        projectValueLabel.textColor = color;
        projectValueLabel.backgroundColor = [UIColor clearColor];
        projectValueLabel.textAlignment = NSTextAlignmentRight;
        projectValueLabel.font = [UIFont systemFontOfSize:14];
        projectValueLabel.text = [pm getProjectNameByKey:asset.project];
        
        [cell.contentView addSubview:projectValueLabel];
        [projectValueLabel release];
        
        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 80, 20)];
        startLabel.textColor = color;
        startLabel.backgroundColor = [UIColor clearColor];
        startLabel.textAlignment = NSTextAlignmentLeft;
        startLabel.font = [UIFont systemFontOfSize:14];
        startLabel.text = _startText;
        
        [cell.contentView addSubview:startLabel];
        [startLabel release];
        
        UILabel *startValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 85, w-100, 20)];
        startValueLabel.textColor = color;
        startValueLabel.backgroundColor = [UIColor clearColor];
        startValueLabel.textAlignment = NSTextAlignmentRight;
        startValueLabel.font = [UIFont systemFontOfSize:14];
        startValueLabel.text = asset.startTime == nil?_noneText:[Common getFullDateString:asset.startTime];
        
        [cell.contentView addSubview:startValueLabel];
        [startValueLabel release];
        
        UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 80, 20)];
        endLabel.textColor = color;
        endLabel.backgroundColor = [UIColor clearColor];
        endLabel.textAlignment = NSTextAlignmentLeft;
        endLabel.font = [UIFont systemFontOfSize:14];
        endLabel.text = _dueText;
        
        [cell.contentView addSubview:endLabel];
        [endLabel release];
        
        UILabel *endValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 110, w-100, 20)];
        endValueLabel.textColor = color;
        endValueLabel.backgroundColor = [UIColor clearColor];
        endValueLabel.textAlignment = NSTextAlignmentRight;
        endValueLabel.font = [UIFont systemFontOfSize:14];
        endValueLabel.text = asset.deadline == nil?_noneText:[Common getFullDateString:asset.deadline];
        
        [cell.contentView addSubview:endValueLabel];
        [endValueLabel release];
        
        UIButton *editButton = [Common createButton:_editText
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(w-70, 135, 60, 30)
                                         titleColor:[Colors blueButton]
                                             target:self
                                           selector:@selector(editAsset:)
                                   normalStateImage:nil
                                 selectedStateImage:nil];
        
        editButton.tag = asset;
        
        editButton.titleLabel.font = [UIFont systemFontOfSize:14];
        //editButton.backgroundColor = [UIColor lightGrayColor];
        editButton.layer.cornerRadius = 5;
        editButton.layer.borderWidth = 1;
        editButton.layer.borderColor = [[Colors blueButton] CGColor];
        
        [cell.contentView addSubview:editButton];        
    }
    
}

- (void) createURLCell:(UITableViewCell *)cell asset:(URLAsset *)asset
{
    NSInteger lines = [Common countLines:asset.urlValue boundWidth:linkTableView.bounds.size.width withFont:[UIFont fontWithName:@"Helvetica" size:16]];
    
    GuideWebView *webView = [[GuideWebView alloc] initWithFrame:CGRectMake(0, lines>1?-5:0, linkTableView.bounds.size.width, 50)];
    webView.backgroundColor = [UIColor clearColor];
    
    webView.safariEnabled = YES;
    
    NSString *url = [NSString stringWithFormat:@"<a style='font-size:14px;font-family:Helvetica' href='%@'>%@</a>", asset.urlValue, asset.urlValue];
    
    [webView loadHTMLContent:url];
    
    [cell.contentView addSubview:webView];
    
    [webView release];
}

/*
- (CGFloat) calculateExpandedNoteHeight
{
    //CGFloat h = contentView.bounds.size.height-60;
    CGFloat h = contentView.bounds.size.height;
    
    NSInteger count = self.linkList.count;
    
    if (hasNote)
    {
        count -= 1;
    }
    
    h -= (count >= 3?2.5:count)*40;
    
    if (h<100)
    {
        h = 100;
    }
    else if (h>150)
    {
        h = 150;
    }
    
    return h;
}
*/
#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSInteger count = self.linkList.count;
    
    if (!hasNote && ![self.item isNote]) //don't show empty Note for Note
    {
        count += 1;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
	CGFloat h = (indexPath.row == expandedNoteIndex) || (!hasNote && indexPath.row == 0) ?[self calculateExpandedNoteHeight]:(indexPath.row == tapRow?150:40);
    
    return h;*/
    
    NSInteger index = selectedIndex;
    
    if (!hasNote && ![self.item isNote])
    {
        if (index > 0)
        {
            index -= 1;
        }
    }
    
    if (indexPath.row == selectedIndex && index >= 0)
    {
        NSObject *asset = [self.linkList objectAtIndex:index];
        
        return ![asset isKindOfClass:[URLAsset class]]?170:40;
    }

    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger index = indexPath.row;
    
    /*
    if (!hasNote)
    {
        if (index == 0)
        {
            //CGRect frm = tableView.bounds;
            
            CGRect frm = CGRectMake(0, 0, tableView.bounds.size.width, 0);
            
            frm.size.height = [self calculateExpandedNoteHeight];
            
            noteView = [[NoteView alloc] initWithFrame:frm];
            //noteView.editEnabled = YES;
            noteView.editEnabled = NO;
            noteView.touchEnabled = YES;
            
            [cell.contentView addSubview:noteView];
            [noteView release];
            
            //nextButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //nextButton.frame = CGRectMake(frm.size.width - 30, frm.size.height/2-30, 30, 30);
            //[nextButton addTarget:self action:@selector(editNote:) forControlEvents:UIControlEventTouchUpInside];
            
            //[cell.contentView addSubview:nextButton];
            
            
            return cell;
        }
        else
        {
            index -= 1;
        }
    }
    
    Task *item = [self.linkList objectAtIndex:index];
    
    if (indexPath.row == expandedNoteIndex)
    {
        CGRect frm = CGRectMake(0, 0, tableView.bounds.size.width, 0);
        
        frm.size.height = [self calculateExpandedNoteHeight];
        
        //printf("note view frame x:%f - y:%f\n", frm.origin.x, frm.origin.y);
        
        noteView = [[NoteView alloc] initWithFrame:frm];
        
        //noteView.editEnabled = YES;
        noteView.editEnabled = NO;
        noteView.touchEnabled = YES;
        
        noteView.note = item;
        
        [cell.contentView addSubview:noteView];
        [noteView release];
        
        
        //nextButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //nextButton.frame = CGRectMake(frm.size.width - 30, frm.size.height/2-30, 30, 30);
        //[nextButton addTarget:self action:@selector(editNote:) forControlEvents:UIControlEventTouchUpInside];
        
        //[cell.contentView addSubview:nextButton];
    }*/
    
    
    BOOL expanded = (selectedIndex == indexPath.row);
    
    if (!hasNote && ![self.item isNote])
    {
        if (index == 0)
        {
            [self createEmptyNoteCell:cell expanded:expanded];
            
            return cell;
        }
        else
        {
            index -= 1;
        }
    }
    
    NSObject *linkedItem = [self.linkList objectAtIndex:index];
    
    if ([linkedItem isKindOfClass:[Task class]])
    {
        Task *asset = (Task *) linkedItem;
        
        if ([asset isTask])
        {
            [self createTaskCell:cell asset:asset expanded:expanded];
        }
        else if ([asset isEvent])
        {
            [self createEventCell:cell asset:asset expanded:expanded];
        }
        else if ([asset isNote])
        {
            [self createNoteCell:cell asset:asset expanded:expanded];
        }
        else
        {
            cell.textLabel.text = asset.name;
        }        
    }
    else if ([linkedItem isKindOfClass:[URLAsset class]])
    {
        URLAsset *asset = (URLAsset *) linkedItem;
        
        //cell.textLabel.text = asset.urlValue;
        
        [self createURLCell:cell asset:asset];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tapCount++;
    tapRow = indexPath.row;
    
    switch (tapCount)
    {
        case 1: //single tap
            [self performSelector:@selector(singleTap) withObject:nil afterDelay: .4];
            break;
        case 2: //double tap
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            
            [self performSelector:@selector(doubleTap) withObject: nil];
        }
            break;
        default:
            break;
    }
}

@end
