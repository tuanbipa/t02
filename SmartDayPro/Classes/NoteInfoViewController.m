//
//  NoteInfoViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 6/7/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "NoteInfoViewController.h"

#import "Common.h"
#import "Colors.h"
#import "Task.h"
#import "Project.h"

#import "ProjectManager.h"
#import "TagDictionary.h"

#import "DatePickerViewController.h"
#import "ProjectSelectionTableViewController.h"
#import "LinkViewController.h"
#import "TagEditViewController.h"

@interface NoteInfoViewController ()

@end

@implementation NoteInfoViewController

@synthesize note;

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

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    frm.size.width = 320;
    
	UIView *contentView = [[UIView alloc] initWithFrame:frm];
	contentView.backgroundColor = [UIColor clearColor];
    
    self.view = contentView;
    [contentView release];
    
	noteTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStyleGrouped];
	noteTableView.delegate = self;
	noteTableView.dataSource = self;
	
	[contentView addSubview:noteTableView];
	[noteTableView release];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:_backText style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];        
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [noteTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Actions
- (void) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Tag

/*
- (NSString *) getCombinedTag
{
    NSString *parentTag = [[ProjectManager getInstance] getProjectTagByKey:self.note.project];
    
    NSString *tag = self.note.tag;
    
    if (![parentTag isEqualToString:@""])
    {
        tag = [NSString stringWithFormat:@"%@%@", parentTag, [tag isEqualToString:@""]?@"":[NSString stringWithFormat:@",%@",tag]];
    }
    
    return tag;
}
*/
- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = [self.note getCombinedTag];
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
    
    //tagInputTextField.placeholder = self.note.tag;
    tagInputTextField.placeholder = [self.note getCombinedTag];
	
	[tagInputTextField resignFirstResponder];
	
	TagDictionary *dict = [TagDictionary getInstance];
	
	int j = 0;
	
	NSDictionary *prjDict = [ProjectManager getProjectDictionaryByName];
	
	for (NSString *tag in [dict.presetTagDict allKeys])
	{
		[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
		[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[tagButtons[j] setEnabled:YES];
		
		Project *prj = [prjDict objectForKey:tag];
		
		if (prj != nil)
		{
			NSDictionary *tagDict = [TagDictionary getTagDict:prj.tag];
			
			if ([tagDict objectForKey:tag] != nil) //Project has the tag with the same name as Project name
			{
				[tagButtons[j] setTitleColor:[Common getColorByID:prj.colorId colorIndex:0]  forState:UIControlStateNormal];
			}
		}
		
		j++;
	}
	
	for (;j<9;j++)
	{
		[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
		
		[tagButtons[j] setEnabled:NO];
	}	
}

- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            self.note.tag = [TagDictionary addTagToList:self.note.tag tag:tag];
        }
		
		[self tagInputReset];
	}		
}

#pragma mark Edit
- (void)editStart
{
	DatePickerViewController *ctrler = [[DatePickerViewController alloc] init];
	ctrler.objectEdit = self.note;
	ctrler.keyEdit = TASK_EDIT_START;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)editProject
{
	ProjectSelectionTableViewController *ctrler = [[ProjectSelectionTableViewController alloc] init];
	ctrler.objectEdit = self.note;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void)editLink
{
	LinkViewController *ctrler = [[LinkViewController alloc] init];

    ctrler.task = self.note;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
}

- (void) editTag:(id) sender
{
	TagEditViewController *ctrler = [[TagEditViewController alloc] init];
	
	ctrler.objectEdit = self.note;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];		
	
}

#pragma mark Cell Creation
- (void) createDateCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 30)];
    dateLabel.font=[UIFont systemFontOfSize:15];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [Colors darkSteelBlue];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.tag = baseTag;
    
    if (self.note.startTime != nil)
    {
        dateLabel.text = [Common getFullDateTimeString:self.note.startTime];
    }
    
    [cell.contentView addSubview:dateLabel];
    [dateLabel release];
    
    cell.textLabel.text = _dateText;
    //cell.backgroundColor = [UIColor colorWithRed:246.0/255 green:243.0/255 blue:212.0/255 alpha:1];
    
}

