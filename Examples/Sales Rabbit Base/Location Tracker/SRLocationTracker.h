//
//  SRLocationTracker.h
//  Security Sales
//
//  Created by Bryan Bryce on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVLocationManager.h"
#import "UserLocation.h"

@interface SRLocationTracker : NSObject<GetLocationDelegate>

+ (SRLocationTracker *)singleton;

//Saving Locations
- (void)beginSavingLocationData;
- (void)stopSavingLocationData;
- (void)saveAndSyncLocation;
//Getting Locations
- (NSArray *)getUserLocationsForUserId:(NSString *) userId;
- (NSArray *)getUserLocationsForUserIds:(NSArray *)userIds fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

@end
    