//
//  PageAbstractViewController.m
//  SmartCal
//
//  Created by Left Coast Logic on 5/10/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "PageAbstractViewController.h"

#import "MovableController.h"
#import "MovableView.h"
#import "TaskView.h"
#import "PlanView.h"
#import "ContentView.h"

#import "Task.h"
#import "Project.h"

#import "AbstractSDViewController.h"
#import "DummyMovableController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@interface PageAbstractViewController ()

@end

@implementation PageAbstractViewController

@synthesize movableController;
@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setMovableContentView:(UIView *)contentView
{
    if ([movableController isKindOfClass:[DummyMovableController class]])
    {
        ((DummyMovableController *) movableController).contentView = contentView;
    }
}

- (void) deselect
{
    if (self.movableController != nil)
    {
        [self.movableController unhighlight];
    }
}

- (Task *) getSelectedTask
{
    if (self.movableController != nil && 
        self.movableController.activeMovableView != nil &&
        [self.movableController.activeMovableView isKindOfClass:[TaskView class]])
    {
        return (Task *) self.movableController.activeMovableView.tag;
    }
    
    return nil;
}

- (Project *) getSelectedCategory
{
    if (self.movableController != nil && 
        self.movableController.activeMovableView != nil &&
        [self.movableController.activeMovableView isKindOfClass:[PlanView class]])
    {
        return (Project *) self.movableController.activeMovableView.tag;
    }
    
    return nil;
}

- (MovableView *)getFirstMovableView
{
    return nil;
}

- (void) enableMultiEdit:(BOOL)enabled
{
    
}

- (void) reconcileItem:(Task *)item
{
    
}

- (void) reconcileLinks:(NSDictionary *)dict
{
}

- (void) reloadAlert4Task:(NSInteger)taskId
{
    
}

- (void) loadAndShowList
{
    
}

- (MovableView *) getMovableView4Item:(NSObject *)item
{
    return nil;
}

- (void) changeFrame:(CGRect)frm
{
    contentView.frame = frm;
}

- (void)refreshLayout
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"ctrler touch end");
    
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler deselect];
    }
    
}

@end
