//
//  RestoreViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 6/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface RestoreViewController : ViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *listFileTableView;
    
    NSArray * backupDirectoryContents;
    
    NSInteger *selectedItem;
}

@end