//
//  NoteDetailTableViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 4/5/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class NoteView;

@interface NoteDetailTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UIView *contentView;
    UITableView *noteTableView;
    
    //UIView *doneBarView;
    UIButton *checkButton;
    
    UIView *noteContentView;
    NoteView *noteView;
    
    UIImageView *noteImgView;
    UILabel *prjNameLabel;
    UILabel *dateLabel;
    
    //UITextField *tagInputTextField;
    //UIButton *tagButtons[9];
    
    UIBarButtonItem *saveButton;
    
    Task *note;
}

@property (nonatomic, retain) Task *note;
@property (nonatomic, copy) Task *noteCopy;

- (void) refreshStart;

@end
