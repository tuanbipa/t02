//
//  CalendarADEView.h
//  SmartTime
//
//  Created by Left Coast Logic on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuickColorPickerView: UIView {
	
	NSMutableArray *colorIdList;
	NSInteger currentIndex;
	NSInteger startIndex;
	
	BOOL scrollToRight;
	
	BOOL selected;	
}

@property (nonatomic, retain) NSMutableArray *colorIdList; 
@property BOOL selected;
@property 	NSInteger currentIndex;

-(void)resetIndex;
- (void) changeBackgroundStyle;

- (NSInteger) getSelectedColorId;
- (void) selectColorId:(NSInteger) colorId;

@end
