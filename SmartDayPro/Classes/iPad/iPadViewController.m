//
//  iPadSmartDayViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 12/3/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "iPadViewController.h"

#import "Common.h"
#import "ContentView.h"

#import "ImageManager.h"

#import "iPadSmartDayViewController.h"
#import "PlannerViewController.h"
#import "iPadSettingViewController.h"

extern BOOL _isiPad;

extern iPadSmartDayViewController *_iPadSDViewCtrler;

iPadViewController *_iPadViewCtrler;

@interface iPadViewController ()

@end

@implementation iPadViewController

@synthesize activeViewCtrler;

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
        _iPadViewCtrler = self;
    }
    
    return self;
}

- (void) showCategory:(id) sender
{
    [_iPadSDViewCtrler showCategory];
}

- (void) showTag:(id) sender
{
    [_iPadSDViewCtrler showTag];
}

- (void) showTimer:(id) sender
{
    [_iPadSDViewCtrler showTimer];
}

- (void) deactivateSearchBar
{
    [searchBar resignFirstResponder];
}

- (void) showMenu:(id) sender
{
    [_iPadSDViewCtrler showMenu];
}

- (UIButton *) getTimerButton
{
    return timerButton;
}

- (void) createToolbar
{
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];

	UIBarButtonItem *fixed40Item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			   target:nil
																			   action:nil];
	fixed40Item.width = 40;
	
	UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			   target:nil
																			   action:nil];
	fixedItem.width = 155;
    
	UIButton *settingButton = [Common createButton:@""
                                       buttonType:UIButtonTypeCustom
                                            frame:CGRectMake(0, 0, 40, 40)
                                       titleColor:[UIColor whiteColor]
                                           target:self
                                         selector:@selector(showMenu:)
                                 normalStateImage:@"bar_setting.png"
                               selectedStateImage:nil];
	
	UIBarButtonItem *settingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];

	UIButton *eyeButton = [Common createButton:@""
                                        buttonType:UIButtonTypeCustom
                                             frame:CGRectMake(0, 0, 40, 40)
                                        titleColor:[UIColor whiteColor]
                                            target:self
                                          selector:@selector(showCategory:)
                                  normalStateImage:@"bar_eye.png"
                                selectedStateImage:nil];
	
	UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
	UIButton *tagButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 0, 40, 40)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(showTag:)
                              normalStateImage:@"tag.png"
                            selectedStateImage:nil];
	
	UIBarButtonItem *tagButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tagButton];

	timerButton = [Common createButton:@""
                                    buttonType:UIButtonTypeCustom
                                         frame:CGRectMake(0, 0, 40, 40)
                                    titleColor:[UIColor whiteColor]
                                        target:self
                                      selector:@selector(showTimer:)
                              normalStateImage:@"bar_timer.png"
                            selectedStateImage:nil];
	
	UIBarButtonItem *timerButtonItem = [[UIBarButtonItem alloc] initWithCustomView:timerButton];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    searchBar.placeholder = _seekOrCreate;
    searchBar.translucent = YES;
    searchBar.delegate = self;

    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    [searchBar release];
	
	NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, fixedItem, timerButtonItem, flexItem, searchBarItem,nil];
	//NSArray *items = [NSArray arrayWithObjects:settingButtonItem, fixed40Item, eyeButtonItem, fixed40Item, tagButtonItem, flexItem, searchBarItem,nil];
	 
	[flexItem release];
	[fixedItem release];
    [fixed40Item release];
	[timerButtonItem release];
    [settingButtonItem release];
    [eyeButtonItem release];
    [tagButtonItem release];
    [searchBarItem release];
    
    self.navigationItem.leftBarButtonItems = items;
}

-(void)changeSkin
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        [self.navigationController.navigationBar setBackgroundImage:[[ImageManager getInstance] getImageWithName:@"top_bg.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void) dealloc
{
    self.activeViewCtrler = nil;
    
    [super dealloc];
}

#pragma mark View

- (void) showLandscapeView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }
        
    PlannerViewController *ctrler = [[PlannerViewController alloc] init];
    
    self.activeViewCtrler = ctrler;
    
    [ctrler release];
    
    [contentView addSubview:self.activeViewCtrler.view];
}

- (void) showPortraitView
{
    if (self.activeViewCtrler != nil && [self.activeViewCtrler.view superview])
    {
        [self.activeViewCtrler.view removeFromSuperview];
    }

    //iPadSmartDayViewController *ctrler = _iPadSDViewCtrler;
    
    self.activeViewCtrler = _iPadSDViewCtrler;
    
    [contentView addSubview:self.activeViewCtrler.view];    
}

- (void) loadView
{
    CGRect frm = [Common getFrame];
    
    contentView = [[ContentView alloc] initWithFrame:frm];
    
    contentView.backgroundColor = [UIColor darkGrayColor];
    
    self.view = contentView;
    
    [self showPortraitView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self changeSkin];
    [self createToolbar];
}

-(NSUInteger)supportedInterfaceOrientations
{
     return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
        
        [self showLandscapeView];
    }
    else
    {
        frm.size = sz;
        
        [self showPortraitView];
    }
    
    contentView.frame = frm;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_iPadSDViewCtrler showSeekOrCreate:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_iPadSDViewCtrler showSeekOrCreate:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}


@end
