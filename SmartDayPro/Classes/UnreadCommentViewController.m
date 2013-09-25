//
//  UnreadCommentViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "UnreadCommentViewController.h"

#import "Common.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "Project.h"
#import "Task.h"

#import "UnreadComment.h"

#import "iPadViewController.h"

//extern BOOL _isiPad;
extern iPadViewController *_iPadViewCtrler;

@implementation UnreadCommentViewController

@synthesize unreadCommentList;

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
    }
    
    return self;
}

- (void) dealloc
{
    self.unreadCommentList = nil;
    
    [super dealloc];
}

- (void) refreshData
{
    DBManager *dbm = [DBManager getInstance];
    
    self.unreadCommentList = [dbm getUnreadComments];
    
    [listTableView reloadData];
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
    /*if (_isiPad)
    {
        frm.size.height = 440;
    }
    */
    frm.size.height = 416;
	
	UIView *contentView= [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1];
    
	self.view = contentView;
	[contentView release];
    
    listTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
    
	listTableView.delegate = self;
	listTableView.dataSource = self;
	listTableView.sectionHeaderHeight = 10;
    listTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:listTableView];
	[listTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self refreshData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return self.unreadCommentList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
   	/*else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}
	}*/
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    UnreadComment *comment = [self.unreadCommentList objectAtIndex:indexPath.row];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, listTableView.bounds.size.width - 20, 20)];
    
    countLabel.text = [NSString stringWithFormat:@"%d unread comment(s) on", comment.count];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor grayColor];
    countLabel.font = [UIFont systemFontOfSize:16];
    
    [cell.contentView addSubview:countLabel];
    [countLabel release];
    
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    
    NSString *text = @"";
    UIColor *color = [UIColor clearColor];
    
    if (comment.itemType == COMMENT_TYPE_PROJECT)
    {
        Project *project = [[Project alloc] initWithPrimaryKey:comment.itemKey database:[dbm getDatabase]];
        
        text = project.name;
        
        color = [pm getProjectColor0:project.primaryKey];
    }
    else
    {
        Task *task = [[Task alloc] initWithPrimaryKey:comment.itemKey database:[dbm getDatabase]];
        
        text = task.name;
        
        color = [pm getProjectColor0:task.project];
    }
    
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, listTableView.bounds.size.width - 20, 20)];
    
    itemLabel.text = text;
    itemLabel.backgroundColor = [UIColor clearColor];
    itemLabel.textColor = color;
    itemLabel.font = [UIFont systemFontOfSize:16];
    
    [cell.contentView addSubview:itemLabel];
    [itemLabel release];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBManager *dbm = [DBManager getInstance];
    
    UnreadComment *comment = [self.unreadCommentList objectAtIndex:indexPath.row];

    [[AbstractActionViewController getInstance] hidePopover];
    
    if (comment.itemType == COMMENT_TYPE_PROJECT)
    {
        Project *prj = [[Project alloc] initWithPrimaryKey:comment.itemKey database:[dbm getDatabase]];
        
        [[AbstractActionViewController getInstance] editProject:prj inView:nil];
        
        [prj release];
    }
    else
    {
        Task *task = [[Task alloc] initWithPrimaryKey:comment.itemKey database:[dbm getDatabase]];
        
        [[AbstractActionViewController getInstance] editItem:task inView:nil];
        
        [task release];
    }
}

@end
