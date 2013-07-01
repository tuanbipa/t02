//
//  RestoreViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 6/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *listFileTableView;
    
    NSArray * backupDirectoryContents;
}

@end