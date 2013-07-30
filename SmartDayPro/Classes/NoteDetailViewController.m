//
//  NoteDetailViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 7/23/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "NoteDetailViewController.h"

#import "Common.h"
#import "Task.h"
#import "Project.h"

#import "ProjectManager.h"
#import "TagDictionary.h"

#import "ContentView.h"
#import "NoteView.h"

#import "PreviewViewController.h"
#import "LinkViewController.h"
#import "ProjectInputViewController.h"
#import "DateInputViewController.h"

#import "iPadViewController.h"

extern iPadViewController *_iPadViewCtrler;

extern BOOL _isiPad;

NoteDetailViewController *_noteDetailViewCtrler;

@implementation NoteDetailViewController

@synthesize note;
@synthesize noteCopy;
@synthesize previewViewCtrler;

@synthesize inputViewCtrler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
	if (self = [super init])
	{
        self.inputViewCtrler = nil;
        self.previewViewCtrler = nil;
	}
	
	return self;
}

- (void)dealloc
{
	self.note = nil;
	self.noteCopy = nil;
    
    self.inputViewCtrler = nil;
    self.previewViewCtrler = nil;
	
    [super dealloc];
}

-(void)changeSkin
{
    contentView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
    
    frm = CGRectInset(contentView.bounds, 5, 5);
    
    detailTableView.frame = frm;
    
    inputView.frame = CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300);
}

- (void) refreshData
{
    self.noteCopy = self.note;
    
    self.previewViewCtrler.item = self.noteCopy;
}

#pragma mark Refresh
- (void) refreshNote
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshDate
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshProject
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) refreshLink
{
    [detailTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Actions
- (void) done:(id) sender
{
    if (![self.noteCopy.name isEqualToString:@""])
    {
        [_iPadViewCtrler.activeViewCtrler updateTask:self.note withTask:self.noteCopy];
    }
    
    if (_isiPad)
    {
        [_iPadViewCtrler closeDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) delete:(id)sender
{
    if (_isiPad)
    {
        [_iPadViewCtrler.activeViewCtrler deleteNote:self.note];
        
        [_iPadViewCtrler closeDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Views

- (void) loadView
{
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frm.size.height = frm.size.width - 20;
    }
    
    frm.size.width = 384;
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    contentView.backgroundColor = [UIColor clearColor];
	
	self.view = contentView;
	[contentView release];
    
    frm = CGRectInset(contentView.bounds, 5, 5);
    
    detailTableView = [[UITableView alloc] initWithFrame:frm style:UITableViewStylePlain];
	detailTableView.delegate = self;
	detailTableView.dataSource = self;
    detailTableView.backgroundColor = [UIColor clearColor];
	
	[contentView addSubview:detailTableView];
	[detailTableView release];
    
    inputView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bounds.size.height - 300, contentView.bounds.size.width, 300)];
    inputView.hidden = YES;
    
    [contentView addSubview:inputView];
    [inputView release];
    
    self.previewViewCtrler = [[[PreviewViewController alloc] init] autorelease];
    
    [self refreshData];
    
    [self changeSkin];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    self.navigationItem.leftBarButtonItem = doneItem;
    
    [doneItem release];
    
    UIButton *deleteButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, 30, 30)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(delete:)
                                 normalStateImage:@"menu_trash.png"
                               selectedStateImage:nil];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    self.navigationItem.rightBarButtonItem = deleteItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _noteDetailViewCtrler = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _noteDetailViewCtrler = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Tag
- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            self.noteCopy.tag = [TagDictionary addTagToList:self.noteCopy.tag tag:tag];
        }
		
		[self tagInputReset];
	}
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
    
    tagInputTextField.placeholder = [self.noteCopy getCombinedTag];
	
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

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = [self.noteCopy getCombinedTag];
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

#pragma mark Edit
- (void) editDate
{
    DateInputViewController *ctrler = [[DateInputViewController alloc] initWithNibName:@"DateInputViewController" bundle:nil];
    ctrler.task = self.noteCopy;
    ctrler.dateEdit = TASK_EDIT_START;
    
    [self showInputView:ctrler];
    
    [ctrler release];
}

- (void) editProject
{
	ProjectInputViewController *ctrler = [[ProjectInputViewController alloc] init];
	ctrler.task = self.noteCopy;
	
	[self showInputView:ctrler];
	[ctrler release];    
}

- (void)editLink:(id)sender
{
	LinkViewController *ctrler = [[LinkViewController alloc] init];
    
    ctrler.task = self.noteCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
}

#pragma mark Input Views
-(void) showInputView:(UIViewController *)ctrler
{
    self.inputViewCtrler = ctrler;
    
    ctrler.view.frame = inputView.bounds;
    
    [inputView addSubview:ctrler.view];
    
    inputView.hidden = NO;
    [contentView bringSubviewToFront:inputView];
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
}

- (void) closeInputView
{
    if (self.inputViewCtrler != nil)
    {
        [self.inputViewCtrler.view removeFromSuperview];
        
        inputView.hidden = YES;
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        
        [animation setType:kCATransitionReveal];
        [animation setSubtype:kCATransitionFromBottom];
        
        // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
        [animation setDuration:kTransitionDuration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [inputView.layer addAnimation:animation forKey:kInfoViewAnimationKey];
        
        self.inputViewCtrler = nil;
    }
}

#pragma mark Cells

- (void) createNoteContentCell:(UITableViewCell *)cell
{
    CGRect frm = CGRectMake(0, 0, detailTableView.bounds.size.width, 0);
    
    frm.size.height = 400;
    
    NoteView *noteView = [[NoteView alloc] initWithFrame:frm];
    
    noteView.editEnabled = NO;
    noteView.touchEnabled = YES;
    
    noteView.note = self.noteCopy;
    
    [cell.contentView addSubview:noteView];
    [noteView release];
}

- (void) createDateCell:(UITableViewCell *)cell
{
    cell.textLabel.text = _dateText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.detailTextLabel.text = [Common getFullDateString:self.noteCopy.startTime];
}

- (void) createProjectCell:(UITableViewCell *)cell
{    
	cell.textLabel.text = _projectText;
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
	
	ProjectManager *pm = [ProjectManager getInstance];
	
	Project *prj = [pm getProjectByKey:self.noteCopy.project];
    
    cell.detailTextLabel.text = prj.name;
    cell.detailTextLabel.textColor = [Common getColorByID:prj.colorId colorIndex:0];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16];
}

- (void) createTagCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	UILabel *tagLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];

	tagLabel.text=_tagText;
	tagLabel.backgroundColor=[UIColor clearColor];
	tagLabel.font=[UIFont systemFontOfSize:16];
	tagLabel.textColor=[UIColor grayColor];
	
	[cell.contentView addSubview:tagLabel];
	[tagLabel release];
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 5, detailTableView.bounds.size.width - 60, 25)];

	tagInputTextField.textAlignment = NSTextAlignmentLeft;
	tagInputTextField.backgroundColor=[UIColor clearColor];
	tagInputTextField.textColor = [Colors darkSteelBlue];
	tagInputTextField.font=[UIFont systemFontOfSize:15];
    
	tagInputTextField.placeholder=_tagGuideText;
	tagInputTextField.keyboardType=UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
	tagInputTextField.delegate = self;
	
	[cell.contentView addSubview:tagInputTextField];
	[tagInputTextField release];
    
	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(detailTableView.bounds.size.width - 30, 0, 25, 25);

	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:tagDetailButton];
    
    CGFloat w = (detailTableView.bounds.size.width - 50)/3;
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@""
										buttonType:UIButtonTypeCustom
											 frame:CGRectMake(mod*(w + 10) + 10, div*30 + 30, w, 25)
										titleColor:[UIColor blackColor]
											target:self
										  selector:@selector(selectTag:)
								  normalStateImage:@"sort_button.png"
								selectedStateImage:nil];
		tagButton.tag = i;
		
		[cell.contentView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
    
	[self tagInputReset];
}

