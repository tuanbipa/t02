//
//  MovableView.m
//  SmartPlan
//
//  Created by Huy Le on 11/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MovableView.h"

#import "MovableController.h"

#import "Common.h"

@implementation MovableView

//@synthesize seqNo;
@synthesize movableController;
@synthesize isSelected;
@synthesize multiSelectionEnable;
@synthesize touchHoldEnable;
@synthesize isReused;
@synthesize movedDirection;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		originalFrame = frame;

		isSelected = NO;
		isMoving = NO;
		//isMovable = NO;
		isMovable = YES;
		self.touchHoldEnable = NO;
		
		self.multiSelectionEnable = NO;
		
		self.isReused = NO;
		
		/*
		UILongPressGestureRecognizer *lpHandler = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
		lpHandler.minimumPressDuration = 0.4; //seconds
		lpHandler.delegate = self;
		[self addGestureRecognizer:lpHandler];
		[lpHandler release];*/  
		
    }
    return self;
}

- (CGRect) getOriginalFrame
{
    return originalFrame;
}

- (void) changeFrame:(CGRect) frame
{
	self.frame = frame;
	originalFrame = frame;
}

- (void) doSelect:(BOOL)needSelect
{
    isSelected = needSelect;
    
    [self setNeedsDisplay];
}

/*
-(void) multiSelect:(BOOL)needSelect
{
}

- (void) doSelect:(BOOL)needSelect
{
	isSelected = needSelect;
	
	if (self.multiSelectionEnable)
	{
		[self multiSelect:needSelect];
	}
	else 
	{
		[self setNeedsDisplay];	
	}
}

-(void) showMultiSelectIndicator:(BOOL)multiEnable
{
}

-(void) startMultiSelect
{
	self.multiSelectionEnable = YES;
    
    [self setNeedsDisplay];
	
	//[self showMultiSelectIndicator:self.multiSelectionEnable];
}

-(void) finishMultiSelect
{
	self.multiSelectionEnable = NO;	
    
    [self setNeedsDisplay];
	
	//[self showMultiSelectIndicator:self.multiSelectionEnable];	
}
*/

-(void) multiSelect:(BOOL)enabled
{
	self.multiSelectionEnable = enabled;
    
    [self setNeedsDisplay];
}

- (void) beginMove:(NSSet *)touches
{
	////////printf("MovableView - beginMove\n");
	
	CGPoint p = [[touches anyObject] locationInView:self.superview];
	
	touchedOffset.x = self.center.x - p.x;
	touchedOffset.y = self.center.y - p.y;
    
    self.movedDirection = 0;
	
	if (self.movableController != nil)
	{
		//[self.movableController beginMove:self becomeSubview:NO];
		[self.movableController beginMove:self];
	}
	
	isMoving = YES;
}

- (void) enableMove:(BOOL) enable
{
	isMovable = enable;
}

-(BOOL) checkMovable:(NSSet *)touches
{
	if (isMoving)
	{
		return YES;
	}
	else if (isMovable)
	{
		[self beginMove:touches];
	}
	
	return isMovable;
}

-(CGPoint)getMovedDelta:(NSSet *)touches
{
	CGPoint location = [[touches anyObject] locationInView:self.superview];
	
	location.x += touchedOffset.x - self.center.x;
	location.y += touchedOffset.y - self.center.y;
	
	return location;
}

-(CGPoint)getTouchPoint
{
	CGPoint location;
	
	location.x = self.center.x - touchedOffset.x;
	location.y = self.center.y - touchedOffset.y;
	
	return location;
}

-(void)move:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint delta = [self getMovedDelta:touches];
    
    self.movedDirection = (delta.y == 0?0:(delta.y < 0?1:2));
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.superview];
	
	location.x += touchedOffset.x;
	location.y += touchedOffset.y;
	
	self.center = location;	
}

- (void) endMove:(BOOL)needRestoreFrame
{
	if (needRestoreFrame)
	{
		self.frame = originalFrame;
	}
}

- (void) enableActions:(BOOL)enable
{
}

- (void) singleTouch
{
	//printf("single touch\n");
	
	if (self.movableController != nil)
	{
		[self.movableController highlight:self];
        
        isSelected = !isSelected;
		
		if (!self.multiSelectionEnable)
		{
			[self enableActions:self.isSelected];
            //[self enableActions:YES];
		}
	}
}

- (void) doubleTouch
{
}

- (void) touchAndHold
{
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[super touchesBegan:touches withEvent:event];
    
	touchTime = [[NSDate date] retain];
	
/*
	UITouch *touch = [touches anyObject];
	
	NSUInteger tapCount = [touch tapCount];
	
	switch (tapCount) {
		case 0:
		case 1:
			[self performSelector:@selector(singleTouch) withObject:nil afterDelay:.6];
			break;
		case 2:
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
			[self doubleTouch];
			break;

		default:
			break;
	}	
*/
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (!isMoving)
    {
        //////printf("cancel singleTouch\n");
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
    }
    
    if (self.multiSelectionEnable)
    {
        return;
    }
    
    NSTimeInterval diff = [touchTime timeIntervalSinceNow]*(-1);
    
    //if (diff > .7 && [self checkMovable:touches])
    if (diff > .2 && [self checkMovable:touches])
    {
        if (self.movableController != nil)
        {
            [self.movableController move:touches withEvent:event];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	////////printf("touch end %s\n", [[self.tag name] UTF8String]);
    [super touchesEnded:touches withEvent:event];
	
	if (isMoving) 
	{
		[self.movableController endMove:self];
	}
	else
	{
		NSTimeInterval diff = [touchTime timeIntervalSinceNow]*(-1);
		
		if (diff > .2)
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
			
			if (self.touchHoldEnable)
			{
                //printf("touch and hold\n");
                
				[self touchAndHold];
			}
		}
        else
        {
            UITouch *touch = [touches anyObject];
            
            NSUInteger tapCount = [touch tapCount];
            
            switch (tapCount) {
                case 0:
                case 1:
                    [self performSelector:@selector(singleTouch) withObject:nil afterDelay:.4];
                    break;
                case 2:
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
                    [self doubleTouch];
                    break;
                    
                default:
                    break;
            }
        }
	}

	[touchTime release];
	
	isMoving = NO;
	//isMovable = NO; 
}

/*
-(void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer
{
	if (self.touchHoldEnable && !isMoving)
	{
		if (gestureRecognizer.state != UIGestureRecognizerStateEnded) 
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTouch) object:nil];
			
			[self touchAndHold];
		}			
	}
}
*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)dealloc {
	//[self stopTouchHoldTimer];
	
	//self.lastTouchTime = nil;
	
    [super dealloc];
}


@end
