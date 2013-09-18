//
//  MenuTableViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/22/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "MenuTableViewController.h"

#import "Common.h"

#import "iPadSettingViewController.h"
#import "iPadAboutUsViewController.h"

#import "iPadViewController.h"
#import "iPadSmartDayViewController.h"

//extern iPadSmartDayViewController *_iPadSDViewCtrler;

extern iPadViewController *_iPadViewCtrler;

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) editSettings
{
    iPadSettingViewController *ctrler = [[iPadSettingViewController alloc] init];
    
    [_iPadViewCtrler.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
}

- (void) aboutUs
{
    iPadAboutUsViewController *ctrler = [[iPadAboutUsViewController alloc] init];
    
    [_iPadViewCtrler.navigationController pushViewController:ctrler animated:YES];
    
    [ctrler release];
    
}

- (void) backup
{
    [[AbstractActionViewController getInstance] backup];
}

- (void) sync
{
    [[AbstractActionViewController getInstance] sync];
}

#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationController.navigationBarHidden=YES;
	
    self.tableView.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1];
    
	//self.tableView.backgroundColor=[UIColor colorWithRed:(CGFloat)95/255 green:(CGFloat)95/255 blue:(CGFloat)95/255 alpha:1];
	//self.tableView.backgroundView.backgroundColor=[UIColor colorWithRed:(CGFloat)95/255 green:(CGFloat)95/255 blue:(CGFloat)95/255 alpha:1];
	//self.tableView.backgroundView.alpha=0;
	self.tableView.sectionFooterHeight=0;
	//self.tableView.sectionHeaderHeight=5;
    self.tableView.sectionHeaderHeight=1;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    cell.backgroundColor = [UIColor clearColor];
	
	//cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
	switch (indexPath.section)
    {
		case 0:
			cell.textLabel.text = _settingTitle;
			//cell.imageView.image = [UIImage imageNamed:@"menu_setting.png"];
            cell.imageView.image = [UIImage imageNamed:@"settings_general.png"];
			break;
		case 1:
			cell.textLabel.text = _infoText;
			cell.imageView.image=[UIImage imageNamed:@"menu_info.png"];
			break;
		case 2:
			cell.textLabel.text = _backupText;
			//cell.imageView.image=[UIImage imageNamed:@"menu_backup.png"];
            cell.imageView.image=[UIImage imageNamed:@"settings_backup.png"];
            
			break;
		case 3:
			cell.textLabel.text = _syncText;
			//cell.imageView.image = [UIImage imageNamed:@"menu_sync.png"];
            cell.imageView.image = [UIImage imageNamed:@"settings_sync.png"];
			break;
	}
    // Configure the cell...
    
    
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	cell.backgroundView.backgroundColor=[UIColor clearColor];
	cell.contentView.backgroundColor=[UIColor clearColor];
	cell.textLabel.backgroundColor=[UIColor clearColor];
	cell.backgroundColor=[UIColor colorWithRed:(CGFloat)62/255 green:(CGFloat)62/255 blue:(CGFloat)63/255 alpha:1];
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AbstractActionViewController getInstance] hidePopover];
    
    switch (indexPath.section)
    {
        case 0:
        {
            [self editSettings];
        }
            break;
        case 1:
        {
            [self aboutUs];
        }
            break;
        case 2:
        {
            [self backup];
        }
            break;
        case 3:
        {
            [self sync];
        }
            break;
    }
}

@end
