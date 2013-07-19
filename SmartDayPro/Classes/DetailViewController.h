//
//  DetailViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/8/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentView;
@class Task;

@class HPGrowingTextView;
@class NoteView;
@class PreviewViewController;

@interface DetailViewController : UIViewController
{
    ContentView *contentView;
    
    UIView *inputView;
    
    UITableView *detailTableView;
    
    HPGrowingTextView *titleTextView;
    
    NoteView *noteView;
    
    UIButton *tagButtons[9];
    UITextField *tagInputTextField;
    
    BOOL showAll;
}

@property (nonatomic, retain) 	Task *task;
@property (nonatomic, copy) 	Task *taskCopy;

@property (nonatomic, retain) UIViewController *inputViewCtrler;
@property (nonatomic, retain) PreviewViewController *previewViewCtrler;

- (void) closeInputView;

- (void) refreshDuration;
- (void) refreshProject;
- (void) refreshWhen;
- (void) refreshUntil;
- (void) refreshAlert;
- (void) refreshDescription;
- (void) refreshTag;
- (void) refreshLink;

- (void) editAsset:(Task *)asset;

- (void) createLinkedNote:(Task *)note;

@end
