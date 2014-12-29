//
//  AppDelegate.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/17/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRPremiumAppDelegate.h"
#import "AVLocationManager.h"
#import "ServiceCalls.h"

@interface AppDelegate : SRPremiumAppDelegate

// Overridden property for subclassed service calls
@property (strong, nonatomic) ServiceCalls *serviceCalls;

@end
