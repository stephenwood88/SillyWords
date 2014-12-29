//
//  SRServiceCalls.m
//  Original Sales
//
//  Created by Jeff on 3/27/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "SRServiceCalls.h"
#import "Constants.h"
#import "SRConstants.h"
#import "SRProduct.h"
#import "AFHTTPRequestOperation.h"
#import "AppDelegate.h"
#import "AVTextUtilities.h"

@implementation SRServiceCalls

/**
 * DO NOT OVERRIDE this method
 * There should only be one singleton object for all service calls subclasses, whether accessed via the parent or the child class method. This service calls singleton is instantiated in the app delegate. If the service calls is subclassed, return an instatiated subclassed service calls object in the - (SRServiceCalls *)initializeServiceCalls method, overridden in the app delegate subclass.
 */
+ (instancetype)singleton {
    
    return [[SRAppDelegate singleton] serviceCalls];
}

- (id)init {
    
    return [self initWithBaseURL:[NSURL URLWithString:kWebServiceBaseURL]];
}

- (id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.parameterEncoding = AFJSONParameterEncoding;
        //  ONLY NECESSARY WHEN USING https://dev.mysalesrabbit.com or https://beta.mysalesrabbit.com
//        [self setAuthorizationHeaderWithUsername:@"devGroup" password:@"Grdd4,rulbe"];
    }
    return self;
}

#pragma mark - API methods

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/login/
 */
- (void)loginUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"login" withParameters:@{@"username":username, @"password":password, @"appType":kAppType} includeDepartment:NO completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getDomain/
 */
- (void)getDomainIncludeDepartment:(BOOL) department completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {

    [self postServiceCall:@"getDomain" withParameters:nil includeDepartment:department completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getuserdepartments/
 */
- (void)getUserDepartmentsCompletionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    
    [self postServiceCall:@"getUserDepartments" withParameters:nil includeDepartment:NO completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/fetchorganization/
 */
- (void)fetchOrganizationDomain:(NSString *)domain filterOrganizationType:(NSString *)filterOrganizationType id:(NSString *)filterOrganizationId completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"domain"] = domain;
    if (filterOrganizationType != nil && filterOrganizationId != nil) {
        params[@"organization"] = @{[NSString stringWithFormat:@"%@ID", [filterOrganizationType lowercaseString]]:filterOrganizationId};
    }
    NSString *todayString = [self todayString];
    params[@"options"] = @{@"startTime":todayString, @"endTime":todayString};
    [self postServiceCall:@"fetchOrganization" withParameters:params includeDepartment:YES completionHandler:completionHandler];
}

- (void)fetchOrganizationDomain:(NSString *)domain completionHandler:(void (^)(BOOL, NSArray *, NSError *))completionHandler {
    
    [self fetchOrganizationDomain:domain filterOrganizationType:nil id:nil completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/fetchproducts/
 */
- (void)fetchProductsCompletionHandler:(void (^)(BOOL succes, NSDictionary *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"fetchProducts" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/joblist/
 */
- (void)jobListStartTime:(NSDate *)startTime endTime:(NSDate *)endTime completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"jobList" withParameters:@{@"personal":@YES, @"options":@{@"startTime":[self dateAsString:startTime], @"endTime":[self dateAsString:endTime], @"sort":@{@"JobDate":@"DESC", @"JobStart":@"ASC"}}} includeDepartment:YES completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/salesreport/
 */
- (void)salesReport:(NSString *)domain filterOrganizationType:(NSString *)filterOrganizationType ids:(NSArray *)filterOrganizationIds startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"domain"] = domain;
    if (filterOrganizationType != nil && filterOrganizationIds != nil) {
        params[@"organization"] = @{[NSString stringWithFormat:@"%@ID", [filterOrganizationType lowercaseString]]:filterOrganizationIds};
    }
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    if (startTime) {
        options[@"startTime"] = [self dateAsString:startTime];
    }
    if (endTime) {
        options[@"endTime"] = [self dateAsString:endTime];
    }
    if (products) {
        NSMutableDictionary *productsAsValidJson = [NSMutableDictionary dictionaryWithCapacity:products.count];
        for (id key in products) {
            productsAsValidJson[key] = [products[key] proxyForJson];
        }
        options[@"products"] = productsAsValidJson;
    }
    options[@"totals"] = [NSNumber numberWithBool:totals];
    params[@"options"] = options;
    [self postServiceCall:@"salesReport" withParameters:params includeDepartment:YES completionHandler:completionHandler];
}

- (void)salesReport:(NSString *)domain reportType:(NSString *)reportType filterColumns:(BOOL)filterColumns filterOrganization:(NSDictionary *)organizationDictionary startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completionHandler
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"domain"] = domain;
    params[@"reportType"] = reportType;
    if (organizationDictionary != nil && organizationDictionary.count > 0) {
        params[@"organization"] = organizationDictionary;
    }
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    if (startTime) {
        options[@"startTime"] = [self dateAsString:startTime];
    }
    if (endTime) {
        options[@"endTime"] = [self dateAsString:endTime];
    }
    if (reportType) {
        options[@"filterColumns"] = [NSNumber numberWithBool:filterColumns];
    }
    if (products) {
        NSMutableDictionary *productsAsValidJson = [NSMutableDictionary dictionaryWithCapacity:products.count];
        for (id key in products) {
            productsAsValidJson[key] = [products[key] proxyForJson];
        }
        options[@"products"] = productsAsValidJson;
    }
    options[@"totals"] = [NSNumber numberWithBool:totals];
    params[@"options"] = options;
    [self postServiceCall:@"salesReport" withParameters:params includeDepartment:YES completionHandler:completionHandler];
}

- (void)areasSalesReportStartTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kArea filterOrganizationType:nil ids:nil startTime:startTime endTime:endTime products:products totals:totals completionHandler:completionHandler];
}

