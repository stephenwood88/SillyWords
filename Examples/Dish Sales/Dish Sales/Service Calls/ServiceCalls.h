//
//  ServiceCalls.h
//  DishTech
//
//  Created by Jeff on 3/27/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "SRPremiumSalesServiceCalls.h"

@class Agreement;

@interface ServiceCalls : SRPremiumSalesServiceCalls


///------------------
/// @name API methods
///------------------

/**
 Each service call API method closely mirrors the backend method it implements. The parameters are as defined in the wiki ( https://wiki.mysalesrabbit.com ). Parameters that are not required in the app are either left out or set to default values that the app always requires. 
 
 The completion handler is called with the request's results. If success is YES, result will contain the result in the response body. If success is NO, the error parameter contains an error message.
 
 Convenience methods are available to simplify calls to the more complex API calls for common use cases.
 */

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/customer-agreements/
 */
- (void)putCustomerAgreement:(Agreement *)agreement pdf:(NSData *)pdf uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)putCustomerAgreementFields:(NSDictionary *)fields provider:(NSString *)provider completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)sendCustomerAgreementPdf:(NSData *)pdf forLeadId:(NSNumber *)leadId uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;


@end
