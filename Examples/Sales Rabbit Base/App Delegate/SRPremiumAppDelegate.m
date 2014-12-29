//
//  SRPremiumAppDelegate.m
//  Premium Sales
//
//  Created by Bryan Bryce on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumAppDelegate.h"
#import "SRPremiumConstants.h"
#import "AVLocationManager.h"

@implementation SRPremiumAppDelegate

// Overriden for subclassed service calls
- (SRServiceCalls *)initializeServiceCalls {
    
    return [[SRPremiumSalesServiceCalls alloc] init];
}

- (NSDictionary *)defaultNSUserDefaults {
    
    NSMutableDictionary *defaults = [[super defaultNSUserDefaults] mutableCopy];
    [defaults addEntriesFromDictionary:@{ kLastUserMapSyncServerTimestamps:@{}, kDeletedAreaIds:@[], kLastUserMapSyncDeviceTimestamps:@{}}];
    [defaults addEntriesFromDictionary:@{ kNewAreaIndex:@{}}];
    return defaults;
}

@end
