//
//  GrowingTextView.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/9/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "GrowingTextView.h"

#import "Common.h"

@implementation GrowingTextView

@synthesize maxNumberOfLines;
@synthesize placeholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGRect frm = CGRectOffset(self.bounds, 5, 5);
        frm.size.height = 20;
        
        placeHolderLabel = [[UILabel alloc] initWithFrame:frm];
        placeHolderLabel.userInteractionEnabled = NO;
        placeHolderLabel.backgroundColor = [UIColor clearColor];
        placeHolderLabel.textColor = [UIColor grayColor];
        
        [self addSubview:placeHolderLabel];
        [placeHolderLabel release];
        
        originalDelegate = nil;
        self.delegate = self;
        self.returnKeyType = UIReturnKeyDone;
    }
    
    return self;
}

- (void) setDelegate:(id<UITextViewDelegate>)delegateParam
{
    if (delegateParam != self)
    {
        originalDelegate = delegateParam;
    }
    else
    {
        [super setDelegate:delegateParam];
    }
}

- (void) setPlaceholder:(NSString *)placeholderParm
{
    placeHolderLabel.text = placeholderParm;
}

-(void)setText:(NSString *)newText
{
    super.text = newText;
    
    placeHolderLabel.hidden = ![newText isEqualToString:@""];
    
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    [self performSelector:@selector(textViewDidChange:) withObject:self];
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat oldH = self.frame.size.height;
    
    NSInteger lines = [Common countLines:textView.text boundWidth:self.bounds.size.width withFont:self.font];
    
    if (lines > self.maxNumberOfLines)
    {
        lines = self.maxNumberOfLines;
    }
    else if (lines == 0)
    {
        lines = 1;
    }
    
    CGFloat h = lines * self.font.lineHeight + 8;
    
    if (h > oldH)
    {
        CGRect frm = self.frame;
        frm.size.height = h;
        
        [UIView animateWithDuration:0.1f
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction|
                                     UIViewAnimationOptionBeginFromCurrentState)
                         animations:^(void) {
                             self.frame = frm;
                         }
                         completion:^(BOOL finished) {
                             if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewDidChange:)])
                             {
                                 [originalDelegate textViewDidChange:textView];
                             }
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewGrowingNotification" object:nil];
                         }];
        
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    BOOL ret = YES;
    
    if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
    {
        ret = [originalDelegate textViewShouldBeginEditing:textView];
    }
    if (ret)
    {
        placeHolderLabel.hidden = YES;
    }
    
    return ret;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewShouldEndEditing:)])
    {
        return [originalDelegate textViewShouldBeginEditing:textView];
    }
    
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewDidBeginEditing:)])
    {
        return [originalDelegate textViewDidBeginEditing:textView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewDidEndEditing:)])
    {
        return [originalDelegate textViewDidEndEditing:textView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
 	if ([atext isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        
        return NO;
    }
   
    if (originalDelegate != nil &&[originalDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
    {
        return [originalDelegate textView:textView shouldChangeTextInRange:(NSRange)range
                          replacementText:(NSString *)atext];
    }
	
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (originalDelegate != nil && [originalDelegate respondsToSelector:@selector(textViewDidChangeSelection:)])
    {
        [originalDelegate textViewDidChangeSelection:textView];
    }
}


@end
