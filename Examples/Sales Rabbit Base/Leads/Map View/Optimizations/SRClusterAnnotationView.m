//
//  SRClusterAnnotationView.m
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRClusterAnnotationView.h"
#import "SRGlobalState.h"

#define  Arrow_height 15

CGPoint SRRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect SRCenterRect(CGRect rect, CGPoint center)
{
    CGRect r = CGRectMake(center.x - rect.size.width/2.0,
                          center.y - rect.size.height/2.0,
                          rect.size.width,
                          rect.size.height);
    return r;
}

static CGFloat const SRScaleFactorAlpha = 0.3;
static CGFloat const SRScaleFactorBeta = 0.4;

CGFloat SRScaledValueForValue(CGFloat value)
{
    return 1.0 / (1.0 + expf(-1 * SRScaleFactorAlpha * powf(value, SRScaleFactorBeta)));
}

@interface SRClusterAnnotationView ()
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation SRClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - Arrow_height)];
        self.contentView.backgroundColor   = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        [self setupLabel];
        [self setCount:1];
    }
    return self;
}

- (void)setupLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.frame];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
    _countLabel.shadowOffset = CGSizeMake(0, -1);
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self addSubview:_countLabel];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    CGRect newBounds = CGRectMake(0, 0, roundf(44 * SRScaledValueForValue(count)), roundf(44 * SRScaledValueForValue(count)));
    self.frame = SRCenterRect(newBounds, self.center);
    
    CGRect newLabelBounds = CGRectMake(0, 0, newBounds.size.width / 1.3, newBounds.size.height / 1.3);
    self.countLabel.frame = SRCenterRect(newLabelBounds, SRRectCenter(newBounds));
    self.countLabel.text = [@(_count) stringValue];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, true);
    
    UIColor *outerCircleStrokeColor = [UIColor colorWithWhite:0 alpha:0.25];
    UIColor *innerCircleStrokeColor = [UIColor whiteColor];
    UIColor *innerCircleFillColor = [[SRGlobalState singleton] accentColor];
    
    CGRect circleFrame = CGRectInset(rect, 4, 4);
    
    [outerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleFillColor setFill];
    CGContextFillEllipseInRect(context, circleFrame);
}

@end
