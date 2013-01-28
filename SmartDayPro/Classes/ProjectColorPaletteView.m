//
//  ProjectColorPaletteView.m
//  SmartCal
//
//  Created by Mac book Pro on 10/18/11.
//  Copyright (c) 2011 LCL. All rights reserved.
//

#import "ProjectColorPaletteView.h"

#import "Common.h"
#import "Project.h"

#import "HighlightView.h"

#define COLOR_CELL_PAD 5

@implementation ProjectColorPaletteView

@synthesize projectEdit;

@synthesize colorId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        highlightView = [[HighlightView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:highlightView];
        [highlightView release];
    }
    return self;
}

- (void) setColorId:(NSInteger)colorIdParam
{
    colorId = colorIdParam;
    
    [self highlightColorId:colorId];
}

- (void) highlightColorId:(NSInteger) colorId
{
    CGFloat w = self.frame.size.width/8;
    CGFloat h = self.frame.size.height/4;
    
    int div = colorId/8;
    int mod = colorId%8;
    
    CGRect frm = CGRectMake(mod*w + COLOR_CELL_PAD, div*h + COLOR_CELL_PAD, w - 2*COLOR_CELL_PAD, h - 2*COLOR_CELL_PAD);
    
    highlightView.frame = frm;
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
   
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat w = rect.size.width/8;
    CGFloat h = rect.size.height/4;
    
    UIColor *shadowColor = [Common getShadowColor];
    
    for (int i=0; i<32; i++)
    {
        int div = i/8;
        int mod = i%8;
        
        CGRect r = CGRectMake(mod*w + COLOR_CELL_PAD, div*h + COLOR_CELL_PAD, w - 2*COLOR_CELL_PAD, h - 2*COLOR_CELL_PAD);
        
        CGRect shadowR = CGRectOffset(r, 2, 2);
        
        [shadowColor setFill];
        
        CGContextFillRect(ctx, shadowR);
        
        UIColor *color = [Common getColorByID:i colorIndex:0];
        
        [color setFill];
        
        CGContextFillRect(ctx, r);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self];
    
    CGFloat w = self.frame.size.width/8;
    CGFloat h = self.frame.size.height/4;
    
    int div = location.y/h;
    int mod = location.x/w;
    
    self.colorId = div*8 + mod;
    
    if (self.projectEdit != nil)
    {
        self.projectEdit.colorId = self.colorId;
    }
}

@end
