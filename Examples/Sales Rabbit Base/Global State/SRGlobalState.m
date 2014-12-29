//
//  SRGlobalState.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/19/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRGlobalState.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation SRGlobalState

/**
 * DO NOT OVERRIDE this method
 * There should only be one singleton object for all global state subclasses, whether accessed via the parent or the child class method. This global state singleton is instantiated in the app delegate. If the global state is subclassed, return an instatiated subclassed global state object in the - (SRGlobalState *)initializeGlobalState method, overridden in the app delegate subclass.
 */
+ (instancetype)singleton {
    
    return [[SRAppDelegate singleton] globalState];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    return self.modelDocument.managedObjectContext;
}

#pragma mark - Login dictionary convenience accessors

- (NSString *)countryCode {
    
    return self.loginInfoDictionary[@"SystemAccountCountry"];
}

- (NSString *)companyId {
    
    return self.loginInfoDictionary[@"CompanyID"];
}

- (NSString *)systemAccountId {
    
    return self.loginInfoDictionary[@"SystemAccountID"];
}

- (NSString *)userId {
    
    return self.loginInfoDictionary[@"UserID"];
}

- (NSString *)repId {
    if ([self.loginInfoDictionary[@"RepID"] count]) {
        return [self.loginInfoDictionary[@"RepID"] firstObject];
    }
    return @"N/A";
}

- (NSString *)userName {
    
    return self.loginInfoDictionary[@"UserName"];
}

- (NSString *)userType {

    return self.loginInfoDictionary[@"UserType"];
}

- (NSString *)areaId
{
    return self.loginInfoDictionary[@"AreaID"];
}

- (NSString *)officeId {
    
    return self.loginInfoDictionary[@"OfficeID"];
}

- (NSTimeInterval)agreementSettingsUpdated {
    
    return [self.loginInfoDictionary[@"agreementSettingsUpdated"] doubleValue];
}

- (NSTimeInterval)termsPDFUpdated {
    if ([self.loginInfoDictionary[@"termsPDFUpdated"] isKindOfClass:[NSNull class]] ) {
        return 0;
    }
    return [self.loginInfoDictionary[@"termsPDFUpdated"] doubleValue];
}

- (NSTimeInterval)logoTimeStamp {
    
    return [self.loginInfoDictionary[@"logoTimestamp"] doubleValue];
}

- (NSTimeInterval)salesMaterialsUpdatedDate {
    
    return [self.loginInfoDictionary[@"salesMaterialsUpdatedDate"] doubleValue];
}

- (NSString *)satelliteProvider {
    
    return self.loginInfoDictionary[@"satelliteProvider"];
}

- (NSArray *)userDepartments {
    
    return self.loginInfoDictionary[@"userDepartments"];
}

- (CGFloat)accentColorValueRed {
    return [[self.loginInfoDictionary[@"accentColor"] objectForKey:@"red"] floatValue]/255.0;
}

- (CGFloat)accentColorValueGreen {
    return [[self.loginInfoDictionary[@"accentColor"] objectForKey:@"green"] floatValue]/255.0;
}

- (CGFloat)accentColorValueBlue {
    return [[self.loginInfoDictionary[@"accentColor"] objectForKey:@"blue"] floatValue]/255.0;
}

- (UIColor *)accentColor{
    return [UIColor colorWithRed:[self accentColorValueRed] green:[self accentColorValueGreen] blue:[self accentColorValueBlue] alpha:1];
}

- (BOOL)isAppleTester {
    
    return [self.systemAccountId isEqualToString:@"3"] && [self.userId isEqualToString:@"11684403"];
}

// Department managment
- (NSString *)departmentCode {

    return [[self.activeDepartments objectForKey:self.companyId] objectForKey:@"CompanyCode"];
}

- (NSString *)departmentTitle {

    return [[self.activeDepartments objectForKey:self.companyId] objectForKey:@"CompanyTitle"];
}

- (BOOL)agreementsConfigured{
    if ([[self companyId] isEqualToString:@"145"]) {
        return YES;
    }
    return NO;
}

- (BOOL)integratedWithAgemni{
    return [self.loginInfoDictionary[@"CRM"] isEqualToString:@"agemni"];
}

- (BOOL)prequalEnabled
{
#ifdef DISHONE
    return YES;
#endif

    if ([self.loginInfoDictionary[@"PrequalEnabled"] isEqual: @(NO)]) {
        return NO;
    }
    else{
        return YES;
    }
}

#pragma mark - Queue accessor

- (dispatch_queue_t)appointmentQueue {
    if (_appointmentQueue) {
        return _appointmentQueue;
    }
    
    _appointmentQueue = dispatch_queue_create("com.mysalesrabbit.appointment", NULL);
    return _appointmentQueue;
}

@end
