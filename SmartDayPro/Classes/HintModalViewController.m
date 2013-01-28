//
//  HintModalViewController.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 11/16/12.
//  Copyright (c) 2012 Left Coast Logic. All rights reserved.
//

#import "HintModalViewController.h"

#import "Common.h"

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
    }
    
    return self;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) closeHint: (id) sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
