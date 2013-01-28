//
//  LinkPreviewPane.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/8/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class NoteView;

@interface LinkPreviewPane : UIView<UITableViewDataSource, UITableViewDelegate>
{
    NoteView *noteView;
    UIImageView *separatorView;
    
    UITableView *listTableView;
    UIButton *moreButton;
    
    BOOL isExpanded;
    BOOL hasMore;
    NSInteger expandedNoteIndex; //selected Note index in expanded mode
    
    NSInteger tapCount;
    NSInteger tapRow;
    
    BOOL noteLinkCreated;
    BOOL noteChange; //user checks in Note content
}

@property (nonatomic, assign) Task *task;

@property (nonatomic, retain) NSMutableArray *linkList; //array of Task objects

- (void) expand;
- (void) show;
- (void) createLinkedNote:(NSString *)text;
- (void) markNoteChange;

@end
