//
//  ProjectColorPaletteView.h
//  SmartCal
//
//  Created by Mac book Pro on 10/18/11.
//  Copyright (c) 2011 LCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HighlightView;

@class Project;

@interface ProjectColorPaletteView : UIView
{
    HighlightView * highlightView;
    
    NSInteger colorId;
    
    Project *projectEdit;
}

@property NSInteger colorId;

@property (nonatomic, assign) Project *projectEdit;

@end
