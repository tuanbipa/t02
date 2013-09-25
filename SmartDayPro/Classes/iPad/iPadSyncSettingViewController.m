//
//  iPadSyncSettingViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadSyncSettingViewController.h"

#import "Common.h"
#import "Settings.h"

#import "ContentView.h"
#import "GuideWebView.h"

#import "HintModalViewController.h"
#import "SDWAccountViewController.h"
#import "ToodledoSyncViewController.h"
#import "iOSCalSyncViewController.h"
#import "TaskSyncViewController.h"

#import "iPadSettingViewController.h"

extern iPadSettingViewController *_iPadSettingViewCtrler;

@interface iPadSyncSettingViewController ()

@end

@implementation iPadSyncSettingViewController

@synthesize setting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) confirmSyncOn
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_synchronizationText message:_confirmSyncOnText delegate:self cancelButtonTitle:_okText otherButtonTitles:_syncWizardText,nil];
    alertView.tag = 10000;
    
    [alertView show];
    [alertView release];

}

- (void) popupSyncGuide
{
    HintModalViewController *ctrler = [[HintModalViewController alloc] init];
    ctrler.closeEnabled = YES;
    
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    GuideWebView *hintView = [[GuideWebView alloc] initWithFrame:frm];
    [hintView loadURL:URL_SYNC content:nil];
    
    ctrler.view = hintView;
    
    [hintView release];
    
    [self presentViewController:ctrler animated:YES completion:NULL];
}

-(void) editSDWAccount
{
	SDWAccountViewController *ctrler = [[SDWAccountViewController alloc] init];
	
    ctrler.setting = [Settings getInstance];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editToodledoSync
{
    ToodledoSyncViewController *ctrler = [[ToodledoSyncViewController alloc] init];
    ctrler.setting = self.setting;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editTaskSync
{
    TaskSyncViewController *ctrler = [[TaskSyncViewController alloc] init];
    ctrler.setting = self.setting;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

- (void) editCalSync
{
    iOSCalSyncViewController *ctrler = [[iOSCalSyncViewController alloc] init];
    ctrler.setting = self.setting;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

#pragma mark Actions

- (void) enableSynchronization:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.setting.syncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    if (!self.setting.syncEnabled)
    {
        self.setting.autoSyncEnabled = NO;
        self.setting.tdSyncEnabled = NO;
        self.setting.ekSyncEnabled = NO;
        self.setting.sdwSyncEnabled = NO;
    }
    else
    {
        self.setting.sdwSyncEnabled = YES;
    }
    
    [settingTableView reloadData];
    
    if (self.setting.syncEnabled)
    {
        [self confirmSyncOn];
    }

    [_iPadSettingViewCtrler refresh]; //to refresh Data Recovery row
}

- (void) enableAutoSync:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.setting.autoSyncEnabled = (segmentedControl.selectedSegmentIndex == 0);
    
    [settingTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    //[settingTableView reloadData];
    
    if (self.setting.autoSyncEnabled)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_synchronizationText message:_syncAtStartUpHint delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}

- (void) enableAutoPush:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.setting.autoPushEnabled = (segmentedControl.selectedSegmentIndex == 0);
}

- (void) switchSyncSource: (id) sender
{
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
        
    if (ctrl.selectedSegmentIndex == 0)
    {
        self.setting.sdwSyncEnabled = YES;
    }
    else
    {
        self.setting.sdwSyncEnabled = NO;
    }
    
    if (self.setting.sdwSyncEnabled)
    {
        self.setting.tdSyncEnabled = NO;
        self.setting.rmdSyncEnabled =  NO;
    }

    [settingTableView reloadData];
    
    [_iPadSettingViewCtrler refresh];    
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertVw.tag == 10000 && buttonIndex != 0)
    {
        [self popupSyncGuide];
    }
}

#pragma mark View

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

#pragma mark Cell Creation
- (void) createSynchronizationCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _enableText;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableSynchronization:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.setting.syncEnabled?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createSyncAtStartUpCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 40)];
    titleLabel.numberOfLines = 2;
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.tag = baseTag;
    titleLabel.text = _syncAtStartUp;
    
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];*/
    
    cell.textLabel.text = _syncAtStartUp;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableAutoSync:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.setting.autoSyncEnabled?0:1;
	segmentedStyleControl.tag = baseTag+1;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createAutoPushCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.textLabel.text = _pushChanges;
	
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _onText, _offText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(settingTableView.bounds.size.width - 110, 5, 100, 30);
	[segmentedStyleControl addTarget:self action:@selector(enableAutoPush:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;
	segmentedStyleControl.selectedSegmentIndex = self.setting.autoPushEnabled?0:1;
	segmentedStyleControl.tag = baseTag;
	
	[cell.contentView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
}

- (void) createSyncSourceSwitchCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _mySmartDayDotCom, _others, nil];
    
    CGFloat w = settingTableView.bounds.size.width - 20;
    
	UISegmentedControl *syncSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	syncSegmentedControl.frame = CGRectMake(10, 5, w, 30);
	[syncSegmentedControl addTarget:self action:@selector(switchSyncSource:) forControlEvents:UIControlEventValueChanged];
	syncSegmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
	syncSegmentedControl.selectedSegmentIndex = (self.setting.sdwSyncEnabled?0:1);
	syncSegmentedControl.tag = baseTag+1;
    
    //[syncSegmentedControl setWidth:w/2 forSegmentAtIndex:0];
    //[syncSegmentedControl setWidth:w/2 forSegmentAtIndex:1];
	
	[cell.contentView addSubview:syncSegmentedControl];
	[syncSegmentedControl release];
}

