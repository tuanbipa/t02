//
//  LocationDetailViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/28/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Location;

@interface LocationDetailViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>
{
    UITextField *nameTextField;
    UITextField *addressTextField;
    UIButton *currentLocationButton;
    
    Location *location;
    
    CLLocationManager *locationManager;
    
    //CLLocation *currentLocation;
    //NSArray *searchPlacemarksCache;
}

@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSArray *searchPlacemarksCache;
@property (nonatomic, retain) CLLocation *currentLocation;
@end
