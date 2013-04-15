//
//  PreviewViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PreviewViewController.h"

#import "Common.h"
#import "Task.h"

#import "ProjectManager.h"
#import "TaskManager.h"
#import "DBManager.h"
#import "TaskLinkManager.h"
#import "TimerManager.h"

#import "ContentView.h"
#import "NoteView.h"

#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"

#import "iPadSmartDayViewController.h"

#import "AbstractSDViewController.h"
#import "PlannerViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern PlannerViewController *_plannerViewCtrler;

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
        
        hasNote = NO;
        
        noteChange = NO;
        noteLinkCreated = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteFinishEdit:)
													 name:@"NoteFinishEditNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteDoubleTap:)
													 name:@"NoteDoubleTapNotification" object:nil];
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
    }
}

- (void) markNoteChange
{
    noteChange = YES;
}

- (void) doubleTap
{
    tapCount = 0;
    
    if (!hasNote)
    {
        tapRow -= 1;
    }
    
    if (tapRow >= 0)
    {
        Task *item = [self.linkList objectAtIndex:tapRow];
    
        //[_iPadSDViewCtrler editItem:item];
        if (_plannerViewCtrler != nil)
        {
            [_plannerViewCtrler editItem:item];
        }
        else if (_abstractViewCtrler != nil)
        {
            [_abstractViewCtrler editItem:item];
        }
    }
}

- (void) createLinkedNote:(NSString *)text
{
    DBManager *dbm = [DBManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    Task *note = [[Task alloc] init];
    
    note.type = TYPE_NOTE;
    note.startTime = [NSDate date];
    note.note = text;
    note.name = [Common getNoteTitle:text];
    
    [note insertIntoDB:[dbm getDatabase]];
    
    NSInteger itemId = self.item.primaryKey;
    
    if (self.item.original != nil && ![self.item isREException])
    {
        itemId = self.item.original.primaryKey;
    }
    
    NSInteger linkId = [tlm createLink:itemId destId:note.primaryKey];
    
    if (linkId != -1)
    {
        [self.linkList insertObject:note atIndex:0];
    }
    
    noteView.note = note;
    
    [note release];
    
    noteLinkCreated = YES;
}

#pragma mark Notification
- (void) noteFinishEdit:(NSNotification *)notification
{
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

#pragma mark Actions
- (void) editItem:(id) sender
{
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

#pragma mark View

- (void) loadView
{
    CGRect frm = CGRectMake(0, 0, 320, 416);
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
	UIButton *nameButton = [Common createButton:self.item.name
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(10, 0, frm.size.width-50, 40)
										titleColor:[UIColor blackColor]
											target:self
										  selector:@selector(editItem:)
								  normalStateImage:nil
								selectedStateImage:nil];
    nameButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    [contentView addSubview:nameButton];
/*
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -2, frm.size.width-40, 40)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    nameLabel.text = self.item.name;
    
    [contentView addSubview:nameLabel];
    [nameLabel release];
*/    
    UIButton *nextButton = [Common createButton:@""
                                     buttonType:UIButtonTypeCustom
                                          frame:CGRectMake(frm.size.width - 40, 0, 40, 40)
                                     titleColor:[UIColor blackColor]
                                         target:self
                                       selector:@selector(editItem:)
                               normalStateImage:nil
                             selectedStateImage:nil];
    
    [contentView addSubview:nextButton];
   
    UIImageView *detailImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MM_next.png"]];
    
    //detailImgView.frame = CGRectMake(frm.size.width - 40, 5, 25, 30);
    detailImgView.frame = CGRectMake(10, 3, 25, 30);
    
    [nextButton addSubview:detailImgView];
    [detailImgView release];
    
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
    
    frm = contentView.bounds;
    
    //frm.origin.x += 10;
    frm.origin.y += 60;
    frm.size.height -= 60;
    //frm.size.width -= 20;
    
    linkTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    linkTableView.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1];
    linkTableView.separatorColor = [UIColor grayColor];
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
    
    expandedNoteIndex = -1;
    
	// Do any additional setup after loading the view.    
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
                
                if (expandedNoteIndex == -1)
                {
                    expandedNoteIndex = index;
                }
            }
            
            index ++;
        }
    }
    
    [linkTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.item isTask] && _plannerViewCtrler == nil)
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
    if (noteLinkCreated)
    {
        //NoteViewController *ctrler = [_iPadSDViewCtrler getNoteViewController];
        NoteViewController *ctrler = [_abstractViewCtrler getNoteViewController];
        [ctrler loadAndShowList];
        
        CategoryViewController *catCtrler = [_abstractViewCtrler getCategoryViewController];
        [catCtrler setNeedsDisplay];
    }
    
    if (noteChange || noteLinkCreated)
    {
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
- (void) createNoteCell:(UITableViewCell *)cell item:(Task *)item
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [pm getNoteIcon:item.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 10, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-75, 10, 70, 20)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.text = [Common getFullDateString2:item.startTime];
    
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    CGFloat rightWidth = dateLabel.bounds.size.width + 10;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, w-30-rightWidth, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = item.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
}

