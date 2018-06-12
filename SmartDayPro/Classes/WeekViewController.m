//
//  WeekViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/22/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "WeekViewController.h"

#import "Common.h"
#import "Task.h"

#import "TaskManager.h"
#import "ProjectManager.h"

#import "SmartDayViewController.h"
#import "FontManager.h"

extern SmartDayViewController *_sdViewCtrler;

@interface WeekViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation WeekViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init{
    if (self = [super init])
    {
        for (int i=0; i<7; i++)
        {
            adeLists[i] = nil;
            eventLists[i] = nil;
            taskLists[i] = nil;
        }
        
        [self loadData];
    }
    return self;
}

- (void) dealloc
{
    for (int i=0; i<7; i++)
    {
        if (adeLists[i] != nil)
        {
            [adeLists[i] release];
        }

        if (eventLists[i] != nil)
        {
            [eventLists[i] release];
        }
        
        if (taskLists[i] != nil)
        {
            [taskLists[i] release];
        }
    }
    
    [super dealloc];
}

- (void) loadData
{
    TaskManager *tm = [TaskManager getInstance];
    
    for (int i=0; i<7; i++)
    {
        if (adeLists[i] != nil)
        {
            [adeLists[i] release];
        }
        
        if (eventLists[i] != nil)
        {
            [eventLists[i] release];
        }
        
        if (taskLists[i] != nil)
        {
            [taskLists[i] release];
        }
        
        NSDate *dt = [Common dateByAddNumDay:i toDate:[NSDate date]];
        
        adeLists[i] = [[tm getADEListOnDate:dt] retain];
        eventLists[i] = [[tm getEventListOnDate:dt] retain];
        taskLists[i] = [[tm getUnSplittedScheduledTasksOnDate:dt] retain];
    }
}

- (void) exportPNG
{
    UIImage* snapshot = nil;
    
    UIGraphicsBeginImageContext(listTableView.contentSize);
    {
        CGPoint savedContentOffset = listTableView.contentOffset;
        CGRect savedFrame = listTableView.frame;
        
        listTableView.contentOffset = CGPointZero;
        listTableView.frame = CGRectMake(0, 0, listTableView.contentSize.width, listTableView.contentSize.height);
        
        [listTableView.layer renderInContext: UIGraphicsGetCurrentContext()];
        snapshot = UIGraphicsGetImageFromCurrentImageContext();
        
        listTableView.contentOffset = savedContentOffset;
        listTableView.frame = savedFrame;
    }
    
    UIGraphicsEndImageContext();
    
    //UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil);
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	
	if (picker != nil)
	{
		picker.mailComposeDelegate = self;
		
		//[picker setSubject:@"SmartDay - Overview"];
        [picker setSubject:_reportWeekEmailSubject];
		
		
		// Set up recipients
		//NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
		//NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
		//NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
		
		[picker setToRecipients:nil];
		[picker setCcRecipients:nil];
		[picker setBccRecipients:nil];
		
		// Attach an image to the email
		//NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
		//NSData *myData = [NSData dataWithContentsOfFile:path];
		
		NSData *dataForPNGFile = UIImagePNGRepresentation(snapshot);
		
		[picker addAttachmentData:dataForPNGFile mimeType:@"image/png" fileName:@"overview"];
		//[picker addAttachmentData:myData mimeType:@"text/csv" fileName:[NSString stringWithFormat:@"%@.csv", self.plan.name]];
		
		// Fill out the email body text
//		NSString *emailBody = [NSString stringWithFormat:@"The attachment is week overview exported from SmartDay."];
		NSString *emailBody = _reportWeekEmailBody;
		[picker setMessageBody:emailBody isHTML:NO];
		
		//[self presentModalViewController:picker animated:YES];
        //picker.modalPresentationStyle = UIModalPresentationFullScreen;
        //picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [_sdViewCtrler presentViewController:picker animated:YES completion:NULL];
        
		[picker release];
	}
}

#pragma  mark MailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[_sdViewCtrler dismissViewControllerAnimated:controller completion:NULL];
}

#pragma mark View

