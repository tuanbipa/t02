//
//  AlertSelectionTableViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 8/16/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "AlertSelectionTableViewController.h"

#import "Common.h"
#import "Colors.h"
#import "Task.h"
#import "AlertData.h"
#import "DBManager.h"
#import "AlertManager.h"
#import "ImageManager.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

@implementation AlertSelectionTableViewController

@synthesize taskEdit;
@synthesize alertIndex;
@synthesize alertData;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/

-(id) init 
{
	if (self = [super init]) 
	{
		selectedIndex = -1;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
	}
	
	return self;	
}

- (void) createAlertDict
{
	NSInteger alertDurations[8] = {-15, -30, -45, -60, -120, -1440, -2880, 0};
	
	//NSInteger adeAlertDurations[8] = {8*60, 0, -4*60, -8*60, -12*60, -16*60, -36*60, -60*60};
    NSInteger adeAlertDurations[6] = {-4*60, -8*60, -12*60, -16*60, -36*60, -60*60};
	
	NSMutableArray *alerts = [NSMutableArray arrayWithCapacity:8];
	NSMutableArray *indices = [NSMutableArray arrayWithCapacity:8];
    
    int count = [self.taskEdit isADE]?6:8;
	
	for (int i=0; i<count; i++)
	{
		[alerts addObject:[NSNumber numberWithInt:([self.taskEdit isADE]?adeAlertDurations[i]:alertDurations[i])]];
		[indices addObject:[NSNumber numberWithInt:i]];
	}
	
	alertDict = [[NSDictionary dictionaryWithObjects:indices forKeys:alerts] retain];	
}

- (void) showAlertTime
{
	NSString *timeStr = [self.alertData getAbsoluteTimeString:self.taskEdit];
	
	timeLabel.text = [NSString stringWithFormat:@"%@: %@", @"Alert Time", timeStr];
}

/*
- (void)changeTableFrame
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	alertTableView.frame = CGRectMake(0, 0, 320, 416 - barHeight);
}
*/
- (void)loadView 
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	//UIView *contentView= [[UIView alloc] initWithFrame:CGRectZero];
    UIView *contentView= [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor=[UIColor darkGrayColor];
	
	timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, frm.size.width-20, 20)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [UIFont systemFontOfSize:16];
	
	[contentView addSubview:timeLabel];
	[timeLabel release];
	
	//alertTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 320, 416) style:UITableViewStyleGrouped];
    alertTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
                      
	alertTableView.delegate = self;
	alertTableView.dataSource = self;
	alertTableView.sectionHeaderHeight=5;	
	
	[contentView addSubview:alertTableView];
	[alertTableView release];
	
	//[self changeTableFrame];
	
	self.view = contentView;
	[contentView release];	
	
	UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																			   target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];	
	
	self.navigationItem.title = _alertEditText;
	
	[self createAlertDict];
	
	if (self.alertIndex == -1) //new Alert
	{
		alertData = [[AlertData alloc] init];
		
		alertData.beforeDuration = [self.taskEdit isADE]?8*60*60:-15*60;
	}
	else 
	{
		self.alertData = [self.taskEdit.alerts objectAtIndex:self.alertIndex];
	}
	
	if (self.alertData.absoluteTime == nil)
	{
		NSNumber *val = [alertDict objectForKey:[NSNumber numberWithInt:self.alertData.beforeDuration/60]];
		
		if (val != nil)
		{
			selectedIndex = [val intValue];
		}		
	}
	
	[self showAlertTime];
}


#pragma mark -
#pragma mark View lifecycle

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
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.taskEdit isADE]?6:8;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSString *alerts[8]={_15minBeforeText, _30minBeforeText, _45minBeforeText, _1hourBeforeText, _2hourBeforeText, _1dayBeforeText, _2dayBeforeText, (self.taskEdit.type == TYPE_TASK?_onDueOfTaskText:_onDateOfEventText)};

  	//NSString *adeAlerts[8]={_8hoursAfterText, _0hoursBeforeText, _4hoursBeforeText, _8hoursBeforeText, _12hoursBeforeText, _16hoursBeforeText, _1dot5daysBeforeText, _2dot5daysBeforeText};

  	NSString *adeAlerts[6]={_4hoursBeforeText, _8hoursBeforeText, _12hoursBeforeText, _16hoursBeforeText, _1dot5daysBeforeText, _2dot5daysBeforeText};
	
	cell.textLabel.text = ([self.taskEdit isADE]?adeAlerts[indexPath.row]:alerts[indexPath.row]);
	
	cell.accessoryType = (indexPath.row == selectedIndex?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
	
    return cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if (selectedIndex >= 0)
	{
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		
		[[alertTableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	[[alertTableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	selectedIndex = indexPath.row;
	
	NSInteger alertDurations[8] = {-15, -30, -45, -60, -120, -1440, -2880, 0};
	
    //NSInteger adeAlertDurations[8] = {8*60, 0, -4*60, -8*60, -12*60, -16*60, -36*60, -60*60};
    NSInteger adeAlertDurations[6] = {-4*60, -8*60, -12*60, -16*60, -36*60, -60*60};
	
	self.alertData.beforeDuration = ([self.taskEdit isADE]?adeAlertDurations[selectedIndex]:alertDurations[selectedIndex])*60;
    self.alertData.absoluteTime = nil;
	
	[self showAlertTime];
}

#pragma mark -
#pragma mark Actions

- (void)save:(id)sender
{
	if (alertIndex == -1) //new alert
	{
		if (taskEdit.primaryKey != -1)
		{
			self.alertData.taskKey = taskEdit.primaryKey;
			
			[self.alertData insertIntoDB:[[DBManager getInstance] getDatabase]];
			
			[[AlertManager getInstance] generateAlert:self.alertData forTask:taskEdit];
		}
		
		[self.taskEdit.alerts addObject:self.alertData];
		alertIndex = self.taskEdit.alerts.count-1;
	}
	else 
	{
		AlertData *alert = [self.taskEdit.alerts objectAtIndex:alertIndex];
		
		[alert updateByAlertData:self.alertData];
		
		[alert updateIntoDB:[[DBManager getInstance] getDatabase]];
		
		[[AlertManager getInstance] generateAlert:alert forTask:taskEdit];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[alertDict release];
	
	self.alertData = nil;
	
    [super dealloc];
}


@end

