//
//  FilterObject.h
//  SmartDayPro
//
//  Created by Tuan Pham on 6/10/18.
//  Copyright © 2018 Left Coast Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterObject : NSObject
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *iconName;
@property (nonatomic) BOOL isSelected;

@end
