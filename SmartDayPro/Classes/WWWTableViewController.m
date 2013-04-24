//
//  WWWTableViewController.m
//  SmartPlan
//
//  Created by Huy Le on 12/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>

#import "WWWTableViewController.h"

#import "Common.h";
#import "Colors.h"
#import "Task.h"

#import "ImageManager.h"

#import "HPGrowingTextView.h"

#import "LocationViewController.h"

//#import "SCTabBarController.h"
//extern SCTabBarController *_tabBarCtrler;

@implementation WWWTableViewController

@synthesize task;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

/*
- (void)changeTableFrame
{
	CGFloat barHeight = [_tabBarCtrler getBarHeight];

	wwwTableView.frame = CGRectMake(0, 0, 320, 416 - barHeight);
}
*/

- (id) init
{
    if (self = [super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	//contentView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor=[UIColor darkGrayColor];
	
	//wwwTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    wwwTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStyleGrouped];
	wwwTableView.delegate = self;
	wwwTableView.dataSource = self;
	wwwTableView.sectionHeaderHeight=5;	
	
	[contentView addSubview:wwwTableView];
	[wwwTableView release];
	
	//doneBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, 320, 40)];
    doneBarView = [[UIView alloc] initWithFrame:CGRectMake(0, frm.size.height-[Common getKeyboardHeight]-40, frm.size.width, 40)];
	doneBarView.backgroundColor=[UIColor clearColor];
	doneBarView.hidden = YES;
	
	[contentView addSubview:doneBarView];
	[doneBarView release];	
	
	//UIView *backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIView *backgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frm.size.width, 40)];
	backgroundView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
	backgroundView.alpha=0.3;
	
	[doneBarView addSubview:backgroundView];
	[backgroundView release];
	
	UIButton *locationDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	//locationDoneButton.frame = CGRectMake(250, 5, 60, 30);
    locationDoneButton.frame = CGRectMake(frm.size.width-60-10, 5, 60, 30);
	locationDoneButton.alpha=1;
	[locationDoneButton setTitle:_doneText forState:UIControlStateNormal];
	locationDoneButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[locationDoneButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[locationDoneButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"blue-small.png"] forState:UIControlStateNormal];
	
	[locationDoneButton addTarget:self action:@selector(locationDone:) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *locationCleanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	locationCleanButton.frame = CGRectMake(10, 5, 60, 30);
	locationCleanButton.alpha=1;
	[locationCleanButton setTitle:_cleanText forState:UIControlStateNormal];
	locationCleanButton.titleLabel.font=[UIFont systemFontOfSize:14];
	[locationCleanButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];		
	[locationCleanButton setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"blue-small.png"] forState:UIControlStateNormal];
	
	[locationCleanButton addTarget:self action:@selector(cleanLocation:) forControlEvents:UIControlEventTouchUpInside];	
	
	[doneBarView addSubview:locationDoneButton];
	[doneBarView addSubview:locationCleanButton];
	
	self.view = contentView;
	[contentView release];
    
    titleTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 75, 300-20, 30)];
    //titleTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    titleTextView.placeholder = _titleGuideText;
    
    titleTextView.minNumberOfLines = 1;
    titleTextView.maxNumberOfLines = 4;
    titleTextView.returnKeyType = UIReturnKeyDone; //just as an example
    titleTextView.font = [UIFont systemFontOfSize:15.0f];
    titleTextView.delegate = self;
    //titleTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    //titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    titleTextView.layer.borderWidth = 1;
    titleTextView.layer.cornerRadius = 8;
    
    titleTextView.text = self.task.name;    
	
	selectedButton = nil;
	
	self.navigationItem.title = _titleLocationText;
	
	//[self changeTableFrame];
}

- (void) stopTextEdit
{
	[locationTextView resignFirstResponder];
    
    //CGRect frm = CGRectMake(0, 0, 320, 416);
    CGRect frm = contentView.bounds;
    
    //contentView.frame = frm;
    wwwTableView.frame = frm;    
	
	doneBarView.hidden = YES;	
}

