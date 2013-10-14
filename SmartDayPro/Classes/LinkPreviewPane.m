//
//  LinkPreviewPane.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/8/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "LinkPreviewPane.h"

#import "Common.h"
#import "Task.h"

#import "TaskLinkManager.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskManager.h"

#import "NoteView.h"
#import "CustomTextView.h"

#import "SmartDayViewController.h"
#import "NoteViewController.h"
#import "CategoryViewController.h"

SmartDayViewController *_sdViewCtrler;

@implementation LinkPreviewPane

@synthesize task;

@synthesize linkList;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //printf("Preview Init x:%f, y:%f\n", self.frame.origin.x, self.frame.origin.y);
        
        self.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1];
        
        self.hidden = YES;
        self.linkList = nil;
        noteLinkCreated = NO;
        noteChange = NO;
        hasMore = NO;
        tapCount = 0;
        tapRow = -1;
        
        listTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        //listTableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        listTableView.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1];
        listTableView.separatorColor = [UIColor grayColor];
        listTableView.delegate = self;
        listTableView.dataSource = self;
        listTableView.hidden = YES;
        
        [self addSubview:listTableView];
        [listTableView release];
        
        noteView = [[NoteView alloc] initWithFrame:self.bounds];
        noteView.editEnabled = YES;
        noteView.touchEnabled = YES;
        
        [self addSubview:noteView];
        [noteView release];
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(frame.size.width - 55, frame.size.height - 30, 50, 25);
        moreButton.layer.cornerRadius = 4;
        moreButton.layer.borderWidth = 1;
        moreButton.layer.borderColor = [[UIColor blackColor] CGColor];
        moreButton.backgroundColor = [Colors linen];
        moreButton.clipsToBounds = YES;
        [moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        moreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [moreButton addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];

        moreButton.hidden = YES;
        
        [self addSubview:moreButton];
        
        separatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 6)];
        separatorView.image = [UIImage imageNamed:@"ade_separator.png"];
        
        [self addSubview:separatorView];
        [separatorView release];
        
        [self collapse];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteBeginEdit:)
													 name:@"NoteBeginEditNotification" object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteFinishEdit:)
													 name:@"NoteFinishEditNotification" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.linkList = nil;
    
    [super dealloc];
}

- (CGFloat) calculateExpandedNoteHeight
{
    CGFloat h = self.bounds.size.height - (self.linkList.count >= 4?2.5:self.linkList.count-1)*40;
    
    return h;
}

- (CGFloat) calculatedExpandedHeight
{
    CGFloat h = 0;
    
    CGSize sz = [Common getScreenSize];
    
    if (expandedNoteIndex >= 0)
    {
        h = 2*sz.height/3;
    }
    else // no Note
    {
        h = (self.linkList.count >= 3?2.5:self.linkList.count)*40;
    }
    
    return h;
}

- (void) expand
{
    noteView.hidden = YES;
    moreButton.hidden = YES;
    listTableView.hidden = NO;
    
    expandedNoteIndex = -1;
    
    if (self.linkList.count > 0)
    {
        Task *item = [self.linkList objectAtIndex:0];
        
        if ([item isNote])
        {
            expandedNoteIndex = 0;
        }
    }    
    
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    
    frm.size.width = sz.width;
    frm.size.height = [self calculatedExpandedHeight];
    frm.origin.y = sz.height - frm.size.height;
    
    self.frame = frm;
    
    listTableView.frame = self.bounds;

    isExpanded = YES;
        
    [listTableView reloadData];
    
    [_sdViewCtrler expandPreview];
}

- (void) expand:(id) sender
{
    [self expand];
}

- (void) collapse
{
    self.task = nil;
    
    [listTableView reloadData];
    
    noteView.hidden = NO;
    
    listTableView.hidden = YES;
    
    CGRect frm = self.frame;
    frm.size.height = 80;
    frm.origin.y = self.superview.bounds.size.height - 80;
    
    self.frame = frm;
    
    moreButton.frame = CGRectMake(frm.size.width - 55, frm.size.height - 30, 50, 25);
    moreButton.hidden = !hasMore;
    
    [noteView changeFrame:self.bounds];
    
    isExpanded = NO;
    
    [noteView cancelEdit];
    
    if (noteLinkCreated)
    {
        if ([_sdViewCtrler.activeViewCtrler isKindOfClass:[NoteViewController class]])
        {
            NoteViewController *ctrler = (NoteViewController *)_sdViewCtrler.activeViewCtrler;
            
            [ctrler loadAndShowList];
        }
        else if ([_sdViewCtrler.activeViewCtrler isKindOfClass:[CategoryViewController class]])
        {
            CategoryViewController *ctrler = (CategoryViewController *)_sdViewCtrler.activeViewCtrler;
            
            [ctrler setNeedsDisplay];
        }
    }
    
    if (noteChange || noteLinkCreated)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteChangeNotification" object:nil]; //to auto-sync mSD        
    }
    
    noteLinkCreated = NO;
    noteChange = NO;
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
    NSInteger linkId = [tlm createLink:self.task.primaryKey destId:note.primaryKey destType:ASSET_ITEM];
    
    if (linkId != -1)
    {
        [self.linkList insertObject:note atIndex:0];
        
        //self.task.links = [[TaskLinkManager getInstance] getLinkIds4Task:self.task.primaryKey];
    }
    
    noteView.note = note;
    
    noteView.editEnabled = NO;
    
    [note release];
    
    noteLinkCreated = YES;
}

