//
//  ServiceCalls.m
//  DishTech
//
//  Created by Jeff on 3/27/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "ServiceCalls.h"
#import "Constants.h"
#import "SRConstants.h"
#import "SRProduct.h"
#import "AFHTTPRequestOperation.h"
#import "AppDelegate.h"
#import "Agreement+Rabbit.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "ServiceInfo+Rabbit.h"
#import "CreditCard+Rabbit.h"
#import "Ach+Rabbit.h"
#import "AVTextUtilities.h"
#import "Lead+Rabbit.h"


@implementation ServiceCalls


#pragma mark - API methods

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/customer-agreements/
 */
- (void)putCustomerAgreement:(Agreement *)agreement pdf:(NSData *)pdf uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    if (!agreement.isCompleted) {
        NSLog(@"Error: Cannot submit incomplete agreement");
        return;
    }
    Person *person = agreement.person;
    Address *address = person.address;
    Address *billingAddress = person.billingAddress;
    ServiceInfo *serviceInfo = agreement.serviceInfo;
    CreditCard *creditCard = agreement.creditCard;
    Ach *ach = agreement.ach;
    NSCharacterSet *numChars = [NSCharacterSet decimalDigitCharacterSet];
    // Required fields
    NSMutableDictionary *parameters = [@{@"service": @"putCustomerAgreement",
                                             kFName: person.firstName,
                                             kLName: person.lastName,
                                             kPhone: [AVTextUtilities filterString:person.phonePrimary byCharacterSet:numChars],
                                            kStreet: address.street1,
                                              kCity: address.city,
                                             kState: address.state,
                                               kZip: address.zip,
                                       kContactDate: [self dateAsAgemniString:agreement.dateCreated],
                                          kSaleDate: [self dateAsAgemniString:agreement.signedDate]} mutableCopy];
    if ([serviceInfo.provider isEqualToString:kDishNetwork]) {
        parameters[@"provider"] = @"dishnetwork";
    }
    else if ([serviceInfo.provider isEqualToString:kDirecTv]) {
        parameters[@"provider"] = @"directv";
    }
    // Optional fields
    if (agreement.agemniLeadId.length) {
        parameters[@"leadID"] = agreement.agemniLeadId;
    }
    if (person.businessName.length) {
        parameters[kBusinessName] = person.businessName;
    }
    if (person.phoneAlternate.length) {
        parameters[kPhone2] = [AVTextUtilities filterString:person.phoneAlternate byCharacterSet:numChars];
    }
    if (person.phoneCell.length) {
        parameters[kPhone3] = [AVTextUtilities filterString:person.phoneCell byCharacterSet:numChars];
    }
    if (person.email.length) {
        parameters[kEmail] = person.email;
    }
    if (person.dateOfBirth) {
        parameters[kDob] = [self dateAsAgemniString:person.dateOfBirth];
    }
    if (person.ssn.length) {
        parameters[kSsn] = [AVTextUtilities filterString:person.ssn byCharacterSet:numChars];
    }
    if (address.street2.length) {
        parameters[kStreet2] = address.street2;
    }
    if (billingAddress.isCompleted) {
        parameters[kBillStreet] = billingAddress.street1;
        if (billingAddress.street2.length) {
            parameters[kBillStreet2] = billingAddress.street2;
        }
        parameters[kBillCity] = billingAddress.city;
        parameters[kBillState] = billingAddress.state;
        parameters[kBillZip] = billingAddress.zip;
    }
    if (creditCard.isCompleted) {
        parameters[kCcNumber] = [AVTextUtilities filterString:creditCard.number byCharacterSet:numChars];
        if ([AVTextUtilities isAmericanExpressIIN:creditCard.number]) {
            parameters[kCcType] = kAmericanExpress;
        }
        else if ([AVTextUtilities isDiscoverIIN:creditCard.number]) {
            parameters[kCcType] = kDiscover;
        }
        else if ([AVTextUtilities isMasterCardIIN:creditCard.number]) {
            parameters[kCcType] = kMasterCard;
        }
        else if ([AVTextUtilities isVisaIIN:creditCard.number]) {
            parameters[kCcType] = kVisa;
        }
        parameters[kExpirationDate] = [self dateAsAgemniString:creditCard.expirationDate];
        parameters[kCcCode] = creditCard.cvv;
    }
    if (ach.isCompleted) {
        parameters[kFinancialName] = ach.financialInstitution;
        parameters[kAccountType] = ach.accountType;
        parameters[kRoutingNumber] = ach.routingNumber;
        parameters[kAccountNumber] = ach.accountNumber;
    }
    // Service Info Note
    parameters[kNumberTvs] = serviceInfo.tvs;
    parameters[kServiceInfo] = [serviceInfo serviceCallDictionary];
    // General Note
    if (agreement.notes.length) {
        parameters[kNotes] = agreement.notes;
    }
    NSLog(@"request: %@", parameters);
    self.parameterEncoding = AFFormURLParameterEncoding;
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:kWebServicePath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:pdf name:@"file"];
    }];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            //NSLog(@"response: %@", responseDictionary);
            if ([responseDictionary[@"success"] isEqualToNumber:@1]) {
                completionHandler(YES, responseDictionary[@"result"], nil);
            }
            else {
                if ([responseDictionary[@"success"] isEqualToNumber:@-4]) {
                    [AppDelegate logout];
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
//            NSLog(@"result = %@", [NSString stringWithUTF8String:[responseObject bytes]]);
            completionHandler(NO, nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(NO, nil, error);
    }];
    [operation setUploadProgressBlock:uploadProgress];
    [self enqueueHTTPRequestOperation:operation];
    self.parameterEncoding = AFJSONParameterEncoding;
}

- (void)putCustomerAgreementFields:(NSDictionary *)fields provider:(NSString *)provider completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    [self postServiceCall:@"putCustomerAgreementFields" withParameters:@{@"provider":provider, @"fields":fields} includeDepartment:YES completionHandler:completionHandler];
}

- (void)sendCustomerAgreementPdf:(NSData *)pdf forLeadId:(NSNumber *)leadId uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress completionHandler:(void (^)(BOOL success, NSError *error))completionHandler {
    
    NSDictionary *parameters = @{@"service": @"sendCustomerAgreementPDF", @"leadID": leadId};
    self.parameterEncoding = AFFormURLParameterEncoding;
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:kWebServicePath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:pdf name:@"file"];
    }];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if (!error) {
            //NSLog(@"response: %@", responseDictionary);
            if ([responseDictionary[@"success"] isEqualToNumber:@1]) {
                completionHandler(YES, nil);
            }
            else {
                if ([responseDictionary[@"success"] isEqualToNumber:@-4]) {
                    [AppDelegate logout];
                }
                error = [NSError errorWithDomain:@"Sales Rabbit" code:[responseDictionary[@"success"] integerValue] userInfo:@{NSLocalizedDescriptionKey:responseDictionary[@"errMsg"]}];
                NSLog(@"%@", error.localizedDescription);
                completionHandler(NO, error);
            }
        }
        else {
            NSLog(@"%@", error.localizedDescription);
            completionHandler(NO, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
        completionHandler(NO, error);
    }];
    [operation setUploadProgressBlock:uploadProgress];
    [self enqueueHTTPRequestOperation:operation];
    self.parameterEncoding = AFJSONParameterEncoding;
}

@end