- (void)officesSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kOffice filterOrganizationType:(entity?entity.entityTypeString:nil) ids:(entity?@[entity.entityId]:nil) startTime:startTime endTime:endTime products:products totals:totals completionHandler:completionHandler];
}

- (void)managersSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kManager filterOrganizationType:(entity?entity.entityTypeString:nil) ids:(entity?@[entity.entityId]:nil) startTime:startTime endTime:endTime products:products totals:totals completionHandler:completionHandler];
}

- (void)usersSalesReportForEntity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kUser filterOrganizationType:(entity?entity.entityTypeString:nil) ids:(entity?@[entity.entityId]:nil) startTime:startTime endTime:endTime products:products totals:totals completionHandler:completionHandler];
}

- (void)usersSalesReportForOffices:(NSArray *)offices startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kUser filterOrganizationType:(offices?kOffice:nil) ids:offices startTime:startTime endTime:endTime products:products totals:NO completionHandler:completionHandler];
}

- (void)userSalesReport:(NSString *)userId startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kUser filterOrganizationType:kUser ids:@[userId] startTime:startTime endTime:endTime products:products totals:YES completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            completionHandler(YES, result[kTotals], nil);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

- (void)accountsSalesReport:(NSString *)userId startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self salesReport:kAccount filterOrganizationType:kUser ids:@[userId] startTime:startTime endTime:endTime products:products totals:YES completionHandler:completionHandler];
}

- (void)fetchSalesStandingsForDomain:(NSString *)domain startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products completionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completionHandler {
    
    [self salesReport:domain reportType:@"standings" filterColumns:YES filterOrganization:nil startTime:startTime endTime:endTime products:products totals:NO completionHandler:completionHandler];
}

- (void)fetchSalesOverviewForDepth:(NSString *)depth entity:(Entity *)entity startTime:(NSDate *)startTime endTime:(NSDate *)endTime products:(NSDictionary *)products totals:(BOOL)totals completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    NSMutableDictionary *organizationDictionary = [[NSMutableDictionary alloc] init];
    
    if (entity.entityAreaId) {
        NSArray *idList = [[NSArray alloc] initWithObjects:entity.entityAreaId, nil];
        organizationDictionary[@"areaID"] = idList;
    }
    if (entity.entityOfficeId) {
        NSArray *idList = [[NSArray alloc] initWithObjects:entity.entityOfficeId, nil];
        organizationDictionary[@"officeID"] = idList;
    }
    if (entity.entityManagerId) {
        NSArray *idList = [[NSArray alloc] initWithObjects:entity.entityManagerId, nil];
        organizationDictionary[@"managerID"] = idList;
    }
    if (entity.entityId) {
        NSArray *idList = [[NSArray alloc] initWithObjects:entity.entityId, nil];
        NSString *idType = [NSString stringWithFormat:@"%@ID",[entity.entityTypeString lowercaseString]];
        organizationDictionary[idType] = idList;
    }
    
    [self salesReport:depth reportType:@"production" filterColumns:YES filterOrganization:organizationDictionary startTime:startTime endTime:endTime products:products totals:totals completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getdeptsettings/
 */
- (void)getDeptSettingsType:(NSString *)type completionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"getDeptSettings" withParameters:@{@"type":type} includeDepartment:YES completionHandler:completionHandler];
}

