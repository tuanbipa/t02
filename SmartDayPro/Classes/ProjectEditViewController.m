//
//  ColorPickerViewController.m
//  SmartPlan
//
//  Created by Huy Le on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ProjectEditViewController.h"

#import "Common.h"
#import "Project.h"
#import "ProjectManager.h"
#import "ImageManager.h"
#import "DBManager.h"
#import "TaskManager.h"
#import "Settings.h"

#import "ProjectColorPaletteView.h"
#import "MiniMonthView.h"

#import "TagDictionary.h"

#import "TagEditViewController.h"
#import "CategoryViewController.h"
#import "AbstractSDViewController.h"

extern BOOL _transparentHintShown;

extern AbstractSDViewController *_abstractViewCtrler;

extern BOOL _isiPad;

@implementation ProjectEditViewController

@synthesize project;
@synthesize projectCopy;
@synthesize settings;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
    self.projectCopy = self.project;
    
	mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	//mainView.backgroundColor = [UIColor colorWithRed:161.0/255 green:162.0/255 blue:169.0/255 alpha:1];
    mainView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
	[mainView setContentSize:CGSizeMake(320, 600)];
	mainView.canCancelContentTouches = NO;
	mainView.delaysContentTouches = YES;
	
    /*
	NSArray *segmentTextContent = [NSArray arrayWithObjects: _normalText, _listText, nil];
	UISegmentedControl *segmentedStyleControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedStyleControl.frame = CGRectMake(10, 10, 145, 30);
	[segmentedStyleControl addTarget:self action:@selector(changeProjectType:) forControlEvents:UIControlEventValueChanged];
	segmentedStyleControl.segmentedControlStyle = UISegmentedControlStylePlain;	
	segmentedStyleControl.selectedSegmentIndex = (self.projectCopy.type == TYPE_LIST?1:0);
	
	[mainView addSubview:segmentedStyleControl];
	[segmentedStyleControl release];
    */
    
    //transparentView = [[UIView alloc] initWithFrame:CGRectMake(190, 10, 130, 30)];
    transparentView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 130, 30)];
    transparentView.backgroundColor = [UIColor clearColor];
    [mainView addSubview:transparentView];
    [transparentView release];

	transparentCheckButton = [Common createButton:@"" 
										buttonType:UIButtonTypeCustom
											 //frame:CGRectMake(190, 45, 30, 30) 
                              frame:CGRectMake(0, 0, 30, 30) 
										titleColor:[UIColor whiteColor] 
											target:self 
										  selector:@selector(checkTransparent:) 
								  normalStateImage:@"Trans_CheckOff.png"
								selectedStateImage:@"Trans_CheckOn.png"];
    
    transparentCheckButton.selected = project.isTransparent;//(project.status == PROJECT_STATUS_TRANSPARENT);
    transparentCheckButton.enabled = (project.status != PROJECT_STATUS_INVISIBLE);
	
	[transparentView addSubview:transparentCheckButton];
    
	//UILabel *transparentLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 45, 100, 25)];
    UILabel *transparentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 25)];
	transparentLabel.backgroundColor = [UIColor clearColor];
	transparentLabel.text = _transparentText;
	
	[transparentView addSubview:transparentLabel];
	[transparentLabel release];    
	
	//UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 25)];
    UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 300, 25)];
	projectNameLabel.backgroundColor = [UIColor clearColor];
	projectNameLabel.text = _nameText;
	
	[mainView addSubview:projectNameLabel];
	[projectNameLabel release];

	//UITextField *projectNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 75, 300, 30)];
    UITextField *projectNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    
	projectNameTextField.text = self.projectCopy.name;
	projectNameTextField.delegate = self;
	projectNameTextField.borderStyle = UITextBorderStyleRoundedRect;
	projectNameTextField.keyboardType=UIKeyboardTypeDefault;
	projectNameTextField.returnKeyType = UIReturnKeyDone;
	projectNameTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	projectNameTextField.tag = 0;
    [projectNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	[mainView addSubview:projectNameTextField];
	[projectNameTextField release];	
	
	//UILabel *projectColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 300, 25)];
    UILabel *projectColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 25)];
	projectColorLabel.backgroundColor = [UIColor clearColor];
	projectColorLabel.text = _colorText;
	
	[mainView addSubview:projectColorLabel];
	[projectColorLabel release];
	
    ProjectColorPaletteView *colorPaletteView = [[ProjectColorPaletteView alloc] initWithFrame:CGRectMake(0, 125, 320, 160)];	
    
    colorPaletteView.projectEdit = self.projectCopy;
    
    colorPaletteView.colorId = self.projectCopy.colorId;
    
    [mainView addSubview:colorPaletteView];
    [colorPaletteView release];
	
    //UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 290, 300, 25)];
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, 300, 25)];
	tagLabel.backgroundColor = [UIColor clearColor];
	tagLabel.text = _tagText;
	
	[mainView addSubview:tagLabel];
	[tagLabel release];

    //UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(10, 320, 300, 125)];
    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(10, 315, 300, 125)];
	tagView.backgroundColor = [UIColor whiteColor];
	
	tagView.layer.cornerRadius = 8;
	
	[mainView addSubview:tagView];
	[tagView release];
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 260, 25)];
	tagInputTextField.tag = 10000;
	tagInputTextField.delegate = self;
	tagInputTextField.borderStyle = UITextBorderStyleRoundedRect;
	tagInputTextField.keyboardType = UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tagInputTextField.placeholder = self.projectCopy.tag;
	
	[tagView addSubview:tagInputTextField];
	[tagInputTextField release];
	
	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(270, 0, 25, 25);
	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[tagView addSubview:tagDetailButton];
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@"" 
										   buttonType:UIButtonTypeCustom
												frame:CGRectMake(mod*100 + 5, div*30 + 35, 90, 25)
										   titleColor:[UIColor blackColor]
											   target:self 
											 selector:@selector(selectTag:) 
									 normalStateImage:@"sort_button.png"
								   selectedStateImage:nil];
		tagButton.tag = 10010+i;
		
		[tagView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
	
	self.view = mainView;
	[mainView release];
	
	//self.navigationItem.title = _calendarText;
	self.navigationItem.title = _projectText;
    
	saveButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                               target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
    
    [self check2EnableSave];
}

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = self.projectCopy.tag;
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
	tagInputTextField.placeholder = self.projectCopy.tag;
	
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

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	[self tagInputReset];
    
    [self check2EnableSave];
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


