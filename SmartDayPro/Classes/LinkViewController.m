//
//  LinkViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 4/18/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "LinkViewController.h"

#import "Common.h"
#import "Task.h"
#import "DBManager.h"
#import "ProjectManager.h"
#import "TaskLinkManager.h"
#import "TaskManager.h"
#import "URLAssetManager.h"

#import "LinkSearchViewController.h"
#import "NoteDetailTableViewController.h"
#import "TaskDetailTableViewController.h"
#import "PreviewViewController.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"
#import "AbstractSDViewController.h"

#import "DetailViewController.h"

#import "iPadViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

extern iPadViewController *_iPadViewCtrler;

extern BOOL _isiPad;

@interface LinkViewController ()

@end

@implementation LinkViewController
@synthesize task;

@synthesize saveEnabled;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        self.saveEnabled = NO;
        
        self.contentSizeForViewInPopover = CGSizeMake(320,416);
    }
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) save:(id) sender
{
    [self.task updateIntoDB:[[DBManager getInstance] getDatabase]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) loadView
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
    
    UIView *contentView = [[UIView alloc] initWithFrame:frm];
    //contentView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.view = contentView;
    [contentView release];
    
    linkTableView = [[UITableView alloc] initWithFrame:contentView.bounds style:UITableViewStylePlain];
    linkTableView.backgroundColor = [UIColor clearColor];
	linkTableView.delegate = self;
	linkTableView.dataSource = self;
    linkTableView.allowsSelectionDuringEditing = YES;
	
	[contentView addSubview:linkTableView];
	[linkTableView release];    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [linkTableView reloadData]; //refresh linked information in case user has edited linked task and back
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.topViewController isKindOfClass:[DetailViewController class]])
    {
        DetailViewController *ctrler = (DetailViewController *)self.navigationController.topViewController;
        
        [ctrler.previewViewCtrler refreshData];
        
        [ctrler refreshLink];
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.saveEnabled)
    {
        UIBarButtonItem *saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                   target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) addLink:(NSInteger)destId
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    NSInteger linkId = [tlm createLink:self.task.primaryKey destId:destId destType:ASSET_ITEM];
    
    if (linkId != -1)
    {
        //edit in Category view
        self.task.links = [tlm getLinkIds4Task:task.primaryKey];
        
        [linkTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
}

- (void) deleteLinkAtIndex:(NSInteger) index
{
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    [tlm deleteLink:self.task linkIndex:index reloadLink:YES];
    
    [_abstractViewCtrler setNeedsDisplay];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link    
}

- (void) createURLLink:(NSString *)text
{
    URLAssetManager *uam = [URLAssetManager getInstance];
    TaskLinkManager *tlm = [TaskLinkManager getInstance];
    
    int urlId = [uam createURL:text];
    
    NSInteger linkId = [tlm createLink:self.task.primaryKey destId:urlId destType:ASSET_URL];
    
    if (linkId != -1)
    {
        //edit in Category view
        self.task.links = [tlm getLinkIds4Task:task.primaryKey];
        
        [linkTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; //trigger sync for Link
    }
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![text isEqualToString:@""])
    {
        if (textField.tag == -10000)
        {
            [self createURLLink:text];
            
            textField.text = @"";
        }
        else
        {
            TaskLinkManager *tlm = [TaskLinkManager getInstance];
            URLAssetManager *uam = [URLAssetManager getInstance];
            
            NSNumber *linkIdNum = [self.task.links objectAtIndex:textField.tag];
            
            NSInteger linkedId = [tlm getLinkedId4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
            
            [uam updateURL:linkedId value:text];
            
            [textField removeFromSuperview];
                        
            [linkTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:textField.tag inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return section == 0?2:self.task.links.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 1)
        return 40.0f;
    
    return 0.01f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGRect frm = tableView.bounds;
        frm.size.height = 40;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frm];
        label.backgroundColor = [UIColor clearColor];
        label.text = _assetsText;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:20];
        label.textColor = [UIColor lightGrayColor];
        
        return [label autorelease];
    }
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LinkCell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	/*else
	{
		for(UIView *view in cell.contentView.subviews)
		{
			if(view.tag >= 10000)
			{
				[view removeFromSuperview];
			}
		}		
	}*/
    
    // Configure the cell...
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor grayColor];
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = _addNewLinkText;
            }
            else if (indexPath.row == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                UITextField *urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, tableView.bounds.size.width-30, 30)];
                urlTextField.tag = -10000;
                
                urlTextField.textAlignment = NSTextAlignmentLeft;
                urlTextField.backgroundColor=[UIColor clearColor];
                urlTextField.font=[UIFont systemFontOfSize:16];
                urlTextField.textColor = [UIColor grayColor];
                
                urlTextField.placeholder=_addNewURLText;
                urlTextField.keyboardType=UIKeyboardTypeDefault;
                urlTextField.returnKeyType = UIReturnKeyDone;
                urlTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
                urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                
                urlTextField.delegate = self;
                urlTextField.text = @"";
                
                [cell.contentView addSubview:urlTextField];
                [urlTextField release];
            }
            
        }
            break;
        case 1:
        {
            TaskLinkManager * tlm = [TaskLinkManager getInstance];
            
            NSNumber *linkIdNum = [self.task.links objectAtIndex:indexPath.row];
            
            NSInteger linkedId = [tlm getLinkedId4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
            
            NSInteger linkedAssetType = [tlm getLinkedAssetType4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
            
            if (linkedAssetType == ASSET_URL)
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                URLAssetManager *uam = [URLAssetManager getInstance];
                
                cell.textLabel.text = [uam getURLValue:linkedId];
            }
            else
            {
                Task *task = [[Task alloc] initWithPrimaryKey:linkedId database:[[DBManager getInstance] getDatabase]];
                
                UIImage *img = nil;
                
                ProjectManager *pm = [ProjectManager getInstance];
                
                if ([task isEvent])
                {
                    img = [pm getEventIcon:task.project];
                }
                else if ([task isTask])
                {
                    img = [pm getTaskIcon:task.project];
                }
                else if ([task isNote])
                {
                    img = [pm getNoteIcon:task.project];
                }
                
                cell.imageView.image = img;
                
                cell.textLabel.text = task.name;
                
                [task release];            
            }
            
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete)
	{
        [self deleteLinkAtIndex:indexPath.row];
        
        [tableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    if (indexPath.section == 1)
    {
        return UITableViewCellEditingStyleDelete;	
    }
    
    return UITableViewCellEditingStyleNone;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0? @"":_assetsText;
}
*/

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
    
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        LinkSearchViewController *ctrler = [[LinkSearchViewController alloc] init];
        ctrler.excludeId = self.task.primaryKey;
        
        [self.navigationController pushViewController:ctrler animated:YES];
        [ctrler release];        
    }
    else if (indexPath.section == 1)
    {
        TaskLinkManager *tlm = [TaskLinkManager getInstance];
        
        NSNumber *linkIdNum = [self.task.links objectAtIndex:indexPath.row];
        
        NSInteger linkedId = [tlm getLinkedId4Task:self.task.primaryKey linkId:[linkIdNum intValue]];

        NSInteger linkedAssetType = [tlm getLinkedAssetType4Task:self.task.primaryKey linkId:[linkIdNum intValue]];
        
        if (linkedAssetType == ASSET_URL)
        {
            URLAssetManager *uam = [URLAssetManager getInstance];
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.textLabel.text = @"";
            
            UITextField *urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, tableView.bounds.size.width-30, 30)];
            urlTextField.tag = indexPath.row;
            
            urlTextField.textAlignment = NSTextAlignmentLeft;
            urlTextField.backgroundColor=[UIColor clearColor];
            urlTextField.font=[UIFont systemFontOfSize:18];
            
            urlTextField.keyboardType=UIKeyboardTypeDefault;
            urlTextField.returnKeyType = UIReturnKeyDone;
            urlTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
            urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            
            urlTextField.delegate = self;
            urlTextField.text = [uam getURLValue:linkedId];
            
            [cell.contentView addSubview:urlTextField];
            [urlTextField release];
            
            [urlTextField becomeFirstResponder];
            
        }
        else if (linkedAssetType == ASSET_ITEM)
        {
            Task *asset = [[Task alloc] initWithPrimaryKey:linkedId database:[[DBManager getInstance] getDatabase]];
            asset.listSource = SOURCE_NONE;//to update smart list as well when there is any change
            
            if ([asset isRE])
            {
                TaskManager *tm = [TaskManager getInstance];
                
                Task *firstInstance = [tm findRTInstance:asset fromDate:asset.startTime];
                
                asset.startTime = firstInstance.startTime;
                asset.endTime = firstInstance.endTime;
                
            }
            
            /*
            if ([task isNote])
            {
                NoteDetailTableViewController *ctrler = [[NoteDetailTableViewController alloc] init];
                
                ctrler.note = task;
                
                [self.navigationController pushViewController:ctrler animated:YES];
                [ctrler release];
            }
            else
            {
                TaskDetailTableViewController *ctrler = [[TaskDetailTableViewController alloc] init];
                
                ctrler.task = task;
                
                [self.navigationController pushViewController:ctrler animated:YES];
                [ctrler release];            
                
            }*/
            
            [_iPadViewCtrler.activeViewCtrler editItem:asset inView:nil];
        }
    }
}

@end
