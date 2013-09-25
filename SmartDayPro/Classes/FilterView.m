//
//  FilterView.m
//  SmartCal
//
//  Created by Trung Nguyen on 6/23/10.
//  Copyright 2010 LCL. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "FilterView.h"

#import "Common.h"
#import "Colors.h"
#import "ProjectManager.h"
#import "FilterData.h"
#import "TaskManager.h"
#import "Project.h"
#import "Settings.h"

#import "SmartListViewController.h"
#import "CalendarViewController.h"

#import "TagDictionary.h"
#import "TagEditViewController.h"

#import "CalendarSelectionTableViewController.h"

#import "AbstractSDViewController.h"

extern SmartListViewController *_smartListViewCtrler;
extern CalendarViewController *_sc2ViewCtrler;

extern AbstractSDViewController *_abstractViewCtrler;

@implementation FilterView

@synthesize orientation;
@synthesize filterData;

- (id)initWithOrientation:(NSInteger)orientationParam
{
    CGRect frm = CGRectZero;
    
    CGSize sz = [Common getScreenSize];
    frm.size.width = (orientationParam == 0?sz.width:sz.height+44+20);
    frm.size.height = (orientationParam == 0?sz.height:sz.width-20);
    
	self.orientation = orientationParam;
	
	self.filterData = [[[FilterData alloc] init] autorelease];
	
	//CGRect frm = (orientationParam == 0?frm:CGRectMake(0, WEEKVIEW_TITLE_HEIGHT, 480, 300-WEEKVIEW_TITLE_HEIGHT));
	
	return [self initWithFrame:frm];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
		
		self.userInteractionEnabled = NO;
		self.backgroundColor = [UIColor clearColor];
				
		contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
		[contentView setContentSize:CGSizeMake(self.bounds.size.width, 460)];
		contentView.backgroundColor = [UIColor clearColor];
		contentView.hidden = YES;
		
		[self addSubview:contentView];
		[contentView release];		
		
		UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
		//backgroundView.backgroundColor = [UIColor blackColor];
		//backgroundView.alpha = 0.8;
		
		[contentView addSubview:backgroundView];
		[backgroundView release];
        
        for (int i=0; i<3; i++)
        {
            UIButton *presetButton = [Common createButton:_newPresetText 
                                            buttonType:UIButtonTypeCustom 
                                                 frame:CGRectMake(10 + 105*i, 10, 90, 30)
                                            titleColor:[UIColor grayColor]
                                                target:self
                                              selector:@selector(editPreset:) 
                                      //normalStateImage:@"gray_button.png"
                                      //selectedStateImage:@"blue_button.png"
                                      normalStateImage:nil
                                    selectedStateImage:nil];
            
            presetButton.tag = i;
            
            presetButton.layer.cornerRadius = 4;
            presetButton.layer.borderWidth = 1;
            presetButton.layer.borderColor = [[UIColor grayColor] CGColor];
            [presetButton setTitleColor:[Colors blueButton] forState:UIControlStateSelected];
            
            [contentView addSubview:presetButton];
            
            presetButtons[i] = presetButton;
        }
        
        [self refreshPresetButtonTitles];
        
        selectedPresetButton = nil;

        presetView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, 40)];
        presetView.hidden = YES;
        [contentView addSubview:presetView];
        [presetView release];
        
		UILabel *presetLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
		presetLabel.text = _presetText;
		presetLabel.backgroundColor = [UIColor clearColor];
		presetLabel.textColor = [UIColor grayColor];
		
		[presetView addSubview:presetLabel];
		[presetLabel release];   
        
        
        CGRect frm = CGRectMake(60, 10, 250, 30);
		
		presetTextField = [[UITextField alloc] initWithFrame:frm];
		presetTextField.tag = 1;
		presetTextField.borderStyle = UITextBorderStyleRoundedRect;
		presetTextField.delegate = self;
		presetTextField.keyboardType=UIKeyboardTypeDefault;
		presetTextField.returnKeyType = UIReturnKeyDone;
		
		[presetView addSubview:presetTextField];
		[presetTextField release];
        
        
        criteriaView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-80)];
        [contentView addSubview:criteriaView];
        [criteriaView release];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
		nameLabel.text = _titleText;
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor grayColor];
		
		[criteriaView addSubview:nameLabel];
		[nameLabel release];
		
		//CGRect frm = (self.orientation == 0?CGRectMake(60, 10, 250, 30):CGRectMake(60, 10, 180, 30));
        frm = CGRectMake(60, 10, 250, 30);
		
		nameTextField = [[UITextField alloc] initWithFrame:frm];
		nameTextField.tag = 2;
		nameTextField.borderStyle = UITextBorderStyleRoundedRect;
		nameTextField.delegate = self;
		nameTextField.keyboardType=UIKeyboardTypeDefault;
		nameTextField.returnKeyType = UIReturnKeyDone;
		
		[criteriaView addSubview:nameTextField];
		[nameTextField release];
		
		//frm = (self.orientation == 0?CGRectMake(10, 50, 50, 30):CGRectMake(250, 10, 50, 30));
        frm = CGRectMake(10, 50, 50, 30);
		
		UILabel *typeLabel = [[UILabel alloc] initWithFrame:frm];
		typeLabel.text = _typeText;
		typeLabel.backgroundColor = [UIColor clearColor];
		typeLabel.textColor = [UIColor grayColor];
		
		[criteriaView addSubview:typeLabel];
		[typeLabel release];

		NSInteger _taskFilterValues[3] = {0x01, 0x02, 0x04};
                
		//frm = (self.orientation == 0?CGRectMake(115, 50, 90, 30):CGRectMake(290, 10, 90, 30));
        frm = CGRectMake(60, 50, 80, 30);
		
		UIButton *eventButton=[Common createButton:_eventText 
                                        buttonType:UIButtonTypeCustom 
                                             frame:frm
                                        titleColor:[UIColor grayColor]
                                            target:self
                                          selector:@selector(changeType:) 
                                  //normalStateImage:@"gray_button.png"
                               //selectedStateImage:@"blue_button.png"
                               normalStateImage:nil
                                selectedStateImage:nil];
        
        eventButton.layer.cornerRadius = 4;
        eventButton.layer.borderWidth = 1;
        eventButton.layer.borderColor = [[UIColor grayColor] CGColor];
        [eventButton setTitleColor:[Colors blueButton] forState:UIControlStateSelected];
        
		eventButton.tag = _taskFilterValues[0];
		
		[criteriaView addSubview:eventButton];
		
		typeButtons[0] = eventButton;
		
		//frm = (self.orientation == 0?CGRectMake(215, 50, 90, 30):CGRectMake(390, 10, 90, 30));
        frm = CGRectMake(145, 50, 80, 30);
		
		UIButton *taskButton=[Common createButton:_taskText
                                       buttonType:UIButtonTypeCustom 
                                            frame:frm
                                       titleColor:[UIColor grayColor]
                                           target:self
                                         selector:@selector(changeType:) 
                                 //normalStateImage:@"gray_button.png"
                              //selectedStateImage:@"blue_button.png"
                              normalStateImage:nil
                               selectedStateImage:nil];
        
        taskButton.layer.cornerRadius = 4;
        taskButton.layer.borderWidth = 1;
        taskButton.layer.borderColor = [[UIColor grayColor] CGColor];
        [taskButton setTitleColor:[Colors blueButton] forState:UIControlStateSelected];
        
		taskButton.tag = _taskFilterValues[1];
		
		[criteriaView addSubview:taskButton];
		
		typeButtons[1] = taskButton;

        frm = CGRectMake(230, 50, 80, 30);
		
		UIButton *noteButton = [Common createButton:_noteText
                                       buttonType:UIButtonTypeCustom 
                                            frame:frm
                                       titleColor:[UIColor grayColor]
                                           target:self
                                         selector:@selector(changeType:) 
                                 //normalStateImage:@"gray_button.png"
                              //selectedStateImage:@"blue_button.png"
                              normalStateImage:nil
                               selectedStateImage:nil];
        
        noteButton.layer.cornerRadius = 4;
        noteButton.layer.borderWidth = 1;
        noteButton.layer.borderColor = [[UIColor grayColor] CGColor];
        [noteButton setTitleColor:[Colors blueButton] forState:UIControlStateSelected];
        
		noteButton.tag = _taskFilterValues[2];
		
		[criteriaView addSubview:noteButton];
		
		typeButtons[2] = noteButton;
        
        frm = CGRectMake(10, 90, 80, 30);
		
		UILabel *tagLabel = [[UILabel alloc] initWithFrame:frm];
		tagLabel.text = _tagText;
		tagLabel.backgroundColor = [UIColor clearColor];
		tagLabel.textColor = [UIColor grayColor];
		
		[criteriaView addSubview:tagLabel];
		[tagLabel release];
        
        //frm = CGRectMake(10, 160, 300, 125);
        frm = CGRectMake(10, 130, 300, 125);
		
		UIView *tagView = [[UIView alloc] initWithFrame:frm];
		tagView.backgroundColor = [UIColor whiteColor];
		tagView.layer.cornerRadius = 8;
		[criteriaView addSubview:tagView];
		[tagView release];
		
        frm = CGRectMake(5, 5, 260, 25);
		
		tagInputTextField = [[UITextField alloc] initWithFrame:frm];
		tagInputTextField.tag = 10000;
		tagInputTextField.delegate = self;
		tagInputTextField.borderStyle = UITextBorderStyleRoundedRect;
		tagInputTextField.keyboardType = UIKeyboardTypeDefault;
		tagInputTextField.returnKeyType = UIReturnKeyDone;
		tagInputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		tagInputTextField.placeholder = filterData.tag;
		
		[tagView addSubview:tagInputTextField];
		[tagInputTextField release];
		
		if (self.orientation == 0)
		{
			frm = CGRectMake(270, 5, 25, 25);
				   
			UIButton *tagDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			tagDetailButton.frame = frm;
			[tagDetailButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
			[tagView addSubview:tagDetailButton];
						
			for (int i=0; i<9; i++)
			{
				int div = i/3;
				int mod = i%3;
				
				frm = CGRectMake(mod*100 + 5, div*30 + 35, 90, 25);

				UIButton *tagButton = [Common createButton:@"" 
									   buttonType:UIButtonTypeCustom
													 frame:frm
												titleColor:[UIColor blackColor]
													target:self 
												  selector:@selector(selectTag:) 
										  normalStateImage:@"sort_button.png"
										selectedStateImage:nil];
				tagButton.tag = 10010+i;
				
				[tagView addSubview:tagButton];
				
				tagButtons[i] = tagButton;
			}			
		}
        presetActionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, 320, 40)];
        presetActionView.hidden = YES;
        
        [contentView addSubview:presetActionView];
        [presetActionView release];
        
        frm = CGRectMake(20, 0, 80, 30);	
		
		UIButton *deleteButton = [Common createButton:_deleteText 
                                             buttonType:UIButtonTypeCustom 
                                                  frame:frm
                                             titleColor:[Colors redButton]
                                                 target:self
                                               selector:@selector(deletePreset:) 
                                       //normalStateImage:@"blue_button.png"
                                  normalStateImage:nil
                                     selectedStateImage:nil];
        
        deleteButton.layer.cornerRadius = 8;
        deleteButton.layer.borderWidth = 1;
        deleteButton.layer.borderColor = [[Colors redButton] CGColor];
		
		[presetActionView addSubview:deleteButton];
		
        frm = CGRectMake(120, 0, 80, 30);	
		
		UIButton *saveButton=[Common createButton:_saveText 
										buttonType:UIButtonTypeCustom 
											 frame:frm
										titleColor:[Colors blueButton]
											target:self
										  selector:@selector(savePreset:) 
								  //normalStateImage:@"blue_button.png"
                              normalStateImage:nil
								selectedStateImage:nil];
        
        saveButton.layer.cornerRadius = 8;
        saveButton.layer.borderWidth = 1;
        saveButton.layer.borderColor = [[Colors blueButton] CGColor];
		
		[presetActionView addSubview:saveButton];
        
        frm = CGRectMake(220, 0, 80, 30);

		UIButton *doneButton=[Common createButton:_doneText 
                                       buttonType:UIButtonTypeCustom 
                                            frame:frm
                                       titleColor:[Colors blueButton]
                                           target:self
                                         selector:@selector(donePreset:) 
                                 //normalStateImage:@"blue_button.png"
                              normalStateImage:nil
                               selectedStateImage:nil];
        
        doneButton.layer.cornerRadius = 8;
        doneButton.layer.borderWidth = 1;
        doneButton.layer.borderColor = [[Colors blueButton] CGColor];
		
		[presetActionView addSubview:doneButton];
        
        
        filterActionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        
        [contentView addSubview:filterActionView];
        [filterActionView release];
        
        frm = CGRectMake(10, 0, 100, 30);	
		
		UIButton *noFilterButton = [Common createButton:_noFilterText 
										buttonType:UIButtonTypeCustom 
											 frame:frm
										titleColor:[Colors blueButton]
											target:self
										  selector:@selector(noFilter:) 
								  //normalStateImage:@"blue_button.png"
                                    normalStateImage:nil
								selectedStateImage:nil];
        
        noFilterButton.layer.cornerRadius = 8;
        noFilterButton.layer.borderWidth = 1;
        noFilterButton.layer.borderColor = [[Colors blueButton] CGColor];
		
		[filterActionView addSubview:noFilterButton];
		
		//frm = CGRectMake(self.bounds.size.width - 100 - 10, self.bounds.size.height - barHeight - 40, 100, 30);	
        frm = CGRectMake(self.bounds.size.width - 100 - 10, 0, 100, 30);	
		
		UIButton *applyButton = [Common createButton:_applyText
										buttonType:UIButtonTypeCustom 
											 frame:frm
										titleColor:[Colors blueButton]
											target:self
										  selector:@selector(applyFilter:) 
								  //normalStateImage:@"blue_button.png"
                               normalStateImage:nil
								selectedStateImage:nil];
        
        applyButton.layer.cornerRadius = 8;
        applyButton.layer.borderWidth = 1;
        applyButton.layer.borderColor = [[Colors blueButton] CGColor];
		
		[filterActionView addSubview:applyButton];
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)update
{
	TaskManager *tm = [TaskManager getInstance];
    
    [self populateFilterData:tm.filterData];
}

