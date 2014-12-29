//
//  SignatureView.m
//  Dish Sales
//
//  Created by Jeff on 11/17/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "SignatureView.h"
#import <QuartzCore/QuartzCore.h>

@interface SignatureView () {
    
    UIBezierPath *signature;
    UIColor *lineColor;
}

//@property (strong, nonatomic) UIBezierPath *signature;
@property (nonatomic) BOOL signatureSigned;

@end

@implementation SignatureView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        signature = [[UIBezierPath alloc] init];
        signature.lineCapStyle = kCGLineCapRound;
        signature.miterLimit = 0.0;
        self.signatureSigned = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
    [lineColor setStroke];
    [signature strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)clear {
    
    self.signatureSigned = NO;
    [signature removeAllPoints];
    [self setNeedsDisplay];
}

- (BOOL)isSigned {
    
    return self.signatureSigned;
}

- (UIImage *)signatureImage {
    
    if (self.signatureSigned) {
        // Save the image at a 2x scale for a good image resolution to embed in the PDF
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 2.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
    return nil;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [signature moveToPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    [signature addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
    if (!self.signatureSigned) {
        self.signatureSigned = YES;
        if (self.delegate) {
            [self.delegate signatureSigned];
        }
    }
}

#pragma mark - Custom Accessors

- (void)setDelegate:(id<SignatureViewDelegate>)delegate {
    
    _delegate = delegate;
    signature.lineWidth = delegate.lineWidth;
    lineColor = delegate.lineColor;
}

@end
