//
//  LocationViewController.m
//  iVo
//
//  Created by Nang Le on 7/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import <AddressBook/AddressBook.h>
#import "Common.h"
#import "Colors.h"
#import "Task.h"
#import "ContactManager.h"
#import "ImageManager.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

NSString *localeNameForTimeZoneNameComponents(NSArray *nameComponents);

@implementation LocationViewController
@synthesize task;
@synthesize oldSelectedIndex;
@synthesize indexArrayList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (id) init
{
	if (self = [super init])
	{
	}
	return self;
}

/*
- (void)changeTableFrame
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];
	
	tableView.frame = CGRectMake(0, 0, 320, 416 - barHeight - sortAddress.frame.size.height);
}
*/

- (void)loadView {
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
															  target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
		
	self.navigationItem.title = _locationText;//@"Locations";
	
	//contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    contentView=[[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor=[UIColor darkGrayColor];
	
    /*
	sortAddress=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: _sortedByAddressText, _sortedByContactText, nil]];

	//sortAddress.frame=CGRectMake(10, contentView.frame.size.height - 2*MINI_BAR_HEIGHT - 36, 300, 36);
    sortAddress.frame=CGRectMake(10, frm.size.height - 36, frm.size.width - 20, 36);
    
	sortAddress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	sortAddress.segmentedControlStyle = UISegmentedControlStylePlain;
	[sortAddress addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventValueChanged];
	sortAddress.selectedSegmentIndex=0;
	[contentView addSubview:sortAddress];
	*/
    
	//tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, contentView.frame.size.height) style:UITableViewStylePlain];
    tableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
	
	[contentView addSubview:tableView];
	[tableView release];
	
	//[self changeTableFrame];
	
    self.view = contentView;
	[contentView release];

	indexArrayList=[[NSMutableArray alloc] initWithCapacity:1];
	[indexArrayList addObject:_aText];
	[indexArrayList addObject:_bText];
	[indexArrayList addObject:_ccText];
	[indexArrayList addObject:_dText];
	[indexArrayList addObject:_eText];
	[indexArrayList addObject:_fText];
	[indexArrayList addObject:_gText];
	[indexArrayList addObject:_hText];
	[indexArrayList addObject:_iText];
	[indexArrayList addObject:_jText];
	[indexArrayList addObject:_kText];
	[indexArrayList addObject:_lText];
	[indexArrayList addObject:_mText];
	[indexArrayList addObject:_nText];
	[indexArrayList addObject:_oText];
	[indexArrayList addObject:_pText];
	[indexArrayList addObject:_qText];
	[indexArrayList addObject:_rText];
	[indexArrayList addObject:_sText];
	[indexArrayList addObject:_tText];
	[indexArrayList addObject:_uText];
	[indexArrayList addObject:_vText];
	[indexArrayList addObject:_wText];
	[indexArrayList addObject:_xText];
	[indexArrayList addObject:_yText];
	[indexArrayList addObject:_zText];
	[indexArrayList addObject:@"#"];
}