/*
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[wwwTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	selectedButton = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self stopTextEdit];
}

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


- (void)whatAction:(id) sender
{
	if (selectedButton != nil)
	{
		selectedButton.selected = NO;
	}
	
	selectedButton = (UIButton *)sender;
	selectedButton.selected = YES;
	
	NSString *actionTexts[5] = {_gotoText, _contactText, _getText, _writeToText, _meetText};
	
	NSString *actionText = actionTexts[selectedButton.tag - 10002];
	
	if (task.contactName != nil && ![task.contactName isEqualToString:@""])
	{
		task.name = [actionText stringByAppendingString:task.contactName];
	}
	else
	{
		task.name = actionText;
	}
	
	//taskTitleEditField.text = task.name;
    titleTextView.text = task.name;
}

- (void)editContact
{
	ABPeoplePickerNavigationController *contactList=[[ABPeoplePickerNavigationController alloc] init];
	contactList.peoplePickerDelegate = self;
	//[self presentModalViewController:contactList animated:YES];
    contactList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:contactList animated:YES completion:NULL];

	[contactList release];
}

#pragma mark Actions

- (void)editLocation:(id) sender
{
	LocationViewController *locationViewController=[[LocationViewController alloc] init];	
	
	locationViewController.oldSelectedIndex=nil;
	locationViewController.task=self.task;
	[locationViewController setEditing:YES animated:YES];
	[self.navigationController pushViewController:locationViewController animated:YES];
	[locationViewController release];
	
}

- (void)locationDone:(id) sender
{
	[self stopTextEdit];
    	
	//self.task.location = locationTextView.text;
}

- (void)cleanLocation:(id) sender
{
	//locationTextView.text = @"";
    
    ////printf("");
    
    UITableViewCell *cell = [wwwTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    
    UITextView *textView = [cell.contentView viewWithTag:10008];
    
    if (textView != nil)
    {
        textView.text = @"";
    }                       
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return _whatText;//@"What";
			break;
		case 1:
			return _whoText;//@"Who";
			break;
		case 2:
			return _whereText;//@"Where";
			break;
	}
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.section) {
		case 0:
        {
			//return 130;
            CGFloat h = [titleTextView getHeight];
            //printf("title height: %f\n", h);
            
            return h + 80;
        }
			break;
		case 1:
			return 60;
			break;
		case 2:
			return 80;
			break;
	}
	return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
/*	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}		
	}*/
    
    // Set up the cell...
	cell.textLabel.text = @"";
	
	switch (indexPath.section) 
	{
		case 0:
		{
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *instrustionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 280, 25)];
			instrustionLabel.tag = 10000;
			instrustionLabel.text = _titleGuideWWWText;
			instrustionLabel.textColor = [UIColor grayColor];
            instrustionLabel.backgroundColor = [UIColor clearColor];
			
			[cell.contentView addSubview:instrustionLabel];
			[instrustionLabel release];
			
			UIView *whatButtonGroup=[[UIView alloc] initWithFrame:CGRectMake(10, 30, 280, 40)];
			whatButtonGroup.tag = 10001;
			[cell.contentView addSubview:whatButtonGroup];
			[whatButtonGroup release];
			
			UIButton *gotoButton=[Common createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(0, 0, 40, 40) 
										   titleColor:nil 
											   target:self 
											 selector:@selector(whatAction:) 
									 normalStateImage:@"Go.png"
								   selectedStateImage:@"blueGo.png"];
			
			gotoButton.tag = 10002;
			[whatButtonGroup addSubview:gotoButton];
			
			UIButton *callButton=[Common createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(60, 0, 40, 40) 
										   titleColor:nil 
											   target:self 
											 selector:@selector(whatAction:) 
									 normalStateImage:@"Call.png"
								   selectedStateImage:@"blueCall.png"];
			
			callButton.tag = 10003;
			[whatButtonGroup addSubview:callButton];
			
			UIButton *buyButton=[Common createButton:@"" 
										  buttonType:UIButtonTypeCustom 
											   frame:CGRectMake(120, 0, 40, 40) 
										  titleColor:nil 
											  target:self 
											selector:@selector(whatAction:) 
									normalStateImage:@"Buy.png"
								  selectedStateImage:@"blueBuy.png" ];
			
			buyButton.tag = 10004;
			[whatButtonGroup addSubview:buyButton];
			
			UIButton *mailButton=[Common createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(180, 0, 40, 40) 
										   titleColor:nil 
											   target:self 
											 selector:@selector(whatAction:) 
									 normalStateImage:@"Mail.png"
								   selectedStateImage:@"blueMail.png"];
			
			mailButton.tag = 10005;
			[whatButtonGroup addSubview:mailButton];
			
			UIButton *meetButton=[Common createButton:@"" 
										   buttonType:UIButtonTypeCustom 
												frame:CGRectMake(240, 0, 40, 40) 
										   titleColor:nil 
											   target:self 
											 selector:@selector(whatAction:) 
									 normalStateImage:@"Meet.png"
								   selectedStateImage:@"blueMeet.png"];
			
			meetButton.tag = 10006;
			[whatButtonGroup addSubview:meetButton];
            
            [cell.contentView addSubview:titleTextView];
		}
			break;
		case 1:
		{
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = self.task.contactName;
		}
			break;
		case 2:
		{
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			locationTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 0, 250, 80)];
			locationTextView.delegate=self;
			locationTextView.backgroundColor=[UIColor clearColor];
			locationTextView.keyboardType=UIKeyboardTypeDefault;
			locationTextView.font=[UIFont systemFontOfSize:18];
			
			locationTextView.text = self.task.location;
			
			locationTextView.tag = 10008;
			[cell.contentView addSubview:locationTextView];
			[locationTextView release];
			
			UIButton *editLocationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			editLocationButton.frame = CGRectMake(260, 0, 40, 80);
			[editLocationButton addTarget:self action:@selector(editLocation:) forControlEvents:UIControlEventTouchUpInside];					
			
			editLocationButton.tag = 10009;
			
			[cell.contentView addSubview:editLocationButton];
			
		}
			break;			
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 1)
	{
		[self editContact];
	}
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


