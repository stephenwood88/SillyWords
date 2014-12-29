//
//  UserLocation+Rabbit.m
//  Security Sales
//
//  Created by Bryan Bryce on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "UserLocation+Rabbit.h"
#import "SRGlobalState.h"


@interface UserLocation (PrimativeAccessor)

- (void)setPrimitiveLatitude:(NSNumber *)latitude;
- (void)setPrimitiveLongitude:(NSNumber *)longitude;

@end

@implementation UserLocation (Rabbit)

/**
 * Since super can't be called in categories, be sure this method is overwritten
 * in UserLocation.m when regenerating that class.
 *
 
 #import "AppDelegate.h"
 
 @interface UserLocation (PrimitiveAccessor)
 
 - (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
 - (void)setPrimitiveUserId:(NSString *)userId;
 
 @end
 
 - (void)awakeFromInsert {
 
 [super awakeFromInsert];
 
 NSDate *date = [NSDate date];
 [self setPrimitiveDateCreated:date];
 [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
 }
 */

#pragma mark - New UserLocation class methods

+ (UserLocation *)newUserLocationForLocation:(CLLocation *) location
{
    NSAssert(location != nil, @"Location should not be nil");
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    UserLocation *userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"UserLocation"
                                                      inManagedObjectContext:context];

    //Attribuites
    userLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    userLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    userLocation.dateCreated = [NSDate date];

    //Relationships
    userLocation.user = [User currentUserWithUserId:[[SRGlobalState singleton] userId] fromContext:[[SRGlobalState singleton] managedObjectContext]];

    [userLocation.user addUserLocationsObject:userLocation];

    return userLocation;
}

+ (UserLocation *)newUserLocationFromJSON:(id)json forUser:(User *)user
{
    NSAssert(json != nil, @"json should not be nil");

    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    UserLocation *userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"UserLocation"
                                                               inManagedObjectContext:context];

    userLocation.latitude = [NSNumber numberWithDouble:[json[@"Latitude"] doubleValue]];
    userLocation.longitude = [NSNumber numberWithDouble:[json[@"Longitude"] doubleValue]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy'-'MM'-'dd HH':'mm':'ss";
    userLocation.dateCreated = [dateFormatter dateFromString:json[@"LocationTime"]];
    userLocation.alpha = @1.0;

    [user addUserLocationsObject:userLocation];
    userLocation.user = user;

    NSAssert(userLocation.latitude != nil, @"User locations must have a latitude!");
    NSAssert(userLocation.longitude != nil, @"User locations must have a longitude!");
    NSAssert(userLocation.dateCreated != nil, @"User locations must have a dateCreated!");

    return userLocation;
}

#pragma mark - MKAnnotation methods

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D newcoordinate = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    return newcoordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    self.latitude = [NSNumber numberWithDouble:newCoordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:newCoordinate.longitude];
}

- (NSString *)title
{
    if (self.user.lastName) {
        return [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    }
    else
    {
        return [NSString stringWithFormat:@"%@", self.user.firstName];
    }

}

- (NSString *)subtitle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy '@' hh:mm a"];
    
    return [formatter stringFromDate:[self dateCreated]];
}

#pragma mark - Proxy for JSON

- (id)proxyForJSON {
    
    NSMutableDictionary *json = [NSMutableDictionary dictionary];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss'"];
    json[@"LocationTime"] = [dateFormatter stringFromDate:self.dateCreated];
    json[@"Latitude"] = self.latitude ? self.latitude : [NSNull null];
    json[@"Longitude"] = self.longitude ? self.longitude : [NSNull null];
 
    return json;
}

#pragma mark - Helper Methods

- (NSDate *)dateFromString:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:string];
}

- (id)filterNSNull:(id)json {
    
    if ([json isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return json;
}


@end
