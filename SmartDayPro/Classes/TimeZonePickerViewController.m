//
//  TimeZonePickerViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 5/15/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "TimeZonePickerViewController.h"

#import "Common.h"
#import "Settings.h"

#import "iPadCalendarSettingViewController.h"

@implementation TimeZonePickerViewController

@synthesize searchDict;
@synthesize tzIDList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    self.searchDict = nil;
    
    self.tzIDList = nil;
    
    [super dealloc];
}

- (void) createSearchForName:(NSString *)name timeZoneID:(NSInteger)timeZoneID
{
	for (int i=0; i<name.length; i++)
	{
		NSRange range;
		
		range.location = 0;
		range.length = i+1;
        
		NSString *str = [name substringWithRange:range];
		
		NSMutableArray *list = [self.searchDict objectForKey:str];
		
		if (list == nil)
		{
			list = [NSMutableArray arrayWithCapacity:5];
			
			[self.searchDict setObject:list forKey:str];
		}
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:list forKeys:list];
        
        NSNumber *numID = [NSNumber numberWithInt:timeZoneID];
        
        if ([dict objectForKey:numID] == nil)
        {
            [list addObject:numID];
        }
	}
}

- (void) createSearchDict
{
    self.searchDict = [NSMutableDictionary dictionaryWithCapacity:100];
    
    NSArray *list = [self.settings.timeZoneDict allKeys];
    
    for (NSNumber *key in list)
    {
        NSString *name = [self.settings.timeZoneDict objectForKey:key];
        
        name = [name substringFromIndex:11];
        
        [self createSearchForName:name timeZoneID:[key intValue]];
    }
}

- (void) initData
{
    [self createSearchDict];
    
    [self searchForName:@""];
}

- (void) searchForName:(NSString *)name
{
    if ([name isEqualToString:@""])
    {
        self.tzIDList = [NSMutableArray arrayWithArray:[self.settings.timeZoneDict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2)
            {
                NSRange range;
                range.location = 4;
                range.length = 5;
                
                NSString *offset1 = [name1 substringWithRange:range];
                NSString *offset2 = [name2 substringWithRange:range];
                
                NSInteger off1 = [offset1 intValue];
                NSInteger off2 = [offset2 intValue];
                
                if (off1 < off2)
                {
                    return NSOrderedAscending;
                }
                else
                {
                    return NSOrderedDescending;
                }
                
                return NSOrderedSame;
            }
                                                        ]];
    }
    else
    {
        self.tzIDList = [self.searchDict objectForKey:name];
    }
    
    [listTableView reloadData];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    if ([ctrler isKindOfClass:[iPadCalendarSettingViewController class]])
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(30, 10, frm.size.width-60, 30)];
    searchBar.placeholder = @"";
    searchBar.translucent = NO;
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.delegate = self;
    searchBar.backgroundImage = [UIImage imageNamed:@"none.png"];
    
    [contentView addSubview:searchBar];
    [searchBar release];
    
    frm = contentView.bounds;
    frm.origin.y += 40;
    frm.size.height -= 40;
	
    listTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	listTableView.delegate = self;
	listTableView.dataSource = self;
	listTableView.sectionHeaderHeight=5;
	
	[contentView addSubview:listTableView];
	[listTableView release];
	
	self.view = contentView;
	[contentView release];
	
	self.navigationItem.title = _timeZone;
    
    [self initData];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.tzIDList.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;

    NSNumber *key = [self.tzIDList objectAtIndex:indexPath.row];
    
	cell.textLabel.text = [self.settings.timeZoneDict objectForKey:key];
    
	if (self.settings.timeZoneID == [key intValue])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		selectedIndex = indexPath.row;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (selectedIndex >= 0)
	{
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
		
		[[listTableView cellForRowAtIndexPath:oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	[[listTableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	
	selectedIndex = indexPath.row;
	
    NSNumber *key = [self.tzIDList objectAtIndex:indexPath.row];
    self.settings.timeZoneID = [key intValue];
}

#pragma mark UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchForName:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}


@end
