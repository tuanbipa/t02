    //
//  ToodledoAccountViewController.m
//  SmartCal
//
//  Created by MacBook Pro on 10/8/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "ToodledoAccountViewController.h"

#import "Common.h"
#import "Settings.h"
#import "TDClient.h"
#import "TDFetchParam.h"
#import "TDKeyParser.h"
#import "ImageManager.h"

#import "TDSyncSection.h"

#import "ToodledoSignupViewController.h"

#import "SettingTableViewController.h"
#import "ToodledoSyncViewController.h"
#import "TaskSyncViewController.h"

extern BOOL _isiPad;

@implementation ToodledoAccountViewController

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
    
    if (_isiPad)
    {
        frm.size.width = 2*frm.size.width/3;
    }
    else
    {
        frm.size.width = 320;
    }
	
    self.userName = setting.tdEmail;
    self.password = setting.tdPassword;
	

    UIView *mainView = [[UIView alloc] initWithFrame:frm];
    //mainView.backgroundColor = [UIColor colorWithRed:219.0/255 green:222.0/255 blue:227.0/255 alpha:1];
    mainView.backgroundColor = [UIColor colorWithRed:237.0/255 green:237.0/255 blue:237.0/255 alpha:1];
    
    //CGFloat marginY = (_isiPad?10:0);
    CGFloat marginY = 0;
	
	UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, marginY+10, frm.size.width-20, 25)];
	emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textColor = [UIColor grayColor];
    emailLabel.font = [UIFont systemFontOfSize:16];

	emailLabel.text = _emailText;
	
	[mainView addSubview:emailLabel];
	[emailLabel release];
	
	emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, marginY+35, frm.size.width-20, 35)];
	//emailTextField.text = self.email;
	emailTextField.text = self.setting.tdEmail;
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
	//pwdTextField.text = self.pwd;
	pwdTextField.text = self.setting.tdPassword;
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
											 frame:CGRectMake(frm.size.width/2-80, marginY+150, 160, 25)
										titleColor:nil 
											target:self 
										  selector:@selector(checkValidity:) 
								  normalStateImage:nil
								selectedStateImage:nil];						   
	[checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    checkButton.titleLabel.font=[UIFont boldSystemFontOfSize:16];
	
	[mainView addSubview:checkButton];
	
    /*
	UILabel *signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, marginY+190, frm.size.width-20, 40)];
	signupLabel.numberOfLines = 0;
	signupLabel.text = _toodledoSignupHintText;
	signupLabel.backgroundColor = [UIColor clearColor];*/

    UILabel *signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, marginY+190, frm.size.width-20, 40)];
    signupLabel.backgroundColor = [UIColor clearColor];
    signupLabel.numberOfLines = 0;
    signupLabel.text = _toodledoSignupHintText;
    signupLabel.textAlignment = NSTextAlignmentLeft;
    signupLabel.font = [UIFont systemFontOfSize:16];
    signupLabel.textColor = [Colors darkSteelBlue];
    
	[mainView addSubview:signupLabel];
	[signupLabel release];
    
	UIButton *signupButton = [Common createButton:_toodledoSignupURLText
									buttonType:UIButtonTypeCustom 
										 frame:CGRectMake(10, marginY+230, 240, 25) 
									titleColor:[UIColor blueColor] 
										target:self 
									  selector:@selector(signup:) 
							  normalStateImage:nil
							selectedStateImage:nil];
	
	//signupButton.font=[UIFont systemFontOfSize:14];
	signupButton.titleLabel.font = [UIFont systemFontOfSize:14];

	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 18, 240, 1)];
	lineView.backgroundColor = [UIColor blueColor];
	[signupButton addSubview:lineView];
	[lineView release];
	
	[mainView addSubview:signupButton];
	
	self.view = mainView;
	[mainView release];
	
	self.navigationItem.title = _toodledoAccountText;
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

