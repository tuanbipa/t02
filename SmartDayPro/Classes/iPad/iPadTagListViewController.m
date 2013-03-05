//
//  TagListViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 2/18/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "iPadTagListViewController.h"

#import "Common.h"
#import "Colors.h"
#import "TagDictionary.h"
#import "TaskManager.h"
#import "FilterData.h"

#import "ContentView.h"

#import "iPadSmartDayViewController.h"

extern iPadSmartDayViewController *_iPadSDViewCtrler;

@interface iPadTagListViewController ()

@end

@implementation iPadTagListViewController

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

- (void) initData
{
    selectedDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    TaskManager *tm = [TaskManager getInstance];
    
    if (tm.filterData != nil && tm.filterData.tag != nil && ![tm.filterData.tag isEqualToString:@""])
    {
        TagDictionary *dict = [TagDictionary getInstance];
        
        NSArray *tags = [dict.tagDict allKeys];
        
        NSMutableArray *keys = [NSMutableArray arrayWithCapacity:tags.count];
        
        for (int i=0; i<tags.count; i++)
        {
            NSNumber *num = [NSNumber numberWithInt:i];
            
            [keys addObject:num];
        }
        
        NSDictionary *tagDict = [NSDictionary dictionaryWithObjects:keys forKeys:tags];
        
        NSArray *parts = [tm.filterData.tag componentsSeparatedByString:@","];
        
        for (NSString *tag in parts)
        {
            NSNumber *num = [tagDict objectForKey:tag];
            
            if (num != nil)
            {
                [selectedDict setObject:@"1" forKey:num];
            }
        }
    }

    [tagTableView reloadData];
}

- (void) dealloc
{
    [selectedDict release];
    
    [super dealloc];
}

- (void) filter:(id) sender
{
    UIButton *button = (UIButton *) sender;
    
    TaskManager *tm = [TaskManager getInstance];
    
    if (button.tag == 10000)
    {
        tm.filterData = nil;
    }
    else if (button.tag == 10001)
    {
        NSString *tagStr = nil;
        
        if (selectedDict.count > 0)
        {
            TagDictionary *dict = [TagDictionary getInstance];
            
            NSArray *tags = [dict.tagDict allKeys];
            
            for (NSNumber *key in [selectedDict.keyEnumerator allObjects])
            {
                int index = [key intValue];
                
                NSString *tag = [tags objectAtIndex:index];
                
                tagStr = (tagStr == nil?tag:[tagStr stringByAppendingFormat:@",%@", tag]);
            }
            
        }
        
        if (tagStr == nil)
        {
            tagStr = @"";
        }
        
        FilterData *filter = [[[FilterData alloc] init] autorelease];
        filter.tag = tagStr;
        
        tm.filterData = filter;
    }

    [_iPadSDViewCtrler applyFilter];
}

- (void) loadView
{
    CGSize sz = [Common getScreenSize];
    
    CGRect frm = CGRectZero;
    frm.size = sz;
    
    frm.size.width = 320;
    frm.size.height = 416;
    
    ContentView *contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    
    self.view = contentView;
    
    [contentView release];
    
    frm.origin.y += 40;
    frm.size.height -= 80;
    
    tagTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	tagTableView.delegate = self;
	tagTableView.dataSource = self;
	tagTableView.allowsSelectionDuringEditing = YES;
	
	[contentView addSubview:tagTableView];
	[tagTableView release];
    
    frm = CGRectMake(10, 10, 300, 30);
    
    UITextField *tagTextField = [[UITextField alloc] initWithFrame:frm];
    tagTextField.backgroundColor = [UIColor whiteColor];
	tagTextField.keyboardType = UIKeyboardTypeDefault;
	tagTextField.returnKeyType = UIReturnKeyDone;
	tagTextField.placeholder = _tapToAddTagText;
	tagTextField.textAlignment = NSTextAlignmentLeft;
	tagTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tagTextField.delegate = self;
    
    [contentView addSubview:tagTextField];
    [tagTextField release];
    
    frm = CGRectMake(40, contentView.bounds.size.height-35, 100, 30);
	
	UIButton *noFilterButton = [Common createButton:_noFilterText
										buttonType:UIButtonTypeCustom
                                             frame:frm
										titleColor:[UIColor whiteColor]
											target:self
										  selector:@selector(filter:)
								  normalStateImage:@"blue_button.png"
								selectedStateImage:nil];
    noFilterButton.tag = 10000;
	
	[contentView addSubview:noFilterButton];
    
    frm = CGRectMake(180, contentView.bounds.size.height-35, 100, 30);
    
	UIButton *applyButton = [Common createButton:_applyText
										buttonType:UIButtonTypeCustom
                                             frame:frm
										titleColor:[UIColor whiteColor]
											target:self
										  selector:@selector(filter:)
								  normalStateImage:@"blue_button.png"
								selectedStateImage:nil];
    applyButton.tag = 10001;
	
	[contentView addSubview:applyButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[TagDictionary getInstance] saveDict];
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
	
    TagDictionary *dict = [TagDictionary getInstance];
    
    return dict.tagDict.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *flag = [selectedDict objectForKey:[NSNumber numberWithInt:indexPath.row]];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (flag != nil)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [selectedDict removeObjectForKey:[NSNumber numberWithInt:indexPath.row]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [selectedDict setObject:@"1" forKey:[NSNumber numberWithInt:indexPath.row]];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}
	}
	
	cell.textLabel.text = @"";
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    TagDictionary *dict = [TagDictionary getInstance];
    
    cell.textLabel.text = [[dict.tagDict allKeys] objectAtIndex:indexPath.row];
    
    NSNumber *num = [NSNumber numberWithInt:indexPath.row];
    
    NSString *check = [selectedDict objectForKey:num];
    
    if (check != nil)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
	
	return cell;
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (![text isEqualToString:@""])
	{
		[[TagDictionary getInstance] addTag:text];
		
		[self initData];
	}
	
	textField.text = @"";
	
	[textField resignFirstResponder];
    
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@","] || [string isEqualToString:@"'"] || [string isEqualToString:@"\""])
    {
        return NO;
    }
    
	return YES;
}

@end
