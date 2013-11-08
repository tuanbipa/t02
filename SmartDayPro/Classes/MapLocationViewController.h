//
//  MapLocationViewController.h
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 9/12/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Task;

@interface MapLocationViewController : UIViewController <UITextFieldDelegate, MKMapViewDelegate>
{
    UIView *contentView;
    MKMapView *mapView;
    
    Task *task;
    
    UITextField *locationTextField;
    UILabel *etaLable;
    
    MKMapItem *destination;
    
    BOOL isDone;
}

@property (nonatomic, assign) Task *task;
@property (nonatomic, retain) MKMapItem *destination;
@end