-(void) reset
{
    [self populateFilterData:nil];
}

-(void)popUpView
{	
	[self update];
	
	contentView.hidden = NO;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
	
	self.userInteractionEnabled = YES;
}

-(void)popDownView
{
	contentView.hidden = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	
	[animation setType:kCATransitionReveal];
	[animation setSubtype:kCATransitionFromBottom];
	
	// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
	[animation setDuration:kTransitionDuration];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self layer] addAnimation:animation forKey:kTimerViewAnimationKey];
	
	self.userInteractionEnabled = NO;
}

- (void) scroll
{
	[contentView setContentOffset:CGPointMake(0, self.orientation == 0?100:70)];	
}

- (BOOL) checkExistingTag:(NSString *)tag
{
    NSString *allTag = filterData.tag;
    
    NSDictionary *dict = [TagDictionary getTagDict:allTag];
    
    return ([dict objectForKey:tag] != nil);
}

- (void) tagInputReset
{
	tagInputTextField.text = @"";
	tagInputTextField.placeholder = filterData.tag;
	
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
	
	[contentView setContentOffset:CGPointMake(0,0)];
}

- (void) selectTag:(id) sender
{
	UIButton *tagButton = sender;
	
	NSString *tag = tagButton.titleLabel.text;
	
	if (tag != nil)
	{
        if (![self checkExistingTag:tag])
        {
            filterData.tag = [TagDictionary addTagToList:filterData.tag tag:tag];
        }
		
		[self tagInputReset];
		
        
	}	
}

