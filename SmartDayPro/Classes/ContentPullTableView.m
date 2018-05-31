//
//  ContentPullTableView.m
//  SmartDayPro
//
//  Created by Left Coast Logic on 10/29/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "ContentPullTableView.h"

#import "AbstractActionViewController.h"
#import "BusyController.h"

extern BOOL _isiPad;

#define PULL_DISTANCE (_isiPad?150:100)

@implementation ContentPullTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        activityView = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleGray];
		//activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        
        activityView.frame = CGRectMake(frame.size.width/2 - 10, -40.0f, 20.0f, 20.0f);
        
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		[activityView release];
        
        arrowImage = [[UIImageView alloc] initWithFrame:
                      CGRectMake(frame.size.width/2 - 15, - 65.0f, 30.0f, 55.0f)];
		arrowImage.contentMode = UIViewContentModeScaleAspectFit;
		arrowImage.image = [UIImage imageNamed:@"pullArrow.png"];
		[arrowImage layer].transform =
        CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		[self addSubview:arrowImage];
		[arrowImage release];
        
        UIView *viewNil = [[UIView alloc] init];
        self.tableFooterView = viewNil;
        self.tableHeaderView = viewNil;
        
        //self.delegate = self;
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    activityView.frame = CGRectMake(frame.size.width/2 - 10, -40.0f, 20.0f, 20.0f);
    
    arrowImage.frame = CGRectMake(frame.size.width/2 - 15, - 65.0f, 30.0f, 55.0f);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)flipImageAnimated:(BOOL)animated
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animated ? .18 : 0.0];
	[arrowImage layer].transform = isFlipped ?
    CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
    CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
    
	isFlipped = !isFlipped;
}

- (void)toggleActivityView:(BOOL)isON
{
	if (!isON)
	{
		[activityView stopAnimating];
	}
	else
	{
		[activityView startAnimating];
	}
}

- (void) showReloadAnimationAnimated:(BOOL)animated
{
	reloading = YES;
    
    arrowImage.hidden = YES;
    
	[self toggleActivityView:YES];
    
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f,
                                                       0.0f);
		[UIView commitAnimations];
	}
	else
	{
		self.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f,
                                                       0.0f);
	}
}

- (void) finishReload
{
	reloading = NO;
    [self flipImageAnimated:NO];
    [self toggleActivityView:NO];
    
    arrowImage.hidden = NO;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
		[UIView commitAnimations];
}

- (void) reload
{
    //printf("reload\n");
    [[AbstractActionViewController getInstance] sync];
    
    [self performSelector:@selector(finishReload) withObject:nil afterDelay:1.0];
}

- (void) sync
{
    [self showReloadAnimationAnimated:YES];
    
    [self reload];
}

- (void)scrollViewWillBeginDragging
{
	if (!reloading)
	{
		checkForRefresh = YES;  //  only check offset when dragging
	}
}

- (void)scrollViewDidScroll
{
	if (reloading) return;
    
	if (checkForRefresh)
    {
		if (isFlipped && self.contentOffset.y > -PULL_DISTANCE && self.contentOffset.y < 0.0f)
        {
            //printf("2\n");
            [self flipImageAnimated:YES];
		}
        else if (!isFlipped && self.contentOffset.y < -PULL_DISTANCE)
        {
            //printf("1\n");
            [self flipImageAnimated:YES];
		}
	}
}

- (void)scrollViewDidEndDragging
{
	if (reloading) return;
    
    //printf("y: %f\n", self.contentOffset.y);
    
	if (![[BusyController getInstance] checkSyncBusy] && self.contentOffset.y <= - PULL_DISTANCE)
    {
        [self sync];
	}
    
	checkForRefresh = NO;
}


@end
