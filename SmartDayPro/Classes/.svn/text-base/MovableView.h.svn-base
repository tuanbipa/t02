//
//  MovableView.h
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovableController;

@interface MovableView : UIView<UIGestureRecognizerDelegate> {
	//NSInteger seqNo;	
	CGPoint touchedOffset;
	
	BOOL isMovable;
	BOOL isMoving;
	CGRect originalFrame;
	
	BOOL isSelected;
	BOOL multiSelectionEnable;
	BOOL touchHoldEnable;
	
	BOOL isReused;
	
	MovableController *movableController;
	NSDate *touchTime;
}

//@property NSInteger seqNo;
@property (nonatomic, assign) MovableController *movableController;
@property (readonly) BOOL isSelected;
@property BOOL multiSelectionEnable;
@property BOOL touchHoldEnable;
@property BOOL isReused;

-(CGPoint)getMovedDelta:(NSSet *)touches;
-(CGPoint)getTouchPoint;
- (void) changeFrame:(CGRect) frame;
-(void)move:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) multiSelect:(BOOL)enabled;
/*
-(void) multiSelect:(BOOL)needSelect;
-(void) finishMultiSelect;
-(void) startMultiSelect;
- (void) doSelect:(BOOL)needSelect;
*/
- (void) endMove:(BOOL)needRestoreFrame;
- (void) singleTouch;
- (void) doubleTouch;
-(BOOL) checkMovable:(NSSet *)touches;
- (void) enableMove:(BOOL) enable;
- (void) doSelect:(BOOL)needSelect;

@end
