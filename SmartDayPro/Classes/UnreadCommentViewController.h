//
//  UnreadCommentViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 8/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadCommentViewController : UIViewController
{
    UITableView *listTableView;
}

@property (nonatomic, retain) NSMutableArray *unreadCommentList;

@end
