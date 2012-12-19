//
//  MovableController.h
//  SmartPlan
//
//  Created by Huy Le on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MovableView;
@class LayoutController;

@interface MovableController : NSObject {
	MovableView *activeMovableView;	
	MovableView *rightMovableView;
	MovableView *leftMovableView;
	MovableView *onMovableView;
	
	//multi-select
	NSInteger selectionMode;
	NSMutableArray *selectedMovableViews;
	
	BOOL autoScroll;
    BOOL unseparateInProgress;
}

@property (nonatomic, retain) MovableView *activeMovableView;
@property NSInteger selectionMode;
@property (nonatomic, retain)  NSMutableArray *selectedMovableViews;

@property BOOL autoScroll;

- (void)highlight: (MovableView *) view;
- (void)unhighlight;
-(void)reset;
- (void)unselectAll:(BOOL)unhighlight;
- (void) beginMove:(MovableView *)view;
-(void) animateRelations;
-(void) finishMove:(BOOL)toRestore;
- (void) endMove:(MovableView *)view;
- (void)zoom: (MovableView *) onView;
- (void)unzoom;
-(void)scroll:(NSSet *)touches container:(UIView *)container;
- (void)deselect;
-(void)move:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)checkSeparate:(MovableView *)view;
- (void)separate: (MovableView *) rightView fromLeft:(MovableView *) leftView;
- (void)unseparate;

@end
