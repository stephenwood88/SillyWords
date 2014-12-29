//
//  SRDataPoint.m
//  Park View
//
//  Created by Raul Lopez Villalpando on 1/17/14.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

#import "SRDataPoint.h"

@implementation SRDataPoint


- (id)initWithX:(double)xValue andY:(double)yValue
{
    self = [super init];
    
    if (self != nil)
    {
        self.x = xValue;
        self.y = yValue;
    }
    
    return self;
}

- (BOOL)equalsTo:(SRDataPoint *)point
{
    if (point == nil)
        return NO;
    
    return (point.x == self.x && point.y == self.y);
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"x = %f, y = %f \n",self.x,self.y];
}

- (CGPoint)point{
    CGPoint newPoint;
    newPoint.x = self.x;
    newPoint.y = self.y;
    
    return newPoint;
}

@end
