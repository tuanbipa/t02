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
#import "Task.h"

#import "iPadCalendarSettingViewController.h"
#import "StartEndPickerViewController.h"
#import "SettingTableViewController.h"

extern BOOL _isiPad;

@implementation TimeZonePickerViewController

@synthesize searchDict;
@synthesize tzIDList;
@synthesize objectEdit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
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
    
    Settings *settings = [Settings getInstance];
    
    NSArray *list = [settings.timeZoneDict allKeys];
    
    for (NSNumber *key in list)
    {
        NSString *name = [[settings.timeZoneDict objectForKey:key] substringFromIndex:11];
        
        NSRange range = [name rangeOfString:@"/" options:NSBackwardsSearch range:NSMakeRange(0, name.length-1)];
        
        if (range.location != NSNotFound)
        {
            name = [name substringFromIndex:range.location+1];
        }
        
        [self createSearchForName:[name uppercaseString] timeZoneID:[key intValue]];
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
        Settings *settings = [Settings getInstance];
        
        self.tzIDList = [NSMutableArray arrayWithArray:[settings.timeZoneDict keysSortedByValueUsingComparator:^NSComparisonResult(NSString *name1, NSString *name2)
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
        
        /*for (NSNumber *key in self.tzIDList)
        {
            printf("%s,%d\n", [[settings.timeZoneDict objectForKey:key] UTF8String], [key intValue]);
        }*/
    }
    else
    {
        self.tzIDList = [self.searchDict objectForKey:name];
    }

    [self.tzIDList removeObject:[NSNumber numberWithInt:0]];

    if (![self.objectEdit isKindOfClass:[Settings class]])
    {
        [self.tzIDList insertObject:[NSNumber numberWithInt:0] atIndex:0];
    }
    
    [listTableView reloadData];
}

- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    //UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    CGFloat pad = 0;
    
    //if ([ctrler isKindOfClass:[iPadCalendarSettingViewController class]])
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
        
        pad = 60;
    }
    else
    {
        frm.size.width = 320;
        
        pad = 20;
    }
    
    //CGFloat marginY = (_isiPad?20:0);
    CGFloat marginY = 0;
    
    contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(pad/2, marginY+10, frm.size.width-pad, 30)];
    searchBar.placeholder = @"";
    searchBar.backgroundColor = [UIColor clearColor];
    //searchBar.translucent = NO;
    //searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.delegate = self;
    searchBar.backgroundImage = [UIImage imageNamed:@"none.png"];
    
    [contentView addSubview:searchBar];
    [searchBar release];
    
    frm = contentView.bounds;
    frm.origin.y = marginY + 50;
    frm.size.height -= frm.origin.y;
	
    listTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	listTableView.delegate = self;
	listTableView.dataSource = self;
    listTableView.backgroundColor = [UIColor clearColor];
	//listTableView.sectionHeaderHeight=5;
	
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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[StartEndPickerViewController class]])
    {
        StartEndPickerViewController *ctrler = (StartEndPickerViewController *)self.navigationController.topViewController;
        
        [ctrler refreshTimeZone];
    }
    else if ([self.navigationController.topViewController isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *)self.navigationController.topViewController;
        
        [ctrler refreshTimeZone];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
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
    
    Settings *settings = [Settings getInstance];
    
	cell.textLabel.text = [settings.timeZoneDict objectForKey:key];
    
    if ([self.objectEdit isKindOfClass:[Settings class]])
    {
        settings = (Settings *)self.objectEdit;

        if (settings.timeZoneID == [key intValue])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedIndex = indexPath.row;
        }
    }
    else if ([self.objectEdit isKindOfClass:[Task class]])
    {
        Task *task = (Task *)self.objectEdit;
        
        if (task.timeZoneId == [key intValue])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            selectedIndex = indexPath.row;
        }
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
    
    //self.settings.timeZoneID = [key intValue];
    
    if ([self.objectEdit isKindOfClass:[Settings class]])
    {
        ((Settings *)self.objectEdit).timeZoneID = [key intValue];
    }
    else if ([self.objectEdit isKindOfClass:[Task class]])
    {
        ((Task *)self.objectEdit).timeZoneId = [key intValue];
    }
}

#pragma mark UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];   
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchForName:[searchBar.text uppercaseString]];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}


@end
