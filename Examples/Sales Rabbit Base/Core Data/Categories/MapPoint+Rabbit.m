//
//  MapPoint+Rabbit.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/31/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "MapPoint+Rabbit.h"

@implementation MapPoint (Rabbit)

+ (MapPoint *)newMapPointFromLocation:(CLLocationCoordinate2D) location
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    MapPoint *newMapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPoint" inManagedObjectContext:context];
    
    newMapPoint.latitude = [NSNumber numberWithDouble:location.latitude];
    newMapPoint.longitude = [NSNumber numberWithDouble:location.longitude];
    
    //NSLog(@"New MapPoint, longitude: %f latitude: %f",  [newMapPoint.longitude doubleValue], [newMapPoint.latitude doubleValue]);
    
    return newMapPoint;
}

+ (MapPoint *)newMapPointFromJSON:(id)json forArea:(Area *)area
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    MapPoint *newMapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"MapPoint" inManagedObjectContext:context];
    
    newMapPoint.latitude = [NSNumber numberWithDouble:[json[@"Latitude"] doubleValue]];
    newMapPoint.longitude = [NSNumber numberWithDouble:[json[@"Longitude"] doubleValue]];

    newMapPoint.area = area;
    
    return newMapPoint;
}

- (CLLocationCoordinate2D)returnLocation
{
    CLLocationCoordinate2D newCoor;
    newCoor.latitude = [self.latitude doubleValue];
    newCoor.longitude = [self.longitude doubleValue];
    
    return newCoor;
}

- (id) proxyForJSON
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    json[@"Latitude"] = self.latitude;
    json[@"Longitude"] = self.longitude;
    
    return json;
}

@end
