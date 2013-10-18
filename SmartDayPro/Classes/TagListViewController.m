    //
//  TagListViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 5/4/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "TagListViewController.h"

#import "Common.h"
#import "ProjectManager.h"
#import "ImageManager.h"
#import "Project.h"
#import "TagDictionary.h"
#import "Settings.h"

#import "iPadGeneralSettingViewController.h"

#import "DetailViewController.h"
#import "TagDetailViewController.h"

//#import "SCTabBarController.h"

//extern SCTabBarController *_tabBarCtrler;

extern BOOL _tagHintShown;

//extern BOOL _isiPad;

@implementation TagListViewController

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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    UIViewController *ctrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    if ([ctrler isKindOfClass:[iPadGeneralSettingViewController class]])
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
	//UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
	self.view = contentView;
	
	[contentView release];
	
	//tagTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStyleGrouped];
    tagTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
	tagTableView.delegate = self;
	tagTableView.dataSource = self;
	tagTableView.allowsSelectionDuringEditing=YES;
    tagTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:tagTableView];
	[tagTableView release];
	
	self.navigationItem.title = _tagListText;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	BOOL showHint = [[Settings getInstance] tagHint];
	
	if (showHint && !_tagHintShown)
	{
		NSString *msg = _tagHintText;
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		
		alertView.tag = -10001;
		
		[alertView addButtonWithTitle:_dontShowText];
		
		[alertView show];
		[alertView release];
		
		_tagHintShown = YES;
		
	}
	
}

- (void)dealloc {
    [super dealloc];
}

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10001 && buttonIndex == 1)
	{
		[[Settings getInstance] enableTagHint:NO];
	}	
}


- (void) selectPreset:(id) sender
{
	
}

- (void) createTagQuickAddCell:(UITableViewCell *)cell
{
	UITextField *quickAddTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, tagTableView.bounds.size.width-20, 30)];
	
	quickAddTextField.keyboardType = UIKeyboardTypeDefault;
	quickAddTextField.returnKeyType = UIReturnKeyDone;
    quickAddTextField.borderStyle = UITextBorderStyleRoundedRect;
	quickAddTextField.placeholder = _tapToAddTagText;
	quickAddTextField.textAlignment = NSTextAlignmentLeft;
	quickAddTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	quickAddTextField.backgroundColor = [UIColor whiteColor];
	quickAddTextField.delegate = self;
	
	quickAddTextField.tag = 10000;
	
	[cell.contentView addSubview:quickAddTextField];
	
	[quickAddTextField release];
}

- (void) createPresetsCell:(UITableViewCell *)cell
{
	TagDictionary *dict = [TagDictionary getInstance];
    
    //CGFloat w = (tagTableView.bounds.size.width - (_isiPad?60:20) - 30)/3;
    CGFloat w = (tagTableView.bounds.size.width - 40)/3;
	
	UIButton *presetButtons[9];
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;

		UIButton *presetButton = [Common createButton:@"" 
									  buttonType:UIButtonTypeCustom
										   //frame:CGRectMake(mod*100 + 5, div*30 + 5, 90, 25)
                                  frame:CGRectMake(mod*(w+10) + 10, div*30 + 5, w, 25)
									  titleColor:[UIColor darkGrayColor]
										  target:self 
										selector:@selector(selectPreset:) 
								normalStateImage:@"sort_button.png"
							  selectedStateImage:nil];
		presetButton.tag = 10011+i;
		presetButton.enabled = NO;
		
		[cell.contentView addSubview:presetButton];
		
		presetButtons[i] = presetButton;
	}
	
	int j = 0;
	
	NSDictionary *prjDict = [ProjectManager getProjectDictionaryByName];
	
	for (NSString *tag in [dict.presetTagDict allKeys])
	{
		[presetButtons[j] setTitle:tag forState:UIControlStateNormal];
		[presetButtons[j] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		
		Project *prj = [prjDict objectForKey:tag];
		
		if (prj != nil)
		{
			NSDictionary *tagDict = [TagDictionary getTagDict:prj.tag];
			
			if ([tagDict objectForKey:tag] != nil) //Project has the tag with the same name as Project name
			{
				[presetButtons[j] setTitleColor:[Common getColorByID:prj.colorId colorIndex:0]  forState:UIControlStateNormal];
			}
		}
		
		j++;
	}
}
	
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	switch (section)
	{
		case 0:			
			return 1;
		case 1:
			return 1;
		case 2:
		{
			TagDictionary *dict = [TagDictionary getInstance];
			
			return dict.tagDict.count;
		}
	}
	
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1)
	{
		return 95;
	}
	
	return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section != 0)
        //return 40.0f;
        return 20.0f;
    
    return 0.01f;
}

/*
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = section==1?_presetsText:_customText;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 2)
	{
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSString *tagKey = [[dict.tagDict allKeys] objectAtIndex:indexPath.row];
		
		NSString *presetTag = [dict.presetTagDict objectForKey:tagKey];
		
		if (presetTag != nil)
		{
			[dict makePreset:tagKey preset:NO];
		}
		else
		{
			[dict makePreset:tagKey preset:YES];
		}
				
		[tableView reloadData];		
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
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];
	
	switch (indexPath.section) 
	{
		case 0:
		{
			[self createTagQuickAddCell:cell];
		}
			break;
		case 1:
		{
			[self createPresetsCell:cell];
		}
			break;
		case 2:
		{
			TagDictionary *dict = [TagDictionary getInstance];
			
			cell.textLabel.text = [[dict.tagDict allKeys] objectAtIndex:indexPath.row];
			
			NSString *presetTag = [dict.presetTagDict objectForKey:cell.textLabel.text];
			
            if (presetTag != nil)
			{
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
            /*[[cell imageView] setImage:[UIImage imageNamed:@"checkmark.png"]];
            [cell imageView].hidden = (presetTag == nil);
            
            // tag location
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            UIButton *editTagButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            editTagButton.frame = CGRectMake(tableView.frame.size.width - 30, 0, 30, cell.frame.size.height);
            [editTagButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
            
            editTagButton.tag = cell.textLabel.text;//presetTag;
            
            [cell.contentView addSubview:editTagButton];*/
		}
			break;
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return _presetsText;
			break;
		case 2:
			return _customText;
			break;
	}
	return @"";
}

- (void)tableView:(UITableView *)tV commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSString *tag = [[dict.tagDict allKeys] objectAtIndex:indexPath.row];
		
		[dict deleteTag:tag];
		
		[tagTableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return UITableViewCellEditingStyleDelete;	
}


#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (![text isEqualToString:@""])
	{
		[[TagDictionary getInstance] addTag:text];
		
		[tagTableView reloadData];
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

#pragma mark Tag detail

- (void)editTag: (id)sender
{
    //NSLog(@"edit tag");
    UIButton *button = (UIButton*)sender;
    
	TagDetailViewController *ctrler = [[TagDetailViewController alloc] init];
	ctrler.keyStr = button.tag;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}
@end
