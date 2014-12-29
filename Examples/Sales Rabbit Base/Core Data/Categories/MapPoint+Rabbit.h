//
//  MapPoint+Rabbit.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/31/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "MapPoint.h"
#import "SRGlobalState.h"
#import <MapKit/MapKit.h>

@interface MapPoint (Rabbit)

+ (MapPoint *)newMapPointFromLocation:(CLLocationCoordinate2D) location;
+ (MapPoint *)newMapPointFromJSON:(id)json forArea:(Area *)area;

- (CLLocationCoordinate2D)returnLocation;

- (id) proxyForJSON;

@end
