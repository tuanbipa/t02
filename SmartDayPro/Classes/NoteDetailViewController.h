//
//  NoteDetailViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/23/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentView;
@class NoteView;
@class Task;
@class PreviewViewController;

@interface NoteDetailViewController : UIViewController
{
    ContentView *contentView;
    
    UIView *inputView;
    UITableView *detailTableView;
    NoteView *noteView;
    
    UITextField *tagInputTextField;
    
    UIButton *tagButtons[9];
    
    BOOL showComments;
}

@property (nonatomic, retain) 	Task *note;
@property (nonatomic, copy) 	Task *noteCopy;

@property (nonatomic, retain) UIViewController *inputViewCtrler;
@property (nonatomic, retain) PreviewViewController *previewViewCtrler;

- (void) refreshNote;
- (void) refreshDate;
- (void) refreshProject;
- (void) refreshLink;
- (void)refreshHeightForTableCell;

- (void) closeInputView;

@end