/*
 If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	[ImageManager free];
}


- (void)dealloc {

    [saveButton release];
	[sortAddress release];
	
	self.selectedLocation = nil;
	self.oldSelectedIndex = nil;
	self.indexArrayList = nil;
	
	[super dealloc];
}

#pragma mark controller delegate

- (void)viewWillAppear:(BOOL)animated {
	self.selectedLocation = self.task.location;
}

- (void)viewDidAppear:(BOOL)animated {
	[tableView scrollToRowAtIndexPath:self.oldSelectedIndex atScrollPosition:UITableViewScrollPositionNone animated:YES];

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
}

- (void)viewDidLoad {
}

#pragma mark action Methods

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
	self.task.location = self.selectedLocation;
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sortAction:(id)sender {
	[tableView reloadData];
}

-(void)cleanContactText:(id)sender{
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	if(sortAddress.selectedSegmentIndex==1){
		NSArray *locationDisplayListByName = [[ContactManager getInstance] getLocationDisplayList:YES];
		if(locationDisplayListByName.count>0)
			return locationDisplayListByName.count;
	}else {
		NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];
		if(locationDisplayListByContact.count>0)
			return locationDisplayListByContact.count;
	}

	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Number of rows is the number of names in the region dictionary for the specified section
		if(sortAddress.selectedSegmentIndex==1){
			NSArray *locationDisplayListByName = [[ContactManager getInstance] getLocationDisplayList:YES];
			if(locationDisplayListByName.count>0){
				NSDictionary *letterDictionary = [locationDisplayListByName objectAtIndex:section];
				NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
				return [locationsForLetter count];
			}
		}else {
			NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];
			if(locationDisplayListByContact.count>0){
				NSDictionary *letterDictionary = [locationDisplayListByContact objectAtIndex:section];
				NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
				return [locationsForLetter count];
			}
		}
		
	return 0;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	
	if(sortAddress.selectedSegmentIndex==1){
		NSArray *locationDisplayListByName = [[ContactManager getInstance] getLocationDisplayList:YES];
		if(locationDisplayListByName.count>0){
			NSDictionary *sectionDictionary = [locationDisplayListByName objectAtIndex:section];
			NSString *titleLeter= [sectionDictionary valueForKey:@"letter"];
			if([titleLeter isEqualToString:@"Z#"])
				return @"#";
			return titleLeter;		
		}
	}else {
		NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];
		if(locationDisplayListByContact.count>0){
			NSDictionary *sectionDictionary = [locationDisplayListByContact objectAtIndex:section];
			NSString *titleLeter= [sectionDictionary valueForKey:@"letter"];
			if([titleLeter isEqualToString:@"Z#"])
				return @"#";
			return titleLeter;		
		}
	}
	
	return @"";
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 Return the index titles for each of the sections (e.g. "A", "B", "C"...).
	 Use key-value coding to get the value for the key @"letter" in each of the dictionaries in list.
	 */
	NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];	
	if(locationDisplayListByContact.count > 0 && sortAddress.selectedSegmentIndex==0){
		return indexArrayList;		
	}
	return nil;
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title
	if(sortAddress.selectedSegmentIndex==1){
		NSArray *locationDisplayListByName = [[ContactManager getInstance] getLocationDisplayList:YES];
		if(locationDisplayListByName.count>0){
			if([title isEqualToString:@"#"]){
				return locationDisplayListByName.count -1;
			}
			
		return [locationDisplayListByName indexOfObject:title];		
		}
	}else {
		NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];
		if(locationDisplayListByContact.count>0){
			if([title isEqualToString:@"#"]){
				return locationDisplayListByContact.count -1;
			}
			
			return [locationDisplayListByContact indexOfObject:title];		
		}
	}
	
		
	return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"] autorelease];
	}
	
	[cell.textLabel setTextColor:[UIColor blackColor]];
	
	if(sortAddress.selectedSegmentIndex==1){
		NSArray *locationDisplayListByName = [[ContactManager getInstance] getLocationDisplayList:YES];
		if(locationDisplayListByName.count>0){
			NSDictionary *letterDictionary = [locationDisplayListByName objectAtIndex:indexPath.section];
			NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
			NSDictionary *locationDictionary = [locationsForLetter objectAtIndex:indexPath.row];
			
			// Set the cell's text to the name of the time zone at the row
			cell.textLabel.text = [locationDictionary objectForKey:@"locationLocaleName"];
			
			if(self.selectedLocation !=nil){
				if ([self.selectedLocation isEqual:cell.textLabel.text] ) {
					self.oldSelectedIndex=indexPath;//[NSIndexPath indexPathForRow:indexPath.row inSection :indexPath.section];
					[cell.textLabel setTextColor:[Colors darkSteelBlue]];
				}	
			}
			
		}else {
			cell.textLabel.text=@"";
		}
	}else {
		NSArray *locationDisplayListByContact = [[ContactManager getInstance] getLocationDisplayList:NO];
		if(locationDisplayListByContact.count>0){
			NSDictionary *letterDictionary = [locationDisplayListByContact objectAtIndex:indexPath.section];
			NSArray *locationsForLetter = [letterDictionary objectForKey:@"locations"];
			NSDictionary *locationDictionary = [locationsForLetter objectAtIndex:indexPath.row];
			
			// Set the cell's text to the name of the time zone at the row
			cell.textLabel.text = [locationDictionary objectForKey:@"locationLocaleName"];
			
			if(self.selectedLocation !=nil){
				if ([self.selectedLocation isEqual:cell.textLabel.text] ) {
					self.oldSelectedIndex=indexPath;
					[cell.textLabel setTextColor:[Colors darkSteelBlue]];
				}	
			}
			
		}else {
			cell.textLabel.text=@"";
		}
	}
	
	if(self.oldSelectedIndex !=nil && [self.oldSelectedIndex compare:indexPath]==NSOrderedSame){
		cell.accessoryType= UITableViewCellAccessoryCheckmark;
    }else {
		cell.accessoryType= UITableViewCellAccessoryNone;
	}
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.oldSelectedIndex !=nil){
		[[tv cellForRowAtIndexPath:self.oldSelectedIndex].textLabel setTextColor:[UIColor blackColor]];
	}
	[[tv cellForRowAtIndexPath:indexPath].textLabel setTextColor:[Colors darkSteelBlue]];
    // Never allow selection.
    if (self.editing) {
		return indexPath;
	}
    return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	//mark the selected cell as checked
	[[table cellForRowAtIndexPath:self.oldSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
    [[table cellForRowAtIndexPath:newIndexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	//keep current index path
    self.oldSelectedIndex=newIndexPath;
	
	//keep selected contact
	self.selectedLocation=[table cellForRowAtIndexPath:newIndexPath].textLabel.text;
	
	//deselect to hide the highlight of selected cell
    [table deselectRowAtIndexPath:newIndexPath animated:YES];
}

#pragma mark common uses

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	NSString *loc=[textField.text copy];
	self.selectedLocation=loc;	
	[loc release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

#pragma mark properties

- (NSString	*)selectedLocation{
	return selectedLocation;	
}

- (void)setSelectedLocation:(NSString *)aString{
	[selectedLocation release];
	selectedLocation=[aString copy];	
}

@end
