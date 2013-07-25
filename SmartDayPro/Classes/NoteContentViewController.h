//
//  NoteContentViewController.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/24/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;
@class NoteView;

@interface NoteContentViewController : UIViewController
{
    UIView *contentView;
    NoteView *noteView;
    
    CGRect originalNoteFrame;
}

@property (nonatomic, retain) Task *note;
@property (nonatomic, copy) Task *noteCopy;

@end
