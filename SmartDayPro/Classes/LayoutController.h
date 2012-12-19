//
//  LayoutController.h
//  SmartPlan
//
//  Created by Huy Le on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MovableController;

@interface LayoutController : NSObject {
	UIView *viewContainer;

	UIView *lastView;
	NSInteger lastIndex;

	NSMutableArray *inMemoryTaskViewList;	
	
	MovableController *movableController;
	
	BOOL viewContainerDisable;
    
    CGPoint lastContentOffset;
}

@property (nonatomic, assign) 	UIView *viewContainer;

@property (nonatomic, retain) MovableController *movableController;

- (void) layout;
- (void) updateView:(NSArray *)objList;
- (void) beginLayout;
- (void) endLayout;
- (void) handleOverlap:(UIView *)view;
//- (void) endLayout:(NSMutableArray *)views;
-(void)reset;
- (BOOL) checkOverlap:(UIView *)view;

@end
