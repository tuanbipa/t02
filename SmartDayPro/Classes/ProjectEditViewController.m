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
#import "CommentViewController.h"

#import "AbstractSDViewController.h"
#import "iPadViewController.h"
#import "PlannerBottomDayCal.h"

extern BOOL _transparentHintShown;

extern AbstractSDViewController *_abstractViewCtrler;
extern iPadViewController *_iPadViewCtrler;

//extern BOOL _isiPad;

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

- (void) refreshData
{
    self.projectCopy = self.project;
    
    projectNameTextField.text = self.projectCopy.name;
    
    transparentCheckButton.selected = self.projectCopy.isTransparent;
    transparentCheckButton.enabled = (self.projectCopy.status != PROJECT_STATUS_INVISIBLE);
   
    colorPaletteView.projectEdit = self.projectCopy;    
    colorPaletteView.colorId = self.projectCopy.colorId;
    
    tagInputTextField.placeholder = self.projectCopy.tag;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
    //self.projectCopy = self.project;
    
    CGRect frm = CGRectZero;
    frm.size = [Common getScreenSize];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        frm.size.height = frm.size.width - 20;
    }
    
    frm.size.width = _isiPad?384:320;
    
	mainView = [[UIScrollView alloc] initWithFrame:frm];
    //mainView.backgroundColor = [UIColor colorWithRed:209.0/255 green:212.0/255 blue:217.0/255 alpha:1];
    mainView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
	[mainView setContentSize:CGSizeMake(320, 600)];
	mainView.canCancelContentTouches = NO;
	mainView.delaysContentTouches = YES;
    
    //mainView.userInteractionEnabled = ![self.project isShared];
    
	self.view = mainView;
	[mainView release];

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
    
    //transparentCheckButton.selected = project.isTransparent;
    //transparentCheckButton.enabled = (project.status != PROJECT_STATUS_INVISIBLE);
	
	[transparentView addSubview:transparentCheckButton];
    
    UILabel *transparentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 100, 25)];
	transparentLabel.backgroundColor = [UIColor clearColor];
	transparentLabel.text = _transparentText;
    transparentLabel.font = [UIFont systemFontOfSize:16];
    transparentLabel.textColor = [UIColor grayColor];
	
	[transparentView addSubview:transparentLabel];
	[transparentLabel release];    
	
    UILabel *projectNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, frm.size.width - 20, 25)];
	projectNameLabel.backgroundColor = [UIColor clearColor];
	projectNameLabel.text = _nameText;
    projectNameLabel.font = [UIFont systemFontOfSize:16];
    projectNameLabel.textColor = [UIColor grayColor];
    
	[mainView addSubview:projectNameLabel];
	[projectNameLabel release];

    projectNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, frm.size.width - 20, 30)];
    
	//projectNameTextField.text = self.projectCopy.name;
	projectNameTextField.delegate = self;
	projectNameTextField.borderStyle = UITextBorderStyleRoundedRect;
	projectNameTextField.keyboardType=UIKeyboardTypeDefault;
	projectNameTextField.returnKeyType = UIReturnKeyDone;
	projectNameTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	projectNameTextField.tag = 0;
    [projectNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    projectNameTextField.font = [UIFont boldSystemFontOfSize:16];
    projectNameTextField.textColor = [UIColor darkGrayColor];
	
	[mainView addSubview:projectNameTextField];
	[projectNameTextField release];	
	
    UILabel *projectColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, frm.size.width - 20, 25)];
	projectColorLabel.backgroundColor = [UIColor clearColor];
	projectColorLabel.text = _colorText;
    projectColorLabel.font = [UIFont systemFontOfSize:16];
    projectColorLabel.textColor = [UIColor grayColor];
	
	[mainView addSubview:projectColorLabel];
	[projectColorLabel release];
	
    colorPaletteView = [[ProjectColorPaletteView alloc] initWithFrame:CGRectMake(10, 125, frm.size.width-20, _isiPad?170:150)];
    
    //colorPaletteView.projectEdit = self.projectCopy;
    //colorPaletteView.colorId = self.projectCopy.colorId;
    
    [mainView addSubview:colorPaletteView];
    [colorPaletteView release];
    
    CGFloat y = colorPaletteView.frame.origin.y + colorPaletteView.frame.size.height;
	
//    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 285, frm.size.width - 20, 25)];
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, frm.size.width - 20, 25)];
	tagLabel.backgroundColor = [UIColor clearColor];
	tagLabel.text = _tagText;
    tagLabel.font = [UIFont systemFontOfSize:16];
    tagLabel.textColor = [UIColor grayColor];
    
	[mainView addSubview:tagLabel];
	[tagLabel release];
    
    y += 30;