- (void) createProjectCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = _projectText;
	
	ProjectManager *pm = [ProjectManager getInstance];
	
	Project *prj = [pm getProjectByKey:self.note.project];
	
	UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 175, 35)];
	projectNameLabel.tag = baseTag;
	projectNameLabel.textAlignment=NSTextAlignmentRight;
	projectNameLabel.backgroundColor=[UIColor clearColor];
	projectNameLabel.font=[UIFont systemFontOfSize:15];
	
	[cell.contentView addSubview:projectNameLabel];
	[projectNameLabel release];
    
	if (prj != nil)
	{
		projectNameLabel.text = prj.name;
		projectNameLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
	}	
}

- (void) createTagCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
	UILabel *tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];
	tagLabel.tag = baseTag;
	tagLabel.text=_tagText;
	tagLabel.backgroundColor=[UIColor clearColor];
	tagLabel.font=[UIFont boldSystemFontOfSize:16];
	tagLabel.textColor=[UIColor blackColor];
	
	[cell.contentView addSubview:tagLabel];
	[tagLabel release];	
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, 220, 25)];
	tagInputTextField.tag = baseTag + 1;
	tagInputTextField.textAlignment = NSTextAlignmentLeft;
	tagInputTextField.backgroundColor = [UIColor clearColor];
	tagInputTextField.textColor = [Colors darkSteelBlue];
	tagInputTextField.font=[UIFont systemFontOfSize:15];
	tagInputTextField.text = self.note.tag;
	tagInputTextField.placeholder = _tagGuideText;
	tagInputTextField.keyboardType = UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
	tagInputTextField.delegate = self;
	
	[cell.contentView addSubview:tagInputTextField];
	[tagInputTextField release];	
    
	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(270, 0, 25, 25);
	tagDetailButton.tag = baseTag + 2;
	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:tagDetailButton];
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@"" 
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(mod*100 + 5, div*30 + 30, 90, 25)
										titleColor:[UIColor blackColor]
											target:self 
										  selector:@selector(selectTag:) 
								  normalStateImage:@"sort_button.png"
								selectedStateImage:nil];
		tagButton.tag = baseTag + 3 +i;
		
		[cell.contentView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
	
	[self tagInputReset];
}

- (void) createLinkCell:(UITableViewCell *)cell baseTag:(NSInteger)baseTag
{
    cell.textLabel.text = _linksText;
    
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(210, 5, 60, 25)];
    label.font=[UIFont systemFontOfSize:15];
	label.tag = baseTag;
	label.text = [NSString stringWithFormat:@"%d links", self.note.links.count];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [Colors darkSteelBlue];
    label.textAlignment = NSTextAlignmentRight;
    label.hidden = (self.note.primaryKey == -1);
	
	[cell.contentView addSubview:label];
	[label release];	
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 && self.note.primaryKey == -1)
    {
        return 0; //don't show Links for new Note
    }
    
    if (indexPath.row == 3) //tag
    {
        return 120;
    }
    
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    // Configure the cell...
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    switch (indexPath.row) 
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self createDateCell:cell baseTag:10000];
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self createProjectCell:cell baseTag:10010];
        }
            break;
            
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self createLinkCell:cell baseTag:11020];
        }
            break;
            
        case 3:
        {
            [self createTagCell:cell baseTag:11030];
        }
            break;
    }            
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    switch (indexPath.row) 
    {
        case 0:
        {
            [self editStart];
        }
            break;
        case 1:
        {
            [self editProject];
        }
            break;
        case 2:
        {
            [self editLink];
        }
            break;
        case 3:
        {
            [self editTag];
        }
            break;
    }
}


#pragma mark TextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.tag == 11030 + 1) //tag
	{
		[noteTableView setContentOffset:CGPointMake(0, 80)];
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![text isEqualToString:@""])
    {
        if (textField.tag == 11030 + 1)
        {
            if (![self checkExistingTag:text])
            {
                self.note.tag = [TagDictionary addTagToList:self.note.tag tag:text];
            }
            
            [self tagInputReset];
        }        
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField.tag == 11030 + 1)
	{
		NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];	
		
		TagDictionary *dict = [TagDictionary getInstance];
		
		NSArray *tags = [dict findTags:s];
		
		int j = 0;
		
		for (NSString *tag in tags)
		{
			[tagButtons[j] setTitle:tag forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:YES];
			j++;
			
			if (j == 8)
			{
				break;
			}
		}	
		
		for (;j<9;j++)
		{
			[tagButtons[j] setTitle:@"" forState:UIControlStateNormal];
			[tagButtons[j] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tagButtons[j] setEnabled:NO];
		}		
	}
	
	return YES;
}


@end
