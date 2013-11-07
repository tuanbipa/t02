//
//  LocationListViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 10/25/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "LocationListViewController.h"
#import "Common.h"
#import "iPadGeneralSettingViewController.h"
#import "Location.h"
#import "LocationManager.h"
#import "LocationDetailViewController.h"
#import "DBManager.h"
#import "Project.h"
#import "ProjectEditViewController.h"
#import "iPadViewController.h"
#import "DetailViewController.h"

extern iPadViewController *_iPadViewCtrler;
extern BOOL _isiPad;

@implementation LocationListViewController

@synthesize locationList;
@synthesize objectEdit;

- (id)init
{
    if (self = [super init])
	{
        
	}
	
	return self;
}

- (void)dealloc
{
    locationList = nil;
    [super dealloc];
}

#pragma mark Views

- (void)loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.origin.y = 20;
    frm.size = sz;
    
    if (self.navigationController.viewControllers.count <= 1) {
        frm.size.width = 2*frm.size.width/3;
    } else {
        
        UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        frm.size.width = ctrler.view.frame.size.width;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	self.view = contentView;
	[contentView release];
    
    frm = contentView.bounds;
    frm.origin.x = 10;
    frm.origin.y = 10;
    frm.size.width -= 20;
    frm.size.height = _isiPad?60:100;
    
    hintLable = [[UILabel alloc] initWithFrame:frm];
    hintLable.backgroundColor = [UIColor clearColor];
    hintLable.numberOfLines = 0;
    hintLable.text = _locationHintText;
    hintLable.textAlignment = NSTextAlignmentLeft;
    hintLable.font = [UIFont systemFontOfSize:16];
    hintLable.textColor = [Colors darkSteelBlue];
    
    [contentView addSubview:hintLable];
    [hintLable release];
    
    frm = contentView.bounds;
    frm.origin.y = hintLable.bounds.size.height+10;
    frm.size.height -= frm.origin.y;
    
    locationsTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	locationsTableView.delegate = self;
	locationsTableView.dataSource = self;
	locationsTableView.allowsSelectionDuringEditing=YES;
    locationsTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:locationsTableView];
	[locationsTableView release];
	
	self.navigationItem.title = _locationText;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get location list;
    self.locationList = [[LocationManager getInstance] getAllLocation];
    [locationsTableView reloadData];
    
    // update UI
    if (objectEdit != nil) {
        
        hintLable.text = _selectLocationHintText;
        CGRect frm = hintLable.frame;
        frm.size.height += _isiPad?40:60;
        hintLable.frame = frm;
        
        frm = self.view.bounds;
        frm.origin.y = hintLable.bounds.size.height + hintLable.frame.origin.y;
        frm.size.height -= frm.origin.y;
        locationsTableView.frame = frm;
    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    // get location list;
//    self.locationList = [[LocationManager getInstance] getAllLocation];
//    [locationsTableView reloadData];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([_iPadViewCtrler.detailNavCtrler.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)_iPadViewCtrler.detailNavCtrler.topViewController;
        
        [ctrler refreshLocationObject];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locationList.count + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}
	}
    
    cell.imageView.image = nil;
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	
	cell.accessoryType = objectEdit == nil ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	//cell.selectionStyle = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = (objectEdit == nil ? _addText : _noneText);
            if (objectEdit != nil && [self getLocationID] <= 0) {
                cell.accessoryType =  UITableViewCellAccessoryCheckmark;
            }
        }
            break;
            
        default:
        {
            Location *location= [self.locationList objectAtIndex: indexPath.row - 1];
            cell.textLabel.text = location.name;
            if ([self getLocationID]== location.primaryKey) {
                cell.accessoryType =  UITableViewCellAccessoryCheckmark;
            }
        }
            break;
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	if(indexPath.row == 0)
	{
		return UITableViewCellEditingStyleNone;
	}
	
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (objectEdit == nil);
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (objectEdit == nil) {
        [self editLocationDetail:indexPath.row];
    } else {
        // select location
        [self selectLocation:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *location = [self.locationList objectAtIndex: indexPath.row - 1];
    
    [location deleteFromDatabase:[[DBManager getInstance] getDatabase]];
    
    [self.locationList removeObject:location];
    
    [locationsTableView reloadData];
}

#pragma mark methods

- (void)editLocationDetail: (NSInteger) index
{
    Location *location;
    if (index == 0) {
        location = [[Location alloc] init];
    } else {
        location = [[self.locationList objectAtIndex:index - 1] copy];
    }
    
    LocationDetailViewController *ctrler = [[LocationDetailViewController alloc] init];
    ctrler.location = location;
    [location release];
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void)selectLocation: (NSInteger)index
{
    if (index > 0) {
    
        Location *location = [self.locationList objectAtIndex:index - 1];
        //[[self objectLocation] setLocation:location.primaryKey];
        [objectEdit setLocationID:location.primaryKey];
    } else {
        //[[self objectLocation] setLocation:-1];
        [objectEdit setLocationID:-1];
    }
    
    [locationsTableView reloadData];
}

- (NSInteger)getLocationID
{
    return [objectEdit locationID];
}
@end
