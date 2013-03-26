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
        
        checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 8, 12, 12)];
        [checkView addSubview:checkImageView];
        [checkImageView release];
        
        [self refreshCheckImage];
        
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
    
}

- (void) drawText:(CGRect)rect context:(CGContextRef) ctx {
    
}

-(void)refreshCheckImage
{
    
    checkImageView.image = [[ImageManager getInstance] getImageWithName:@"markdone.png"];
}

- (void) refresh {
    
}
@end
