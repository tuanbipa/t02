//
//  LinkSearchViewController.h
//  SmartCal
//
//  Created by Left Coast Logic on 4/17/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
{
    UISearchBar *searchBar;
    UITableView *linkTableView;
    
    NSInteger selectedSection;
    NSInteger selectedRow;
}

@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, retain) NSMutableArray *taskList;
@property (nonatomic, retain) NSMutableArray *noteList;
@property (nonatomic, retain) NSMutableArray *anchorList;

@property NSInteger excludeId;

@end
