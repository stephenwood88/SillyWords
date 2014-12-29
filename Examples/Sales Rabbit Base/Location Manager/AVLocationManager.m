//
//  AVLocationManager.m
//  Dish Sales
//
//  Created by Aaron Brown on 7/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AVLocationManager.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface AVLocationManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentBestLocation;
@property (strong, nonatomic) NSDate *locationTimestamp;
@property (strong, nonatomic) CLPlacemark *currentBestPlacemark;
@property (strong, nonatomic) NSMutableArray *placemarkDelegateList;
@property (strong, nonatomic) NSMutableArray *locationDelegateList;

@end

@implementation AVLocationManager

+ (AVLocationManager *)singleton{
    
    static dispatch_once_t once;
    static AVLocationManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//Save newLocation as curentBestLocation if there is no currentBestLocation
//                                    or if currentBestLocation is outside the horizontal accuracy of newLocation
//                                    or if newLocation has a better horizontal accuracy than currentBestLocation
- (void)updateUserLocation: (CLLocation *)newLocation {
    if (self.currentBestLocation == nil ||
        [newLocation distanceFromLocation:self.currentBestLocation] > newLocation.horizontalAccuracy ||
        (newLocation.horizontalAccuracy < self.currentBestLocation.horizontalAccuracy)) {
        
        self.currentBestLocation = newLocation;
        
        //Reverse geocode the placemark
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                self.currentBestPlacemark = [placemarks objectAtIndex:0];
                [self callDelegateMethods];
            }
        }];
    }
}

- (void)getCurrentPlacemark:(id <GetPlacemarkDelegate>)delegate {
    
    if (!self.placemarkDelegateList) {
        self.placemarkDelegateList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    [self.placemarkDelegateList addObject:delegate];
    NSTimeInterval locationAge = -[self.locationTimestamp timeIntervalSinceNow];
    
    if (locationAge < MaxLocationAge && self.currentBestPlacemark) {
        [self callDelegateMethods];
    }
    else {
        [self.locationManager startUpdatingLocation];
        [self performSelector:@selector(locationUpdateTimeout) withObject:nil afterDelay:10.0];
    }
}

- (CLLocation *)getBestLocationAndUpdate:(id <GetLocationDelegate>)delegate {
    
    if (!self.locationDelegateList) {
        self.locationDelegateList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    
    [self.locationDelegateList addObject:delegate];
    NSTimeInterval locationAge = -[self.locationTimestamp timeIntervalSinceNow];
    
    if (locationAge < MaxLocationAge && self.currentBestPlacemark) {
        [self callDelegateMethods];
    }
    else {
        [self.locationManager startUpdatingLocation];
        [self performSelector:@selector(locationUpdateTimeout) withObject:nil afterDelay:10.0];
    }
    
    return self.currentBestLocation;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    if (locationAge > MaxLocationAge) {
        return;
    }
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (location.horizontalAccuracy < 0) {
        return;
    }
    
    //Use new location if the accuracy is better than the old location,
    //or if the accuracy of the new location is less than the distance from the old one (meaning the old location isn't in the possible range of accuracy)
    if (self.currentBestLocation == nil ||
        ([location distanceFromLocation:self.currentBestLocation] > location.horizontalAccuracy) ||
        (location.horizontalAccuracy < self.currentBestLocation.horizontalAccuracy)) {
        self.currentBestLocation = location;

        if (location.horizontalAccuracy <= manager.desiredAccuracy) {
            self.locationTimestamp = [NSDate date];
            
            //Minimize power usage by stopping the location tracker
            [manager stopUpdatingLocation];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationUpdateTimeout) object:nil];
            
            //Reverse geocode the placemark
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                if (!error) {
                    self.currentBestPlacemark = [placemarks objectAtIndex:0];
                    //Send result to delegate
                    [self callDelegateMethods];
                }
                else {
                    [self callDelegateErrorMethods];
                }
            }];
            
        }
    }
}

- (void)locationUpdateTimeout {
    
    self.locationTimestamp = [NSDate date];
    
    [self.locationManager stopUpdatingLocation];
    
    //Reverse geocode the placemark
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.currentBestLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            self.currentBestPlacemark = [placemarks objectAtIndex:0];
            //Send result to delegate
            [self callDelegateMethods];
        }
        else {
            [self callDelegateErrorMethods];
        }
    }];
}

- (void)callDelegateMethods {
    
    for (id<GetLocationDelegate> delegate in self.locationDelegateList) {
        [delegate currentLocationFound:self.currentBestLocation];
    }
    for (id<GetPlacemarkDelegate> delegate in self.placemarkDelegateList) {
        [delegate currentPlacemarkFound:self.currentBestPlacemark];
    }
    
    self.locationDelegateList = nil;
    self.placemarkDelegateList = nil;
}

- (void)callDelegateErrorMethods {
    
    for (id<GetLocationDelegate> delegate in self.locationDelegateList) {
        if ([delegate respondsToSelector:@selector(errorFindingLocation)]) {
            [delegate errorFindingLocation];
        }
    }
    for (id<GetPlacemarkDelegate> delegate in self.placemarkDelegateList) {
        [delegate errorFindingPlacemark];
    }
    
    self.locationDelegateList = nil;
    self.placemarkDelegateList = nil;
}

#pragma mark - Custom Accessors

- (CLLocationManager *)locationManager {
    
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}

#pragma mark - Static Methods

+ (NSString *)subThoroughfareFromAddress:(NSString *)address{
    NSScanner *addressScanner = [NSScanner scannerWithString:address];
    //TODO: Do not understand the &?????
    NSString *subThroughfare = nil;
    [addressScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&subThroughfare];
    
    return subThroughfare;
}

@end
