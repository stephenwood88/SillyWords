//
//  SRSalesLoginViewController.m
//  Premium Sales
//
//  Created by Bryan Bryce on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumLoginViewController.h"
#import "SRPremiumConstants.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRPremiumPurger.h"
#import "SRLocationTracker.h"
#import "SRGlobalState.h"

@implementation SRPremiumLoginViewController

- (void)didLoginWithDictionary:(NSDictionary *)result
{
    [super didLoginWithDictionary:result];
    
    //Purge old User Locations
    [SRPremiumPurger purgeUserLocationsOlderThan:kWeeksOldToPurgeUserLocations];
    
    [[SRPremiumSalesServiceCalls singleton] updateTimeStampsAfterLogin];
    [[SRPremiumSalesServiceCalls singleton] performUserMapSync];
    [[SRLocationTracker singleton] beginSavingLocationData];   
}

@end
