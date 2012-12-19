//
//  ProgressIndicatorView.m
//  SmartCal
//
//  Created by MacBook Pro on 12/13/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "ProgressIndicatorView.h"

#import "Common.h"
#import "Settings.h"

@implementation ProgressIndicatorView

@synthesize progressIndicator, progressMessage;

-(void)setFontSize:(CGFloat)size
{
    self.progressMessage.font = [UIFont boldSystemFontOfSize:size];
}

-(void)setText:(NSString*)text
{
    self.progressMessage.text = text;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		self.alpha           = 0.0;
		self.opaque          = FALSE;

		self.progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[self.progressIndicator release];						 
		
		self.progressIndicator.frame = [self rectIndicator:self.progressIndicator.frame.size];
		
		self.progressMessage = [[UILabel alloc] initWithFrame:[self rectMessage]];
		[self.progressMessage release];
		
		self.progressMessage.backgroundColor = [UIColor greenColor];		
		self.progressMessage.textColor = [UIColor whiteColor];
		self.progressMessage.textAlignment = NSTextAlignmentCenter;
		 
		[self addSubview:self.progressIndicator];
		
		[self setFontSize:19.0];
		[self setText:_loadingText];		
    }
    return self;
}

-(void)showInView:(UIView*)view
{
    self.alpha = 1.0;
    
    [view addSubview:self];
    [self.progressIndicator startAnimating];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

-(void)hide
{
    self.alpha = 0.0;
    [self.progressIndicator stopAnimating];
}

-(void)layoutSubviews
{
    const CGSize  size = self.progressIndicator.frame.size;
    
    self.progressIndicator.frame = [self rectIndicator:size];
    self.progressMessage.frame   = [self rectMessage];
}

// frame rect for the activity indicator

-(CGRect)rectIndicator:(CGSize)size
{
    const CGRect  bnds = self.bounds;
    CGRect        area = bnds;
    CGRect        rect = CGRectZero;
    
    // indicator area is upper half of the view
    area.size.height = [self rectIndicatorHeight];
    
    // indicator size is determined at construction time
    rect.size = size;
    
    // center indicator over its area, then move it down a bit
    rect = [self rectCenter:area target:rect];
    rect.origin.y += [self rectNudge];
    
    return rect;
}

// height pixels for the activity indicator

-(CGFloat)rectIndicatorHeight
{
    const CGRect bnds = self.bounds;
    return floor(bnds.size.height / 2.0);
}

// frame rect for the UILabel control

-(CGRect)rectMessage
{
    const CGRect   bnds = self.bounds;
    CGRect         area = bnds;
    //CGRect         rect = CGRectZero;
    const CGFloat  size = [self rectIndicatorHeight];
    
    // message area is lower half of the view
    area.size.height = bnds.size.height - size;
    area.size.width  = bnds.size.width;
    area.origin.y   += size;
    
/*	
    // message size
    rect.size.width  = bnds.size.width - 8.0;
    rect.size.height = self.progressMessage.font.pixelHeight;
    
    // center message over its area, then move it up a bit
    rect = [self rectCenter:area target:rect];
    rect.origin.y -= [self rectNudge];
    
    return rect;
*/
	return area;
}

// nudge the activity indicator and the text label towards the center of the
// view by this many pixels

-(CGFloat)rectNudge
{
    const CGRect bnds = self.bounds;
    return floor(bnds.size.height * 0.06);
}

-(CGPoint) pointCenter:(CGRect) rect
{
    CGPoint  cgpt = CGPointZero;
	
    cgpt.x = rect.origin.x + floor(rect.size.width  / 2.0);
    cgpt.y = rect.origin.y + floor(rect.size.height / 2.0);
	
    return cgpt;
}

-(CGRect) rectCenter:(CGRect)rect target:(CGRect) target
{
    CGPoint  cgpt = [self pointCenter:rect];
	
    target.origin.x = cgpt.x - floor(target.size.width  / 2.0);
    target.origin.y = cgpt.y - floor(target.size.height / 2.0);
	
    return target;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	if ([[Settings getInstance] skinStyle] == 0)
	{
		[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] setFill];
	}
	else 
	{
		//[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] setFill];
		[[UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.5] setFill];
	}

	fillRoundedRect(ctx, rect, 10, 10);
	
	[self.progressMessage.textColor set];
	
	[self.progressMessage.text drawInRect:CGRectMake(0, rect.size.height/2 + 10, rect.size.width, rect.size.height/2) withFont:[UIFont systemFontOfSize:18] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
}


- (void)dealloc {
	self.progressIndicator = nil;
	self.progressMessage = nil;
	
    [super dealloc];
}


@end
