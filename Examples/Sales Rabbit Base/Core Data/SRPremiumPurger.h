//
//  SRPremiumPurger.h
//  Dish Sales
//
//  Created by Bryan J Bryce on 3/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRPremiumPurger : NSObject

//+ (BOOL)isPurgeRequired;
//+ (void)purgeUsers;
//+ (void)purgeAreas;
+ (void)purgeTimeStamps;
+ (void)purgeUserLocationsOlderThan:(int) numberOfWeeks;

@end
