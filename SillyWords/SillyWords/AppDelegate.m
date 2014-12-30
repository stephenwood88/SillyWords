//
//  AppDelegate.m
//  TutorialBase
//
//  Created by Antonio MG on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "GlobalState.h"

@implementation AppDelegate

@synthesize window = _window;

+ (instancetype)singleton {
    
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#warning Set Parse app ID and client key
    [Parse setApplicationId:@"K6hXi37dgxqragNRyliAbxcYkvykpk3t3zKH4yFp" clientKey:@"6mZmMAiQ3exKDVS1va2sutimSnP2lj17zuEGNTLA"];
    
    [PFFacebookUtils initializeFacebook];
    [FBProfilePictureView class];
    [self initializeCoreDataModel];
   
    return YES;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    //return [PFFacebookUtils handleOpenURL:url];
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - Core Data

- (void)initializeCoreDataModel
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:@"SillyWords.sqlite"];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    UIManagedDocument *modelDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    modelDocument.persistentStoreOptions = options;
    if ([fileManager fileExistsAtPath:url.path]) {
        [modelDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
//                if (kNeedsEncryption) {
//                    if (![self restoreEncryptionKey]) { // If encryption key is not in keychain, must reset core data model since there's no way to decrypt it
//                        NSAssert(NO, @"We should never be getting into this block of code. Something happened that is preventing the encryption key from being restored. The encryption key is required to decrypt the encrypted data in the persistent store.");
//                        /*NSError *error = nil;
//                         [fileManager removeItemAtURL:url error:&error];
//                         if (error) {
//                         NSLog(@"Error deleting core data file after no encryption key found: %@", error.localizedDescription);
//                         }
//                         [self initializeCoreDataModel];*/
//                       // NSString *username = [[SRGlobalState singleton] userName];
//                       // NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Something happened that is preventing the encryption key from being restored.", nil];
//                      //  [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
//                    }
//                }
                [self coreDataModelInitialized:modelDocument];
            }
            // TODO: Need to migrate any schema changes properly to prevent deleting user data
            else if (modelDocument.documentState & UIDocumentStateSavingError) { // Core Data schema is incorrect version
                NSAssert(NO, @"We should never be getting into this block of code. Something happened which changed the model schema in a way that the old model file cannot be migrated to the new schema using lightweight migration techniques. Either a manual migration needs to be setup, or we need to rethink whatever changes were made.");
                //NSString *username = [[SRGlobalState singleton] userName];
               // NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Wrong schema version found-couldnt migrate.", nil];
                //[Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
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
                //NSString *username = [[SRGlobalState singleton] userName];
                //NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Error", @"Failed to open core data model file!", nil];
                //[Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
            }
        }];
    }
    else {
        [modelDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
//                if (kNeedsEncryption) {
//                    [self generateEncryptionKey];
//                }
                [self coreDataModelInitialized:modelDocument];
            }
            else {
                NSLog(@"Failed to save new core data model file!");
                //NSString *username = [[SRGlobalState singleton] userName];
               // NSDictionary *articleParams = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"User", @"Error", @"Failed to save new core data model file!", nil];
               // [Flurry logEvent:@"Core Data Save Error" withParameters:articleParams timed:NO];
            }
        }];
    }
}

- (void)coreDataModelInitialized:(UIManagedDocument *)modelDocument {
    
    [[GlobalState singleton] setModelDocument:modelDocument];
}

//- (BOOL)restoreEncryptionKey {
//    
//    NSDictionary *query = [self encryptionKeyKeychainDictionary];
//    CFTypeRef result = nil;
//    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
//    if (status) {
//        NSLog(@"Keychain error restoring key: %ld (statuscode)", (long)status);
//    }
//    if (!result) {
//        return NO;
//    }
//    NSData *data = (__bridge NSData *)result;
//    EncryptedStringTransformer *stringTransformer = (EncryptedStringTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedStringTransformer"];
//    stringTransformer.key = kPublicEncryptionKey;
//    stringTransformer.salt = nil;
//    NSString *encryptionKey = [stringTransformer reverseTransformedValue:data];
//    if (!encryptionKey) {
//        return NO;
//    }
//    // Initialize encryption transformers with private key
//    stringTransformer.key = encryptionKey;
//    EncryptedImageTransformer *imageTransformer = (EncryptedImageTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedImageTransformer"];
//    imageTransformer.key = encryptionKey;
//    return YES;
//}


@end
