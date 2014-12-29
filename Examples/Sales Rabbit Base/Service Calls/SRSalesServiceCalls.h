//
//  SRSalesServiceCalls.h
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRServiceCalls.h"

@interface SRSalesServiceCalls : SRServiceCalls

- (void)sync;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/syncleads/
 */
- (void)syncLeads:(NSArray *)leads modifiedSince:(NSDate *)date delete:(NSArray *)deleteLeads completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
// Convenience
- (void)syncLeads;
- (void)updateTimeStampsAfterLogin;
- (void)updateTimestampsInNSUserDefaults;

@end
