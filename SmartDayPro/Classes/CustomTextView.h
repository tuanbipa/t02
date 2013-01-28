//
//  CustomTextView.h
//  TestNote
//
//  Created by Left Coast Logic on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTextView : UITextView
{
}

//@property (nonatomic, assign) UIScrollView *noteBgScrollView;
-(void)touchDetected:(UITouch *)touch withEvent:(UIEvent *)event;

@end
