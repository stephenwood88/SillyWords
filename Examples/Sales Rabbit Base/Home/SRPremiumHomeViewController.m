//
//  SRPremiumHomeViewController.m
//  Premium Sales
//
//  Created by Bryan Bryce on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumHomeViewController.h"
#import "SRGlobalState.h"
#import "Constants.h"
#import "SRPremiumConstants.h"
#import "SRLocationTracker.h"
#import "UserLocation.h"
#import "SRPremiumSalesServiceCalls.h"
#import "User.h"

@implementation SRPremiumHomeViewController

- (void)logout
{
    // FIXME: When should User Locations be cleaned out?
    /*
    NSFetchRequest *request =
    [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];

    NSArray *fetchedObjects =
    [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:nil];
    
    for (UserLocation *userLocation in fetchedObjects) {

        [[[SRGlobalState singleton] managedObjectContext] deleteObject:userLocation];
    }
  */
    [[SRLocationTracker singleton] stopSavingLocationData];
    [super logout];
}

@end