- (void) setTask:(Task *)taskParam
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    DBManager *dbm = [DBManager getInstance];
    
    task = (taskParam.original != nil && ![taskParam isREException]?taskParam.original:taskParam);
    
    noteView.note = nil;
    noteView.editEnabled = YES;
    hasMore = NO;
    
    if (self.task != nil)
    {
        self.linkList = [NSMutableArray arrayWithCapacity:self.task.links.count];
        
        for (NSNumber *num in self.task.links)
        {
            NSInteger linkedId = [tlm getLinkedId4Task:self.task.primaryKey linkId:[num intValue]];
            
            Task *item = [[Task alloc] initWithPrimaryKey:linkedId database:[dbm getDatabase]];
            item.listSource = SOURCE_PREVIEW;
            
            [self.linkList addObject:item];
            [item release];
            
            if ([item isRE])
            {
                Task *firstInstance = [[TaskManager getInstance] findRTInstance:item fromDate:item.startTime];
                
                item.startTime = firstInstance.startTime;
                item.endTime = firstInstance.endTime;
                
            }
        }
        
        if ([task isNote])
        {
            noteView.hidden = YES;
            
            CGRect frm = self.frame;
            
            CGFloat dy = self.linkList.count > 0?40:80;
            
            frm.origin.y += dy;
            frm.size.height -= dy;
            
            self.frame = frm;
        }
        
        if (self.linkList.count > 0)
        {
            Task *firstLink = [self.linkList objectAtIndex:0];
            
            NSInteger moreCount = self.linkList.count;
            
            if ([task isNote])
            {
                moreButton.frame = CGRectMake(self.frame.size.width - 55, self.frame.size.height - 30, 50, 25);
            }
            else if ([firstLink isNote])
            {
                noteView.note = firstLink;
                noteView.editEnabled = NO;
                
                moreCount -= 1;
            }
            
            if (moreCount > 0)
            {
                [moreButton setTitle:[NSString stringWithFormat:@"%d %@", moreCount, [task isNote]?_linkMoreText:_moreText] forState:UIControlStateNormal];
                
                hasMore = YES;
            }
        }
        
        moreButton.hidden = !hasMore;
    }
    else
    {
        self.linkList = [NSMutableArray arrayWithCapacity:0];
    }
}

-(void) noteBeginEdit:(NSNotification *)notif
{
    moreButton.hidden = YES;
    
    CGRect frm = self.frame;
    
    frm.origin.y -= [Common getKeyboardHeight] + 40;
    frm.size.height += 40;
    
    self.frame = frm;
    
    [noteView changeFrame:self.bounds];
    
    [_sdViewCtrler expandPreview];
}

-(void) noteFinishEdit:(NSNotification *)notif
{
    if (!self.hidden)
    {
        moreButton.hidden = !hasMore;
        
        CGRect frm = self.frame;
        
        frm.origin.y += [Common getKeyboardHeight] + 40;
        frm.size.height -= 40;
        
        self.frame = frm;
        
        [noteView changeFrame:self.bounds];
        
        NSString *text = [noteView getNoteText];
        
        if (![text isEqualToString:@""])
        {
            [self createLinkedNote:text];
        }        
    }
}

- (void) markNoteChange
{
    noteChange = YES;
}

-(void)popUpView
{
	self.hidden = NO;
    
    //printf("Preview x:%f, y:%f\n", self.frame.origin.x, self.frame.origin.y);
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
}

-(void)popDownView
{
    [self collapse];
    
	self.hidden = YES;
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
}

- (void) show
{
    if (self.hidden)
    {
        [self.superview bringSubviewToFront:self];
        
        [self popUpView];
    }
    else
    {        
        [self popDownView];
    }
}

- (void) singleTap
{    
    tapCount = 0;
    
    Task *item = [self.linkList objectAtIndex:tapRow];
    
    if ([item isNote])
    {
        if (expandedNoteIndex != -1)
        {
            /*
            NSIndexPath *previousPath = [NSIndexPath indexPathForRow:expandedNoteIndex inSection:0];
            
            [listTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
            
            [Common reloadRowOfTable:listTableView row:expandedNoteIndex section:0];
            
            expandedNoteIndex = -1;

        }
        
        expandedNoteIndex = tapRow;
        
        /*
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:expandedNoteIndex inSection:0];
        
        [listTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];*/
        
        [Common reloadRowOfTable:listTableView row:expandedNoteIndex section:0];
        
    }    
}

- (void) doubleTap
{
    tapCount = 0;
    
    Task *item = [self.linkList objectAtIndex:tapRow];
    
    [_sdViewCtrler editItem:item];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark Cell Creation
- (void) createNoteCell:(UITableViewCell *)cell item:(Task *)item
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    CGFloat w = listTableView.bounds.size.width;
    
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
    
    CGFloat w = listTableView.bounds.size.width;
    
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
    
    CGFloat w = listTableView.bounds.size.width;
    
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
    return isExpanded?self.linkList.count:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.row == expandedNoteIndex?[self calculateExpandedNoteHeight]:40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Task *item = [self.linkList objectAtIndex:indexPath.row];
    
    if (indexPath.row == expandedNoteIndex)
    {
        CGRect frm = cell.bounds;
        
        frm.size.height = [self calculateExpandedNoteHeight];
        
        NoteView *noteView = [[NoteView alloc] initWithFrame:frm];
        
        noteView.editEnabled = NO;
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
