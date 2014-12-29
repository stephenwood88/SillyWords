//
//  SRServiceCalls.h
//  Original Sales
//
//  Created by Jeff on 3/27/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "AFHTTPClient.h"
#import "Entity.h"

@interface SRServiceCalls : AFHTTPClient

+ (instancetype)singleton;

///------------------
/// @name API methods
///------------------

/**
 Each service call API method closely mirrors the backend method it implements. The parameters are as defined in the wiki ( https://wiki.mysalesrabbit.com ). Parameters that are not required in the app are either left out or set to default values that the app always requires.
 
 The completion handler is called with the request's results. If success is YES, result will contain the result in the response body. If success is NO, the error parameter contains an error message.
 
 Convenience methods are available to simplify calls to the more complex API calls for common use cases.
 */

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/login/
 */
- (void)loginUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getDomain/
 */
- (void)getDomainIncludeDepartment:(BOOL) department completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getuserdepartments/
 */
- (void)getUserDepartmentsCompletionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/fetchorganization/
 */
- (void)fetchOrganizationDomain:(NSString *)domain filterOrganizationType:(NSString *)filterOrganizationType id:(NSString *)filterOrganizationId completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;
// Convenience
- (void)fetchOrganizationDomain:(NSString *)domain completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/fetchproducts/
 */
- (void)fetchProductsCompletionHandler:(void (^)(BOOL succes, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/joblist/
 */
- (void)jobListStartTime:(NSDate *)startTime endTime:(NSDate *)endTime completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/salesreport/
 */
- (void)salesReport:(NSString *)domain filterOrganizationType:(NSString *)filterOrganizationType ids:(NSArray *)filterOrganizationIds startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)salesReport:(NSString *)domain reportType:(NSString *)reportType filterColumns:(BOOL)filterColumns filterOrganization:(NSDictionary *)organizationDictionary startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
// Convenience
- (void)areasSalesReportStartTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)officesSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)managersSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)usersSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)usersSalesReportForOffices:(NSArray *)offices startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)userSalesReport:(NSString *)userId startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)accountsSalesReport:(NSString *)userId startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

- (void)fetchSalesStandingsForDomain:(NSString *)domain startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)fetchSalesOverviewForDepth:(NSString *)depth entity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;


/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getdeptsettings/
 */
- (void)getDeptSettingsType:(NSString *)type completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;
// Convenience
- (void)getReportDepthCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getuserid/
 */
- (void)getUserIdCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getlogoimage/
 */
- (void)getLogoImageCompletionHandler:(void (^)(BOOL success, UIImage *result, NSError *error))completionHandler;
- (void)getLogoMetaCompletionHandler:(void (^)(BOOL success, NSDate *results, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getdomainsettings/
 */
- (void)getDomainSettings:(NSString *)domain domainId:(NSInteger)domainId type:(NSString *)type getDefault:(BOOL)getDefault completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
// Convenience
- (void)getCustomerAgreementContactCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getstandingsdomains/
 */
- (void)fetchStandingDomainsCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getagreementsettings/
 Note this should be used to get agreeement terms and contact info instead of getDomainSettings now.
 */
- (void)getAgreementSettingsCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getsalesmateriallist/
 */
- (void)getSalesMaterialListCompletionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler;
- (void)getSalesMaterialTreeCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler;
- (void)getCloudFrontDistributionCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler;
- (void)getSalesMaterialId:(NSInteger)salesMaterialId downloadProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgress completionHandler:(void (^)(BOOL success, NSData *result, NSError *error))completionHandler;

- (void)postServiceCall:(NSString *)service withParameters:(NSDictionary *)params includeDepartment:(BOOL)includeDepartment completionHandler:(void (^)(BOOL success, id result, NSError *error))completionHandler;

- (NSString *)dateAsString:(NSDate *)date;
- (NSString *)dateAsAgemniString:(NSDate *)date;
- (NSString *)todayString;

@end
