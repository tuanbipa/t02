//
//  NoteView.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/8/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@class CustomTextView;
@class SimpleCoreTextView;

@interface NoteView : UIView
{
    CustomTextView *noteTextView;
    UIScrollView *noteBgScrollView;
    
    UIView *doneBarView;
    //UIButton *checkButton;
    
    CGRect parentFrame;
}

@property (nonatomic, assign) Task *note;

//@property BOOL inCheckMode;
@property (nonatomic, retain) NSMutableDictionary *checkDict;
@property (nonatomic, readonly) CustomTextView *noteTextView;

@property BOOL editEnabled;
@property BOOL touchEnabled; //allow users to tap or double-tap in Preview pane, disabled in Edit view

@property (nonatomic, assign) IBOutlet UIBarButtonItem *checkItem;
- (IBAction) check:(id)sender;
- (IBAction) uncheckAll:(id)sender;
- (IBAction) done:(id)sender;

- (void) changeFrame:(CGRect)frame;
- (void) changeCheckMode:(BOOL)inCheck;
- (NSString *) getNoteText;

- (void) startEdit;
- (void) cancelEdit;
- (void) finishEdit;

- (void) refreshNoteBackground;

@end
