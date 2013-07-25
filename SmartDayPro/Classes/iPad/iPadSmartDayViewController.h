//
//  iPadSmartDayViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractSDViewController.h"

typedef enum
{
    TAG_VIEW_HEADER_VIEW = 32000,
	TAG_VIEW_EDIT_BAR = 32010,
    TAG_VIEW_COUNT_LABEL = 32011,
    TAG_VIEW_COPY_BUTTON = 32012
} TagsView;

@interface iPadSmartDayViewController : AbstractSDViewController
{
    UIButton *projectShowDoneButton;
    
    UIButton *selectedModuleButton;
    
    //UIButton *taskMultiEditButton;
}

//@property (nonatomic, retain) UIPopoverController *popoverCtrler;

- (BOOL) checkRect:(CGRect)rect inModule:(NSInteger) inModule;
- (void) showCategory;
- (void) showTag;
- (void) showSeekOrCreate:(NSString *)text;
- (void) editItem:(Task *)task inRect:(CGRect)inRect;
- (void) showTimer;
- (void) showMenu;

- (void) refreshTaskFilterTitle;
//- (void) showTaskModule:(BOOL)enabled;
- (void) showModuleOff;
- (void) showTaskModule;
- (void) refreshEditBarViewWithCheck: (BOOL) check;
- (void) cancelEdit;
@end
