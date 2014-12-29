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
 * in UserLocation.m when regenerating this class.
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
    
    userLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    userLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    
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
    return [self userId];
}

- (NSString *)subtitle
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    
    return [formatter stringFromDate:[self dateCreated]];
}


@end
