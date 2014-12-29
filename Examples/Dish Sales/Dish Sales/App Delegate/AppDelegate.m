//
//  AppDelegate.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/17/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SRAppDelegate.h"
#import "Constants.h"
#import "SRConstants.h"
#import "Agreement+Rabbit.h"
#import "SRMapViewController.h"
#import "Lead+Rabbit.h"
#import "Address+Rabbit.h"
#import "SRManagedDocument.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL ret = [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    return ret;
}

- (void)coreDataModelInitialized:(SRManagedDocument *)modelDocument {
    
    [super coreDataModelInitialized:modelDocument];
    [self cleanupAgreements];
    [self cleanupForLeadSync];
    //[self cleanupLeadsWithMissingLocationInformation];
    [self cleanupSalesMaterials];
    [self checkForCoreDataMigration];
}

-(void)resetMaterialsTimeStamps{
    [super resetMaterialsTimeStamps];
    //This will be called durring the update from dish sales 1.9 to 2.0 because the file that flags wether it is an update or install from backkup hasnt been set
    //In the case of the update form 1.9 to 2.0 we delete all of the sales materials so that they have to re-sync, or the app will crash because of the change in folder system.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        NSError *error = NULL;
        [[NSFileManager defaultManager] removeItemAtPath:documentsDirectory error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
    }
}

// This method is required for app updates prior to version 1.10.  Once all users have version 1.10 or above this can be removed.
-(void)checkForCoreDataMigration
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL migrationPerformed = [defaults objectForKey:kVersion1_10CoreDataMigration];
    if (!migrationPerformed) {
        NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
        NSError *error = nil;
        NSArray *people = [context executeFetchRequest:request error:&error];
        for (Person *person in people) {
            if (person.billingAddress && person.billingAddress.billingPerson != person) {
                Address *address = person.address;
                person.billingAddress.billingPerson = person;
                person.billingAddress.person = NULL;
                person.address = address;
            }
        }
        //[self saveModel];
        [defaults setObject:@YES forKey:kVersion1_10CoreDataMigration];
        [defaults synchronize];
    }
}

- (void)cleanupAgreements {
    
    // TODO: Do this on parent context thread
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Agreement"];
    NSError *error = nil;
    NSArray *agreements = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching agreements for cleanup: %@", error.localizedDescription);
    }
    else {
        for (Agreement *agreement in agreements) {
            if (![agreement.saved boolValue]) {
                // Mark saved any agreement that failed to get marked so because the device crashed possibly
                if (agreement.isStarted) {
                    agreement.saved = @YES;
                }
                // Delete those that haven't been started
                else {
                    [agreement deleteAgreement];
                }
            }
            // Cleanup when I forgot to uncomment the line marking agreements submitted after submission!
            else if (![agreement.submitted boolValue] && agreement.agreementId && agreement.agemniLeadId && agreement.isCompleted) {
                agreement.submitted = @YES;
            }
            // Delete submitted agreements after a year
            else if ([agreement.submitted boolValue] && (-agreement.dateCreated.timeIntervalSinceNow > (60 * 60 * 24 * 365))) {
                [context deleteObject:agreement];
            }
        }
    }
}