- (void) createEventCell:(UITableViewCell *)cell item:(Task *)item
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [pm getEventIcon:item.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 10, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    CGFloat rightWidth = [item isADE]?70:90;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-rightWidth-5, 2, rightWidth, 20)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.text = [Common getFullDateString2:item.startTime];
    
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    NSString *str = [item isADE]?[Common getFullDateString2:item.endTime]:[NSString stringWithFormat:@"%@ - %@", [Common getShortTimeString:item.startTime], [Common getShortTimeString:item.endTime]];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(w-rightWidth-5, 18, rightWidth, 20)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.text = str;
    
    [cell.contentView addSubview:timeLabel];
    [timeLabel release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, w-30-rightWidth-10, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = item.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
}

- (void) createTaskCell:(UITableViewCell *)cell item:(Task *)item
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    CGFloat w = linkTableView.bounds.size.width;
    
    UIImage *img = [pm getTaskIcon:item.project];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(10, 10, img.size.width, img.size.height);
    
    [cell.contentView addSubview:imgView];
    [imgView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, w-40-5, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = item.name;
    
    [cell.contentView addSubview:titleLabel];
    [titleLabel release];
}

- (CGFloat) calculateExpandedNoteHeight
{
    CGFloat h = contentView.bounds.size.height-60;
    
    NSInteger count = self.linkList.count;
    
    if (hasNote)
    {
        count -= 1;
    }
    
    h -= (count >= 3?2.5:count)*40;
    
    return h;
}

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
    
    if (!hasNote)
    {
        count += 1;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.row == expandedNoteIndex) || (!hasNote && indexPath.row == 0) ?[self calculateExpandedNoteHeight]:40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger index = indexPath.row;
    
    if (!hasNote)
    {
        if (index == 0)
        {
            CGRect frm = tableView.bounds;
            
            frm.size.height = [self calculateExpandedNoteHeight];
            
            noteView = [[NoteView alloc] initWithFrame:frm];
            noteView.editEnabled = YES;
            noteView.touchEnabled = YES;
            
            [cell.contentView addSubview:noteView];
            [noteView release];
            
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
        CGRect frm = tableView.bounds;
        
        frm.size.height = [self calculateExpandedNoteHeight];
        
        noteView = [[NoteView alloc] initWithFrame:frm];
        
        noteView.editEnabled = YES;
        noteView.touchEnabled = YES;
        
        noteView.note = item;
        
        [cell.contentView addSubview:noteView];
        [noteView release];
    }
    else if ([item isTask])
    {
        [self createTaskCell:cell item:item];
    }
    else if ([item isEvent])
    {
        [self createEventCell:cell item:item];
    }
    else if ([item isNote])
    {
        [self createNoteCell:cell item:item];
    }
    else
    {
        cell.textLabel.text = item.name;
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
