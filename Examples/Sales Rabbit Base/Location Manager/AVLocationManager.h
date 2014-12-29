//
//  AVLocationManager.h
//  Dish Sales
//
//  Created by Aaron Brown on 7/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

NSArray *locationPointsArray;

@protocol GetPlacemarkDelegate <NSObject>
@required
- (void)currentPlacemarkFound:(CLPlacemark *)placemark;
- (void)errorFindingPlacemark;
@end

@protocol  GetLocationDelegate <NSObject>
@required
- (void)currentLocationFound:(CLLocation *)location;
@optional
- (void)errorFindingLocation;
@end

@interface AVLocationManager : NSObject <CLLocationManagerDelegate>

+ (AVLocationManager *)singleton;


- (void)updateUserLocation: (CLLocation *)newLocation;
- (void)getCurrentPlacemark:(id <GetPlacemarkDelegate>)delegate;
- (CLLocation *)getBestLocationAndUpdate:(id <GetLocationDelegate>)delegate;


// This method takes an address and returns the house number (sub thoroughfare)
+ (NSString *)subThoroughfareFromAddress:(NSString *)address;

@end
