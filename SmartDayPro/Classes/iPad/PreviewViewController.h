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
    
    //NSInteger expandedNoteIndex;
    NSInteger selectedIndex;
    BOOL hasNote;
    
    NoteView *noteView;
    CGRect noteFrm;
    UIButton *nextButton;
    
    BOOL noteLinkCreated;
    BOOL noteChange; //track change when user checks in Note content or modify Note content to sync with mSD
}

@property (nonatomic, retain) Task *item;

@property (nonatomic, retain) NSMutableArray *linkList;

- (void) markNoteChange;
- (void) changeFrame:(CGRect) frm;

- (void) showNote;
- (void) refreshData;

@end
