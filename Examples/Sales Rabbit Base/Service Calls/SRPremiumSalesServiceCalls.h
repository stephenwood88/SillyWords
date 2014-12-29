//
//  SRPremiumSalesServiceCalls.h
//  Security Sales
//
//  Created by Bryan Bryce on 2/19/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesServiceCalls.h"

@interface SRPremiumSalesServiceCalls : SRSalesServiceCalls

- (void)sync;
- (void)syncUserMap;
- (void)performUserMapSync;
- (void)performUserMapSyncWithCompletionBlock:(void (^)(BOOL success))completionHandler;
@property (strong, nonatomic) NSDate *lastUserMapSyncServer;
@property (strong, nonatomic) NSDate *lastUserMapSyncDevice;

@property (strong, nonatomic) NSMutableDictionary *usersNotificationDict;
@property (strong, nonatomic) NSMutableDictionary *areasNotificationDict;

@property (strong, nonatomic) NSMutableArray *addedPrequals;


/**
 Each service call API method closely mirrors the backend method it implements. The parameters are as defined in the wiki ( https://wiki.mysalesrabbit.com ). Parameters that are not required in the app are either left out or set to default values that the app always requires.
 
 The completion handler is called with the request's results. If success is YES, result will contain the result in the response body. If success is NO, the error parameter contains an error message.
 
 Convenience methods are available to simplify calls to the more complex API calls for common use cases.
 */

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getprequal/
 
 Returns the prequal records the user has access to if the system account has the Prequal module.
 
 A prequal record is in a sales area if the point of the prequal is encompassed by the polygon of the sales area, and the prequal point is not further than the radius in miles of the center point of the office.
 
 An admin gets whatever prequal records for sales areas in the department they are making the call for, a regional gets them for all offices in his region, a manager for his office, and a sales rep only for his active sales area in his current office.
 
 If the call has more prequal records than can be received in a single call it will return a cursor that should be sent with the next getPrequal call.
 
 NOTE: Currently we aren't utilizing modifiedSince to filter out prequal records on the backend, but we may have to in the future so it should be passed from the modifiedAt in the response.
 */
- (void)getPrequal;


@end
