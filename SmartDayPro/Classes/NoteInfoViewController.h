//
//  NoteInfoViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 6/7/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface NoteInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *noteTableView;
    
    UITextField *tagInputTextField;
    UIButton *tagButtons[9];
}

@property (nonatomic, assign) Task *note; 

@end