- (void) viewWillDisappear:(BOOL)animated
{
    [self.setting saveToodledoAccount];
    
	BOOL accountChange = ![self.setting.tdEmail isEqualToString:@""] && (![self.setting.tdEmail isEqualToString:self.userName] || ![self.setting.tdPassword isEqualToString:self.password]);
    
    UIViewController *topCtrler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
    
/*    if ([topCtrler isKindOfClass:[ToodledoSyncViewController class]])
    {
        ToodledoSyncViewController *ctrler = (ToodledoSyncViewController *) topCtrler;
        
        ctrler.tdAccountChange = accountChange;
        ctrler.setting.tdVerified = self.setting.tdVerified;
        
        [ctrler refreshView];
    }*/
    
    if ([topCtrler isKindOfClass:[TaskSyncViewController class]])
    {
        TaskSyncViewController *ctrler = (TaskSyncViewController *) topCtrler;
        
        ctrler.tdAccountChange = accountChange;
        ctrler.setting.tdVerified = self.setting.tdVerified;
        
        [ctrler refreshView];
    }
    
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

- (void)signup:(id)sender
{
	ToodledoSignupViewController *ctrler = [[ToodledoSignupViewController alloc] init];
	
	[self.navigationController pushViewController:ctrler animated:YES];
	[ctrler release];	
}

#pragma mark Toodledo Check Validity
- (void)fetchUserId
{
	//NSString *param = [NSString stringWithFormat:@"email=%@;pass=%@", emailTextField.text, pwdTextField.text];
	
	NSString *email = emailTextField.text;
	NSString *pwd = pwdTextField.text;
	
	NSString *sig = [TDSyncSection md5:[NSString stringWithFormat:@"%@%@", email, ToodledoAppToken]];
	NSString *param = [NSString stringWithFormat:@"appid=%@;sig=%@;email=%@;pass=%@", ToodledoAppID, sig, email, pwd];
	
	[[TDClient getInstance] fetchData:[TDFetchParam fetchParamWithCommand:FETCH_USER_ID param:param] delegate:self didFinishSelector:@selector(fetchUserIdSuccess:userInfo:) didFailSelector:@selector(fetchError:) userInfo:nil];
}

- (void)fetchUserIdSuccess:(NSData *)xmlData userInfo:(NSObject *)userInfo
{
	//TDKeyParser *parser = [[[TDKeyParser alloc] init] autorelease];
	TDKeyParser *parser = [[TDKeyParser alloc] init];
	
	[parser parseXML:xmlData];
	
	if (parser.error != nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_errorText message:parser.error delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
		[alert release];	
	}
	else 
	{
		NSString *userId = parser.key;
		
		NSString *msg = _accountValidText;
		
		if ([userId isEqualToString:@"0"] || [userId isEqualToString:@"1"])
		{
			msg = _accountInvalidText;
            
            self.setting.tdVerified = NO;
		}
        else 
        {
            self.setting.tdVerified = YES;
        }
			
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_checkValidityText message:msg delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
		[alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
		[alert release];
	}
	
	[parser release];
}

- (void)fetchError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_errorText message:[error localizedDescription] delegate:self cancelButtonTitle:_okText otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
	[alert release];	
}

- (void)checkValidity:(id)sender
{
	[self fetchUserId];
    //[self performSelectorOnMainThread:@selector(fetchUserId) withObject:nil waitUntilDone:NO];
}

#pragma mark TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	if (![emailTextField.text isEqualToString:@""] && ![pwdTextField.text isEqualToString:@""])
	{
		//[self.navigationController popViewControllerAnimated:YES];
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
		self.setting.tdEmail = emailTextField.text;
	}
	else if([textField isEqual:pwdTextField])
	{
		//self.pwd = pwdTextField.text;
		self.setting.tdPassword = pwdTextField.text;
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
    self.setting.tdVerified = NO;
    
    return YES;
}

@end
