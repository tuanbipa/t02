//
//  MenuMakerView.m
//  SmartCal
//
//  Created by Left Coast Logic on 5/21/12.
//  Copyright (c) 2012 LCL. All rights reserved.
//

#import "MenuMakerView.h"

@implementation MenuMakerView

@synthesize menuPoint;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.menuPoint = frame.origin.x + frame.size.width/2; 
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void) setMenuPoint:(NSInteger)point
{
    menuPoint = point;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    UIImage *arrow = [UIImage imageNamed:@"menu_arrow.png"];
    
    UIImage *img = [[UIImage imageNamed:@"menu.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    CGRect rec = rect;
    
    rec.origin.y += arrow.size.height;
    rec.size.height -= arrow.size.height;
    
    [img drawInRect:rec];
    
    rec = rect;
    
    rec.size = arrow.size;
    rec.origin.x += self.menuPoint - rec.size.width/2;
    
    [arrow drawInRect:rec];
}

@end
