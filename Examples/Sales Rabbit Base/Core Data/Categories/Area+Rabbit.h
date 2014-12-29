//
//  Area+Rabbit.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/30/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Area.h"
#import <MapKit/MapKit.h>

@interface Area (Rabbit)

//+ (Area *)newAreaWithMapPoints:(NSOrderedSet *)mapPoints andDate:(NSDate *)date;
+ (Area *)newAreaWithAreaId:(NSString *)areaId office:(Office *)office;

- (void)updateFromJSON:(NSDictionary *)json;
- (void)newFromJSON:(NSDictionary *)json;

- (UIColor *)getAreaColorWithAlpha:(CGFloat) alpha;
- (id)proxyForJSON;

+ (NSString *)generateTempAreaId;


@end
