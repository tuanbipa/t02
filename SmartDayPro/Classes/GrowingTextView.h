//
//  GrowingTextView.h
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/9/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrowingTextView : UITextView<UITextViewDelegate>
{
    id<UITextViewDelegate> originalDelegate;
    UILabel *placeHolderLabel;
}

@property int maxNumberOfLines;
@property (nonatomic, assign) NSString *placeholder;

@end
