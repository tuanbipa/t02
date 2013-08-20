//
//  TagDetailViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 8/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum
{
    CoordinateSelectorLastSelectedTypeSearch = 1,
    CoordinateSelectorLastSelectedTypeCurrent,
    CoordinateSelectorLastSelectedTypeUndefined,
} CoordinateSelectorLastSelectedType;

@interface TagDetailViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (readonly) CLLocationCoordinate2D selectedCoordinate;
@property (readonly) CoordinateSelectorLastSelectedType selectedType;
@property (readonly) NSString *selectedName;

@end
