//
//  iPadGeneralSettingViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/19/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadGeneralSettingViewController.h"

#import "Common.h"
#import "Settings.h"
#import "Project.h"

#import "ProjectManager.h"
#import "DBManager.h"

#import "ContentView.h"

#import "ProjectSelectionTableViewController.h"
#import "TagListViewController.h"
#import "SnoozeDurationViewController.h"

#import "AbstractSDViewController.h"
#import "SmartCalAppDelegate.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern SmartCalAppDelegate *_appDelegate;

@interface iPadGeneralSettingViewController ()

@end

@implementation iPadGeneralSettingViewController

@synthesize setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) selectCategory
{
    ProjectSelectionTableViewController *ctrler = [[ProjectSelectionTableViewController alloc] init];
    ctrler.objectEdit = self.setting;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) editTag
{
    TagListViewController *ctrler = [[TagListViewController alloc] init];
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) editSnoozeDuration
{
    SnoozeDurationViewController *ctrler = [[SnoozeDurationViewController alloc] init];
    ctrler.settings = self.setting;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void)editGeoInterVal
{
    SnoozeDurationViewController *ctrler = [[SnoozeDurationViewController alloc] init];
    ctrler.settings = self.setting;
    
    [self.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.origin.y = 20;
    frm.size = sz;
    
    frm.size.width = 2*frm.size.width/3;
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
	//settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
    settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:settingTableView];
	[settingTableView release];
}

- (void)viewDidAppear:(BOOL)animated {
	[settingTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    printf("rotate\n");
}
*/

#pragma mark Actions
- (void) resetHint: (id) sender
{
	[[Settings getInstance] enableHints];
	
	self.setting.hideWarning = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:_hintResetCompleteText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
}

- (void) enableLandscapeMode: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.landscapeModeEnable = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) changeDeleteWarning: (id) sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.deleteWarning = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) enableSound:(id)sender
{
	UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.soundEnable = (segmentedStyleControl.selectedSegmentIndex == 0);
}

- (void) deleteSuspectedDuplication:(id) sender
{
    [[DBManager getInstance] deleteSuspectedDuplication];
    
    //[_abstractViewCtrler resetAllData];
    [[AbstractActionViewController getInstance] resetAllData];
    
    BOOL syncEnabled = self.setting.syncEnabled && (self.setting.ekSyncEnabled || self.setting.tdSyncEnabled || self.setting.sdwSyncEnabled || self.setting.rmdSyncEnabled);
    
    NSString *msg = (syncEnabled? [NSString stringWithFormat:@"%@ %@", _deleteSuspectedDuplicationCompleteText, _syncAgainText]: _deleteSuspectedDuplicationCompleteText);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:(syncEnabled?_cancelText:_okText) otherButtonTitles:nil];
    
    if (syncEnabled)
    {
        [alertView addButtonWithTitle:_okText];
    }
    
    alertView.tag = -10002;
    
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10002 && buttonIndex != 0) //not Cancel
	{
        [_abstractViewCtrler sync];
	}
}

- (void)changeGeoFencing: (id)sender
{
    UISegmentedControl *segmentedStyleControl = (UISegmentedControl *)sender;
	
	self.setting.geoFencingEnable = (segmentedStyleControl.selectedSegmentIndex == 0);
    if (!self.setting.geoFencingEnable) {
        [_appDelegate disableGeoFencing];
    } else {
        [_appDelegate startGeoFencing:self.setting.geoFencingInterval];
    }
    [settingTableView reloadData];
}

#pragma mark Cell Creation
- (void) createLandscapeEnableCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _landscapeModeEnableText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 70 - 120, 5, 120, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableLandscapeMode:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.setting.landscapeModeEnable?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createHintCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _hintsText;
	
	UIButton *resetButton = [Common createButton:_resetText
                                      buttonType:UIButtonTypeCustom
                                           frame:CGRectMake(settingTableView.bounds.size.width - 90, 5, 80, 30)
                                      titleColor:[Colors blueButton]
                                          target:self
                                        selector:@selector(resetHint:)
                                normalStateImage:nil
                              selectedStateImage:nil];
    
    resetButton.layer.cornerRadius = 8;
    resetButton.layer.borderWidth = 1;
    resetButton.layer.borderColor = [[Colors blueButton] CGColor];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
	resetButton.tag = baseTag;
	[cell.contentView addSubview:resetButton];
}

- (void) createDefaultCategoryCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _defaultProjectText;
	
	Project *prj = [[ProjectManager getInstance] getProjectByKey:self.setting.taskDefaultProject];
	
	UILabel *projectNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 130 - 30, 10, 120, 20)];
	projectNameLabel.tag = baseTag;
	projectNameLabel.textAlignment=NSTextAlignmentRight;
	projectNameLabel.backgroundColor=[UIColor clearColor];
	projectNameLabel.font=[UIFont boldSystemFontOfSize:16];
	
	if (prj != nil)
	{
		projectNameLabel.text = prj.name;
		projectNameLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
	}
	
	[cell.contentView addSubview:projectNameLabel];
	[projectNameLabel release];
}

