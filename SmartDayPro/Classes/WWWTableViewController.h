//
//  WWWTableViewController.h
//  SmartPlan
//
//  Created by Huy Le on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import <AddressBookUI/AddressBookUI.h>

@class Task;
@class GrowingTextView;

@interface WWWTableViewController : UITableViewController<ABPeoplePickerNavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, MKMapViewDelegate> {
	UIView *contentView;
    UITableView *wwwTableView;
	
	Task *task;
	
    GrowingTextView *titleTextView;
	UIButton *selectedButton;
	UIView *doneBarView;
	UITextView *locationTextView;
    
    // map kit
    UITextView *startLocationTextView;
    MKMapView *mapView;
    UILabel *etaLable;
    BOOL isRefreshWhen;
}

@property (nonatomic, assign) Task *task;

@end
