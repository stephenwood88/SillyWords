//
//  Prequal+Rabbit.h
//  DishOne Sales
//
//  Created by Bryan J Bryce on 4/3/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Prequal.h"
#import <MapKit/MapKit.h>
@interface Prequal (Rabbit) <MKAnnotation>

+ (Prequal *) newPrequalFromJSON:(NSDictionary *)json withAreaId:(NSString *)areaId;
+ (Prequal *) generateTestPrequalWithId:(NSString *)prequalId firstName:(NSString *)firstName lastName:(NSString *)lastName lat:(NSNumber *)lattitude long:(NSNumber *)longitude creditLevel:(NSString *)creditLevel;

- (UIColor *)getColor;

@end
