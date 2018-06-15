//
//  CustomTextView.m
//  TestNote
//
//  Created by Left Coast Logic on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTextView.h"

#import "NoteView.h"
#import "LinkPreviewPane.h"

#import "AbstractSDViewController.h"

AbstractSDViewController *_abstractViewCtrler;

@implementation CustomTextView

//@synthesize noteBgScrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //self.font = [UIFont fontWithName:@"marker felt" size:17];
        self.font = [UIFont fontWithName:@"Helvetica" size:17];
        
    }
    return self;
}

- (id)styleString {
    return [[super styleString] stringByAppendingString:@"; line-height: 24px"];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void) setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    if ([self.superview isKindOfClass:[NoteView class]])
    {
        [(NoteView *)self.superview refreshNoteBackground];
    }
}

- (void) setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    if ([self.superview isKindOfClass:[NoteView class]])
    {
        [(NoteView *)self.superview refreshNoteBackground];
    }    
}

@end