- (void) loadView {
    CGRect frm = CGRectZero;
    CGSize sz = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape([Common currentOrientation])) {
        if (sz.width < sz.height) {
            frm.size.width = sz.height + [Common heightTabbar] + [Common heightNavigationbar];
            frm.size.height = sz.width - [Common heightNavigationbarAtLandscapeMode];
        }
    }
    else {
        frm.size = sz;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    self.view = contentView;
    [contentView release];
    
    listTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
    listTableView.backgroundColor = [UIColor whiteColor];
    listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    listTableView.separatorColor = COLOR_LINE;
    listTableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    listTableView.delegate = self;
    listTableView.dataSource = self;
    [contentView addSubview:listTableView];
    [listTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    //[self exportPNG];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (eventLists[indexPath.row].count > 0 || taskLists[indexPath.row].count > 0 || adeLists[indexPath.row] > 0)
	{
        int count = MAX(eventLists[indexPath.row].count, taskLists[indexPath.row].count);
        
        int h = count * 30 + adeLists[indexPath.row].count*25;
        
		return h > 60?h:60;
	}
	
	return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDate *dt = [Common dateByAddNumDay:indexPath.row toDate:[NSDate date]];
    
    NSMutableArray *adeList = adeLists[indexPath.row];
    NSMutableArray *eventList = eventLists[indexPath.row];
    NSMutableArray *taskList = taskLists[indexPath.row];
    
    ProjectManager *pm = [ProjectManager getInstance];
    
    CGFloat left_w = 40;
    CGFloat adeH = adeList.count*25;
    CGFloat h = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
//    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(left_w-6, 0, 6, h)];
//    separatorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"week_separator.png"]];
//    [cell.contentView addSubview:separatorView];
//    [separatorView release];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(left_w, 0, 0.5, h)];
    separatorView.backgroundColor = COLOR_LINE;
    [cell.contentView addSubview:separatorView];
    [separatorView release];
    
    UIView *itemSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(left_w + (tableView.bounds.size.width-left_w)/2, adeH, 0.5, h-adeH)];
    itemSeparatorView.backgroundColor = COLOR_LINE;
    [cell.contentView addSubview:itemSeparatorView];
    [itemSeparatorView release];
    
    if (adeH > 0) {
        UIView *adeSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(left_w, adeH, tableView.bounds.size.width-left_w, 1)];
        adeSeparatorView.backgroundColor = COLOR_LINE;
        [cell.contentView addSubview:adeSeparatorView];
        [adeSeparatorView release];    
    }
    
    CGFloat fontSize = 13;
    CGFloat heightLabel = 20;
    
    UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, left_w-6, heightLabel)];
    weekdayLabel.backgroundColor = [UIColor clearColor];
    weekdayLabel.textColor = COLOR_TEXT_OVERVIEW;
    weekdayLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightThin];
    weekdayLabel.textAlignment = NSTextAlignmentRight;
    weekdayLabel.text = [[Common getWeekdayString:dt] uppercaseString];
    [cell.contentView addSubview:weekdayLabel];
    [weekdayLabel release];
    
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, heightLabel-4, left_w-6, heightLabel)];
    monthLabel.backgroundColor = [UIColor clearColor];
    monthLabel.textColor = COLOR_TEXT_OVERVIEW;
    monthLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightThin];
    monthLabel.textAlignment = NSTextAlignmentRight;
    monthLabel.text = [[Common getMonthString:dt] uppercaseString];
    [cell.contentView addSubview:monthLabel];
    [monthLabel release];

    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, left_w-6, heightLabel)];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.textColor = COLOR_TEXT_OVERVIEW_SEL;
    dayLabel.font = [UIFont systemFontOfSize:20];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.text = [Common getDayString:dt];
    [cell.contentView addSubview:dayLabel];
    [dayLabel release];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
    
    for (int i=0; i<adeList.count; i++)
    {
        Task *ade = [adeList objectAtIndex:i];
        
        UILabel *adeLabel = [[UILabel alloc] initWithFrame:CGRectMake(left_w+5, i==0?2:1 + i*25, tableView.bounds.size.width-left_w-10, 22)];
        adeLabel.backgroundColor = [pm getProjectColor0:ade.project];
        adeLabel.textColor = [UIColor whiteColor];
        adeLabel.textAlignment = NSTextAlignmentCenter;
        adeLabel.font = font;
        //adeLabel.numberOfLines = 0;
        adeLabel.text = ade.name;
        
        adeLabel.layer.cornerRadius = 5;
        
        [cell.contentView addSubview:adeLabel];
        [adeLabel release];        
    }
    
    CGFloat sizeIcon = 16;
    
    for (int i=0; i<eventList.count; i++) {
        Task *event = [eventList objectAtIndex:i];
        
        UIImage *eventImageIcon = [FontManager flowasticImageWithIconName:@"event"
                                                                   andSize:sizeIcon
                                                                 iconColor:[Common colorWithProject:event.project]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(left_w+2, adeH + i*30 + 8, 16, 16)];
        imgView.image = eventImageIcon;
        [cell.contentView addSubview:imgView];
        [imgView release];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left_w+20, adeH + i*30,
                                                                        (tableView.bounds.size.width-left_w)/2-20, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = font;
        titleLabel.numberOfLines = 0;
        titleLabel.text  = [NSString stringWithFormat:@"[%@-%@] %@",
                                                                [Common getShortTimeString:event.startTime],
                                                                [Common getShortTimeString:event.endTime], event.name];
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
    }

    for (int i=0; i<taskList.count; i++) {
        Task *task = [taskList objectAtIndex:i];
        
        UIImage *taskImageIcon = [FontManager flowasticImageWithIconName:@"undone"
                                                                  andSize:sizeIcon
                                                                iconColor:[Common colorWithProject:task.project]];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(left_w+(tableView.bounds.size.width-left_w)/2+2,
                                                                             adeH + i*30 + 8, 14, 14)];
        imgView.image = taskImageIcon;
        [cell.contentView addSubview:imgView];
        [imgView release];
        
        /*
        UIImageView *checkImgView = [[UIImageView alloc] initWithFrame:imgView.frame];
        checkImgView.image = [UIImage imageNamed:@"checkmark.png"];
        [cell.contentView addSubview:checkImgView];
        [checkImgView release];
        */
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left_w+(tableView.bounds.size.width-left_w)/2+20,
                                                                        adeH + i*30, (tableView.bounds.size.width-left_w)/2-20, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = font;
        titleLabel.numberOfLines = 0;
        titleLabel.text = task.name;
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
    }
    
    return cell;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
    {
        [_sdViewCtrler dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
