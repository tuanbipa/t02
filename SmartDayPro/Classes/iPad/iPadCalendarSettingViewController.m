//
//  iPadCalendarSettingViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/20/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadCalendarSettingViewController.h"

#import "Common.h"
#import "Settings.h"

#import "ContentView.h"

#import "TimeZonePickerViewController.h"

@interface iPadCalendarSettingViewController ()

@end

@implementation iPadCalendarSettingViewController

@synthesize setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) refreshPicker
{
	datePicker.date = (segmentedStyleControl.selectedSegmentIndex == 0?
					   [self.setting getWorkingStartTimeOnDay:selectedIndex+1]:
					   [self.setting getWorkingEndTimeOnDay:selectedIndex+1]);
}

- (void) editTimeZone
{
    TimeZonePickerViewController *ctrler = [[TimeZonePickerViewController alloc] init];
    ctrler.objectEdit = self.setting;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

#pragma mark Actions
- (void) changeTimeZoneSupport:(id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.timeZoneSupport = (segmentedStyleControl.selectedSegmentIndex==0);
    
    self.setting.timeZoneID = 0;
    
    if (self.setting.timeZoneSupport)
    {
        NSTimeZone *tz = [NSTimeZone defaultTimeZone];
        
        self.setting.timeZoneID = [Settings findTimeZoneIDByDisplayName:tz.name];
    }
    
    //[settingTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [settingTableView reloadData];
}

- (void) changeWeekStart: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.weekStart = segmentedStyleControl.selectedSegmentIndex;
}

- (void) changeStartEnd:(id) sender
{
    [self refreshPicker];
}

-(void)timeChanged:(id)sender
{
	NSString *time = [Common get24TimeString:datePicker.date];
	
	NSString *workingTimeStr = @"";
	
	switch (selectedIndex)
	{
		case 0:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.sunEndTime compare:time] == NSOrderedAscending)
				{
					time = setting.sunEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.sunStartTime = time;
			}
			else
			{
				if ([self.setting.sunStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.sunStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.sunEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.sunStartTime],
							  [Common convertWorkingTimeString:self.setting.sunEndTime]];
		}
			break;
		case 1:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.monEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.monEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.monStartTime = time;
			}
			else
			{
				if ([self.setting.monStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.monStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.monEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.monStartTime],
							  [Common convertWorkingTimeString:self.setting.monEndTime]];
			
		}
			break;
		case 2:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.tueEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.tueEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.tueStartTime = time;
			}
			else
			{
				if ([self.setting.tueStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.tueStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.tueEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.tueStartTime],
							  [Common convertWorkingTimeString:self.setting.tueEndTime]];
			
		}
			break;
		case 3:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.wedEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.wedEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.wedStartTime = time;
			}
			else
			{
				if ([self.setting.wedStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.wedStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.wedEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.wedStartTime],
							  [Common convertWorkingTimeString:self.setting.wedEndTime]];
			
		}
			break;
		case 4:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.thuEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.thuEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.thuStartTime = time;
			}
			else
			{
				if ([self.setting.thuStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.thuStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.thuEndTime = time;
			}
            
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.thuStartTime],
							  [Common convertWorkingTimeString:self.setting.thuEndTime]];
		}
			break;
		case 5:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.friEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.friEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.friStartTime = time;
			}
			else
			{
				if ([self.setting.friStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.friStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.friEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.friStartTime],
							  [Common convertWorkingTimeString:self.setting.friEndTime]];
            
		}
			break;
		case 6:
		{
			if (segmentedStyleControl.selectedSegmentIndex == 0)
			{
				if ([self.setting.satEndTime compare:time] == NSOrderedAscending)
				{
					time = self.setting.satEndTime;
					
					datePicker.date = [self.setting getWorkingEndTimeOnDay:selectedIndex+1];
					
				}
				
				self.setting.satStartTime = time;
			}
			else
			{
				if ([self.setting.friStartTime compare:time] == NSOrderedDescending)
				{
					time = self.setting.friStartTime;
					
					datePicker.date = [self.setting getWorkingStartTimeOnDay:selectedIndex+1];
				}
				
				self.setting.satEndTime = time;
			}
			
			workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
							  [Common convertWorkingTimeString:self.setting.satStartTime],
							  [Common convertWorkingTimeString:self.setting.satEndTime]];
		}
			break;
	}
	
	UITableViewCell *cell = [settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:1]];
	
	UILabel *label = (UILabel *)[cell viewWithTag:10000+selectedIndex];
	
	label.text = workingTimeStr;
}


