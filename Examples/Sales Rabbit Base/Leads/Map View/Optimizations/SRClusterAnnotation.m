//
//  SRClusterAnnotation.m
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRClusterAnnotation.h"

@implementation SRClusterAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count
{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title = [NSString stringWithFormat:@"%lu Total", count];
        _count = count;
    }
    return self;
}

- (NSUInteger)hash
{
    NSString *toHash = [NSString stringWithFormat:@"%.5F%.5F", self.coordinate.latitude, self.coordinate.longitude];
    return [toHash hash];
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}


@end
