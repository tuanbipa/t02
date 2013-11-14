//
//  CommentViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CommentViewController.h"

#import "Common.h"

#import "Task.h"
#import "Comment.h"

#import "DBManager.h"

#import "ContentView.h"
#import "ContentScrollView.h"

#import "GrowingTextView.h"

//extern BOOL _isiPad;

@implementation CommentViewController

@synthesize comments;
//@synthesize task;
@synthesize itemId;

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
        
    }
    
    return self;
}

- (void) dealloc
{
    self.comments = nil;
    
    [super dealloc];
}

- (void) refreshData
{
    DBManager *dbm = [DBManager getInstance];
    
    //self.comments = [dbm getComments4Task:self.task.primaryKey];
    self.comments = [dbm getComments4Item:self.itemId];
    
    for (UIView *view in listView.subviews)
    {
        if (view.tag == -10000)
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat y = 10;
    
    for (Comment *comment in self.comments)
    {
        CGFloat w = contentView.bounds.size.width-20;
        GrowingTextView *growTextView = [[GrowingTextView alloc] initWithFrame:CGRectMake(10, 25, contentView.bounds.size.width-20, 30)];
        
        growTextView.font = [UIFont systemFontOfSize:15.0f];
        //growTextView.delegate = self;
        growTextView.backgroundColor = [UIColor clearColor];
        growTextView.textView.editable = NO;
        growTextView.textView.textColor = [UIColor grayColor];
        growTextView.maxLineNumber = 20;

        growTextView.text = comment.content;
        
        CGFloat h = growTextView.bounds.size.height + 30;
        
        UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(10, y, contentView.bounds.size.width-20, h)];
        commentView.tag = -10000;
        commentView.backgroundColor = [UIColor colorWithRed:213.0/255 green:222.0/255 blue:231.0/255 alpha:1];
        commentView.layer.cornerRadius = 5;
        
        [listView addSubview:commentView];
        [commentView release];
        
        UIFont *font = [UIFont systemFontOfSize:14];
        //NSString *time = [Common getFullDateTimeString:comment.createTime];
        NSString *time = [Common getDateTimeString:comment.createTime];
        
        CGSize sz = [time sizeWithFont:font];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(commentView.bounds.size.width - sz.width - 10, 0, sz.width + 10, 25)];
        timeLabel.font = font;
        timeLabel.text = time;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor grayColor];
        
        [commentView addSubview:timeLabel];
        [timeLabel release];
        
        font = [UIFont boldSystemFontOfSize:16];
        
        NSString *name = [NSString stringWithFormat:@"%@ %@", comment.firstName, comment.lastName];
        
        //sz = [name sizeWithFont:font];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, commentView.bounds.size.width - timeLabel.bounds.size.width - 10, 25)];
        nameLabel.font = font;
        nameLabel.text = name;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor grayColor];
        
        [commentView addSubview:nameLabel];
        [nameLabel release];
        

        [commentView addSubview:growTextView];
        [growTextView release];
        
        y += h + 10;
    }
    
    listView.contentSize = CGSizeMake(contentView.bounds.size.width, y);

    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul);
    
    dispatch_async(backgroundQueue, ^{
        [dbm updateCommentStatus:COMMENT_STATUS_NONE forItem:self.itemId];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentUpdateNotification" object:nil];
        
    });
    
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    /*
     frm.size.width = 320;
     
     if (_isiPad)
     {
     frm.size.height = 416;
     }*/
    
    if (_isiPad)
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            frm.size.height = frm.size.width - 20;
        }
        
        frm.size.width = 384;
    }
    else
    {
        frm.size.width = 320;
    }

    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	self.view = contentView;
	[contentView release];
    
    frm = contentView.bounds;
	
    listView = [[ContentScrollView alloc] initWithFrame:frm];
    listView.contentSize = CGSizeMake(frm.size.width, 1.2*frm.size.height);
    listView.backgroundColor = [UIColor clearColor];
	listView.delegate = self;
	listView.scrollsToTop = NO;
	listView.showsVerticalScrollIndicator = YES;
	
	[contentView addSubview:listView];
	[listView release];
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

@end