//    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(10, 315, frm.size.width - 20, 125)];
    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(10, y, frm.size.width - 20, 125)];
	tagView.backgroundColor = [UIColor whiteColor];
	
	tagView.layer.cornerRadius = 8;
	
	[mainView addSubview:tagView];
	[tagView release];
    
    y += 130;
	
	tagInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, frm.size.width - 20 - 40, 25)];
	tagInputTextField.tag = 10000;
	tagInputTextField.delegate = self;
	tagInputTextField.borderStyle = UITextBorderStyleRoundedRect;
	tagInputTextField.keyboardType = UIKeyboardTypeDefault;
	tagInputTextField.returnKeyType = UIReturnKeyDone;
	tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	//tagInputTextField.placeholder = self.projectCopy.tag;
	
	[tagView addSubview:tagInputTextField];
	[tagInputTextField release];
	
	UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	tagDetailButton.frame = CGRectMake(frm.size.width - 20 - 30, 0, 25, 25);
	[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
	[tagView addSubview:tagDetailButton];
    
    CGFloat w = (frm.size.width - 60)/3;
	
	for (int i=0; i<9; i++)
	{
		int div = i/3;
		int mod = i%3;
		
		UIButton *tagButton = [Common createButton:@"" 
										   buttonType:UIButtonTypeCustom
												frame:CGRectMake(mod*(w + 10) + 10, div*30 + 35, w, 25)
										   titleColor:[UIColor blackColor]
											   target:self 
											 selector:@selector(selectTag:) 
									 normalStateImage:@"sort_button.png"
								   selectedStateImage:nil];
		tagButton.tag = 10010+i;
		
		[tagView addSubview:tagButton];
		
		tagButtons[i] = tagButton;
	}
    
    if ([self.project isShared])
    {
//        UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(10, 450, frm.size.width - 20, 25)];
        UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(10, y, frm.size.width - 20, 25)];
        commentView.backgroundColor = [UIColor clearColor];
        [mainView addSubview:commentView];
        [commentView release];
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 200, 25)];
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.font = [UIFont systemFontOfSize:16];
        commentLabel.textColor = [UIColor grayColor];
        commentLabel.text = _conversationsText;
        
        [commentView addSubview:commentLabel];
        [commentLabel release];
        
        NSInteger commentCount = [[DBManager getInstance] countCommentsForItem:self.project.primaryKey];
        
        UILabel *commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(frm.size.width - 45 - 100, 2, 100, 25)];
        commentCountLabel.backgroundColor = [UIColor clearColor];
        commentCountLabel.textAlignment = NSTextAlignmentRight;
        commentCountLabel.font = [UIFont boldSystemFontOfSize:16];
        commentCountLabel.textColor = [UIColor darkGrayColor];
        commentCountLabel.text = [NSString stringWithFormat:@"%d", commentCount];
        
        [commentView addSubview:commentCountLabel];
        [commentCountLabel release];
        
        UIImageView *detailImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SYSTEM_VERSION_LESS_THAN(@"7.0")?@"detail_disclosure.png":@"detail_disclosure_iOS7.png"]];
        detailImgView.frame = CGRectMake(frm.size.width - 40, 2, 20, 20);
        
        [commentView addSubview:detailImgView];
        [detailImgView release];
        
		UIButton *commentButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:commentView.bounds
                                            titleColor:[UIColor blackColor]
                                                target:self
                                              selector:@selector(showConversations:)
                                      normalStateImage:nil
                                    selectedStateImage:nil];
        commentView.backgroundColor = [UIColor clearColor];
        
        [commentView addSubview:commentButton];
    }
    