- (void)cleanupForLeadSync {
 
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     // Clean up leadIds for syncing web service calls
     // Once we can confirm nobody is upgrading from v1.2 of the app, we can remove this routine and simply add an empty dictionary for kLastLeadSyncDeviceTimestamps in the registerDefaults above
     if (![defaults objectForKey:kLastLeadSyncDeviceTimestamps]) {
         // Delete leadIds
         NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
         NSError *error = nil;
         NSArray *coreDataLeads= [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
         
         NSMutableArray *leadsToDelete = [[NSMutableArray alloc] init];
         for (Lead *lead in coreDataLeads) {
             //delete all invalid leads so sync will work
             if (lead.status == nil) {
                 [leadsToDelete addObject:lead];
             }
             //wipe out old lead IDs and set the saved property on all valid leads
             else {
                 lead.leadId = nil;
                 lead.saved = @YES;
             }
         }
         for (Lead *lead in leadsToDelete) {
             [lead deleteLeadSync:NO];
         }
         
         [defaults setObject:@{} forKey:kLastLeadSyncDeviceTimestamps];
         [defaults setObject:@YES forKey:kBuild20130625BugFix];
         [defaults synchronize];
     }
     else if (![defaults objectForKey:kBuild20130625BugFix]) {
         // Fix bug in build 20130625 where dateModified is set to nill on first sync. This fix can be removed when we can confirm that nobody has this build installed anymore.
         // Clear sync timestamps to force a full sync again
         [defaults setObject:@{} forKey:kLastLeadSyncDeviceTimestamps];
         [defaults setObject:@{} forKey:kLastLeadSyncServerTimestamps];
         [defaults setObject:@YES forKey:kBuild20130625BugFix];
         [defaults synchronize];
     }
 }

/*  If /Documents/<systemAccountId exists>, then sales materials need to be moved to /Documents/SalesMaterials/<systemAccountId>
 The filenames will then be changed to reflect the material id rather than the name to avoid illegal characters.
 Only necessary for users with version 1.4 or prior versions.  Can be removed once no one has any version older than that.
 */
- (void)cleanupSalesMaterials {
 
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     if (![defaults objectForKey:kVersion1_4SalesMaterialsBugFix]) {
         
         NSFileManager *fileManager = [NSFileManager defaultManager];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         
         //Find all old sales materials directories
         NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
         NSError *contentsError;
         NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&contentsError];
         for (NSString *item in directoryContents){
             //don't look at any items that contain non-numerical characters
             if ([item rangeOfCharacterFromSet:notDigits].location != NSNotFound) {
                 continue;
             }
             
             NSString *itemPath = [documentsDirectory stringByAppendingPathComponent:item];
             BOOL isDirectory;
             BOOL pathExists = [fileManager fileExistsAtPath:itemPath isDirectory:&isDirectory];
             
             //Cleanup sales materials if old folder is found
             if (pathExists && isDirectory) {
                 NSString *oldSalesMaterialsPath = itemPath;
                 
                 //initialize sales materials arrays from old filepath
                 NSString *salesMaterialsFilePath = [oldSalesMaterialsPath stringByAppendingPathComponent:kSalesMaterialsFileName];
                 NSMutableDictionary *salesMaterials = [[NSMutableDictionary alloc] initWithContentsOfFile:salesMaterialsFilePath];
                 [self addSkipBackupAttributeToItemAtURL:salesMaterialsFilePath];
                 
                 NSMutableArray *materialListTitles = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"Titles"]];
                 NSMutableArray *materialIDs = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"IDs"]];
                 NSMutableArray *materialList = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"FileName"]];
                 
                 if(materialListTitles == NULL) {
                     materialListTitles = [[NSMutableArray alloc] init];
                 }
                 
                 //create new directory and move directory
                 NSString *newSalesMaterialsPath = [paths objectAtIndex:0];
                 newSalesMaterialsPath = [newSalesMaterialsPath stringByAppendingPathComponent:kSalesMaterialsDirectory];
                 
                 NSError *createDirError;
                 if (![fileManager fileExistsAtPath:newSalesMaterialsPath]) {
                     [fileManager createDirectoryAtPath:newSalesMaterialsPath withIntermediateDirectories:YES attributes:nil error:&createDirError];
                 }
                 
                 if (!createDirError) {
                     newSalesMaterialsPath = [newSalesMaterialsPath stringByAppendingPathComponent:item];
                     NSError *moveDirError;
                     [fileManager moveItemAtPath:oldSalesMaterialsPath toPath:newSalesMaterialsPath error:&moveDirError];
                     
                     //rename files
                     if (!moveDirError) {
                         NSMutableArray *newMaterialList = [[NSMutableArray alloc] initWithCapacity:[materialList count]];
                         int index = 0;
                         for (NSString *fileName in materialList) {
                             NSString *extension = [fileName pathExtension];
                             NSString *newFileName = [[materialIDs objectAtIndex:index] stringByAppendingPathExtension:extension];
                             NSString *newFilePath = [newSalesMaterialsPath stringByAppendingPathComponent:newFileName];
                             NSString *oldFilePath = [newSalesMaterialsPath stringByAppendingPathComponent:fileName];
                             
                             NSError *moveItemError;
                             [fileManager moveItemAtPath:oldFilePath toPath:newFilePath error:&moveItemError];
                             
                             if (!moveItemError) {
                                 [newMaterialList addObject:newFileName];
                                 index++;
                             }
                             else {
                                 [materialIDs removeObjectAtIndex:index];
                                 [materialListTitles removeObjectAtIndex:index];
                                 [salesMaterials setObject:materialIDs forKey:@"IDs"];
                                 [salesMaterials setObject:materialListTitles forKey:@"Titles"];
                             }
                         
                         }
                         materialList = newMaterialList;
                         [salesMaterials setObject:materialList forKey:@"FileName"];
                         [salesMaterials writeToFile:[self salesMaterialsDataFilePath:kSalesMaterialsFileName systemAccountId:item] atomically:YES];
                         [self addSkipBackupAttributeToItemAtURL:[self salesMaterialsDataFilePath:kSalesMaterialsFileName systemAccountId:item]];
                     }
                 }
             
             }
         }
        // Fix bug in version 1.4 and previous where sales materials were saved by material title. This can be removed when no one has version 1.4 or any version older than that.
        [defaults setObject:@YES forKey:kVersion1_4SalesMaterialsBugFix];
        [defaults synchronize];
    }
 }


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URLstring
{
    NSURL *URL = [NSURL fileURLWithPath:URLstring];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (NSString *)salesMaterialsDataFilePath:(NSString *)fileName systemAccountId:(NSString *)systemAccountId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:systemAccountId];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

// Overriden for subclassed service calls
- (ServiceCalls *)initializeServiceCalls {
    
    return [[ServiceCalls alloc] init];
}

@end