- (void) createTagListCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _tagListText;
}

- (void) createSnoozeDurationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _snoozeDuration;
	
	UILabel *durationLabel=[[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 130 - 30, 10, 120, 20)];
	durationLabel.tag = baseTag;
	durationLabel.textAlignment=NSTextAlignmentRight;
	durationLabel.backgroundColor=[UIColor clearColor];
	durationLabel.font=[UIFont boldSystemFontOfSize:16];
    durationLabel.textColor=[UIColor darkGrayColor];
    durationLabel.text = [Common getDurationString:self.setting.snoozeDuration*60];
		
	[cell.contentView addSubview:durationLabel];
	[durationLabel release];
}

- (void) createDeleteWarningCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _deleteWarningText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeDeleteWarning:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.setting.deleteWarning?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createSoundEnabledCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _soundEnabledText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableSound:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.setting.soundEnable?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createDeleteSuspectedDuplicationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _deleteSyncDuplicationText;
	
	UIButton *deleteButton = [Common createButton:_deleteText
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(settingTableView.bounds.size.width - 90, 5, 80, 30)
                                       titleColor:[Colors redButton]
                                           target:self
                                         selector:@selector(deleteSuspectedDuplication:)
                                 normalStateImage:nil
                               selectedStateImage:nil];
    
    deleteButton.layer.cornerRadius = 8;
    deleteButton.layer.borderWidth = 1;
    deleteButton.layer.borderColor = [[Colors redButton] CGColor];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
	deleteButton.tag = baseTag;
	[cell.contentView addSubview:deleteButton];
}

- (void) createGeoFencingCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _geoFencingText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeGeoFencing:) forControlEvents:UIControlEventValueChanged];
	//segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = (self.setting.geoFencingEnable?0:1);
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createGeoIntervalCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.textLabel.text = _geoIntervalText;
	
    UITextField *geoInterValTextField = [[UITextField alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 130 - 30, 5, 120, 30)];
    geoInterValTextField.backgroundColor = [UIColor whiteColor];
    geoInterValTextField.textAlignment = NSTextAlignmentRight;
	geoInterValTextField.keyboardType = UIKeyboardTypeNumberPad;
    geoInterValTextField.returnKeyType = UIReturnKeyDone;
	geoInterValTextField.delegate = self;
    geoInterValTextField.text = [NSString stringWithFormat:@"%d", self.setting.geoFencingInterval/60];
    
	[cell.contentView addSubview:geoInterValTextField];
	[geoInterValTextField release];
    
    UILabel *minsLable = [[UILabel alloc] initWithFrame:CGRectMake(geoInterValTextField.frame.origin.x + geoInterValTextField.frame.size.width, 10, 40, 20)];
    minsLable.tag = baseTag;
	minsLable.textAlignment=NSTextAlignmentRight;
	minsLable.backgroundColor=[UIColor clearColor];
	minsLable.font=[UIFont boldSystemFontOfSize:16];
    minsLable.textColor=[UIColor darkGrayColor];
    minsLable.text = @"mins";
    
    [cell.contentView addSubview:minsLable];
    [minsLable release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.setting.geoFencingEnable) {
        return 9;
    }
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
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
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
	
    switch (indexPath.row)
    {
        case 0:
        {
            [self createHintCell:cell baseTag:10000];
        }
            break;
        case 1:
        {
            [self createDefaultCategoryCell:cell baseTag:10010];
        }
            break;
        case 2:
        {
            [self createTagListCell:cell baseTag:10020];
        }
            break;
        case 3:
        {
            [self createSnoozeDurationCell:cell baseTag:10030];
        }
            break;
        case 4:
        {
            [self createDeleteWarningCell:cell baseTag:10040];
        }
            break;
        case 5:
        {
            [self createSoundEnabledCell:cell baseTag:10050];
        }
            break;
        case 6:
        {
            [self createDeleteSuspectedDuplicationCell:cell baseTag:10060];
        }
            break;
        case 7:
        {
            [self createGeoFencingCell:cell baseTag:10070];
        }
            break;
        case 8:
        {
            [self createGeoIntervalCell:cell baseTag:10080];
        }
            break;
    }

	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
        {
            [self selectCategory];
        }
            break;
        case 2:
        {
            [self editTag];
        }
            break;
        case 3:
        {
            [self editSnoozeDuration];
        }
            break;
        case 8:
        {
            [self editGeoInterVal];
        }
            break;
    }
}

#pragma mark TextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	unichar c;
	
	if ([string length]>0)
	{
		c = [string characterAtIndex:0];
	}
	else
	{
		return YES;
	}
	
	if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c])
	{
		return YES;
	}
    
	return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger number = [textField.text isEqualToString:@""]?0:[textField.text intValue];
    
    self.setting.geoFencingInterval = number*60;
    
    [_appDelegate startGeoFencing:self.setting.geoFencingInterval];
}
@end