- (void)getReportDepthCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler {
    
    [self getDeptSettingsType:@"reportDepth" completionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (success) {
            // TODO: Got a crash here because result was an empty array. Need to handle this. Why was it empty?
            completionHandler(YES, result[0][@"Value"], nil);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getuserid/
 */
- (void)getUserIdCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"getUserID" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getlogoimage/
 */
- (void)getLogoImageCompletionHandler:(void (^)(BOOL success, UIImage *result, NSError *error))completionHandler {
    
    [self postPath:kWebServicePath parameters:@{@"service":@"getLogoImage"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(YES, [UIImage imageWithData:responseObject], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(NO, nil, error);
    }];
}

- (void)getLogoMetaCompletionHandler:(void (^)(BOOL success, NSDate *results, NSError *error))completionHandler {
    
    [self postServiceCall:@"getLogoMeta" withParameters:nil includeDepartment:YES completionHandler:^(BOOL success, NSNumber *result, NSError *error) {
        if (success) {
            completionHandler(YES, [NSDate dateWithTimeIntervalSince1970:[result doubleValue]], nil);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getdomainsettings/
 */
- (void)getDomainSettings:(NSString *)domain domainId:(NSInteger)domainId type:(NSString *)type getDefault:(BOOL)getDefault completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"domain"] = domain;
    if (domainId) {
        params[@"domainID"] = [NSNumber numberWithInteger:domainId];
    }
    params[@"type"] = type;
    if (getDefault) {
        params[@"default"] = @YES;
    }
    [self postServiceCall:@"getDomainSettings" withParameters:params includeDepartment:YES completionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (result) {
            completionHandler(success, result[0], error); // TODO: Have Mat remove the redundant array enclosing the dictionary response
        }
        else {
            completionHandler(success, nil, error);
        }
    }];
}

- (void)getCustomerAgreementContactCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self getDomainSettings:@"SystemAccount" domainId:0 type:@"customerAgreementContact" getDefault:YES completionHandler:completionHandler];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getstandingsdomains/
 */
- (void)fetchStandingDomainsCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler
{
    [self postServiceCall:@"getStandingsDomains" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}



/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getagreementsettings/
 Note this should be used to get agreeement terms and contact info instead of getDomainSettings now.
 */
- (void)getAgreementSettingsCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler
{
    [self postServiceCall:@"getAgreementSettings" withParameters:nil includeDepartment:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (result) {
            completionHandler(success, result, error);
        }
        else {
            completionHandler(success, nil, error);
        }
    }];
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/getsalesmateriallist/
 */
- (void)getSalesMaterialListCompletionHandler:(void (^)(BOOL success, NSArray *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"getSalesMaterialList" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}

- (void)getSalesMaterialTreeCompletionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    [self postServiceCall:@"getSalesMaterialTree" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}

- (void)getCloudFrontDistributionCompletionHandler:(void (^)(BOOL success, NSString *result, NSError *error))completionHandler {

    [self postServiceCall:@"getCloudFrontDistribution" withParameters:nil includeDepartment:YES completionHandler:completionHandler];
}

- (void)getSalesMaterialId:(NSInteger)salesMaterialId downloadProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgress completionHandler:(void (^)(BOOL success, NSData *result, NSError *error))completionHandler {

    NSURLRequest *request = [self requestWithMethod:@"POST" path:kWebServicePath parameters:@{@"service":@"getSalesMaterial", @"params":@{@"salesMaterialID":[NSNumber numberWithInteger:salesMaterialId]}}];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(NO, nil, error);
    }];
    [operation setDownloadProgressBlock:downloadProgress];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - Private methods

- (void)postServiceCall:(NSString *)service withParameters:(NSDictionary *)params includeDepartment:(BOOL)includeDepartment completionHandler:(void (^)(BOOL success, id result, NSError *error))completionHandler {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:service forKey:@"service"];
    if (params) {
        parameters[@"params"] = params;
    }
    if (includeDepartment) {
        if ([[SRGlobalState singleton] departmentCode] != nil) {
            parameters[@"department"] = [[SRGlobalState singleton] departmentCode];
        }
        
    }
    
    DLog(@"request: %@", parameters);
    [self postPath:kWebServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
//        DLog(@"responseString: %@", [NSString stringWithUTF8String:((NSData *)responseObject).bytes]);
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
//            DLog(@"responseDict: %@", responseDictionary);
            if ([responseDictionary[@"success"] isEqualToNumber:@1]) {
                completionHandler(YES, responseDictionary[@"result"], nil);
            }
            else {
                if ([responseDictionary[@"success"] isEqualToNumber:@-4]) {
                    [SRAppDelegate logout];
                }
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (responseDictionary[@"errMsg"]) {
                    userInfo[NSLocalizedDescriptionKey] = responseDictionary[@"errMsg"];
                }
                if (responseDictionary[@"errCode"]) {
                    userInfo[NSLocalizedFailureReasonErrorKey] = responseDictionary[@"errCode"];
                }
                error = [NSError errorWithDomain:@"Sales Rabbit" code:[responseDictionary[@"success"] integerValue] userInfo:userInfo];
                NSLog(@"%@", error.localizedDescription);
                completionHandler(NO, nil, error);
            }
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            completionHandler(NO, nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        completionHandler(NO, nil, error);
    }];
}

/**
 * Date formatted as string for web service call
 */
- (NSString *)dateAsString:(NSDate *)date {
    
    if (date == nil) {
        return @"null";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd 00:00:00";
    return [dateFormatter stringFromDate:date];
}

/**
 * Date formatted as string for Agemni web service call
 */
- (NSString *)dateAsAgemniString:(NSDate *)date {
    
    if (date ==  nil) {
        return @"null";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    return [dateFormatter stringFromDate:date];
}

/**
 * Today's date formatted as string for web service call
 */
- (NSString *)todayString {
    
    return [self dateAsString:[NSDate date]];
}

@end