#pragma mark View

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    frm.size.width = 2*frm.size.width/3;
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
    //frm.size.height = 400;
    
	settingTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:settingTableView];
	[settingTableView release];
    
    pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 500, contentView.bounds.size.width, [Common getKeyboardHeight]+40)];
    //pickerView.hidden = YES;
    
    [contentView addSubview:pickerView];
    [pickerView release];
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(30, 40, contentView.bounds.size.width-60, 0)];
    
	[datePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
	datePicker.minuteInterval = 5;
	datePicker.datePickerMode = UIDatePickerModeTime;
    
    [pickerView addSubview:datePicker];
    [datePicker release];
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _startText, _endText, nil];
	
	segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(30, 5, 100, 30);
	
	[segmentedStyleControl addTarget:self action:@selector(changeStartEnd:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = 0;
	
	[pickerView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    
    selectedIndex = [Common getWeekday:[NSDate date]]-1;
    
    [self refreshPicker];
}

- (void)viewWillAppear:(BOOL)animated {
	[settingTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	// Do any additional setup after loading the view.
    
    [settingTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section)
    {
        case 0: //TimeZone Support
        {
            return self.setting.timeZoneSupport?2:1;
        }
        case 1: //Week Start
            return 1;
        case 2:
            return 7;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if (section == 2)
    {
        return _workingTimeText;
    }
    
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = _timeZoneSupport;
                    
                    NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
                    UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
                    segmentedStyleControl.tag = 10000;
                    segmentedStyleControl.frame = CGRectMake(tableView.bounds.size.width - 70 - 120, 5, 120, 30);
                    [segmentedStyleControl addTarget:self action:@selector(changeTimeZoneSupport:) forControlEvents:UIControlEventValueChanged];
                    segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
                    segmentedStyleControl.selectedSegmentIndex = self.setting.timeZoneSupport?0:1;
                    
                    [cell.contentView addSubview:segmentedStyleControl];
                    [segmentedStyleControl release];                    
                    
                }
                    break;
                    
                case 1:
                {
                    NSString *timeZoneName = [Settings getTimeZoneDisplayNameByID:self.setting.timeZoneID];
                    
                    cell.textLabel.text = _timeZone;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 90 - 205, 8, 205, 20)];
                    label.tag = 10001;
                    label.textAlignment=NSTextAlignmentRight;
                    label.backgroundColor=[UIColor clearColor];
                    label.font=[UIFont systemFontOfSize:15];
                    label.textColor= [Colors darkSteelBlue];
                    
                    label.text = timeZoneName==nil?@"":timeZoneName;
                    
                    [cell.contentView addSubview:label];
                    [label release];
                }
                    break;
            }
        }
            break;
        case 1:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = _weekStartText;
            
            NSArray *segmentTextContent = [NSArray arrayWithObjects: _sundayText, _mondayText, nil];
            UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
            segmentedStyleControl.tag = 11000;
            segmentedStyleControl.frame = CGRectMake(tableView.bounds.size.width - 70 - 170, 5, 170, 30);
            [segmentedStyleControl addTarget:self action:@selector(changeWeekStart:) forControlEvents:UIControlEventValueChanged];
            segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
            segmentedStyleControl.selectedSegmentIndex = self.setting.weekStart;
            
            [cell.contentView addSubview:segmentedStyleControl];
            [segmentedStyleControl release];
        }
            break;
            
        case 2:
        {
            NSString *wkStrings[7] = {@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"};
            
            cell.textLabel.text = wkStrings[indexPath.row];
            
            UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 70 - 205, 10, 205, 20)];
            label.tag = 12000 + indexPath.row;
            label.textAlignment=NSTextAlignmentRight;
            label.backgroundColor=[UIColor clearColor];
            label.font=[UIFont systemFontOfSize:15];
            label.textColor= [Colors darkSteelBlue];
            
            NSString *wkStartTime[7] = {self.setting.sunStartTime, self.setting.monStartTime, self.setting.tueStartTime, self.setting.wedStartTime,
                self.setting.thuStartTime, self.setting.friStartTime, self.setting.satStartTime};
            
            NSString *wkEndTime[7] = {self.setting.sunEndTime, self.setting.monEndTime, self.setting.tueEndTime, self.setting.wedEndTime,
                self.setting.thuEndTime, self.setting.friEndTime, self.setting.satEndTime};
            
            
            NSString *workingTimeStr = [NSString stringWithFormat:@"%@ ~ %@",
                                        [Common convertWorkingTimeString:wkStartTime[indexPath.row]],
                                        [Common convertWorkingTimeString:wkEndTime[indexPath.row]]];
            
            label.text = workingTimeStr; 
            
            [cell.contentView addSubview:label];
            [label release];
            
        }
            break;
    }
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 1)
            {
                [self editTimeZone];
            }
        }
            break;
            
        case 2:
        {
            selectedIndex = indexPath.row;
            
            [self refreshPicker];
            
        }
            break;
    }
}

@end