- (void) createSDWAccountCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *verifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 110 - 30, 5, 100, 30)];
    verifiedLabel.backgroundColor = [UIColor clearColor];
    verifiedLabel.textAlignment = NSTextAlignmentRight;
    verifiedLabel.font = [UIFont boldSystemFontOfSize:16];
    verifiedLabel.textColor = [UIColor darkGrayColor];
    verifiedLabel.tag = baseTag;
    verifiedLabel.text = (self.setting.sdwVerified?_verifiedText:_unverifiedText);
    
	[cell.contentView addSubview:verifiedLabel];
	[verifiedLabel release];
    
    cell.textLabel.text = _accountText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void) createTaskSyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _tasksText;
	
    UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 130 - 30, 10, 120, 20)];
	nameLabel.tag = baseTag;
	nameLabel.textAlignment=NSTextAlignmentRight;
	nameLabel.backgroundColor=[UIColor clearColor];
	nameLabel.font=[UIFont boldSystemFontOfSize:16];
    nameLabel.textColor = [UIColor darkGrayColor];
	nameLabel.text = (!self.setting.tdSyncEnabled && !self.setting.rmdSyncEnabled)?_offText:(self.setting.tdSyncEnabled?_toodledoText:_reminderText);
    
	[cell.contentView addSubview:nameLabel];
	[nameLabel release];
}

- (void) createEventSyncCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",_iOSCalSyncText, _eventsText];
	
    UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(settingTableView.bounds.size.width - 130 - 30, 10, 120, 20)];
	nameLabel.tag = baseTag;
	nameLabel.textAlignment=NSTextAlignmentRight;
	nameLabel.backgroundColor=[UIColor clearColor];
	nameLabel.font=[UIFont boldSystemFontOfSize:16];
    nameLabel.textColor = [UIColor darkGrayColor];
	nameLabel.text = self.setting.ekSyncEnabled?_onText:_offText;
    
	[cell.contentView addSubview:nameLabel];
	[nameLabel release];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.setting.syncEnabled?2:1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section)
    {
        case 0: //Syncronization
            return (self.setting.autoSyncEnabled?3:(self.setting.syncEnabled?2:1));
		case 1: //Split Source
            return (self.setting.sdwSyncEnabled?2:3);
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1)
        return 20.0f;
    
    //return 0.01f;
    return 0;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = _syncSetupText;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
    {
        //case 0:
            //return _synchronizationText;
		case 1:
			return _syncSetupText;
	}
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	/*else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}
	}*/
	
    cell.imageView.image = nil;
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
	
    switch (indexPath.section)
    {
        case 0:
        {
			switch (indexPath.row)
			{
				case 0:
				{
                    [self createSynchronizationCell:cell baseTag:10000];
                }
                    break;
                case 1:
                {
                    [self createSyncAtStartUpCell:cell baseTag:10010];
                }
                    break;
                case 2:
                {
                    [self createAutoPushCell:cell baseTag:10020];
                }
                    break;
            }
            
            break;
        }
		case 1:
		{
			switch (indexPath.row)
			{
				case 0:
				{
                    [self createSyncSourceSwitchCell:cell baseTag:11000];
                }
                    break;
				case 1:
				{
                    if (self.setting.sdwSyncEnabled)
                    {
                        [self createSDWAccountCell:cell baseTag:11010];
                    }
                    else
                    {
                        //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",_toodledoSyncText, _tasksText];
                        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        [self createTaskSyncCell:cell baseTag:11010];
                    }
                }
                    break;
				case 2:
				{
                    //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",_iOSCalSyncText, _eventsText];
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [self createEventSyncCell:cell baseTag:11020];
                }
                    break;
            }
        }
            break;

    }
    
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (self.setting.sdwSyncEnabled)
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    [self editSDWAccount];
                }
                    break;
            }
        }
        else
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    //[self editToodledoSync];
                    [self editTaskSync];
                }
                    break;
                case 2:
                {
                    [self editCalSync];
                }
                    break;
            }
        }
    }

}


@end