-(UIViewController *)getController
{	
	if (_sc2ViewCtrler != nil)
	{
		return _sc2ViewCtrler;
	}
	else if (_smartListViewCtrler != nil)
	{
		return _smartListViewCtrler;
	}
	
	return nil;
}

- (void) editTag:(id) sender
{
	TagEditViewController *ctrler = [[TagEditViewController alloc] init];
	
	ctrler.objectEdit = filterData;

    [_abstractViewCtrler.navigationController pushViewController:ctrler animated:YES];

	[ctrler release];
}

- (void) populateFilterData:(FilterData *)dat
{
	if (dat != nil)
	{
		[self.filterData updateByFilterData:dat];
	}
	else 
	{
		[self.filterData reset];
	}
    
    presetTextField.text = self.filterData.presetName;
    nameTextField.text = self.filterData.taskName;
    tagTextField.text = self.filterData.tag;
    
 	NSInteger _taskFilterValues[3] = {0x01, 0x02, 0x04};
	
	for (int i=0; i<3; i++)
	{
		typeButtons[i].selected = NO;
		
		if (filterData.typeMask & _taskFilterValues[i])
		{
			typeButtons[i].selected = YES;
		}
	}
    
	[self tagInputReset];      
}

- (void) refreshPresetButtonTitles
{
    Settings *settings = [Settings getInstance];
    
    NSString *presetTexts[3] = {_newPresetText, _newPresetText, _newPresetText};
    
    NSEnumerator *keyEnum = settings.filterPresets.keyEnumerator;
    
    NSNumber *key;
    
    while ((key = [keyEnum nextObject]) != nil)
    {
        NSDictionary *dict = [settings.filterPresets objectForKey:key];
        
        presetTexts[[key intValue]] = [dict objectForKey:@"Preset"];
    }
    
    for (int i=0; i<3; i++)
    {
        [presetButtons[i] setTitle:presetTexts[i] forState:UIControlStateNormal];
        [presetButtons[i] setTitle:presetTexts[i] forState:UIControlStateSelected];
    }
}

