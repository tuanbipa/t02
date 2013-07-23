//
//  TaskView.m
//  SmartCal
//
//  Created by Trung Nguyen on 5/20/10.
//  Copyright 2010 LCL. All rights reserved.
//

#import "PlanView.h"

#import "Common.h"
#import "Settings.h"
#import "Colors.h"

#import "Project.h"
#import "ProjectManager.h"
#import "ImageManager.h"
#import "DBManager.h"

#import "AbstractSDViewController.h"
#import "iPadViewController.h"

#import "CategoryViewController.h"

extern AbstractSDViewController *_abstractViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation PlanView

@synthesize listStyle;
@synthesize listType;

//@synthesize projectColorID;
@synthesize project;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		expandImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, frame.size.height/2 - 5, 10, 10)];
		
		[self addSubview:expandImageView];
		[expandImageView release];
		
		UIButton *expandButton=[Common createButton:@"" 
									   buttonType:UIButtonTypeCustom 
											frame:CGRectMake(0, 0, 30, frame.size.height)
									   titleColor:[UIColor whiteColor]
										   target:self 
										 selector:@selector(expand:) 
								 normalStateImage:nil 
							   selectedStateImage:nil];
		expandButton.backgroundColor=[UIColor clearColor];
		
		[self addSubview:expandButton];
		        
        self.listStyle = NO;
    }
    return self;	
}

- (void) dealloc
{
    self.project = nil;
    
    [super dealloc];
}

- (void) refreshExpandImage
{
	//if ([(Project *)self.tag isExpanded])
    if ([self.project isExpanded])
	{
		expandImageView.image = [[ImageManager getInstance] getImageWithName:@"arrow_down.png"];
	}
	else 
	{
		expandImageView.image = [[ImageManager getInstance] getImageWithName:@"arrow_left.png"];
	}
}

- (void) expand:(id) sender
{
	//Project *prj = (Project *)self.tag;
    
    CategoryViewController *ctrler = [_abstractViewCtrler getCategoryViewController];
    
    //[ctrler expandProject:prj];
    [ctrler expandProject:self.project];
}

- (void) enableActions:(BOOL)enable
{
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler enableCategoryActions:enable onView:self];
    }
}

- (void) singleTouch
{
    //[self enableActions:YES];
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editProject:self.project inView:self];
    }
}

- (void) doubleTouch
{
	[super doubleTouch];
	
    if (_abstractViewCtrler != nil)
    {
        [_abstractViewCtrler editProject:self.project inView:self];
    }
}

- (void) drawHand:(CGRect)rect context:(CGContextRef) ctx
{
    UIImage *flagImage = [[ImageManager getInstance] getImageWithName:@"assign.png"];
    
    [flagImage drawInRect:rect];
}

