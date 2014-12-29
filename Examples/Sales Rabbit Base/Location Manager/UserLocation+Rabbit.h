//
//  UserLocation+Rabbit.h
//  Security Sales
//
//  Created by Bryan Bryce on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "UserLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface UserLocation (Rabbit) <MKAnnotation>

+ (UserLocation *)newUserLocationForLocation:(CLLocation *) location;

@end