- (void)dealloc {
    self.project = nil;
    self.projectCopy = nil;
    
    [super dealloc];
}

- (void) scroll
{
	[mainView setContentOffset:CGPointMake(0, 300)];	
}

- (void) checkTransparent:(id) sender
{
    transparentCheckButton.selected = !transparentCheckButton.selected;
    
    //self.projectCopy.status = transparentCheckButton.selected?PROJECT_STATUS_TRANSPARENT:PROJECT_STATUS_NONE;
    
    self.projectCopy.isTransparent = transparentCheckButton.selected;
    
    BOOL showHint = (transparentCheckButton.selected && [[Settings getInstance] transparentHint]);
    
    if (showHint && !_transparentHintShown)
    {
        NSString *msg = _transparentHintText;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_hintText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        
        alertView.tag = -10000;
        
        [alertView addButtonWithTitle:_dontShowText];
        
        [alertView show];
        [alertView release];
        
        _transparentHintShown = YES;
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
            self.projectCopy.tag = [TagDictionary addTagToList:self.projectCopy.tag tag:tag];
        }
		
		[self tagInputReset];
		
        //saveButton.enabled = YES;
	}	
}

- (void) editTag:(id) sender
{
	TagEditViewController *ctrler = [[TagEditViewController alloc] init];
	
	ctrler.objectEdit = self.projectCopy;
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
	
}

- (void) changeProjectType:(id) sender
{
	UISegmentedControl *segmentCtrl = sender;
	
	project.type = (segmentCtrl.selectedSegmentIndex == 0?TYPE_PLAN:TYPE_LIST);
    
    transparentView.hidden = (project.type == TYPE_LIST);
}

/*
- (void) changeProjectStatus:(id) sender
{
	UISegmentedControl *segmentCtrl = sender;
	
	project.status = (segmentCtrl.selectedSegmentIndex == 0?(transparentCheckButton.selected?PROJECT_STATUS_TRANSPARENT:PROJECT_STATUS_NONE):PROJECT_STATUS_INVISIBLE);

    transparentCheckButton.selected = (project.status == PROJECT_STATUS_INVISIBLE? NO:transparentCheckButton.selected);
    
    transparentCheckButton.enabled = (project.status != PROJECT_STATUS_INVISIBLE);
}
*/

- (void)alertView:(UIAlertView *)alertVw clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertVw.tag == -10000 && buttonIndex == 1)
	{
		[[Settings getInstance] enableTransparentHint:NO];
	}
}

- (void) check2EnableSave
{
    saveButton.enabled = [self.projectCopy isShared] || [self.projectCopy.name isEqualToString:@""]?NO:YES;
}

