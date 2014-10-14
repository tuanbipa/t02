//
//  RestoreViewController.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 6/26/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "RestoreViewController.h"

#import "Common.h"

#import "DBManager.h"
#import "AbstractActionViewController.h"

#import "SmartCalAppDelegate.h"

//extern BOOL _isiPad;

@interface RestoreViewController () {
    NSInteger lastSelectedRow;
}

@end

@implementation RestoreViewController

- (id)init
{
    if (self) {
        self.preferredContentSize = CGSizeMake(320,416);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
        NSError * error = nil;
        
        backupDirectoryContents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:backupPath error:&error] copy];
        
        selectedItem = -1;
    }
    return self;
}

- (void)loadView
{
    //CGRect frm = CGRectMake(0, 0, 320, 416);
    CGRect frm = CGRectZero;
    frm.origin.y = 20;
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
    frm.origin.y = 10;
    frm.size.width -= 20;
    frm.size.height = _isiPad?40:80;
    
    UILabel *label = [[UILabel alloc] initWithFrame:frm];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = _autoBackupHint;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [Colors darkSteelBlue];
    
    [contentView addSubview:label];
    [label release];
    
    frm = contentView.bounds;
    frm.origin.y = label.bounds.size.height+10;
    frm.size.height -= frm.origin.y;
    
    // list file table
    listFileTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	listFileTableView.delegate = self;
	listFileTableView.dataSource = self;
    listFileTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:listFileTableView];
	[listFileTableView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _autoBackup;
    
    lastSelectedRow = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
    //backupDirectoryContents = nil;
    [backupDirectoryContents release];
}

#pragma mark - Actions
- (void)restoreDBFromLocalFile//: (NSString *) filePath
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dBPath = [documentsDirectory stringByAppendingPathComponent:@"SmartCalDB.sql"];
    NSError * error = nil;
    
    // get backup file path
    NSString *fileName = [backupDirectoryContents objectAtIndex:selectedItem];
    NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
    NSString *filePath = [backupPath stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:dBPath] == YES) {
        [fileManager removeItemAtPath:dBPath error:&error];
    }
    [fileManager copyItemAtPath:filePath toPath:dBPath error:&error];
    
    //exit(0);
    
    [DBManager startup];
    
    [[AbstractActionViewController getInstance] resetAllData];
}

- (NSDate *)getFileMoficationDate: (NSString *) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *backupPath = [documentsDirectory stringByAppendingPathComponent:@"Backup"];
    NSString *filePath = [backupPath stringByAppendingPathComponent:fileName];
    NSError *error;
    
    NSDictionary* properties = [[NSFileManager defaultManager]
                                attributesOfItemAtPath:filePath
                                error:&error];
    NSDate* modDate = [properties objectForKey:NSFileModificationDate];
    
    return modDate;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return 40.0f;
    
    return 0.01f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        CGRect frm = tableView.bounds;
        frm.origin.x = 100;
        frm.size.width -= 200;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.text = _autoBackupHint;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [Colors darkSteelBlue];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return backupDirectoryContents.count;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section)
    {
		case 0:
			return _autoBackupHint;
	}
    
	return @"";
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
            [view removeFromSuperview];
		}
	}
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSString *fileTile = [_backupOn stringByAppendingString:@" "];
    NSString *fileName = [backupDirectoryContents objectAtIndex:indexPath.row];
    fileTile = [fileTile stringByAppendingString:[Common getFullDateTimeString2:[self getFileMoficationDate:fileName]]];
	cell.textLabel.text = fileTile;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

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
    if (lastSelectedRow >= 0 && lastSelectedRow < backupDirectoryContents.count && lastSelectedRow != [indexPath row]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedRow inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    lastSelectedRow = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    selectedItem = indexPath.row;
    [self confirmRestore];
}

#pragma mark Alert

- (void)confirmRestore
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_restoreDBTitle message:_restoreDBText delegate:self cancelButtonTitle:_cancelText otherButtonTitles:_okText,nil];
    alertView.tag = -10000;
    
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex != 0 && selectedItem >= 0) //not Cancel
	{
        [self restoreDBFromLocalFile];
	} else {
        UITableViewCell *cell = [listFileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedItem inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}
@end