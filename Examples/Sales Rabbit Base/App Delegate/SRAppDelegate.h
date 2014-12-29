//
//  SRAppDelegate.h
//  Original Sales
//
//  Created by Brady Anderson on 10/17/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRGlobalState.h"
#import "SRServiceCalls.h"

@interface SRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)singleton;
+ (void)logout;
- (void)logout;
- (BOOL)shouldLogout;
- (void)saveModel;
- (NSDictionary *)defaultNSUserDefaults;
- (void)coreDataModelInitialized:(SRManagedDocument *)modelDocument;
- (void)initializeCoreDataModel;

/**
 * Override this method in the app delegate subclass and return the global state subclass that the app is using if there is one.
 */
- (SRGlobalState *)initializeGlobalState;

/**
 * Override this property in the app delegate subclass and set the type to the global state subclass that the app is using if there is one.
 */
@property (strong, nonatomic) SRGlobalState *globalState;

/**
 * Override this method in the app delegate subclass and return the service calls subclass that the app is using if there is one.
 */
- (SRServiceCalls *)initializeServiceCalls;

/**
 * Override this property in the app delegate subclass and set the type to the service calls subclass that the app is using if there is one.
 */
@property (strong, nonatomic) SRServiceCalls *serviceCalls;

@end
