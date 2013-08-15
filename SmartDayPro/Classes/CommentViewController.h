//
//  CommentViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentView;
@class ContentScrollView;
@class Task;

@interface CommentViewController : UIViewController
{
    ContentView *contentView;
    ContentScrollView *listView;
}

//@property (nonatomic, assign) Task *task;
@property NSInteger itemId;

@property (nonatomic, retain) NSMutableArray *comments;

@end
