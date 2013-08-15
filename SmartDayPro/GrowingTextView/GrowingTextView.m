//
//  GrowingTextView.m
//  SmartDayPro
//
//  Created by LeftCoastLogic on 10/24/12.
//  Copyright (c) 2013 LeftCoastLogic. All rights reserved.
//

#import "GrowingTextView.h"

#import "Common.h"

@implementation GrowingTextView

@synthesize textView;
@synthesize text;
@synthesize maxLineNumber;
@synthesize font;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        textView = [[UITextView alloc] initWithFrame:self.bounds];
        textView.backgroundColor = [UIColor clearColor];
        textView.delegate = self;
        textView.scrollEnabled = YES;
        textView.font = [UIFont systemFontOfSize:14];
        textView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
        textView.showsVerticalScrollIndicator = YES;
        textView.text = @"";
        
        [self addSubview:textView];
        [textView release];
        
        minHeight = frame.size.height;
        
        self.maxLineNumber = 1;
    }
    return self;
}

- (void) changeFrame:(CGRect)frm
{
    self.frame = frm;
    
    frm.origin = CGPointZero;
    
    self.textView.frame = frm;
}

- (void) setText:(NSString *)textParam
{
    self.textView.text = textParam;
    
    [self textViewDidChange:self.textView];
}

- (NSString *) text
{
    return self.textView.text;
}


- (void) setMaxLineNumber:(NSInteger)maxLineNumberParam
{
    /*
    NSString *savedText = self.textView.text, *newText = @"";
    
    self.textView.delegate = nil;
    self.textView.hidden = YES;
    
    for (int i = 1; i < maxLineNumberParam; ++i)
        newText = [newText stringByAppendingString:@"\n"];
    
    self.textView.text = newText;
    
    maxHeight = self.textView.contentSize.height - self.textView.font.lineHeight - self.textView.font.descender;
    
    self.textView.text = savedText;
    self.textView.hidden = NO;
    self.textView.delegate = self;*/
    
    maxLineNumber = maxLineNumberParam;
    
    maxHeight = maxLineNumberParam * self.textView.font.lineHeight + 16;
}

- (void) setFont:(UIFont *)fontParam
{
    textView.font = fontParam;
    
    maxHeight = self.maxLineNumber * self.textView.font.lineHeight + 16;
}

- (void) resize:(CGFloat)height
{
    if (height > maxHeight)
    {
        height = maxHeight;
    }
    
    if (height < minHeight)
    {
        height = minHeight;
    }
    
    if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [delegate growingTextView:self willChangeHeight:height];
    }
    
    CGRect frm = self.frame;
    
    frm.size.height = height;
    
    [self changeFrame:frm];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark UITextView Delegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) textViewDidChange:(UITextView *)textView
{
    //CGFloat h = self.textView.contentSize.height - self.textView.font.lineHeight - self.textView.font.descender;
    
    NSInteger lines = [Common countLines:textView.text boundWidth:textView.bounds.size.width withFont:textView.font];
    
    CGFloat lh = textView.font.lineHeight;
    
    CGFloat h = lines*lh + 16;

    if (h != self.bounds.size.height && h >= minHeight && self.bounds.size.height != maxHeight)
    {
        [UIView animateWithDuration:0.1f
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             [self resize:h];
                         }
                         completion:^(BOOL finished) {
                             
                             if (h >= maxHeight)
                             {
                                 if(!self.textView.scrollEnabled)
                                 {
                                     self.textView.scrollEnabled = YES;
                                     [self.textView flashScrollIndicators];
                                 }
                                 
                             }
                             else
                             {
                                 self.textView.scrollEnabled = NO;
                             }
                             
                             if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                 [delegate growingTextView:self didChangeHeight:h];
                             }
                             
                         }];
        
    }
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[delegate growingTextViewDidBeginEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[delegate growingTextViewDidEndEditing:self];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textViewParam shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
	//weird 1 pixel bug when clicking backspace when textView is empty
	if(![textViewParam hasText] && [atext isEqualToString:@""]) return NO;
	
	if ([atext isEqualToString:@"\n"]) {
		if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)])
        {
			if ([delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self])
            {
                return YES;
            }
            else
            {
                [self.textView resignFirstResponder];
                
                return NO;
            }            
        }
	}
	
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[delegate growingTextViewDidChangeSelection:self];
	}
}

@end