- (void) drawText:(CGRect)rect context:(CGContextRef) ctx
{
	//Project *plan = (Project *)self.tag;
    Project *plan = self.project;
    
    //NSString *name = [NSString stringWithFormat:@"%@%@", plan.source == CATEGORY_SOURCE_ICAL?@"[iOS/OSX] ":(plan.source == CATEGORY_SOURCE_SDW?@"[mySmartDay] ":@""), plan.name];
    
    //NSString *name = plan.name;
    NSString *name = [NSString stringWithFormat:@"%@%@", [plan isShared]?[NSString stringWithFormat:@"[%@] ", plan.ownerName]:@"", plan.name];
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
	
	UIColor *embossedColor = [UIColor colorWithRed:94.0/255 green:120.0/255 blue:112.0/255 alpha:1];
	UIColor *textColor = [UIColor whiteColor];
	
	UITextAlignment alignment = NSTextAlignmentLeft;
	    
	if (isSelected)
	{
		textColor = [UIColor yellowColor];
	}
    
    CGSize oneCharSize = [@"a" sizeWithFont:font];
    NSInteger lineMaxChars = floor(rect.size.width/oneCharSize.width);
    
	CGSize sz = [name sizeWithFont:font];
    
    if (name.length > lineMaxChars) //2 lines
    {
        sz.height *= 2;
    }
    
    CGRect textRec = rect;
    
    textRec.origin.y = rect.origin.y + (rect.size.height - sz.height)/2;
    
    CGRect embossedRec = CGRectOffset(textRec, 0, -1);
    
    [embossedColor set];
    [name drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];

    [textColor set];
    [name drawInRect:textRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
    
}

- (void)drawInfo:(CGRect)rect context:(CGContextRef) ctx info:(PlanInfo) info
{
	CGFloat hrs = info.totalDuration*1.0/3600;

	NSDecimalNumber *hrsNumber = [NSDecimalNumber numberWithDouble:hrs];
	NSDecimalNumberHandler *roundingStyle = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
	NSDecimalNumber *roundedNumber = [hrsNumber decimalNumberByRoundingAccordingToBehavior:roundingStyle];
	NSString *hrsStr = [roundedNumber descriptionWithLocale:[NSLocale currentLocale]];
	
	NSString *str = [NSString stringWithFormat:@"%d/%d - %@ hrs", info.doneTotal, info.total, hrsStr];
	
	[[UIColor whiteColor] set];
	
	UIFont *font = [UIFont systemFontOfSize:13];
	
	[str drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
}

- (void)drawListInfo:(CGRect)rect context:(CGContextRef) ctx info:(PlanInfo) info
{
	CGFloat hrs = info.totalDuration*1.0/3600;
	
	NSDecimalNumber *hrsNumber = [NSDecimalNumber numberWithDouble:hrs];
	NSDecimalNumberHandler *roundingStyle = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
	NSDecimalNumber *roundedNumber = [hrsNumber decimalNumberByRoundingAccordingToBehavior:roundingStyle];
	NSString *hrsStr = [roundedNumber descriptionWithLocale:[NSLocale currentLocale]];
	
	NSString *str = [NSString stringWithFormat:@"%d/%d           ", info.doneTotal, info.total, hrsStr];
	
	[[UIColor whiteColor] set];
	
	UIFont *font = [UIFont systemFontOfSize:13];
	
	[str drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
	
	//UIImage *listImage = [UIImage imageNamed:@"list_style.png"];
	UIImage *listImage = [[ImageManager getInstance] getImageWithName:@"list_style.png"];
	
	rect.origin.x += rect.size.width - 18;
	rect.size.width = 18;
	
	[listImage drawInRect:rect];
}

- (void)drawBadge:(CGRect)rect context:(CGContextRef) ctx doneTotal:(NSInteger)doneTotal total:(NSInteger)total
{
	NSString *str = [NSString stringWithFormat:@"%d/%d", doneTotal, total];
	
	UIColor *dueColor = [Colors seaGreen];
	
	if (doneTotal == 0 && total != 0)
	{
		dueColor = [Colors red];
	}
	
	[dueColor setFill];
	//CGContextFillEllipseInRect(ctx, rect);
	
	CGFloat radius = rect.size.height/2 - 1;
	
	fillRoundedRect(ctx, rect, radius, radius);
	
	rect.origin.x -= 1;
	rect.origin.y -= 1;
	rect.size.width += 2;
	rect.size.height += 2;
	
	[[UIColor whiteColor] set];
	CGContextSetLineWidth(ctx, 2);
	
	//CGContextStrokeEllipseInRect(ctx, rect);
	strokeRoundedRect(ctx, rect, radius, radius);
	
	rect.origin.x -= 1;
	rect.origin.y -= 1;
	rect.size.width += 2;
	rect.size.height += 2;	
	
	[[UIColor grayColor] set];
	
	CGContextSetLineWidth(ctx, 1);
	//CGContextStrokeEllipseInRect(ctx, rect);
	strokeRoundedRect(ctx, rect, radius, radius);
	
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	
	rect = CGRectOffset(rect, 0, 2);
	
	[[UIColor whiteColor] set];
	[str drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];		
}

- (void)drawProgress:(CGRect)rect context:(CGContextRef) ctx
{
	CGFloat xProgress = rect.origin.x + rect.size.width/2;
	CGFloat yProgress = rect.origin.y;
	
	CGContextBeginPath (ctx);
	CGContextMoveToPoint(ctx, xProgress, yProgress);
	CGContextAddLineToPoint(ctx, xProgress - 5, yProgress + 10);
	CGContextAddLineToPoint(ctx, xProgress + 5, yProgress + 10);
	CGContextClosePath(ctx);
	
	[[UIColor greenColor] setFill];
	[[UIColor greenColor] setStroke];
	CGContextDrawPath(ctx, kCGPathFillStroke);			
}

- (void) drawListStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
    //Project *plan = (Project *) self.tag;
    Project *plan = self.project;

    UIColor *color = [Common getColorByID:plan.colorId colorIndex:0];
    
    [color setFill];
    
    CGRect frm = rect;
    
    CGContextFillRect(ctx, frm);
    
    if ([plan checkTransparent])
    {
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];
        
        [color setFill];
        CGContextFillRect(ctx, frm);
    }    
    
    //frm.size.width -= PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH - 80;
    //frm.origin.x += PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH;
    
    NSString *infoStr = @"";
    
    if (self.listType == TYPE_TASK)
    {
        PlanInfo info = [plan getInfo];
        
        CGFloat hrs = info.totalDuration*1.0/3600;
        
        infoStr = [NSString stringWithFormat:@"%d/%d - %.1f hrs - %.0f%%", info.doneTotal, info.total, hrs, info.progress*100];
    }
    else 
    {
        NSInteger count = [[DBManager getInstance] countItems:self.listType inPlan:plan.primaryKey];
        
        infoStr = [NSString stringWithFormat:@"%d", count];
    }
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    CGSize sz = [infoStr sizeWithFont:font];
    sz.width += SPACE_PAD;
    
    frm.size = sz;
    frm.origin.x = rect.origin.x + rect.size.width - sz.width;
    frm.origin.y = rect.origin.y + (rect.size.height - sz.height)/2;
    
	[[UIColor whiteColor] set];
	[infoStr drawInRect:frm withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    //rect.size.width -= frm.size.width + SPACE_PAD + PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH;
    //rect.origin.x += PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH;
    
    rect.size.width -= frm.size.width + SPACE_PAD;
    
    if ([plan checkDefault]) 
    {
		frm.size.width = 20;
		frm.size.height = 20;
        
        frm.origin.x = rect.origin.x + rect.size.width - 20 - SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;                
        
        UIImage *img = [UIImage imageNamed:@"default_cate.png"];
        
        [img drawInRect:frm];
        
        rect.size.width -= 20 + SPACE_PAD;
    }  
    
    rect.origin.x += PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH;
    rect.size.width -= PLAN_EXPAND_WIDTH + PLAN_PAD_WIDTH;
    
    if ([plan isShared])
    {
        [[[Colors darkSlateGray] colorWithAlphaComponent:0.5] setFill];
        
        CGContextFillRect(ctx, self.bounds);
        
        frm.size.width = HAND_SIZE;
        frm.size.height = HAND_SIZE;
        
        frm.origin.x = rect.origin.x + SPACE_PAD/2;
        frm.origin.y = rect.origin.y + (rect.size.height-frm.size.height)/2;
        
        [self drawHand:frm context:ctx];
        
        rect.origin.x += HAND_SIZE + SPACE_PAD/2;
        rect.size.width -= HAND_SIZE + SPACE_PAD/2;
    }
    
    [self drawText:rect context:ctx];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	//Project *plan = (Project *) self.tag;
    Project *plan = self.project;
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (self.listStyle)
    {
        [self drawListStyle:rect ctx:ctx];
        
        return;
    }    
	
	CGFloat xPad = PLAN_PAD_WIDTH;
	CGFloat shadowPad = 2;
	
	CGRect bounds = CGRectOffset(rect, xPad + PLAN_EXPAND_WIDTH, shadowPad);
	bounds.size.width -= xPad*2 + PLAN_EXPAND_WIDTH - shadowPad;
	bounds.size.height -= shadowPad;
	
	[[Common getShadowColor] setFill];
	
	CGContextFillRect(ctx, bounds);
	
	UIColor *lightColor = [Common getColorByID:plan.colorId colorIndex:1];

	UIColor *dimColor = [Common getColorByID:plan.colorId colorIndex:0];
	
	const CGFloat *fstComps = CGColorGetComponents([lightColor CGColor]);	
	const CGFloat *sndComps = CGColorGetComponents([dimColor CGColor]);
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.4, 1.0 };
	
	CGFloat components[12] = { fstComps[0], fstComps[1], fstComps[2], 1.0,  // Start color
		sndComps[0], sndComps[1], sndComps[2], 1.0, sndComps[0], sndComps[1], sndComps[2], 1.0 };
	
	bounds = CGRectOffset(bounds, -shadowPad, -shadowPad);
	
	gradientRect(ctx, bounds, components, locations, num_locations);
    
    //if (plan.status == PROJECT_STATUS_TRANSPARENT)
    if (plan.isTransparent)
    {
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparent_pattern.png"]];
        
        [color setFill];
        CGContextFillRect(ctx, bounds);        
    }
	
	CGRect rec = CGRectZero;
	CGFloat leftWidth = 0;
	
	CGFloat badgeWidth = 120;
	CGFloat badgeHeight = 20;
	CGFloat moreButtonWidth = 30;
		
	rec = CGRectOffset(bounds, leftWidth + SPACE_PAD, SPACE_PAD);
	rec.size.height -= 2*SPACE_PAD;
	rec.size.width -= leftWidth + 2*SPACE_PAD + badgeWidth + moreButtonWidth;		
	
	[self drawText:rec context:ctx];
	
	rec = CGRectOffset(bounds, bounds.size.width - badgeWidth - moreButtonWidth + SPACE_PAD, (bounds.size.height-badgeHeight)/2);
	rec.size.height = badgeHeight;
	rec.size.width = badgeWidth - 2*SPACE_PAD;
	
	PlanInfo info = [plan getInfo];
	
	if (plan.type == TYPE_PLAN)
	{
		[self drawInfo:rec context:ctx info:info];
	}
	else 
	{
		[self drawListInfo:rec context:ctx info:info];
	}

	
	if (isSelected)
	{
		CGRect outlineRec = CGRectOffset(rect, xPad + PLAN_EXPAND_WIDTH, 1);
		outlineRec.size.width -= 2*xPad + PLAN_EXPAND_WIDTH;
		outlineRec.size.height -= 2;
		
		[[UIColor yellowColor] set];
		CGContextSetLineWidth(ctx, 3);
		
		CGContextStrokeRect(ctx, outlineRec);
	}

	CGFloat width = info.progress*bounds.size.width;
	
	rec.origin.x = bounds.origin.x + width - 5;
	rec.origin.y = bounds.origin.y + bounds.size.height - 10;
	rec.size.width = 10;
	rec.size.height = 10;
	
	[self drawProgress:rec context:ctx];
}

@end
