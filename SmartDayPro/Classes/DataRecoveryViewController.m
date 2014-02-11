//
//  DataRecoveryViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 1/23/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "DataRecoveryViewController.h"

#import "Common.h"

#import "DBManager.h"
#import "SDWSync.h"

#import "SettingTableViewController.h"

#import "iPadSettingViewController.h"

//extern BOOL _isiPad;

extern iPadSettingViewController *_iPadSettingViewCtrler;

@interface DataRecoveryViewController ()

@end

@implementation DataRecoveryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void) performSync:(NSNumber *)mode
{
    NSInteger syncMode = [mode intValue];
    
    switch (syncMode)
    {
        case SYNC_MANUAL_1WAY_mSD2SD:
        {
            [[DBManager getInstance] cleanDB];
            
            [[SDWSync getInstance] initBackground1WayGet];
        }
            break;
            
        case SYNC_MANUAL_1WAY_SD2mSD:
        {
            [[SDWSync getInstance] initBackground1WayPush];
        }
            break;
    }
}

- (void) sync1way2SDW
{
    if (_iPadSettingViewCtrler != nil)
    {
        [_iPadSettingViewCtrler.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        if ([ctrler isKindOfClass:[SettingTableViewController class]])
        {
            SettingTableViewController *settingCtrler = (SettingTableViewController *) ctrler;
            
            [settingCtrler save];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];        
    }
    
    //[[SDWSync getInstance] initBackground1WayPush];
    
    [self performSelector:@selector(performSync:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_SD2mSD] afterDelay:0.1]; //wait until Settings is saved after dismiss
}

- (void) sync1way2SD
{
    if (_iPadSettingViewCtrler != nil)
    {
        [_iPadSettingViewCtrler.navigationController popToRootViewControllerAnimated:YES];        
    }
    else
    {
        UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        if ([ctrler isKindOfClass:[SettingTableViewController class]])
        {
            SettingTableViewController *settingCtrler = (SettingTableViewController *) ctrler;
            
            [settingCtrler save];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    //[[DBManager getInstance] cleanDB];
    
    //[[SDWSync getInstance] initBackground1WayGet];
    
    [self performSelector:@selector(performSync:) withObject:[NSNumber numberWithInt:SYNC_MANUAL_1WAY_mSD2SD] afterDelay:0.1]; //wait until Settings is saved after dismiss
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex != 0) //not Cancel
	{
        [self sync1way2SDW];
	}
	else if (alertVw.tag == -10001 && buttonIndex != 0) //not Cancel
	{
        [self sync1way2SD];
	}
}

- (void) confirmSync1way2SDW:(id) sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_deleteAllMySDDataConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText,nil];
    alertView.tag = -10000;
    
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alertView release];
    
}

- (void) confirmSync1way2SD:(id) sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_deleteAllSDDataConfirmation delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText,nil];
    
    alertView.tag = -10001;
    
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alertView release];
}

#pragma mark View

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor darkGrayColor];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    frm = contentView.bounds;
    frm.origin.x = 10;
    frm.origin.y = 20;
    frm.size.width -= 20;
    frm.size.height = 100;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frm];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = _dataRecoveryHint;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [Colors darkSteelBlue];
    
    [contentView addSubview:label];
    [label release];
    
    frm = contentView.bounds;
    frm.origin.y = 120;
    //frm.size.height -= 120;
    frm.size.height = 140;
    
    settingTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:settingTableView];
	[settingTableView release];
    
    // note for smart share
    frm = label.frame;
    frm.origin.y = settingTableView.frame.size.height + settingTableView.frame.origin.y + 10;
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:frm];
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.numberOfLines = 0;
    noteLabel.text = _notePush1WayText;
    noteLabel.textAlignment = NSTextAlignmentLeft;
    noteLabel.font = [UIFont systemFontOfSize:16];
    noteLabel.textColor = [Colors darkSteelBlue];
    
    [contentView addSubview:noteLabel];
    [noteLabel release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = _dataRecovery;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
    {
		case 0:
			return _dataRecoveryHint;
	}
    
	return @"";
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}


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
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
	//cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                UIButton *fromSDButton = [Common createButton:@""
                                                   buttonType:UIButtonTypeCustom
                                                        frame:CGRectMake((settingTableView.bounds.size.width-135)/2, 5, 135, 60)
                                                   titleColor:[UIColor whiteColor]
                                                       target:self
                                                     selector:@selector(confirmSync1way2SDW:)
                                             normalStateImage:@"replace_SDtomSD.png"
                                           selectedStateImage:nil];
                fromSDButton.tag = 10000;
                [cell.contentView addSubview:fromSDButton];
                
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0)
            {
                UIButton *toSDButton = [Common createButton:@""
                                                 buttonType:UIButtonTypeCustom
                                                      frame:CGRectMake((settingTableView.bounds.size.width-135)/2, 5, 135, 60)
                                                 titleColor:[UIColor whiteColor]
                                                     target:self
                                                   selector:@selector(confirmSync1way2SD:)
                                           normalStateImage:@"replace_mSDtoSD.png"
                                         selectedStateImage:nil];
                toSDButton.tag = 11000;
                [cell.contentView addSubview:toSDButton];
            }
            
        }
            break;
    }
    
    return cell;
}

@end