/*
- (void) refreshFilterCategories
{
    int count = 0;
    
    if (![self.filterData.categories isEqualToString:@""])
    {
        NSArray *parts = [self.filterData.categories componentsSeparatedByString:@","];
        
        count = parts.count;
    }
    else
    {
        NSArray *visibleList = [[ProjectManager getInstance] getVisibleProjectList];
        
        count = visibleList.count;
    }
    
    categoryCountLabel.text = [NSString stringWithFormat:@"%d categories", count];    
}
*/

#pragma mark Actions
- (void) editPreset:(id) sender
{
    UIButton *button = (UIButton *) sender;
    
    BOOL editPreset = YES;
    
    if (selectedPresetButton != nil)
    {
        selectedPresetButton.selected = NO;
        
        if (selectedPresetButton == button)
        {
            editPreset = NO;
        }

        selectedPresetButton = nil;
    }

    if (editPreset)
    {
        selectedPresetButton = button;
        
        selectedPresetButton.selected = YES;
        
        Settings *settings = [Settings getInstance];
        
        NSString *key = [NSString stringWithFormat:@"%d", selectedPresetButton.tag];
        
        NSDictionary *presetDict = [settings.filterPresets objectForKey:key];
        
        if (presetDict != nil)
        {
            FilterData *dat = [FilterData fromDictionary:presetDict];
            [self populateFilterData:dat];
        }
        else 
        {
            [self populateFilterData:nil];
        }
    }
    else 
    {
        [self reset]; //reset Global Filter
    }
    
    presetView.hidden = !editPreset;
    
    presetActionView.hidden = !editPreset;
    
    filterActionView.hidden = editPreset;
    
    //CGRect frm = CGRectMake(0, editPreset?80:40, self.bounds.size.width, self.bounds.size.height-editPreset?120:80);
    
    CGRect frm = CGRectMake(0, editPreset?80:40, self.bounds.size.width, self.bounds.size.height);
    
    criteriaView.frame = frm;
}

