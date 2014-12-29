//
//  SRAppDelegate.m
//  Original Sales
//
//  Created by Brady Anderson on 10/17/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRAppDelegate.h"
#import "Constants.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Flurry.h"
#import "EncryptedImageTransformer.h"
#import "EncryptedStringTransformer.h"
#import "AVTextUtilities.h"
#import "SRManagedDocument.h"

@implementation SRAppDelegate

+ (instancetype)singleton {
    
    return [[UIApplication sharedApplication] delegate];
}

+ (void)logout {
    
    [[self singleton] logout];
}

+ (void)initialize {
    
    [super initialize];
    // Register value transformers for core data
    [NSValueTransformer setValueTransformer:[[EncryptedImageTransformer alloc] init] forName:@"EncryptedImageTransformer"];
    [NSValueTransformer setValueTransformer:[[EncryptedStringTransformer alloc] init] forName:@"EncryptedStringTransformer"];
}

- (void)customizeAppearance {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIButton appearance] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [[UIButton appearance] setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [[UIProgressView appearance] setTrackTintColor:[UIColor grayColor]];
}

#pragma Custom Initialization

- (NSDictionary *)defaultNSUserDefaults {
    
    return @{kCompanyLogoDictionary:@{}, kUserLastDepartmentDictionary:@{}};
}

#pragma mark - App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.globalState = [self initializeGlobalState];
    self.serviceCalls = [self initializeServiceCalls];
    
    [self customizeAppearance];
    [Constants initValues];
    [self initializeCoreDataModel];
    
//    Disable these lines except when submitting an update
//    [Flurry setCrashReportingEnabled:YES];
//    [Flurry startSession:kFlurryAppKey];

    // This will enable Flurry logging to console
//    [Flurry setDebugLogEnabled:YES];
    
    // Set defaults for NSUserDefaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultNSUserDefaults]];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Default implementation does nothing
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [SRGlobalState singleton].backgroundTimeStamp = [NSDate date];
    //[self saveModel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([self shouldLogout]) {
        [self logout];
    }
}

- (BOOL)shouldLogout {
    
    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //[self saveModel];
}

#pragma mark - Core Data

- (void)initializeCoreDataModel
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:kCoreDataPath];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    SRManagedDocument *modelDocument = [[SRManagedDocument alloc] initWithFileURL:url];
    modelDocument.persistentStoreOptions = options;
    if ([fileManager fileExistsAtPath:url.path]) {
        [modelDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                if (kNeedsEncryption) {
                    if (![self restoreEncryptionKey]) { // If encryption key is not in keychain, must reset core data model since there's no way to decrypt it
                        NSAssert(NO, @"We should never be getting into this block of code. Something happened that is preventing the encryption key from being restored. The encryption key is required to decrypt the encrypted data in the persistent store.");
                        /*NSError *error = nil;
                        [fileManager removeItemAtURL:url error:&error];
                        if (error) {
                            NSLog(@"Error deleting core data file after no encryption key found: %@", error.localizedDescription);
                        }
                        [self initializeCoreDataModel];*/
                        NSString *username = [[SRGlobalState singleton] userName];
                        NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Something happened that is preventing the encryption key from being restored.", nil];
                        [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
                    }
                }
                [self coreDataModelInitialized:modelDocument];
            }
            // TODO: Need to migrate any schema changes properly to prevent deleting user data
            else if (modelDocument.documentState & UIDocumentStateSavingError) { // Core Data schema is incorrect version
                NSAssert(NO, @"We should never be getting into this block of code. Something happened which changed the model schema in a way that the old model file cannot be migrated to the new schema using lightweight migration techniques. Either a manual migration needs to be setup, or we need to rethink whatever changes were made.");
                NSString *username = [[SRGlobalState singleton] userName];
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Wrong schema version found-couldnt migrate.", nil];
                [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
                // Delete file and start over for now
                /*NSError *error = nil;
                [fileManager removeItemAtURL:url error:&error];
                if (error) {
                    NSLog(@"Error deleting core data file after wrong schema version found: %@", error.localizedDescription);
                }
                [self initializeCoreDataModel];*/
            }
            else {
                NSLog(@"Failed to open core data model file!");
                NSString *username = [[SRGlobalState singleton] userName];
                NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Failed to open core data model file!", nil];
                [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
            }
        }];
    }
    else {
        [modelDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                if (kNeedsEncryption) {
                    [self generateEncryptionKey];
                }
                [self coreDataModelInitialized:modelDocument];
            }
            else {
                NSLog(@"Failed to save new core data model file!");
                NSString *username = [[SRGlobalState singleton] userName];
                NSDictionary *articleParams = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"User", @"Error", @"Failed to save new core data model file!", nil];
                [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
            }
        }];
    }
}

- (void)coreDataModelInitialized:(SRManagedDocument *)modelDocument {
    
    [[SRGlobalState singleton] setModelDocument:modelDocument];
}

// TODO: So why does this keep core data from persisting any data?
/*- (void)disableUndoManager {
 
 // Set undo manager to nil to increase performance, unless we need undo support
 // https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdPerformance.html
 [[[SRGlobalState singleton] managedObjectContext] setUndoManager:nil];
 }*/

- (void)logout {
    //No default implementation
}

