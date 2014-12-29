//
//  SRDataPoint.h
//  Park View
//
//  Created by Raul Lopez Villalpando on 1/17/14.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRDataPoint : NSObject


@property (assign, nonatomic) double x;
@property (assign, nonatomic) double y;

- (id)initWithX:(double)xValue andY:(double)yValue;
- (BOOL)equalsTo:(SRDataPoint *)point;
- (NSString *)description;
- (CGPoint)point;


@end
