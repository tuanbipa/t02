    //
//  ToodledoAccountViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 10/8/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "SDWAccountViewController.h"

#import "Common.h"
#import "Settings.h"
#import "SDWSync.h"
#import "ImageManager.h"
#import "DBManager.h"

#import "SettingTableViewController.h"
#import "iPadSyncSettingViewController.h"
#import "iPadSettingViewController.h"

extern iPadSettingViewController *_iPadSettingViewCtrler;

//extern BOOL _isiPad;

@implementation SDWAccountViewController

@synthesize userName;
@synthesize password;

@synthesize setting;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
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
    
    //if ([ctrler isKindOfClass:[iPadSyncSettingViewController class]])
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
    
    self.userName = setting.sdwEmail;
    self.password = setting.sdwPassword;
	
    UIView *mainView = [[UIView alloc] initWithFrame:frm];
    //mainView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    mainView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    CGFloat marginY = (_isiPad?10:0);
	
	UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, marginY+10, frm.size.width-20, 25)];
	emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textColor = [UIColor grayColor];
    emailLabel.font = [UIFont systemFontOfSize:16];
	emailLabel.text = _emailText;
	
	[mainView addSubview:emailLabel];
	[emailLabel release];
	
	emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, marginY+35, frm.size.width-20, 35)];
	emailTextField.text = self.setting.sdwEmail;
	emailTextField.delegate = self;
	emailTextField.borderStyle = UITextBorderStyleRoundedRect;
	emailTextField.keyboardType=UIKeyboardTypeDefault;
	emailTextField.returnKeyType = UIReturnKeyDone;
	emailTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	[mainView addSubview:emailTextField];
	[emailTextField release];
	
	UILabel *pwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, marginY+75, frm.size.width-20, 25)];
	pwdLabel.backgroundColor = [UIColor clearColor];
    pwdLabel.textColor = [UIColor grayColor];
    pwdLabel.font = [UIFont systemFontOfSize:16];
	pwdLabel.text = _passwordText;
	
	[mainView addSubview:pwdLabel];
	[pwdLabel release];
	
	pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, marginY+100, frm.size.width-20, 35)];
	pwdTextField.text = self.setting.sdwPassword;
	pwdTextField.secureTextEntry = YES;
	pwdTextField.delegate = self;
	pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
	pwdTextField.keyboardType=UIKeyboardTypeDefault;
	pwdTextField.returnKeyType = UIReturnKeyDone;
	pwdTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
	
	[mainView addSubview:pwdTextField];
	[pwdTextField release];
	
	UIButton *checkButton=[Common createButton:_checkValidityText
										buttonType:UIButtonTypeRoundedRect 
											 frame:CGRectMake(frm.size.width-170, marginY+150, 160, 25)
										titleColor:nil 
											target:self 
										  selector:@selector(checkValidity:) 
								  normalStateImage:nil
								selectedStateImage:nil];						   
	[checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    checkButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	
	[mainView addSubview:checkButton];
    
	UIButton *signupButton=[Common createButton:_signupText
									buttonType:UIButtonTypeRoundedRect 
                                          frame:CGRectMake(10, marginY+150, 100, 25)
									titleColor:[Colors blueButton]
										target:self 
									  selector:@selector(signup:) 
							  normalStateImage:nil
							selectedStateImage:nil];
    signupButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];

	[mainView addSubview:signupButton];
	
	self.view = mainView;
	[mainView release];
	
	self.navigationItem.title = _mySDAccountText;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.setting saveMSDAccount];

	BOOL sdwAccountChange = ![self.setting.sdwEmail isEqualToString:@""] && (![self.setting.sdwEmail isEqualToString:self.userName] || ![self.setting.sdwPassword isEqualToString:self.password]);
    
    UIViewController *topCtrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
    
    if ([topCtrler isKindOfClass:[SettingTableViewController class]])
    {
        SettingTableViewController *ctrler = (SettingTableViewController *) topCtrler;
        
        ctrler.sdwAccountChange = sdwAccountChange;
        ctrler.settingCopy.sdwVerified = self.setting.sdwVerified;
    }
    else if ([topCtrler isKindOfClass:[iPadSyncSettingViewController class]])
    {
        if (_iPadSettingViewCtrler != nil)
        {
            _iPadSettingViewCtrler.sdwAccountChange = sdwAccountChange;
            _iPadSettingViewCtrler.settingCopy.sdwVerified = self.setting.sdwVerified;
            
            [_iPadSettingViewCtrler refresh];
        }
    }
}

/*
- (void)viewWillAppear:(BOOL)animated{
	if(self.email != nil)
	{
		saveButton.enabled = YES;
	}
	else 
	{
		saveButton.enabled = NO;
	}
	
}
*/

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.userName = nil;
    self.password = nil;
	
    [super dealloc];
}

#pragma mark Actions

- (void)checkValidity:(id)sender
{
    [emailTextField resignFirstResponder];
    [pwdTextField resignFirstResponder];
    
    NSInteger errorCode = [SDWSync checkUserValidity:self.setting.sdwEmail password:self.setting.sdwPassword];
    
    self.setting.sdwVerified = (errorCode == 0);
    
    NSString *msg = (errorCode == -1004?_wifiConnectionOffText:(errorCode == 0?_sdwAccountValidText:_sdwAccountInvalidText));
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorCode == -1004? _checkValidityText:(errorCode == 0?_verifiedTitleText:_invalidAccountText) message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (void)signup:(id)sender
{
    BOOL emailValid = [Common validateEmail:emailTextField.text];
    
    if (emailValid)
    {
        NSString *errorMsg = [[SDWSync getInstance] createNewAccount:emailTextField.text passWord:pwdTextField.text];
        
        NSString *msg = (errorMsg == nil?_sdwSignupSuccessText:[NSString stringWithFormat:@"%@ %@", _sdwSignupFailedText, errorMsg]);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_signupText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alert show];
        [alert release];        
    }
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_signupText message:_emailInvalidText delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
        [alert show];
        [alert release];        
        
    } 
}

#pragma mark TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (![emailTextField.text isEqualToString:@""] && ![pwdTextField.text isEqualToString:@""])
	{
        [emailTextField resignFirstResponder];
        [pwdTextField resignFirstResponder];
	}
	else if([textField isEqual:emailTextField])
	{
		[emailTextField resignFirstResponder];
		[pwdTextField becomeFirstResponder];
	}
	else if([textField isEqual:pwdTextField])
	{
		[pwdTextField resignFirstResponder];
		[emailTextField becomeFirstResponder];
	}
	return YES;	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
	if([textField isEqual:emailTextField])
	{
		//self.email = emailTextField.text;
		self.setting.sdwEmail = emailTextField.text;
	}
	else if([textField isEqual:pwdTextField])
	{
		//self.pwd = pwdTextField.text;
		self.setting.sdwPassword = pwdTextField.text;
	}
	
/*	
	if(self.email != nil && ![self.email isEqualToString:@""])
	{
		saveButton.enabled = YES;
	}
	else 
	{
		saveButton.enabled = NO;
	}
*/	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.setting.sdwVerified = NO;
    
    return YES;
}

@end
