//
//  iPadSmartDayViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractSDViewController.h"

@interface iPadSmartDayViewController : AbstractSDViewController
{
    UIButton *projectShowDoneButton;
    
    //UIButton *taskMultiEditButton;
}

//@property (nonatomic, retain) UIPopoverController *popoverCtrler;

- (BOOL) checkRect:(CGRect)rect inModule:(NSInteger) inModule;
- (void) showCategory;
- (void) showTag;
- (void) showSeekOrCreate:(NSString *)text;
- (void) createItem:(NSInteger)index title:(NSString *)title;
- (void) editItem:(Task *)task inRect:(CGRect)inRect;
- (void) showTimer;
- (void) showMenu;

- (void) refreshTaskFilterTitle;

@end
