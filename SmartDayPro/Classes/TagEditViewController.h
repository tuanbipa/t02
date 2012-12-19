//
//  TagEditViewController.h
//  SmartCal
//
//  Created by MacBook Pro on 5/9/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagEditViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	UITableView *tagTableView;

	NSObject *objectEdit;
}


@property (nonatomic, assign) NSObject *objectEdit;

@end