- (void)saveModel {
    
    //NSLog(@"Managed object context has changes: %s", [self.SRGlobalState.managedObjectContext hasChanges]?"Yes":"No");
    if ([[SRGlobalState singleton].managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![[SRGlobalState singleton].managedObjectContext save:&error]) {
            // Core Data info log output
            /*NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
             NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
             if (detailedErrors != nil && [detailedErrors count] > 0) {
             for(NSError* detailedError in detailedErrors) {
             NSLog(@"  DetailedError: %@", [detailedError userInfo]);
             }
             }
             else {
             NSLog(@"  %@", [error userInfo]);
             }*/
            
            // Better formatted core data info log output
            if ([[error domain] isEqualToString:@"NSCocoaErrorDomain"]) {
                // ...check whether there's an NSDetailedErrors array
                NSDictionary *userInfo = [error userInfo];
                if ([userInfo valueForKey:@"NSDetailedErrors"] != nil) {
                    // ...and loop through the array, if so.
                    NSArray *errors = [userInfo valueForKey:@"NSDetailedErrors"];
                    for (NSError *anError in errors) {
                        
                        NSDictionary *subUserInfo = [anError userInfo];
                        subUserInfo = [anError userInfo];
                        // Granted, this indents the NSValidation keys rather a lot
                        // ...but it's a small loss to keep the code more readable.
                        NSLog(@"Core Data Save Error\n\n \
                              NSValidationErrorKey\n%@\n\n \
                              NSValidationErrorPredicate\n%@\n\n \
                              NSValidationErrorObject\n%@\n\n \
                              NSLocalizedDescription\n%@",
                              [subUserInfo valueForKey:@"NSValidationErrorKey"],
                              [subUserInfo valueForKey:@"NSValidationErrorPredicate"],
                              [subUserInfo valueForKey:@"NSValidationErrorObject"],
                              [subUserInfo valueForKey:@"NSLocalizedDescription"]);
                    }
                }
                // If there was no NSDetailedErrors array, print values directly
                // from the top-level userInfo object. (Hint: all of these keys
                // will have null values when you've got multiple errors sitting
                // behind the NSDetailedErrors key.
                else {
                    NSLog(@"Core Data Save Error\n\n \
                          NSValidationErrorKey\n%@\n\n \
                          NSValidationErrorPredicate\n%@\n\n \
                          NSValidationErrorObject\n%@\n\n \
                          NSLocalizedDescription\n%@",
                          [userInfo valueForKey:@"NSValidationErrorKey"],
                          [userInfo valueForKey:@"NSValidationErrorPredicate"],
                          [userInfo valueForKey:@"NSValidationErrorObject"],
                          [userInfo valueForKey:@"NSLocalizedDescription"]);
                }
            }
            // Handle mine--or 3rd party-generated--errors
            else {
                NSLog(@"Custom Error: %@", [error localizedDescription]);
            }
        }
        [[SRGlobalState singleton].managedObjectContext.parentContext save:&error];
        /*else {
         NSLog(@"Changes saved");
         }*/
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Encryption Methods

- (void)generateEncryptionKey {
    
    NSMutableDictionary *query = [self encryptionKeyKeychainDictionary];
    // Remove item if it exists
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    EncryptedStringTransformer *stringTransformer = (EncryptedStringTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedStringTransformer"];
    stringTransformer.key = kPublicEncryptionKey;
    stringTransformer.salt = nil;
    NSString *encryptionKey = [AVTextUtilities randomStringOfLength:32];
    NSData *data = [stringTransformer transformedValue:encryptionKey];
    // Set data (encrypted private key)
    query[(__bridge id)kSecValueData] = data;
    
    CFTypeRef result = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, &result);
    if (status) {
        NSLog(@"Keychain error adding generated key: %ld (statuscode)", (long)status);
    }
    
    // Initialize encryption transformers with private key
    stringTransformer.key = encryptionKey;
    EncryptedImageTransformer *imageTransformer = (EncryptedImageTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedImageTransformer"];
    imageTransformer.key = encryptionKey;
}

- (BOOL)restoreEncryptionKey {
    
    NSDictionary *query = [self encryptionKeyKeychainDictionary];
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status) {
        NSLog(@"Keychain error restoring key: %ld (statuscode)", (long)status);
    }
    if (!result) {
        return NO;
    }
    NSData *data = (__bridge NSData *)result;
    EncryptedStringTransformer *stringTransformer = (EncryptedStringTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedStringTransformer"];
    stringTransformer.key = kPublicEncryptionKey;
    stringTransformer.salt = nil;
    NSString *encryptionKey = [stringTransformer reverseTransformedValue:data];
    if (!encryptionKey) {
        return NO;
    }
    // Initialize encryption transformers with private key
    stringTransformer.key = encryptionKey;
    EncryptedImageTransformer *imageTransformer = (EncryptedImageTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedImageTransformer"];
    imageTransformer.key = encryptionKey;
    return YES;
}

- (NSMutableDictionary *)encryptionKeyKeychainDictionary {
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassKey;
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked;
    query[(__bridge id)kSecReturnData] = @YES;
    // Access key
    query[(__bridge id)kSecAttrApplicationTag] = kEncryptionKeyApplicationTag;
    return query;
}

/**
 * Override this method in the app delegate subclass and return the global state subclass that the app is using if there is one.
 */
- (SRGlobalState *)initializeGlobalState {
    
    return [[SRGlobalState alloc] init];
}

/**
 * Override this method in the app delegate subclass and return the service calls subclass that the app is using if there is one.
 */
- (SRServiceCalls *)initializeServiceCalls {
    
    return [[SRServiceCalls alloc] init];
}

@end
