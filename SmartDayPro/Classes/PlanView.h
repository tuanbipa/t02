//
//  TaskView.h
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Project;

#import "MovableView.h"

@interface PlanView : MovableView {
	//NSInteger projectColorID;
	
	UIImageView *expandImageView;
}

//@property NSInteger projectColorID;

//- (id)initWithPlan:(Project *)plan;

@property BOOL listStyle;
@property NSInteger listType;
@property (nonatomic, retain) Project *project;

- (void) refreshExpandImage;


@end
