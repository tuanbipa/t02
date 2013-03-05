//
//  TagListViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadTagListViewController : UIViewController
{
    UITableView *tagTableView;
    
    NSMutableDictionary *selectedDict;
}

@end
