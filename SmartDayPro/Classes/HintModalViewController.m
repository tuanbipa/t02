//
//  HintModalViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/16/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "HintModalViewController.h"

#import "Common.h"

#import "GuideWebView.h"

@interface HintModalViewController ()

@end

@implementation HintModalViewController

@synthesize closeEnabled;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    return self;
}

- (id) init
{
    if (self = [super init])
    {
        self.closeEnabled = NO;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    return self;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (void) closeHint: (id) sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


- (void) changeFrame:(CGRect) frm
{
    contentView.frame = frm;
    
    closeButton.frame = CGRectMake(frm.size.width-25, 25, 20, 20);
    
    frm = contentView.bounds;
    frm.origin.y = 50;
    frm.size.height -= 30;
    
    hintView.frame = frm;
}

- (void) changeOrientation:(UIInterfaceOrientation) orientation
{
    CGSize sz = [Common getScreenSize];
    sz.height += 20 + 44;
    
    CGRect frm = CGRectZero;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        frm.size.height = sz.width;
        frm.size.width = sz.height;
    }
    else
    {
        frm.size = sz;
    }
    
    frm.origin.y = 20;
    frm.size.height -= 20;
    
    [self changeFrame:frm];
}

- (void) loadView
{
    contentView = [[UIView alloc] initWithFrame:CGRectZero];
    
    contentView.backgroundColor = [Colors darkSlateGray];
    
    self.view = contentView;
    
    hintView = [[GuideWebView alloc] initWithFrame:CGRectZero];
    
    [contentView addSubview:hintView];
    [hintView release];
    
}

- (void)loadURL:(NSString *)url
{
    [hintView loadURL:url content:nil];
}

- (void)loadHTMLFile:(NSString *)fileName extension:(NSString *)fileExt
{
    [hintView loadHTMLFile:fileName extension:fileExt];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    closeButton = [Common createButton:@""
                            buttonType:UIButtonTypeCustom
                                 frame:CGRectMake(self.view.bounds.size.width-25, 5, 20, 20)
                            titleColor:[UIColor whiteColor]
                                target:self
                              selector:@selector(closeHint:)
                      normalStateImage:@"close.png"
                    selectedStateImage:nil];
    
    closeButton.hidden = !self.closeEnabled;
    
    [self.view addSubview:closeButton];
    
    [self changeOrientation:self.interfaceOrientation];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeOrientation:toInterfaceOrientation];
}

@end
