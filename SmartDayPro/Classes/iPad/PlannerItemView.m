//
//  PlannerItemView.m
//  SmartDayPro
//
//  Created by Nguyen Van Thuc on 3/21/13.
//  Copyright (c) 2013 Left Coast Logic. All rights reserved.
//

#import "PlannerItemView.h"
#import "ImageManager.h"
#import "ProjectManager.h"
#import "Task.h"
#import "Common.h"
#import "SimpleCoreTextView.h"
#import "PlannerViewController.h"
#import "iPadViewController.h"

extern PlannerViewController *_plannerViewCtrler;
extern iPadViewController *_iPadViewCtrler;

@implementation PlannerItemView

@synthesize checkEnable;
@synthesize starEnable;
@synthesize transparent;
@synthesize listStyle;

@synthesize task;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.checkEnable = YES;
        
        checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        
        [self addSubview:checkView];
        [checkView release];
        
        checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 12, 12)];
        [checkView addSubview:checkImageView];
        [checkImageView release];
        
        //[self refreshCheckImage];
        
        self.transparent = NO;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
 	CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    
    if (self.listStyle)
    {
        [self drawListStyle:rect ctx:ctx];
    }
    else
    {
        [self drawBoxStyle:rect ctx:ctx];
    }
    
    if ([task isTask]) {
        [self refreshCheckImage];
    }
}

- (void) drawListStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
    ProjectManager *pm = [ProjectManager getInstance];
    
    UIColor *dimProjectColor = [pm getProjectColor1:task.project];
    
    if (isSelected)
    {
        CGRect frm = rect;
        
        frm.origin.x += 1;
        frm.size.width -= 2;
        frm.size.height -= 2;
        
        //[[[UIColor magentaColor] colorWithAlphaComponent:0.2] setFill];
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setFill];
        
        CGContextFillRect(ctx, frm);
    }
    
    if (task.type == TYPE_ADE)
    {
        //CGRect frm = CGRectOffset(rect, SPACE_PAD, 10);
        CGRect frm = CGRectOffset(rect, SPACE_PAD, 0);
        
        //frm.size.height -= 20;
        frm.size.height -= 2;
        frm.size.width -= 2*SPACE_PAD;
        
        [[dimProjectColor colorWithAlphaComponent:0.4] setFill];
        fillRoundedRect(ctx, frm, 5, 5);
    }
    
    UIImage *img = nil;
    
    if ([task isEvent])
    {
        img = [pm getEventIcon:task.project];
    }
    else if ([task isTask])
    {
        img = [pm getTaskIcon:task.project];
    }
    else if ([task isNote])
    {
        img = [pm getNoteIcon:task.project];
    }
    
    CGRect frm = CGRectZero;
    frm.size = img.size;
    // change size
    frm.size.width = 13;
    frm.size.height = 13;
    frm.origin.y = (rect.size.height-frm.size.height)/2;
    //frm.origin.y = SPACE_PAD;
    frm.origin.x = rect.origin.x + SPACE_PAD;
    
    [img drawInRect:frm];
    
    rect.origin.x += frm.size.width + 2*SPACE_PAD;
    rect.size.width -= frm.size.width + 2*SPACE_PAD;
    
    if (self.starEnable)
    {
        rect.size.width -= 20;
    }
    
    [self drawText:rect context:ctx];
}

- (void) drawBoxStyle:(CGRect)rect ctx:(CGContextRef)ctx
{
	UIColor *lightColor = [[ProjectManager getInstance] getProjectColor2:task.project];
	
	UIColor *dimColor = [[ProjectManager getInstance] getProjectColor1:task.project];
    
	const CGFloat *fstComps = CGColorGetComponents([lightColor CGColor]);
	const CGFloat *sndComps = CGColorGetComponents([dimColor CGColor]);
	
	size_t num_locations = 3;
	CGFloat locations[3] = { 0.0, 0.4, 1.0 };
	
	CGFloat components[12] = { fstComps[0], fstComps[1], fstComps[2], 1.0,  // Start color
		sndComps[0], sndComps[1], sndComps[2], 1.0, sndComps[0], sndComps[1], sndComps[2], 1.0 };
    
    CGRect frm = rect;
    int alterSpace = SPACE_PAD/2;
    frm.origin.x += alterSpace;
    frm.size.width -= alterSpace;
    frm.origin.y += alterSpace;
    frm.size.height -= alterSpace;
    
    gradientRect(ctx, frm, components, locations, num_locations);
    
    if (isSelected)
    {
        CGRect outlineRec = frm;
        
        outlineRec.origin.y += 1;
        outlineRec.origin.x += 1;
        
        UIColor *highlightColor = [UIColor colorWithRed:149.0/255 green:185.0/255 blue:239.0/255 alpha:1];
        
        [highlightColor setStroke];
        CGContextSetLineWidth(ctx, 2);
        
        if ([task isTask])
        {
            strokeRoundedRect(ctx, outlineRec, 5, 5);
        }
        else
        {
            CGContextStrokeRect(ctx, outlineRec);
        }
    }
    
    rect = frm;
    
    [self drawText:rect context:ctx];
}