#pragma mark ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
	//[peoplePicker dismissModalViewControllerAnimated:YES];
    [peoplePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker 
      shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
	CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
	CFStringRef company = ABRecordCopyValue(person, kABPersonOrganizationProperty);
	
	if (firstName==nil && lastName==nil && company==nil){
		firstName=(CFStringRef)_nonameText;
		lastName=(CFStringRef)@" ";
		company=(CFStringRef)@" ";
	}else{
		if(firstName==nil) {
			firstName=(CFStringRef) @" ";
		}
		if(lastName==nil){
			lastName=(CFStringRef)@" ";
		}
		if(company==nil){
			company=(CFStringRef)@" ";
		}
		
	}
	
	NSString *contactName=[NSString stringWithFormat:@"%@ %@",firstName, lastName];
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactName=[contactName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	NSString *contactComName=[NSString stringWithFormat:@"%@",company];
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactComName=[contactComName stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	if ([[contactName stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
		contactName=contactComName;
	}
	
	self.task.contactName=contactName;
	
	//get PHONE NUMBER from contact
	NSString *phoneNumber=@"";
	ABMutableMultiValueRef phoneEmailValue = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if(ABMultiValueGetCount(phoneEmailValue)>0){
		phoneNumber=@"";
		
		for(NSInteger i=0;i<ABMultiValueGetCount(phoneEmailValue);i++){
			CFStringRef phoneNo = ABMultiValueCopyValueAtIndex(phoneEmailValue, i);
			CFStringRef label=ABMultiValueCopyLabelAtIndex(phoneEmailValue, i);
			
			if(label==nil){
				label=(CFStringRef)@" ";	
			}
			
			if(phoneNo==nil){
				phoneNo=(CFStringRef)@" ";	
			}
			phoneNumber=[phoneNumber stringByAppendingFormat:@"/%@|%@",label,phoneNo];
		}
		
	}
	CFRelease(phoneEmailValue);
	self.task.contactPhone=phoneNumber;
	
	NSString *contactAddress=nil;
	//get first address for this contact
	ABMutableMultiValueRef multiValue = ABRecordCopyValue(person, kABPersonAddressProperty);
	
	if(ABMultiValueGetCount(multiValue)>0){
		
		//get all address from the contact
		CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, 0);
		CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
		CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
		CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);		
		CFStringRef state = CFDictionaryGetValue(dict,kABPersonAddressStateKey);
		CFStringRef zip = CFDictionaryGetValue(dict,kABPersonAddressZIPKey);
		
		CFRelease(dict);
		
		if(street!=nil){
			contactAddress=[NSString stringWithFormat:@"%@",street];
		}else {
			contactAddress=@"";
		}
		
		if(city!=nil){
			if(street!=nil){
				NSString *cityNameAppend=[NSString stringWithFormat:@", %@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAppend];
			}else{
				NSString *cityNameAsLoc=[NSString stringWithFormat:@"%@",city];
				contactAddress=[contactAddress stringByAppendingString:cityNameAsLoc];
			}
		}
		
		if(country!=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",country];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(state !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",state];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
		if(zip !=nil){
			if(![contactAddress isEqualToString:@""]){
				NSString *countryNameAppend=[NSString stringWithFormat:@", %@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAppend];
			}else{
				NSString *countryNameAsLoc=[NSString stringWithFormat:@"%@",zip];
				contactAddress=[contactAddress stringByAppendingString:countryNameAsLoc];
			}
		}
		
	}else {
		contactAddress=@"";
	}
	
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];//remove the newline character
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\n" withString:@" "];//remove new line character;
	contactAddress=[contactAddress stringByReplacingOccurrencesOfString:@"\r" withString:@" "];//remove new line character;
	
	CFRelease(multiValue);
	
	self.task.location=contactAddress;
	
	//get email address from contact
	NSString *emailAddress=@"";
	ABMutableMultiValueRef multiEmailValue = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(multiEmailValue)>0){
		CFStringRef emailAddr = ABMultiValueCopyValueAtIndex(multiEmailValue, 0);
		
		if(emailAddr==nil){
			emailAddr=(CFStringRef)@" ";	
		}
		emailAddress=[NSString stringWithFormat:@"%@",emailAddr];
	}
	CFRelease(multiEmailValue);
	self.task.contactEmail=emailAddress;
	
	NSString *actionTexts[5] = {_gotoText, _contactText, _getText, _writeToText, _meetText};
	for (int i=0; i<5; i++)
	{
		if ([task.name isEqualToString:actionTexts[i]])
		{
			task.name = [task.name stringByAppendingString:[NSString stringWithFormat:@" %@", task.contactName]];
			
			break;
		}	
	}	
	
	// remove the controller
	//[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier{
	return NO;
}


#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;	
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.task.name = textField.text;		
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return YES;
}

#pragma mark textView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
	//CGRect frm = CGRectMake(0, 0, 320, 200);
    
    //contentView.frame = frm;
    
    CGRect frm = contentView.bounds;
    
    frm.size.height -= [Common getKeyboardHeight] + 40;
    
	wwwTableView.frame = frm;
    
	[wwwTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:NO];
	
	doneBarView.hidden = NO;
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
	self.task.location = textView.text;
}

#pragma mark GrowingTextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    //self.task.name = growingTextView.text;
    
    BOOL isFirstResponder = [titleTextView isFirstResponder];
    
    //[titleTextView retain];
    //[titleTextView removeFromSuperview];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [wwwTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (isFirstResponder)
    {
        [titleTextView becomeFirstResponder];
    }
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return NO;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;
{
    NSString *text = [titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.task.name = text;
}

- (void)dealloc {
	[titleTextView release];
    
    [super dealloc];
}


@end