- (void) save:(id)sender
{
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    if ([[ProjectManager getInstance] checkExistingProjectName:self.projectCopy.name excludeProject:self.projectCopy.primaryKey])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_categoryNameExistsText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        return;
    }    
    
    if (self.project.primaryKey == -1)
    {
        [self.project updateByProject:self.projectCopy];
        
        [pm addProject:self.project];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil]; 
        
        CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
        
        [ctrler loadAndShowList];
    }
    else 
    {
        BOOL nameChange = ![self.project.name isEqualToString:self.projectCopy.name];
        BOOL typeChange = (self.project.type != self.projectCopy.type);
        BOOL tagChange = ![self.project.tag isEqualToString:self.projectCopy.tag];
        
        if (typeChange)
        {
            [pm changeProjectType:self.project type:self.projectCopy.type];
        }
                
        BOOL becomeVisible = (self.project.status == PROJECT_STATUS_INVISIBLE && self.projectCopy.status != PROJECT_STATUS_INVISIBLE); 
        
        BOOL visibilityChange = becomeVisible || (self.project.status != PROJECT_STATUS_INVISIBLE && self.projectCopy.status == PROJECT_STATUS_INVISIBLE);
        
        BOOL transparentChange = (self.project.isTransparent != self.projectCopy.isTransparent);
        
        BOOL colorChange = self.project.colorId != self.projectCopy.colorId;
        
        [self.project updateByProject:self.projectCopy];
        
        [self.project updateIntoDB:[dbm getDatabase]];
        
        BOOL needRefresh = NO;
        
        if (colorChange)
        {
            [pm makeIcon:self.project];
            
            needRefresh = YES;
        }
        
        if (self.project.primaryKey == tm.lastTaskProjectKey && self.project.status == PROJECT_STATUS_INVISIBLE)
        {
            tm.lastTaskProjectKey = [[Settings getInstance] taskDefaultProject];
        }
        
        if (becomeVisible)
        {
            [[Settings getInstance] resetToodledoSync];
        }
        
        if (nameChange || tagChange || colorChange || transparentChange)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventChangeNotification" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskChangeNotification" object:nil];            
        }
        
		if (visibilityChange)
		{
			NSDate *dt = [tm.today copy];
			
			[tm initCalendarData:dt];
            
			[tm initSmartListData];
			
            [_abstractViewCtrler.miniMonthView initCalendar:tm.today];
			
			[dt release];
		}
        else if (transparentChange)
        {
            [tm scheduleTasks];
        }
        
        if (tagChange && tm.filterData != nil)
        {
            [_abstractViewCtrler resetAllData];
        }
		else if (needRefresh)
		{
            [_abstractViewCtrler refreshView];
		}
        else if (transparentChange)
        {
            CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
            
            [ctrler refreshView];
            
            CalendarViewController *calCtrler = [_abstractViewCtrler getCalendarViewController];
            
            [calCtrler refreshView];
            
        }
        else if (nameChange)
        {
            CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
            
            [ctrler refreshView];
        }

    }
    
    [_abstractViewCtrler hidePopover];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIPickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 21;
			break;
	}
	return 0;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	if (self.projectCopy != nil && component == 0)
	{
		self.projectCopy.colorId = row;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
	return 50;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return 300;
			break;
	}
	return 0;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
	UILabel	*rowView=(UILabel*)view;
	if(!rowView){
		rowView = [[[UILabel alloc] 
					initWithFrame:CGRectMake(0, 0,
											 [self pickerView:pickerView widthForComponent:component]-6,
											 [self pickerView:pickerView rowHeightForComponent:component])] autorelease];
	}
	
	rowView.textAlignment=NSTextAlignmentCenter;
	rowView.font=[UIFont systemFontOfSize:14];
	rowView.numberOfLines=2;
	
	switch (component) {
		case 0:
		{
			rowView.backgroundColor = [Common getColorByID:row colorIndex:1];
		}
			break;
	}
	
	return rowView;
	
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //saveButton.enabled = YES;
    
    [textField resignFirstResponder];

	return YES;	
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //saveButton.enabled = NO;
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.tag == 10000)
	{
		[self performSelector:@selector(scroll) withObject:nil afterDelay:.1]; 
	}
}

- (void) textFieldDidChange:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([text isEqualToString:@""])
    {
        saveButton.enabled = NO;
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if (![text isEqualToString:@""] && textField.tag == 0)
	{
		if ([[ProjectManager getInstance] checkExistingProjectName:text excludeProject:self.projectCopy.primaryKey])
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_warningText  message:_categoryNameExistsText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
			[alertView show];
			[alertView release];	
			
			textField.text = self.projectCopy.name;
		}
		else 
		{
			self.projectCopy.name = text;
		}
	}
	else if (textField.tag == 10000) //edit tag
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
            if (![self checkExistingTag:text])
            {
                self.projectCopy.tag = [TagDictionary addTagToList:self.projectCopy.tag tag:text];
            }
		}
		
		[self tagInputReset];
	}
    
    [self check2EnableSave];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if (textField.tag == 10000)
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
