//
//  SRSalesAppDelegate.m
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSalesAppDelegate.h"
#import "Lead+Rabbit.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "SRMapViewController.h"
#import "SRParentLeadViewController.h"
#import "SRConstants.h"
#import "SRSalesConstants.h"
#import "Constants.h"
#import "SRMaterialsState.h"
#import "SRSalesHomeViewController.h"
#import "SRManagedDocument.h"

@implementation SRSalesAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [SRSalesConstants initValues];
    BOOL ret = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //Check for notification
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSString *leadId = [[notification userInfo] objectForKey:kLeadId];
        if (leadId) {
            if ([[SRGlobalState singleton] loggedIn]) {
                [[[SRMaterialsState singleton] tabBarViewController] setSelectedViewController:[[[[SRMaterialsState singleton] tabBarViewController] viewControllers] objectAtIndex:kLeadsTab]];
                
                NSArray *viewControllers = [[[[[SRMaterialsState singleton] tabBarViewController] viewControllers] objectAtIndex:kLeadsTab] childViewControllers];
                SRParentLeadViewController *parentVC;
                for (UIViewController *viewController in viewControllers) {
                    if ([viewController isMemberOfClass:[SRParentLeadViewController class]]) {
                        parentVC = (SRParentLeadViewController *)viewController;
                        break;
                    }
                }
                if (parentVC) {
                    parentVC.leadsViewContainer.hidden = YES;
                    parentVC.streetViewContainer.hidden = YES;
                    parentVC.mapViewContainer.hidden = NO;
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
                    request.predicate = [NSPredicate predicateWithFormat:@"leadId == %@ && userId == %@", leadId, [[SRGlobalState singleton] userId]];
                    NSError *error;
                    NSArray *result = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
                    if (result.count > 0) {
                        parentVC.mapViewVC.leadToEdit = [result objectAtIndex:0];
                        [parentVC.mapViewVC performSegueWithIdentifier:@"MapToLeadDetail" sender:self];
                        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Scheduled Appointment"
                                                                                    message:notification.alertBody
                                                                                   delegate:nil
                                                                          cancelButtonTitle:kOk
                                                                          otherButtonTitles:nil];
                        [notificationAlert show];
                    }
                }
            }
            else {
                [[SRGlobalState singleton] setLeadIdFromNotification:leadId];
                [[SRGlobalState singleton] setAlertBody:notification.alertBody];
            }
        }
    }
    [self resetUserDefaultTimestampsIfRestoringFromBackup];
    return ret;
}

-(void)resetUserDefaultTimestampsIfRestoringFromBackup{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:@"restoringFromBackupFlag"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    // If this file does not exist, they are restoring from back up or doing a clean install - either way the timestamps should be reset to 0 for materials.
    if (!fileExists) {
        [self resetMaterialsTimeStamps];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        NSURL *URL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    }
}

- (NSString *)dataFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[SRGlobalState singleton].systemAccountId];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
    
}

-(void)resetMaterialsTimeStamps{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@{} forKey:kCompanyLogoDictionary];
    [defaults setObject:@{} forKey:kSalesMaterialsTimestampDictionary];
    
    [defaults synchronize];
}

- (NSDictionary *)defaultNSUserDefaults {
    
    NSMutableDictionary *defaults = [[super defaultNSUserDefaults] mutableCopy];
    [defaults addEntriesFromDictionary:@{kSalesMaterialsTimestampDictionary:@{}, kLastLeadSyncServerTimestamps:@{}, kDeletedLeadIds:@[], kAgreementContactAndTermsDictionary:@{}}];
    return defaults;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Default implementation does nothing
    NSString *leadId = [[notification userInfo] objectForKey:kLeadId];
    if (leadId) {
        if ([[SRGlobalState singleton] loggedIn]) {
            [[[SRMaterialsState singleton] tabBarViewController] setSelectedViewController:[[[[SRMaterialsState singleton] tabBarViewController] viewControllers] objectAtIndex:kLeadsTab]];
            
            NSArray *viewControllers = [[[[[SRMaterialsState singleton] tabBarViewController] viewControllers] objectAtIndex:kLeadsTab] childViewControllers];
            SRParentLeadViewController *parentVC;
            for (UIViewController *viewController in viewControllers) {
                if ([viewController isMemberOfClass:[SRParentLeadViewController class]]) {
                    parentVC = (SRParentLeadViewController *)viewController;
                    break;
                }
            }
            if (parentVC) {
                parentVC.leadsViewContainer.hidden = YES;
                parentVC.streetViewContainer.hidden = YES;
                parentVC.mapViewContainer.hidden = NO;
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
                request.predicate = [NSPredicate predicateWithFormat:@"leadId == %@ && userId == %@", leadId, [[SRGlobalState singleton] userId]];
                NSError *error;
                NSArray *result = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
                if (result.count > 0) {
                    parentVC.mapViewVC.leadToEdit = [result objectAtIndex:0];
                    [parentVC.mapViewVC performSegueWithIdentifier:@"MapToLeadDetail" sender:self];
                    UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Scheduled Appointment"
                                                                                message:notification.alertBody
                                                                               delegate:nil
                                                                      cancelButtonTitle:kOk
                                                                      otherButtonTitles:nil];
                    [notificationAlert show];
                }
            }
        }
        else {
            [[SRGlobalState singleton] setLeadIdFromNotification:leadId];
            [[SRGlobalState singleton] setAlertBody:notification.alertBody];
        }
    }
}

- (BOOL)shouldLogout {
    
    if ([SRMaterialsState singleton].tabBarViewController) {
        if (-[SRGlobalState singleton].backgroundTimeStamp.timeIntervalSinceNow > kSecondsBeforeForcedLogout) { // idle logout
            return YES;
        }
    }
    return NO;
}

- (void)logout {
    
    [(SRSalesHomeViewController *)[SRMaterialsState singleton].tabBarViewController.viewControllers[0] logout];
}

- (void)coreDataModelInitialized:(SRManagedDocument *)modelDocument {
    
    [super coreDataModelInitialized:modelDocument];
    //[self disableUndoManager];
    
    // Cleanup agreements and leads not saved if app force closed
    [self cleanupLeads];
}

- (void)cleanupLeads {
    
    // TODO: Do this on parent context thread
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
    request.predicate = [NSPredicate predicateWithFormat:@"saved == NO"];
    NSError *error = nil;
    NSArray *leads = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching agreements for cleanup: %@", error.localizedDescription);
    }
    else {
        for (Lead *lead in leads) {
            if (![lead.saved boolValue]) {
                // Mark saved any lead that failed to get marked so because the device crashed possibly
                if (lead.status != nil) {
                    lead.saved = @YES;
                }
                // Delete all other leads
                else {
                    [lead deleteLeadSync:NO];
                }
            }
        }
    }
}

// Overriden for subclassed service calls
- (SRServiceCalls *)initializeServiceCalls {
    
    return [[SRSalesServiceCalls alloc] init];
}

@end