- (void) drawText:(CGRect)rect context:(CGContextRef) ctx {
    //Task *task = (Task *)self.tag;
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    UIFont *infoFont = [UIFont fontWithName:@"Verdana-Italic" size:11];
    
    CGSize oneCharSize = [@"a" sizeWithFont:font];
    NSInteger lineMaxChars = floor(rect.size.width/oneCharSize.width);
    
    BOOL isList = self.listStyle;
    
    NSTextAlignment alignment = NSTextAlignmentLeft;
    
    UIColor *embossedColor = isList?[UIColor clearColor]:[UIColor colorWithRed:94.0/255 green:120.0/255 blue:112.0/255 alpha:1];
    UIColor *textColor = (isList?[UIColor blackColor]:[UIColor whiteColor]);
    
    NSString *infoStr = task.location;
    
    
        NSString *firstLine = infoStr;
        NSString *secondLine = nil;
        
        CGRect textRec = rect;
        textRec.origin = CGPointZero;
        
        NSString *name = [task isShared]?[NSString stringWithFormat:@"☛ %@", task.name]:task.name;
        
        SimpleCoreTextView *textView = [[SimpleCoreTextView alloc] initWithFrame:textRec];
        textView.text = name;
        textView.font = font;
        
        CGRect caretRect = [textView caretRectForIndex:name.length-1];
        
        [textView release];
        
        CGPoint endPosition = CGPointMake(rect.origin.x + caretRect.origin.x + 20, rect.origin.y + rect.size.height - caretRect.origin.y - caretRect.size.height - 2);
        
        if ((endPosition.y <= rect.size.height - 12) && ![infoStr isEqualToString:@""] ) //draw location
        {
            oneCharSize = [@"a" sizeWithFont:infoFont];
            NSInteger lineMaxChars = floor((rect.size.width - endPosition.x)/oneCharSize.width);
            
            if (infoStr.length > lineMaxChars)
            {
                int idx = lineMaxChars;
                
                firstLine = [infoStr substringToIndex:idx];
                
                NSRange range = [firstLine rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch];
                
                if (range.location != NSNotFound)
                {
                    idx = range.location;
                    
                    firstLine = [infoStr substringToIndex:idx];
                }
                
                range.location = idx;
                range.length = infoStr.length - idx;
                
                secondLine = [infoStr substringWithRange:range];
            }
        }
        
        textRec = rect;
        
        if (name.length <= lineMaxChars && secondLine == nil)
        {
            //1 line text and info -> align vertical center
            
            if (self.listStyle || [task isTask])
            {
                textRec.origin.y += (rect.size.height - oneCharSize.height)/2 - 2;
            }
            
            textRec.size.height = oneCharSize.height;
            
            endPosition.y = textRec.origin.y;
        }
        
        CGRect embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [name drawInRect:embossedRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        
        [textColor set];
        [name drawInRect:textRec withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:alignment];
        
        textRec.origin.x = endPosition.x;
        textRec.origin.y = endPosition.y;
        textRec.size = oneCharSize;
        textRec.size.width = rect.size.width - textRec.origin.x;
        
        embossedRec = CGRectOffset(textRec, 0, -1);
        
        [embossedColor set];
        [firstLine drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        [textColor set];
        [firstLine drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
        
        if (secondLine != nil)
        {
            textRec = rect;
            textRec.origin.y = endPosition.y + oneCharSize.height;
            textRec.size.height -= textRec.origin.y;
            
            if (textRec.size.height >= oneCharSize.height)
            {
                CGRect embossedRec = CGRectOffset(textRec, 0, -1);
                
                [embossedColor set];
                [secondLine drawInRect:embossedRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
                
                [textColor set];
                [secondLine drawInRect:textRec withFont:infoFont lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
            }
        }
}

-(void)refreshCheckImage
{
    
    checkImageView.image = [[ImageManager getInstance] getImageWithName:@"markdone.png"];
}

#pragma mark Touch

- (void) enableActions:(BOOL)enable
{
    [_plannerViewCtrler enableActions:enable onView:self];
}

- (void) doubleTouch
{
	[super doubleTouch];
	
    /*if (_plannerViewCtrler != nil)
    {
        [_plannerViewCtrler editItem:self.task inView:self];
    }*/
    if (_iPadViewCtrler != nil) {
        
        [_iPadViewCtrler slideView:YES];
        MovableView *activeView = [_plannerViewCtrler getActiveView4Item:self.task];
        [[AbstractActionViewController getInstance] editItem:self.task inView:activeView];
    } else {
        [_plannerViewCtrler editItem:self.task inView:self];
    }
}

- (void) singleTouch
{
    if (_iPadViewCtrler != nil)
    {
        [[AbstractActionViewController getInstance] editItem:self.task inView:self];
    } else {
        //[_plannerViewCtrler showPreview:self];
        [self enableActions:YES];
    }
}

- (void)dealloc {
    [task release];
    
    [super dealloc];
}
@end
