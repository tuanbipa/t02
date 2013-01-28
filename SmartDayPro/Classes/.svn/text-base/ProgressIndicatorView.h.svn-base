//
//  ProgressIndicatorView.h
//  SmartCal
//
//  Created by MacBook Pro on 12/13/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressIndicatorView : UIView {
    UIActivityIndicatorView*  progressIndicator;
    UILabel*                  progressMessage;
}

@property(nonatomic, retain) UIActivityIndicatorView*  progressIndicator;
@property(nonatomic, retain) UILabel*                  progressMessage;

-(CGRect)rectIndicator:(CGSize)size;
-(CGFloat)rectIndicatorHeight;
-(CGRect)rectMessage;
-(CGFloat)rectNudge;
-(CGPoint) pointCenter:(CGRect) rect;
-(CGRect) rectCenter:(CGRect)rect target:(CGRect) target;

-(void)setText:(NSString*)text;
-(void)showInView:(UIView*)view;
-(void)hide;

@end