//    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.bounds.size.width, 450)];
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.bounds.size.width, y)];
    maskView.backgroundColor = [UIColor clearColor];
    maskView.hidden = ![self.project isShared];
    [mainView addSubview:maskView];
    [maskView release];
    
	
    [self refreshData];

	/*
	self.navigationItem.title = _projectText;
    
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = saveButton;
    [saveButton release];*/
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
		[tagButtons[j] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
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
    
    if (self.projectCopy.primaryKey == -1)
    {
        [projectNameTextField becomeFirstResponder];
    }
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

- (void) viewDidLoad
{
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = saveButton;
    [saveButton release];
    
    //if (_isiPad)
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        
        UIButton *deleteButton = [Common createButton:@""
                                           buttonType:UIButtonTypeCustom
                                                frame:CGRectMake(0, 0, 30, 30)
                                           titleColor:[UIColor whiteColor]
                                               target:self
                                             selector:@selector(delete:)
                                     normalStateImage:@"menu_trash_white.png"
                                   selectedStateImage:nil];
        
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
        
        UIButton *copyButton = [Common createButton:@""
                                         buttonType:UIButtonTypeCustom
                                              frame:CGRectMake(0, 0, 30, 30)
                                         titleColor:[UIColor whiteColor]
                                             target:self
                                           selector:@selector(copy:)
                                   normalStateImage:@"menu_duplicate_white.png"
                                 selectedStateImage:nil];
        
        UIBarButtonItem *copyItem = [[UIBarButtonItem alloc] initWithCustomView:copyButton];
        
        UIButton *airDropButton = [Common createButton:@""
                                            buttonType:UIButtonTypeCustom
                                                 frame:CGRectMake(0, 0, 30, 30)
                                            titleColor:[UIColor whiteColor]
                                                target:self
                                              selector:@selector(share2AirDrop:)
                                      normalStateImage:@"menu_airdrop_white.png"
                                    selectedStateImage:nil];
        
        UIBarButtonItem *airDropItem = [[UIBarButtonItem alloc] initWithCustomView:airDropButton];
        
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedItem.width = 20;
        
        if ([self.project isShared])
        {
            self.navigationItem.rightBarButtonItem = airDropItem;
        }
        else
        {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:deleteItem, copyItem, airDropItem, nil];
        }
        
        [copyItem release];
        [deleteItem release];
        [fixedItem release];
        [airDropItem release];
    }
    /*else
    {
        self.navigationItem.title = _projectText;
    }*/
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
    if (!_isiPad)
    {
        [mainView setContentOffset:CGPointMake(0, 260)];
    }
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
    if (saveButton != nil)
    {
        saveButton.enabled = [self.projectCopy.name isEqualToString:@""]?NO:YES;
    }
}

- (void) close
{
    if (_isiPad)
    {
        [_iPadViewCtrler closeDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Actions

- (void) delete:(id)sender
{
    //[_iPadViewCtrler closeDetail];
    [[AbstractActionViewController getInstance] deleteCategory];
    
    [self close];
}

- (void) copy:(id)sender
{
    Project *prj = [_abstractViewCtrler copyCategory];
    
    self.project = prj;
    
    [self refreshData];
}

- (void) save:(id)sender
{
    DBManager *dbm = [DBManager getInstance];
    ProjectManager *pm = [ProjectManager getInstance];
    TaskManager *tm = [TaskManager getInstance];
    
    [projectNameTextField resignFirstResponder];
    
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
        
        CategoryViewController *ctrler = [[AbstractActionViewController getInstance] getCategoryViewController];
        
        [ctrler loadAndShowList];
    }
    else if ([self.project checkChange:self.projectCopy])
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
        
        //BOOL needRefresh = NO;
        
        if (colorChange)
        {
            [pm makeIcon:self.project];
            
            //needRefresh = YES;
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
			
            [[AbstractActionViewController getInstance] refreshData];
			
			[dt release];
		}
        else if (transparentChange)
        {
            [tm scheduleTasks];
        }
        
        if (tagChange && tm.filterData != nil)
        {
            [[AbstractActionViewController getInstance] resetAllData];
        }
        else if (colorChange)
        {
            [[AbstractActionViewController getInstance] setNeedsDisplay];
        }
        else if (transparentChange)
        {
            AbstractActionViewController *actionController = [AbstractActionViewController getInstance];
            
            CategoryViewController *ctrler = [actionController getCategoryViewController];
            
            [ctrler setNeedsDisplay];
            
            //CalendarViewController *calCtrler = [_abstractViewCtrler getCalendarViewController];
            
            CalendarViewController *calCtrler = [actionController getCalendarViewController];
            
            [calCtrler refreshView];
            
            PlannerBottomDayCal *plannerDayCal = (PlannerBottomDayCal*)[actionController getPlannerDayCalendarView];
            [plannerDayCal refreshLayout];
        }
        else if (nameChange)
        {
            //CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
            
            CategoryViewController *ctrler = [[AbstractActionViewController getInstance] getCategoryViewController];
            
            [ctrler setNeedsDisplay];
        }

    }
    
    if (_isiPad)
    {
        [[AbstractActionViewController getInstance] deselect];
        [_iPadViewCtrler closeDetail];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) share2AirDrop:(id) sender
{
    [_iPadViewCtrler closeDetail];
    [_abstractViewCtrler share2AirDrop];
}

- (void) showConversations:(id) sender
{
	CommentViewController *ctrler = [[CommentViewController alloc] init];
    ctrler.itemId = self.project.primaryKey;
    
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];
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
	/*if (textField.tag == 10000)
	{
		[self performSelector:@selector(scroll) withObject:nil afterDelay:.1]; 
	}*/
    
    [self scroll];
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
