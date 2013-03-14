//
//  TaskOutlineView.m
//  SmartCal
//
//  Created by MacBook Pro on 4/27/11.
//  Copyright 2011 LCL. All rights reserved.
//

#import "TaskOutlineView.h"

#import "Common.h"
#import "ImageManager.h"

#import "CalendarViewController.h"
#import "SmartDayViewController.h"

#import "AbstractSDViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;

@implementation TaskOutlineView

@synthesize handleFlag;

- (id)initWithFrame:(CGRect)frame {
    
	self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.	
		
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (void) changeFrame:(CGRect)frame
{
	//frame.origin.x += TASK_PAD_WIDTH;
	frame.origin.y -= 20;
	//frame.size.width -= 2*TASK_PAD_WIDTH;
	frame.size.height += 40;

	originalFrame = frame;

	self.frame = frame;
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
		
	CGContextBeginPath (ctx);
	
	CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + 20);
	CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + 20);
	CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 20);
	CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height - 20);	
	CGContextClosePath(ctx);
	
	[[UIColor yellowColor] setStroke];
						  
	CGContextSetLineWidth(ctx, 2);
	CGFloat lengths[] = {4, 2};
						  
	CGContextSetLineDash(ctx, 0, lengths, 2);
						
	CGContextStrokePath(ctx);
	
	//UIImage* handleImage = [UIImage imageNamed:@"handle.png"];
	UIImage* handleImage = [[ImageManager getInstance] getImageWithName:@"handle.png"];
	
	[handleImage drawInRect:CGRectMake((rect.origin.x + rect.size.width)/2 - 10, rect.origin.y + 10, 20, 20)];
	 
	[handleImage drawInRect:CGRectMake((rect.origin.x + rect.size.width)/2 - 10, rect.origin.y + rect.size.height - 30, 20, 20)];
	
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	handleFlag = 0;
	
	location = [[touches anyObject] locationInView:self.superview];
	
	CGPoint p = [[touches anyObject] locationInView:self];
		
	CGRect upHandleRec = CGRectMake(self.frame.size.width/2 - 20, 0, 40, 40);
	CGRect downHandleRec = CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height - 40, 40, 40);	
	
	if (CGRectContainsPoint(upHandleRec, p))
	{
		handleFlag = 1;
	}
	else if (CGRectContainsPoint(downHandleRec, p))
	{
		handleFlag = 2;
	}
	
	changedFrame = self.frame;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint p = [[touches anyObject] locationInView:self.superview];
	
	CGFloat delta = p.y - location.y;
	
	//CGRect frm = self.frame;
	CGRect frm = changedFrame;
	
	if (handleFlag == 1)
	{
		frm.origin.y += delta;
		frm.size.height -= delta;
	}
	else if (handleFlag == 2)
	{
		frm.size.height += delta;
	}
	
	changedFrame = frm;
	
	if (changedFrame.size.height > 40 + TIME_SLOT_HEIGHT/2)
	{
		CGRect frm = self.frame;

		if (handleFlag == 1)
		{
			CGFloat dy = changedFrame.origin.y - frm.origin.y;
			
			int div = (int) dy/(TIME_SLOT_HEIGHT/2);
			int mod = (int) dy%(TIME_SLOT_HEIGHT/2); 
			
			dy = div *(TIME_SLOT_HEIGHT/2);
			
			if (dy != 0)
			{
				frm.origin.y += dy;	
				frm.size.height = changedFrame.size.height + mod;
			}
		}
		else if (handleFlag == 2)
		{
			CGFloat dy = changedFrame.size.height - self.frame.size.height;
			
			int div = (int) dy/(TIME_SLOT_HEIGHT/2);
			
			dy = div *(TIME_SLOT_HEIGHT/2);
			
			frm.size.height += dy;
		}

		
		self.frame = frm;
	
		[self setNeedsDisplay];
	}
	
	location = p;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{	
    CalendarViewController *ctrler = [_abstractViewCtrler getCalendarViewController];
    
    [ctrler finishResize];
}


- (NSInteger) getResizedSegments
{
	int ret = (int) (self.frame.size.height - originalFrame.size.height)/(TIME_SLOT_HEIGHT/2);
	
	
	return ret;
}


@end
