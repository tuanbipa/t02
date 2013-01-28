//
//  MiniProductPageViewController.m
//  SmartTime
//
//  Created by NangLe on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MiniProductPageViewController.h"

#import "ImageManager.h"

@implementation MiniProductPageViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title=@"Smart Apps";
	self.tableView.separatorColor=[UIColor clearColor];
	self.tableView.backgroundColor=[UIColor colorWithRed:(CGFloat)195/255 green:(CGFloat)195/255 blue:(CGFloat)195/255 alpha:1];//[UIColor lightGrayColor];
	//self.tableView.backgroundColor=[UIColor viewFlipsideBackgroundColor];
}


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
    return 5;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }else {
		NSArray *subviews=[cell subviews];
		for (UIView *view in subviews){
			if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]]){
				[view removeFromSuperview];
			}
		}
	}

	cell.textLabel.text=@"";
	cell.accessoryType=UITableViewCellAccessoryNone;
	cell.textLabel.textColor=[UIColor darkGrayColor];
	cell.textLabel.shadowColor=[UIColor grayColor];
	
	UILabel *descriptionLb=[[UILabel alloc] initWithFrame:CGRectMake(90, 45, 240, 30)];
	descriptionLb.backgroundColor=[UIColor clearColor];
	descriptionLb.font=[UIFont systemFontOfSize:13];
	descriptionLb.textColor=[UIColor darkGrayColor];
	descriptionLb.shadowColor=[UIColor grayColor];
	descriptionLb.highlightedTextColor=[UIColor whiteColor];
	
	switch (indexPath.row) {
		case 0://logo
		{
			UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 95)];
			//img.image=[UIImage imageNamed:@"LCLlogo_smartapp.png"];
			img.image=[[ImageManager getInstance] getImageWithName:@"LCLlogo_smartapp.png"];
			[cell.contentView addSubview:img];
			[img release];
		}
			break;
		case 1://sl
			//cell.imageView.image=[UIImage imageNamed:@"SL.png"];
			cell.imageView.image=[[ImageManager getInstance] getImageWithName:@"SL.png"];
			cell.textLabel.text=@"SmartList";
			
			descriptionLb.text=@"You'll never need another";
			break;
		case 2://sn
			//cell.imageView.image=[UIImage imageNamed:@"SN.png"];
			cell.imageView.image=[[ImageManager getInstance] getImageWithName:@"SN.png"];
			cell.textLabel.text=@"SmartNotes";
			
			descriptionLb.text=@"Group your ideas, photos, voice notes";
			
			break;
		case 3://st
			//cell.imageView.image=[UIImage imageNamed:@"ST.png"];
			cell.imageView.image=[[ImageManager getInstance] getImageWithName:@"ST.png"];
			cell.textLabel.text=@"SmartTime";
			
			descriptionLb.text=@"An adaptive organizer with calendar";
			
			break;
		case 4://sp
			//cell.imageView.image=[UIImage imageNamed:@"SP.png"];
			cell.imageView.image=[[ImageManager getInstance] getImageWithName:@"SP.png"];
			cell.textLabel.text=@"SmartPlans";
			
			descriptionLb.text=@"Manage, time, and report everything";
			
			break;
	}
    
	[cell addSubview:descriptionLb];
	[descriptionLb release];
    // Set up the cell...
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
		
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSString *bodyStr;
	switch (indexPath.row) {
		case 1:
			bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/smartlist-w-day-manager-grocery/id365903499?mt=8"];
			
			break;
		case 2://SN
			bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/smart-notes-stickynotes-todo/id348837051?mt=8"];
			
			break;
		case 3://ST
			//bodyStr = [NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=295845767&mt=8"];
			bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/smarttime-pro-adaptive-organizer/id295845767?mt=8"];
			break;
		case 4://SP
			bodyStr = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/smart-plans-w-timer-todo-clients/id351222451?mt=8"];
			
			break;
	}
	
	NSString *encoded = [bodyStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [[NSURL alloc] initWithString:encoded];
	
	[[UIApplication sharedApplication] openURL:url];
	
	[url release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	switch (indexPath.row) {
		case 0://logo
			return 95;
			break;
	}
	
	return 80;
}

- (void)dealloc {
    [super dealloc];
}


@end

