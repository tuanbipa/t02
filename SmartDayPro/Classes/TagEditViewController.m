    //
//  TagEditViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 5/9/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "TagEditViewController.h"

#import "Common.h"

#import "ImageManager.h"

#import "SmartDayViewController.h"

#import "DetailViewController.h"

extern SmartDayViewController *_sdViewCtrler;

//extern BOOL _isiPad;

@implementation TagEditViewController

@synthesize objectEdit;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id) init
{
    if (self = [super init])
    {
        self.preferredContentSize = CGSizeMake(320,416);
    }
    
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //frm.size.width = 320;
    
    if (_isiPad)
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            frm.size.height = frm.size.width - 20;
        }
        
        frm.size.width = 384;
    }
    else
    {
        frm.size.width = 320;
    }
    
    UIView *contentView= [[UIView alloc] initWithFrame:frm];
	//contentView.backgroundColor=[UIColor darkGrayColor];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	   
	tagTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
	tagTableView.delegate = self;
	tagTableView.dataSource = self;
	//tagTableView.sectionHeaderHeight=5;
	tagTableView.allowsSelectionDuringEditing=YES;
    tagTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:tagTableView];
	[tagTableView release];
	
	self.view = contentView;
	[contentView release];
	
	self.navigationItem.title = _tagListText;
	
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
        [ctrler refreshTag];
    }
    
    [_sdViewCtrler refreshFilterTag];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	[ImageManager free];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void) clearAllTags:(id)sender
{
	[objectEdit setTag:@""];
	
	[tagTableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSString *tag = [objectEdit tag];
	
	if ([tag isEqualToString:@""])
	{
		return 0;
	}
	
	NSArray *parts = [tag componentsSeparatedByString:@","];
	
    return parts.count;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return @"";
}
*/
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSString *tag = (NSString *) [objectEdit tag];
	
	NSArray *parts = [tag componentsSeparatedByString:@","];
		
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;

	cell.textLabel.text = [parts objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    cell.backgroundColor = [UIColor clearColor];
	
    return cell;
}

- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSString *tag = (NSString *) [objectEdit tag];
		
		NSArray *parts = [tag componentsSeparatedByString:@","];
		
		tag = @"";
		
		if (parts.count >= 2)
		{
			for (int i=0; i<parts.count; i++)
			{
				if (i != indexPath.row)
				{
					if ([tag isEqualToString:@""])
					{
						tag = [parts objectAtIndex:i];
					}
					else 
					{
						tag = [tag stringByAppendingFormat:@",%@", [parts objectAtIndex:i]];
					}
				}
			}
		}

		[objectEdit setTag:tag];
		[tagTableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return UITableViewCellEditingStyleDelete;	
}


@end
