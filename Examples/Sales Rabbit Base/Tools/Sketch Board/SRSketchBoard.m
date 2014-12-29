//
//  SRSketchBoard.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSketchBoard.h"

@implementation SRSketchBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dealloc {
    if (_paintLayer)
    {
        CGLayerRelease(_paintLayer);
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (_paintLayer == nil)
    {
        _paintLayer = CGLayerCreateWithContext(context, self.bounds.size, NULL);
    }
    CGContextDrawLayerAtPoint(context, (CGPoint){0,0}, _paintLayer);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _fingerDragged = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _fingerDragged = YES;
    UITouch *touch = [touches anyObject]; // no multitouch
    CGContextRef context = [self setupDrawingContext];
    
    CGPoint previous = [touch previousLocationInView:self];
    CGPoint current = [touch locationInView:self];
    CGContextMoveToPoint(context, previous.x, previous.y);
    CGContextAddLineToPoint(context, current.x, current.y);
    CGContextStrokePath(context);
    
    CGFloat margin = self.lineWidth + 2.0;
    CGRect previousRect = CGRectMake(previous.x - margin, previous.y - margin, margin*2, margin*2);
    CGRect currentRect = CGRectMake(current.x - margin, current.y - margin, margin*2, margin*2);
    [self setNeedsDisplayInRect:CGRectUnion(previousRect, currentRect)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_fingerDragged)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        CGContextRef context = [self setupDrawingContext];
        CGContextMoveToPoint(context, touchPoint.x, touchPoint.y);
        CGContextAddLineToPoint(context, touchPoint.x, touchPoint.y);
        CGContextStrokePath(context);
        
        CGFloat margin = self.lineWidth + 2.0;
        [self setNeedsDisplayInRect:CGRectMake(touchPoint.x - margin, touchPoint.y - margin, margin*2, margin*2)];
    }
}


- (CGContextRef)setupDrawingContext {
    CGContextRef context = CGLayerGetContext(_paintLayer);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    return context;
}

- (void)eraseBoard {
    CGContextRef context = [self setupDrawingContext];
    CGContextClearRect(context, self.bounds);
    [self setNeedsDisplay];
}
@end
