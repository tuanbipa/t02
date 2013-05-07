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
        self.font = [UIFont fontWithName:@"marker felt" size:17];
        
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

/*
- (void) singleTouch
{
    printf("Note 1 touch\n");
    
    NoteView *noteView = (NoteView *) self.superview;
    
    if (!noteView.editEnabled && [noteView.superview isKindOfClass:[LinkPreviewPane class]]) //Note View in Preview -> expand Preview
    {
        LinkPreviewPane *previewPane = (LinkPreviewPane *) noteView.superview;
        
        [previewPane expand];
    }
}

- (void) doubleTouch
{
    printf("Note 2 touch\n");
    
    NoteView *noteView = (NoteView *) self.superview;
    
    if (noteView.note != nil)
    {
        [_abstractViewCtrler editItem:noteView.note];
    }
}

-(void)touchDetected:(UITouch *)touch withEvent:(UIEvent *)event
{
    NoteView *noteView = (NoteView *) self.superview;
    
    if (!noteView.touchEnabled)
    {
        return;
    }
    
	switch (touch.tapCount)
    {
		case 1:
        {
            printf("single touch\n");
			[self performSelector:@selector(singleTouch) withObject:nil afterDelay:.2];
        }
			break;
		case 2:
        {
            printf("double touch\n");
            
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
			[self doubleTouch];
        }
			break;
	}
}
*/

@end
