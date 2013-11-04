//
//  NoteContentViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/24/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "NoteContentViewController.h"

#import "Common.h"
#import "Task.h"

#import "NoteView.h"

#import "iPadViewController.h"
#import "SmartDayViewController.h"
#import "DetailViewController.h"
#import "NoteDetailViewController.h"

extern iPadViewController *_iPadViewCtrler;
extern DetailViewController *_detailViewCtrler;
extern SmartDayViewController *_sdViewCtrler;

//extern BOOL _isiPad;

@implementation NoteContentViewController

@synthesize note;
@synthesize noteCopy;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteChanged:)
													 name:@"NoteContentChangeNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];

        
    }
    
    return self;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.note = nil;
    self.noteCopy = nil;
    
    [super dealloc];
}

- (void) done:(id)sender
{
    [noteView finishEdit];
    
    if (![self.noteCopy.name isEqualToString:@""])
    {
        [[AbstractActionViewController getInstance] updateTask:self.note withTask:self.noteCopy];
    }
    
    if (_isiPad)
    {
        if (_iPadViewCtrler.detailNavCtrler != nil)
        {
            if ([_iPadViewCtrler.detailNavCtrler.topViewController isKindOfClass:[DetailViewController class]])
            {
                DetailViewController *ctrler = (DetailViewController *)_iPadViewCtrler.detailNavCtrler.topViewController;
                
                if (self.noteCopy.primaryKey == -1)
                {
                    [ctrler createLinkedNote:self.note];
                }
                
                [ctrler refreshLink];
            }
            else if ([_iPadViewCtrler.detailNavCtrler.topViewController isKindOfClass:[NoteDetailViewController class]])
            {
                NoteDetailViewController *ctrler = (NoteDetailViewController *)_iPadViewCtrler.detailNavCtrler.topViewController;
                
                if (self.note.listSource == SOURCE_PREVIEW)
                {
                    [ctrler refreshLink];
                }
                else
                {
                    [ctrler refreshNote];
                }
            }
        }
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];

        if ([_sdViewCtrler.navigationController.topViewController isKindOfClass:[DetailViewController class]])
        {
            DetailViewController *ctrler = (DetailViewController *)_sdViewCtrler.navigationController.topViewController;
            
            if (self.noteCopy.primaryKey == -1)
            {
                [ctrler createLinkedNote:self.note];
            }
            
            [ctrler refreshLink];
        }
        else if ([_sdViewCtrler.navigationController.topViewController isKindOfClass:[NoteDetailViewController class]])
        {
            NoteDetailViewController *ctrler = (NoteDetailViewController *)_sdViewCtrler.navigationController.topViewController;
            
            if (self.note.listSource == SOURCE_PREVIEW)
            {
                [ctrler refreshLink];
            }
            else
            {
                [ctrler refreshNote];
            }
        }
        
    }
}

- (void) noteChanged:(NSNotification *)notification
{
    //printf("title: %s\n", [self.noteCopy.name UTF8String]);
    
    self.navigationItem.title = self.noteCopy.name;
}

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        CGFloat w = frm.size.height + 20 + 44;
        
        frm.size.height = frm.size.width - 20 - 44;
        
        frm.size.width = w;
    }
    
	contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];

    frm = contentView.bounds;

    //noteView = [[NoteView alloc] initWithFrame:contentView.bounds];
    noteView = [[NoteView alloc] initWithFrame:frm];
    
    [contentView addSubview:noteView];
    [noteView release];
}

- (void) changeFrame:(CGRect) frm
{
    contentView.frame = frm;
    
    [noteView changeFrame:contentView.bounds];
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.size.height -= 20 + 44;
    
    [self changeFrame:frm];
    
    originalNoteFrame = noteView.frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = self.noteCopy.name;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.navigationItem.leftBarButtonItem = doneItem;
    
    [doneItem release];
    
    [self changeOrientation:self.interfaceOrientation];
    
    self.noteCopy = self.note;
    noteView.note = self.noteCopy;
    
    if ([self.note isShared])
    {
        noteView.editEnabled = NO;
    }
    
    [noteView startEdit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeOrientation:toInterfaceOrientation];
    
    if (_iPadViewCtrler != nil)
    {
        //[_iPadViewCtrler changeOrientation:toInterfaceOrientation];
        [_iPadViewCtrler willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    else if (_sdViewCtrler != nil)
    {
        //[_sdViewCtrler changeOrientation:toInterfaceOrientation];
        [_sdViewCtrler willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

#pragma mark Notification
- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect frm = originalNoteFrame;
    
    frm.size.height -= UIInterfaceOrientationIsLandscape(self.interfaceOrientation)?kbSize.width:kbSize.height;
    
    [noteView changeFrame:frm];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [noteView changeFrame:originalNoteFrame];
}


@end
