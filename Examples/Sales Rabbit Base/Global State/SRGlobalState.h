//
//  SRGlobalState.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/19/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRManagedDocument.h"

@interface SRGlobalState : NSObject

// Providers, logo timestamp, sales
@property (strong, nonatomic) NSDictionary *loginInfoDictionary;
@property (strong, nonatomic) NSDate *backgroundTimeStamp;
@property (strong, nonatomic) UIImage *companyLogo;

// Core data model
@property (strong, nonatomic) SRManagedDocument *modelDocument;

// Department management
@property (strong, nonatomic) NSDictionary *activeDepartments; // key-companyId(NSString) -> (key-@"DepartmentCode"->value-departmentCode(NSString)) OR (key-@"DepartmentTitle"->value-departmentTitle(NSString))
- (NSString *)departmentCode;
- (NSString *)departmentTitle;

// Alert Views
@property (nonatomic) BOOL alertViewActive;

/**
 * DO NOT OVERRIDE this method
 * There should only be one singleton object for all global state subclasses, whether accessed via the parent or the child class method. This global state singleton is instantiated in the app delegate. If the global state is subclassed, return an instatiated subclassed global state object in the - (SRGlobalState *)initializeGlobalState method, overridden in the app delegate subclass.
 */
+ (instancetype)singleton;

// Core data model
- (NSManagedObjectContext *)managedObjectContext;

// Login dictionary convenience accessors
- (NSString *)countryCode;
- (NSString *)companyId;
- (NSString *)systemAccountId;
- (NSString *)areaId;
- (NSString *)userId;
- (NSString *)repId;
- (NSString *)userName;
- (NSString *)userType;
- (NSString *)officeId;
- (NSTimeInterval)agreementSettingsUpdated;
- (NSTimeInterval)logoTimeStamp;
- (NSTimeInterval)salesMaterialsUpdatedDate;
- (NSTimeInterval)termsPDFUpdated;
- (NSString *)satelliteProvider;
- (NSArray *)userDepartments;
- (CGFloat)accentColorValueRed;
- (CGFloat)accentColorValueGreen;
- (CGFloat)accentColorValueBlue;
- (UIColor *)accentColor;
- (BOOL)agreementsConfigured;
- (BOOL)integratedWithAgemni;
- (BOOL)prequalEnabled;

//Local Notifications
@property (nonatomic) BOOL loggedIn;
@property (strong, nonatomic) NSString *leadIdFromNotification;
@property (strong, nonatomic) NSString *alertBody;
@property (nonatomic) dispatch_queue_t appointmentQueue;

- (BOOL)isAppleTester;

@end
