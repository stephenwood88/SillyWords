//
//  ResizingLabel.m
//  Dish Sales
//
//  Created by Jeff on 11/3/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "ResizingLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface ResizingLabel ()

@property (nonatomic) CGFloat fontHeightRatio;
@property (nonatomic) CGFloat originalFontSize;
@property (nonatomic) CGSize originalFrameSize;

@end

@implementation ResizingLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.fontHeightRatio = self.font.pointSize / self.frame.size.height;
    }
    return self;
}

- (void)awakeFromNib {
    
    self.originalFontSize = self.font.pointSize;
    self.originalFrameSize = self.frame.size;
    [self calculateFontSizeForText:self.text];
}

- (void)setFrame:(CGRect)frame {
    
    if (self.fontHeightRatio) {
        self.font = [self.font fontWithSize:(frame.size.height * self.fontHeightRatio)];
    }
    [super setFrame:frame];
    [self calculateFontSizeForText:self.text];
}

- (void)setBounds:(CGRect)bounds {
    
    if (self.fontHeightRatio) {
        self.font = [self.font fontWithSize:(bounds.size.height * self.fontHeightRatio)];
    }
    [super setBounds:bounds];
    [self calculateFontSizeForText:self.text];
}

- (void)setText:(NSString *)text {
    
    [self calculateFontSizeForText:text];
    [super setText:text];
}

- (void)calculateFontSizeForText:(NSString *)text {
    
    if (self.numberOfLines != 1 && text.length && self.originalFrameSize.width) { // Handle font autoshrinking for multiline labels, also align to top
        CGSize originalFrameSize = self.frame.size;
        CGFloat sizeRatio = originalFrameSize.width / self.originalFrameSize.width;
        originalFrameSize.height = self.originalFrameSize.height * sizeRatio;
        CGSize testSize = originalFrameSize;
        testSize.height = CGFLOAT_MAX;
        CGFloat originalFontSize = self.originalFontSize * sizeRatio;
        CGFloat minimumFontSize = originalFontSize * self.minimumScaleFactor;
        CGFloat fontSize;
        CGSize neededSize;
        for (fontSize = originalFontSize; fontSize > minimumFontSize; fontSize -= 0.1) {
            UIFont *font = [self.font fontWithSize:fontSize];
            CGRect textRect = [text boundingRectWithSize:testSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            neededSize = textRect.size;
            if (neededSize.height <= originalFrameSize.height) {
                break;
            }   
        }
        if (fontSize < minimumFontSize) {
            fontSize = minimumFontSize;
        }
        CGRect frame = self.frame;
        frame.size.height = neededSize.height;
        [super setFrame:frame];
        self.font = [self.font fontWithSize:fontSize];
        self.fontHeightRatio = fontSize / neededSize.height;
    }
    else if (self.originalFrameSize.height) {
        self.fontHeightRatio = self.originalFontSize / self.originalFrameSize.height;
    }
}

/** Overriding this CALayer delegate method is the magic that allows us to draw a vector version of the label into the layer instead of the default unscalable ugly bitmap */
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
    BOOL isPDF = !CGRectIsEmpty(UIGraphicsGetPDFContextBounds());
    if (!layer.shouldRasterize && isPDF) {
        [self drawRect:self.bounds]; // draw unrasterized
    }
    else {
        [super drawLayer:layer inContext:ctx];
    }
}

@end
