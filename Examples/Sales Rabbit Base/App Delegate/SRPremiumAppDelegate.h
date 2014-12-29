//
//  SRPremiumAppDelegate.h
//  Premium Sales
//
//  Created by Bryan Bryce on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesAppDelegate.h"
#import "SRPremiumSalesServiceCalls.h"

@interface SRPremiumAppDelegate : SRSalesAppDelegate

// Overridden property for subclassed service calls
@property (strong, nonatomic) SRPremiumSalesServiceCalls *serviceCalls;

@end