- (void) deletePreset:(id) sender
{
    Settings *settings = [Settings getInstance];

    /*
    if (settings.filterPresets.count > 0 && selectedPresetButton.tag < settings.filterPresets.count)
    {
        [settings.filterPresets removeObjectAtIndex:selectedPresetButton.tag];
    }
    */
    
    //NSNumber *key = [NSNumber numberWithInt:selectedPresetButton.tag];
    NSString *key = [NSString stringWithFormat:@"%d", selectedPresetButton.tag];
    
    [settings.filterPresets removeObjectForKey:key];
    
    [settings saveFilterPresets];
    
    selectedPresetButton.selected = NO;
    
    selectedPresetButton = nil;
    
    [self populateFilterData:nil];
    
    presetView.hidden = YES;
    presetActionView.hidden = YES;
    filterActionView.hidden = NO;
    
    CGRect frm = CGRectMake(0, 40, self.bounds.size.width, 80);
    
    criteriaView.frame = frm; 
    
    [self refreshPresetButtonTitles];
}

- (void) savePreset:(id) sender
{
    if ([self.filterData.presetName isEqualToString:@""])
    {
        self.filterData.presetName = [NSString stringWithFormat:@"Preset %d", selectedPresetButton.tag + 1];
        
        presetTextField.text = self.filterData.presetName;
    }
    
    Settings *settings = [Settings getInstance];
    
    [presetButtons[selectedPresetButton.tag] setTitle:self.filterData.presetName forState:UIControlStateNormal]; 
    [presetButtons[selectedPresetButton.tag] setTitle:self.filterData.presetName forState:UIControlStateSelected];
    
    /*
    if (settings.filterPresets.count > 0 && selectedPresetButton.tag < settings.filterPresets.count)
    {
        //modify existing Preset
        NSDictionary *dict = [self.filterData toDictionary];
        
        [settings.filterPresets replaceObjectAtIndex:selectedPresetButton.tag withObject:dict];
    }
    else 
    {
        [settings.filterPresets addObject:[self.filterData toDictionary]];        
    }
    */
    
    //NSNumber *key = [NSNumber numberWithInt:selectedPresetButton.tag];
    NSString *key = [NSString stringWithFormat:@"%d", selectedPresetButton.tag];
    
    NSDictionary *presetDict = [self.filterData toDictionary];
    
    [settings.filterPresets setObject:presetDict forKey:key];
    
    [settings saveFilterPresets];
}

