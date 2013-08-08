//
//  GrowingTextView.h
//  SmartDayPro
//
//  Created by LeftCoastLogic on 10/24/12.
//  Copyright (c) 2013 LeftCoastLogic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowingTextView;

@protocol GrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(GrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(GrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(GrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(GrowingTextView *)growingTextView;

- (BOOL)growingTextView:(GrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(GrowingTextView *)growingTextView;

- (void)growingTextView:(GrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(GrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(GrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(GrowingTextView *)growingTextView;
@end

@interface GrowingTextView : UIView<UITextViewDelegate>
{
    UITextView *textView;
    
    CGFloat maxHeight;
    CGFloat minHeight;
}

@property (nonatomic, readonly) UITextView *textView;
@property (nonatomic, retain) NSString *text;
@property (assign) NSInteger maxLineNumber;

@property(nonatomic, assign) NSObject<GrowingTextViewDelegate> *delegate;

@end
