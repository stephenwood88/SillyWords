//
//  SRSalesAppDelegate.h
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRAppDelegate.h"
#import "SRSalesServiceCalls.h"

@interface SRSalesAppDelegate : SRAppDelegate

// Overridden property for subclassed service calls
@property (strong, nonatomic) SRSalesServiceCalls *serviceCalls;

-(void)resetMaterialsTimeStamps;

@end
