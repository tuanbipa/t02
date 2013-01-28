//
//  PreviewViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/4/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentView;
@class NoteView;
@class Task;

@interface PreviewViewController : UIViewController
{
    ContentView *contentView;
    
    UITableView *linkTableView;
    
    NSInteger tapCount;
    NSInteger tapRow;
    
    NSInteger expandedNoteIndex;
    BOOL hasNote;
    
    NoteView *noteView;
}

@property (nonatomic, retain) Task *item;

@property (nonatomic, retain) NSMutableArray *linkList;

@end