- (void) createLinkCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    
	UILabel *linkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 30)];

	linkLabel.text = _assetsText;
	linkLabel.backgroundColor = [UIColor clearColor];
	linkLabel.font = [UIFont systemFontOfSize:16];
	linkLabel.textColor = [UIColor grayColor];
	
	[cell.contentView addSubview:linkLabel];
	[linkLabel release];
    
    UIImageView *detailImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_disclosure.png"]];

    detailImgView.frame = CGRectMake(detailTableView.bounds.size.width - 25, 5, 20, 20);
    [cell.contentView addSubview:detailImgView];
    [detailImgView release];
    
    UIButton *linkEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGRect frm = detailTableView.bounds;
    frm.size.height = 30;
    
    linkEditButton.frame = frm;

    [linkEditButton addTarget:self action:@selector(editLink:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:linkEditButton];
        
    CGFloat h = [self tableView:detailTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    frm = self.previewViewCtrler.view.frame;
    
    frm.origin.y = 40;
    frm.size.width = detailTableView.bounds.size.width;
    frm.size.height = h - 40;
    
    [cell.contentView addSubview:self.previewViewCtrler.view];
    
    [self.previewViewCtrler changeFrame:frm];
}


#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return 400;
    }
    else if (indexPath.row == 3)
    {
        return 120;
    }
    else if (indexPath.row == 4)
    {
        CGFloat rowH = 0;
        
        for (int i=0;i<4;i++)
        {
            rowH += [self tableView:detailTableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        CGFloat h = detailTableView.bounds.size.height - rowH;
        
        return h>400?h:400;        
    }
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = @"";
	cell.textLabel.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.row)
    {
        case 0:
            [self createNoteContentCell:cell];
            break;
        case 1:
            [self createDateCell:cell];
            break;
        case 2:
            [self createProjectCell:cell];
            break;
        case 3:
            [self createTagCell:cell];
            break;
        case 4:
            [self createLinkCell:cell];
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
            [self editDate];
            break;
        case 2:
            [self editProject];
            break;
    }
}

@end
