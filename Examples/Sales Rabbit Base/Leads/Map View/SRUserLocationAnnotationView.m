//
//  SRUserLocationAnnotationView.m
//  Sales Rabbit
//
//  Created by Bryan Bryce on 1/21/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRUserLocationAnnotationView.h"
#import "AppDelegate.h"
#import "SRSalesServiceCalls.h"
#import "Constants.h"

@implementation SRUserLocationAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
   
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor blueColor] CGColor]));
    CGContextFillPath(ctx); 
    
}




@end
