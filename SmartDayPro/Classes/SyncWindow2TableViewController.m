//
//  SyncWindow2TableViewController.m
//  SmartTime
//
//  Created by Huy Le on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncWindow2TableViewController.h"
#import "Common.h"
#import "Colors.h"
#import "GuideWebView.h"
#import "Settings.h"
#import "ImageManager.h"

extern BOOL _scFreeVersion;

//extern BOOL _isiPad;

@implementation SyncWindow2TableViewController

@synthesize setting;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)loadView 
{
	[super loadView];
	
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
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    settingTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
	settingTableView.delegate = self;
	settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor clearColor];
    
	[contentView addSubview:settingTableView];
	[settingTableView release];
    
    frm.size.width = frm.size.width/2;
	
	syncFromTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	
	syncFromTableView.delegate = self;
	syncFromTableView.dataSource = self;
    syncFromTableView.backgroundColor = [UIColor clearColor];
	
	syncToTableView = [[UITableView alloc] initWithFrame:CGRectOffset(frm, frm.size.width, 0) style:UITableViewStylePlain];
	
	syncToTableView.delegate = self;
	syncToTableView.dataSource = self;
    syncToTableView.backgroundColor = [UIColor clearColor];
	
	syncFromIndex = self.setting.syncWindowStart;
	syncToIndex = self.setting.syncWindowEnd;
	
	self.navigationItem.title = _syncWindowText;	
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	self.setting.syncWindowStart = syncFromIndex;
	self.setting.syncWindowEnd = syncToIndex;

}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([tableView isEqual:settingTableView])
	{
		return 1;
	}
	
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([tableView isEqual:settingTableView])
	{
		//return 418;
        
        return 240;
	}
	
	return 44;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:settingTableView] && section == 0)
    {
        CGRect frm = tableView.bounds;
        frm.origin.x = 10;
        frm.size.height = 40;
        
        UIView *headerView = [[UIView alloc] initWithFrame:frm];
        
        frm.size.width /= 2;
        
        UILabel *fromLabel = [[UILabel alloc] initWithFrame:frm];
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.text = _syncFromText;
        fromLabel.textAlignment = NSTextAlignmentLeft;
        fromLabel.font = [UIFont boldSystemFontOfSize:20];
        fromLabel.textColor = [UIColor lightGrayColor];
        
        [headerView addSubview:fromLabel];
        [fromLabel release];
        
        frm.origin.x += frm.size.width;

        UILabel *toLabel = [[UILabel alloc] initWithFrame:frm];
        toLabel.backgroundColor = [UIColor clearColor];
        toLabel.text = _syncToText;
        toLabel.textAlignment = NSTextAlignmentLeft;
        toLabel.font = [UIFont boldSystemFontOfSize:20];
        toLabel.textColor = [UIColor lightGrayColor];
        
        [headerView addSubview:toLabel];
        [toLabel release];

        return [headerView autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // This will create a "invisible" footer
    
    if ([tableView isEqual:settingTableView] && section == 0)
    {
        return 20.0f;
    }
    
    return 0.01f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if ([tableView isEqual:settingTableView])
	{
		return _isiPad?_syncFromTo4iPadText:_syncFromToText;//@"   Sync From               Sync To";
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
	
	cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
    
    // Set up the cell...
	
	if ([tableView isEqual:settingTableView])
	{
		[cell.contentView addSubview:syncFromTableView];
		[cell.contentView addSubview:syncToTableView];
		
        /*
		GuideWebView *guideView = [[GuideWebView alloc] initWithFrame:CGRectMake(10, 260, 300, 80)];
		
		[guideView loadHTMLFile:@"SyncWindow" extension:@"htm"];
		
		[cell.contentView addSubview:guideView];
		[guideView release];
		*/
	}
	else if ([tableView isEqual:syncFromTableView])
	{
		switch (indexPath.row)
		{
			case 0:
			{
				cell.textLabel.text = _thisWeekText;
			}
				break;			
			case 1:
			{
				cell.textLabel.text = _lastWeekText;
			}
				break;
			case 2:
			{
				cell.textLabel.text = _lastMonthText;
			}
				break;
			case 3:
			{
				cell.textLabel.text = _last3MonthText;
			}
				break;
			case 4:
			{
				cell.textLabel.text = _lastYearText;
			}
				break;
			case 5:
			{
				cell.textLabel.text = _allPreviousText;
			}
				break;			
		}
		
		if (indexPath.row == syncFromIndex)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			cell.textLabel.textColor=[Colors darkSteelBlue];
		}else {
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			cell.textLabel.textColor=[UIColor grayColor];
		}		
		
	}		
	else if ([tableView isEqual:syncToTableView])
	{
		switch (indexPath.row)
		{
			case 0:
			{
				cell.textLabel.text = _thisWeekText;
			}
				break;			
			case 1:
			{
				cell.textLabel.text = _nextWeekText;
			}
				break;
			case 2:
			{
				cell.textLabel.text = _nextMonthText;
			}
				break;
			case 3:
			{
				cell.textLabel.text = _next3MonthText;
			}
				break;
			case 4:
			{
				cell.textLabel.text = _nextYearText;
			}
				break;
			case 5:
			{
				cell.textLabel.text = _allForwardText;
			}
				break;			
		}
		
		if (indexPath.row == syncToIndex)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			cell.textLabel.textColor=[Colors darkSteelBlue];
		}else {
			[cell setAccessoryType:UITableViewCellAccessoryNone];
			cell.textLabel.textColor=[UIColor grayColor];
		}		
		
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_scFreeVersion)
	{
		return;
	}
	
	if ([tableView isEqual:syncFromTableView])
	{
		syncFromIndex = indexPath.row;
	}
	else if ([tableView isEqual:syncToTableView])
	{
		syncToIndex = indexPath.row;
	}
	
	[[tableView cellForRowAtIndexPath:indexPath].textLabel setTextColor:[Colors darkSteelBlue]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (_scFreeVersion)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText message:_paidUpgradeText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		[alertView show];
		[alertView release];			

		return indexPath;
	}
	
	NSIndexPath *oldIndexPath = nil;
	
	if ([tableView isEqual:syncFromTableView])
	{
		oldIndexPath = [NSIndexPath indexPathForRow:syncFromIndex inSection:0];
	}
	else if ([tableView isEqual:syncToTableView])
	{
		oldIndexPath = [NSIndexPath indexPathForRow:syncToIndex inSection:0];
	}	
	
	[[tableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	[[tableView cellForRowAtIndexPath:oldIndexPath].textLabel setTextColor:[UIColor blackColor]];
	
	[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	return indexPath;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[syncFromTableView release];
	[syncToTableView release];
	
    [super dealloc];
}


@end