- (void) donePreset:(id) sender
{
/*
    selectedPresetButton.selected = NO;
    
    selectedPresetButton = nil;
    
    [self update];
    
    presetView.hidden = YES;
    
    presetActionView.hidden = YES;
    
    filterActionView.hidden = NO;
    
    CGRect frm = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-80);
    
    criteriaView.frame = frm;
*/
    
    presetView.hidden = YES;
    presetActionView.hidden = YES;
    filterActionView.hidden = NO;

    CGRect frm = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-80);
    
    criteriaView.frame = frm;

}

- (void) selectCategory:(id) sender
{
	CalendarSelectionTableViewController *ctrler = [[CalendarSelectionTableViewController alloc] init];
    
    ctrler.filterData = self.filterData;
    
    [_abstractViewCtrler.navigationController pushViewController:ctrler animated:YES];
     
	[ctrler release];			
    
}

-(void)changeType:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	NSInteger val = button.tag;
	
	if (filterData.typeMask & val)
	{
		filterData.typeMask &= ~val;
	}
	else 
	{
		filterData.typeMask |= val;
	}

	button.selected = !button.selected;
}

-(void)changeProject:(id)sender
{
	UIButton *button = (UIButton *)sender;
	
	NSInteger val = button.tag;
	
	if (filterData.projectMask & val)
	{
		filterData.projectMask &= ~val;
	}
	else 
	{
		filterData.projectMask |= val;
	}
	
	button.selected = !button.selected;
}

-(void)refresh
{
	if (_sc2ViewCtrler != nil)
	{
		[_sc2ViewCtrler refreshView];
	}
	/*else if (_landscapeViewCtrler != nil)
	{
		[_landscapeViewCtrler refreshView];
	}*/
	else if (_smartListViewCtrler != nil)
	{
		[_smartListViewCtrler refreshView];
	}
}

-(void)applyFilter:(id)sender
{
	[self popDownView];
		
	TaskManager *tm = [TaskManager getInstance];
	
	BOOL change = ![FilterData isEqual:tm.filterData toAnother:filterData];
	
	if (change)
	{		
		tm.filterData = filterData;
		
        [_abstractViewCtrler applyFilter];
	}
}

-(void)noFilter:(id)sender
{
	[self popDownView];
		
	TaskManager *tm = [TaskManager getInstance];
	
	BOOL change = ![FilterData isEqual:tm.filterData toAnother:nil];
	
	if (change)
	{		
		tm.filterData = nil;

		[filterData reset];
        
        [_abstractViewCtrler applyFilter];
	}
    
    selectedPresetButton.selected = NO;
    
    selectedPresetButton = nil;
}

#pragma mark TextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{	
	if (textField.tag == 10000)
	{
		NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		if (![text isEqualToString:@""])
		{
            if (![self checkExistingTag:text])
            {
                filterData.tag = [TagDictionary addTagToList:filterData.tag tag:text];
            }
		}
		
		[self tagInputReset];
	}
	else 
	{
		[textField resignFirstResponder];	
        
        if (textField.tag == 1)
        {
            filterData.presetName = textField.text;            
        }
        else if (textField.tag == 2)
        {
            filterData.taskName = textField.text;	
        }        
	}
	
	return YES;	
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1)
    {
        filterData.presetName = textField.text;            
    }
    else if (textField.tag == 2)
    {
        filterData.taskName = textField.text;	
    }    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if (textField.tag == 10000)
	{
		[self performSelector:@selector(scroll) withObject:nil afterDelay:.1]; 
	}
}

/*
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (![textField.text isEqualToString:@""])
	{
        if (textField.tag == 1)
        {
            filterData.presetName = textField.text;
        }
        else if (textField.tag == 2)
        {
            filterData.taskName = textField.text;	
        }
	}
}
*/
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

- (void)dealloc {
	
	self.filterData = nil;
	
    [super dealloc];
}


@end
