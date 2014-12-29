//
//  SRPremiumSalesServiceCalls.m
//  Security Sales
//
//  Created by Bryan Bryce on 2/19/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumSalesServiceCalls.h"
#import "SRGlobalState.h"
#import "Constants.h"
#import "SRPremiumConstants.h"

#import "Department+Rabbit.h"
#import "Region+Rabbit.h"
#import "Office+Rabbit.h"
#import "Area+Rabbit.h"
#import "MapPoint+Rabbit.h"
#import "User+Rabbit.h"
#import "UserLocation+Rabbit.h"
#import "SlimLead+Rabbit.h"
#import "Prequal+Rabbit.h"

@interface SRPremiumSalesServiceCalls ()

@property (nonatomic) BOOL syncMapScheduled;
@property (nonatomic) BOOL syncMapRunning;

@end

@implementation SRPremiumSalesServiceCalls

- (id)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.syncMapScheduled = NO;
        self.syncMapRunning = NO;
        
        self.usersNotificationDict = [NSMutableDictionary dictionary];
        //User Arrays
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kDeletedUsers];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kAddedUsers];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kUpdatedUsers];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kAddedSlimLeads];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kUpdatedSlimLeads];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kDeletedSlimLeads];
        [self.usersNotificationDict setObject:[NSMutableArray array] forKey:kAddedUserLocations];
        
        self.addedPrequals = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPrequal) name:kSyncUserMapFinishedWithCurrentUserActiveAreaChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentChanged) name:kDepartmentChangedNotification object:nil];
        
        
        self.areasNotificationDict = [NSMutableDictionary dictionary];
        //Area Arrays
        [self.areasNotificationDict setObject:[NSMutableArray array] forKey:kAddedAreas];
        [self.areasNotificationDict setObject:[NSMutableArray array] forKey:kUpdatedAreas];
        [self.areasNotificationDict setObject:[NSMutableArray array] forKey:kDeletedAreas];
    }
    return self;
}

-(void)updateTimeStampsAfterLogin{
    [super updateTimeStampsAfterLogin];
    
    NSString *userId = [[SRGlobalState singleton] userId];
    NSString *departmentId = [[SRGlobalState singleton] companyId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastUserMapSyncServer = [[[defaults objectForKey:kLastUserMapSyncServerTimestamps] objectForKey:userId] objectForKey:departmentId];
    self.lastUserMapSyncDevice = [[[defaults objectForKey:kLastUserMapSyncDeviceTimestamps] objectForKey:userId] objectForKey:departmentId];
    
    //Clear out new area index in NSUserDefaults
    NSMutableDictionary *newAreaIndexDict = [[defaults objectForKey:kNewAreaIndex] mutableCopy];
    newAreaIndexDict[userId] = @0;
    [defaults setObject:newAreaIndexDict forKey:kNewAreaIndex];
}

-(void)sync
{
    //NSLog(@"Attempting to sync...");
    [super sync];
    [self syncUserMap];
    //    [self performUserMapSync];//TESTING
}

-(void)departmentChanged{
    NSString *userId = [[SRGlobalState singleton] userId];
    NSString *departmentId = [[SRGlobalState singleton] companyId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.lastUserMapSyncServer = [[[defaults objectForKey:kLastUserMapSyncServerTimestamps] objectForKey:userId] objectForKey:departmentId];
    self.lastUserMapSyncDevice = [[[defaults objectForKey:kLastUserMapSyncDeviceTimestamps] objectForKey:userId] objectForKey:departmentId];
}

/**
 This convenience method makes sure that a user map sync call doesn't get made until a running user map sync call is finished.
 
 syncUserMap should be called ONLY on the main thread.
 
 When it is determined that the map sync is safe to run peformUserMapSync is called.
 */

- (void)syncUserMap {
    
    if (self.syncMapRunning) {
        // Assuming that since these methods will all be called on the main thread, syncScheduled will always be atomically set to NO right after syncRunning is set to YES. This method should never be called in between those two lines or parallel syncs will be scheduled.
        [self scheduleUserMapSyncAfterDelay:kSecondsBetweenUserMapSyncs];
    }
    else if (!self.syncMapScheduled) {
        
        NSDate *lastSyncDevice = self.lastUserMapSyncDevice;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval delay = kSecondsBetweenUserMapSyncs - (now - lastSyncDevice.timeIntervalSince1970);
        if (delay <= 0) {
            DLog(@"sync user map now");
            [self performUserMapSync];
        }
        else {
            DLog(@"sync user map after delay of %f seconds", delay);
            [self scheduleUserMapSyncAfterDelay:delay];
        }
    }
}

/**
 This method schedules a user map sync after a delay in the event that syncUserMap is called while another sync is running.
 */
- (void)scheduleUserMapSyncAfterDelay:(NSTimeInterval)delay {
    
    self.syncMapScheduled = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performUserMapSync) object:nil];
    [self performSelector:@selector(performUserMapSync) withObject:nil afterDelay:delay];
}

/**
 This method is called from syncUserMap to setup data used for the syncUserMap service call made in the (void)syncUserMap: modifiedSince: delete: completionHandler: method.
 */

- (void)performUserMapSync {
    
    // If sync is still in progress (shouldn't be after waiting kSecondsBetweenUserMapSyncs), reschedule it again.
    if (self.syncMapRunning) {
        [self scheduleUserMapSyncAfterDelay:kSecondsBetweenUserMapSyncs];
        return;
    }
    self.syncMapRunning = YES;
    self.syncMapScheduled = NO;
    
    //Get data needed for service call
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [[SRGlobalState singleton] userId];
    
    NSArray *deletedAreaIds = [defaults objectForKey:kDeletedAreaIds];
    
    // Clear out deleted area ids right after they are sent to server.
    [self clearOutNewAndDeletedAreaData];
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    //Fetch the current user's locations that haven't yet been synced
    NSFetchRequest *userLocationsFetch = [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];
    
    if (self.lastUserMapSyncDevice) {
        // userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"(user.userId == %@)", userId];
        userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"((user.userId == %@) AND (%@ < dateCreated))", userId, self.lastUserMapSyncDevice];
    }
    else {
        // First sync won't have a last sync date
        userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"(user.userId == %@)", userId];
    }
    NSError *userLocationsFetchError = nil;
    NSArray *userLocations = [context executeFetchRequest:userLocationsFetch error:&userLocationsFetchError];
    
    //Fetch all areas from core data that haven't been saved to the server and all areas that have been modified since the last sync
    NSFetchRequest *areasToSyncFetch = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    //Areas that haven't been synced do not have an area ID
    if (self.lastUserMapSyncDevice) {
        //areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"((areaId == nil) OR (%@ < dateModified))", lastSyncDevice];
        areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"(((areaId.integerValue < 0 AND office != nil) OR (%@ < dateModified)) AND areaId.integerValue != 0)", self.lastUserMapSyncDevice];
    }
    else{
        //areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"areaId == nil"];
        areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"(areaId.integerValue < 0 AND office != nil)"];
    }
    // Update device sync timeStamp right after query
    self.lastUserMapSyncDevice = [NSDate date];
    
    NSError *areasToSyncFetchError = nil;
    NSArray *areasToSync = [context executeFetchRequest:areasToSyncFetch error:&areasToSyncFetchError];
    
    
    
    if (!userLocationsFetchError && !areasToSyncFetchError) {
        //Make syncUserMap service call
        
        [self syncUserMapWithUserLocations:userLocations areasToSync:areasToSync modifiedSince:self.lastUserMapSyncServer areasIdsToDelete:deletedAreaIds completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (success) {
                DLog(@"\n\nSuccessful Map Sync with result: \n%@",result);
                [self handleSyncUserMapSuccessWithResult:result];
                DLog(@"\n\nFinished adding sync results to core data\n");
            }
            else {
                NSLog(@"Error syncing user map: %@", error.localizedDescription);
                self.syncMapRunning = NO;
                [self scheduleUserMapSyncAfterDelay:kSecondsBetweenLeadSyncs];
            }
        }];
    }
    else {
        if (userLocationsFetchError) {
            NSLog(@"Error fetching user locations to sync: %@", userLocationsFetchError.localizedDescription);
        }
        if (userLocationsFetchError) {
            NSLog(@"Error fetching areas to sync: %@", areasToSyncFetchError.localizedDescription);
        }
        
        //Schedule sync
        self.syncMapRunning = NO;
        [self scheduleUserMapSyncAfterDelay:kSecondsBetweenUserMapSyncs];
    }
}

/**
 This method is called from settings view to make sure that changes are made before switching departments
 */
- (void)performUserMapSyncWithCompletionBlock:(void (^)(BOOL success))completionHandler{
    
    if (self.syncMapRunning) {
        completionHandler(YES);
        return;
    }
    self.syncMapRunning = YES;
    
    //Get data needed for service call
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [[SRGlobalState singleton] userId];
    
    NSArray *deletedAreaIds = [defaults objectForKey:kDeletedAreaIds];
    
    // Clear out deleted area ids right after they are sent to server.
    [self clearOutNewAndDeletedAreaData];
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    //Fetch the current user's locations that haven't yet been synced
    NSFetchRequest *userLocationsFetch = [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];
    
    if (self.lastUserMapSyncDevice) {
        // userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"(user.userId == %@)", userId];
        userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"((user.userId == %@) AND (%@ < dateCreated))", userId, self.lastUserMapSyncDevice];
    }
    else {
        // First sync won't have a last sync date
        userLocationsFetch.predicate = [NSPredicate predicateWithFormat:@"(user.userId == %@)", userId];
    }
    NSError *userLocationsFetchError = nil;
    NSArray *userLocations = [context executeFetchRequest:userLocationsFetch error:&userLocationsFetchError];
    
    //Fetch all areas from core data that haven't been saved to the server and all areas that have been modified since the last sync
    NSFetchRequest *areasToSyncFetch = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    //Areas that haven't been synced do not have an area ID
    if (self.lastUserMapSyncDevice) {
        //areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"((areaId == nil) OR (%@ < dateModified))", lastSyncDevice];
        areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"(((areaId.integerValue < 0 AND office != nil) OR (%@ < dateModified)) AND areaId.integerValue != 0)", self.lastUserMapSyncDevice];
    }
    else{
        //areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"areaId == nil"];
        areasToSyncFetch.predicate = [NSPredicate predicateWithFormat:@"(areaId.integerValue < 0 AND office != nil)"];
    }
    // Update device sync timeStamp right after query
    self.lastUserMapSyncDevice = [NSDate date];
    
    NSError *areasToSyncFetchError = nil;
    NSArray *areasToSync = [context executeFetchRequest:areasToSyncFetch error:&areasToSyncFetchError];
    
    
    
    if (!userLocationsFetchError && !areasToSyncFetchError) {
        //Make syncUserMap service call
        
        [self syncUserMapWithUserLocations:userLocations areasToSync:areasToSync modifiedSince:self.lastUserMapSyncServer areasIdsToDelete:deletedAreaIds completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (success) {
                DLog(@"\n\nSuccessful Map Sync with result: \n%@",result);
                [self handleSyncUserMapSuccessWithResult:result];
                completionHandler(YES);
                DLog(@"\n\nFinished adding sync results to core data\n");
            }
            else {
                NSLog(@"Error syncing user map: %@", error.localizedDescription);
                self.syncMapRunning = NO;
                completionHandler(NO);
            }
        }];
    }
    else {
        if (userLocationsFetchError) {
            NSLog(@"Error fetching user locations to sync: %@", userLocationsFetchError.localizedDescription);
        }
        if (userLocationsFetchError) {
            NSLog(@"Error fetching areas to sync: %@", areasToSyncFetchError.localizedDescription);
        }
    }
    //Schedule sync
    self.syncMapRunning = NO;
}

/**
 https://wiki.mysalesrabbit.com/index.php/web-service/syncusermap/
 */
- (void)syncUserMapWithUserLocations:(NSArray *)locations areasToSync:(NSArray *)areas modifiedSince:(NSDate *)modifiedSinceDate areasIdsToDelete:(NSArray *)areaIdsToDelete completionHandler:(void (^)(BOOL success, NSDictionary *result, NSError *error))completionHandler {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //Add last modified date from server to parameters in UNIX time stamp format
    if (modifiedSinceDate) {
        params[@"modifiedSince"] = [NSNumber numberWithDouble:modifiedSinceDate.timeIntervalSince1970];
    }
    
    //Format locations for service call JSON and add to parameters
    if (locations && locations.count) {
        NSMutableArray *locationsJSON = [[NSMutableArray alloc] initWithCapacity:locations.count];
        for (UserLocation *location in locations) {
            [locationsJSON addObject:[location proxyForJSON]];
        }
        params[@"Locations"] = locationsJSON;
    }
    
    //Format locations for service call JSON and add to parameters
    if (areas && areas.count) {
        NSMutableArray *areasJSON = [[NSMutableArray alloc] initWithCapacity:areas.count];
        for (Area *area in areas) {
            [areasJSON addObject:[area proxyForJSON]];
        }
        params[@"Areas"] = areasJSON;
    }
    
    //Add deleted areaIds to parameters
    if (areaIdsToDelete && areaIdsToDelete.count) {
        params[@"AreasToDelete"] = areaIdsToDelete;
    }
    
//    DLog(@"\n\nStart Sync User Map\n\nModified date: %@\n\n New Areas:\n%@\n\ndDelete Areas: \n %@\n\nLocations: \n%@\n\n",params[@"modifiedSince"],params[@"Areas"],params[@"AreasToDelete"],params[@"Locations"]);
    //DLog(@"Sync User Map Request \n %@", params);
    [self postServiceCall:@"syncUserMap" withParameters:params includeDepartment:YES completionHandler:^(BOOL success, id result, NSError *error) {
        if (success) {
            completionHandler(YES, result, nil);
//            DLog(@"User Map Sync Result: %@",result);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

#pragma mark - Result Handler

- (void)handleSyncUserMapSuccessWithResult:(NSDictionary *)result
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    //Make dictionaries of all existing region ids, office ids, sales area ids, user ids, slim lead ids, and user locations (Not required for map points since these never change once an area has been added)
    //Dictionaries are formatted so that the id is the key and a reference to the object is the value
    //Since SlimLeads don't have ids their dictionaries will use their timestamp for the key
    NSMutableDictionary *existingRecords = [NSMutableDictionary dictionary];
    
    [self updateTempIdsForSyncedAreasWithResult:result];
    
    [self addExistingRecordsToDictionary:existingRecords fromResult:result inContext:context];
    
    [self removeUsersInResult:result fromContext:context];
    
//    [self deleteSlimLeadsInExistingRecords:existingRecords fromContext:context];
    
    [self addResult:result toExistingRecords:existingRecords];
    
    [self updateNonPersistingTimestampsWithResult:result];
    
    [self postUsersChangedNotification];
    [self postAreasChangedNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncUserMapFinishedNotification object:nil];
    
    self.syncMapRunning = NO;
    [self scheduleUserMapSyncAfterDelay:kSecondsBetweenUserMapSyncs];
}

#pragma mark - Result Sub-Handlers

- (void)addResult:(NSDictionary *)result toExistingRecords:(NSMutableDictionary *)existingRecords
{
    //Save/Update Hierarchy
    NSDictionary *departmentsDict = result[@"Company"];
    NSString *currentDepartmentId = [[SRGlobalState singleton] companyId];
    Department *currentDepartment;
    
    if (departmentsDict && departmentsDict.count)
    {
        NSArray *departmentIds = [departmentsDict allKeys];
        for (NSString *departmentId in departmentIds) {
            if ([departmentId isEqualToString:currentDepartmentId]) {
                
                currentDepartment = [existingRecords[@"departments"] objectForKey:departmentId];
                if (currentDepartment) {
                    //Update: (Nothing to update for now)
                }
                else{
                    currentDepartment = [Department newDepartmentWithId:currentDepartmentId];
                }
                [currentDepartment updateFromJSON:[departmentsDict objectForKey:currentDepartmentId]  existingRecords:existingRecords];
                
            }
            else if(departmentId == 0)
            {
                //Do nothing for now
                //Department 0 is where the users outside the calling user's domain will be delivered
            }
        }
    }
    
    [self postUsersChangedNotification];
    [self postAreasChangedNotification];
    
    self.syncMapRunning = NO;
    
    if ([self followSyncUserMapWithGetPrequal]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSyncUserMapFinishedWithCurrentUserActiveAreaChanged object:nil];
    }
    //NSLog(@"...user map synced");
}

-(BOOL)followSyncUserMapWithGetPrequal{
    
    if (![[SRGlobalState singleton] prequalEnabled]) {
        return NO;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",[[SRGlobalState singleton] userId]];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *users = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    if (users.count > 0) {
        Area *activeArea = [[users objectAtIndex:0] activeArea];
        if (!activeArea || activeArea.areaId < 0) {
            return NO;
        }
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Prequal"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"areaId == %@ AND userId == %@", activeArea.areaId, [[SRGlobalState singleton] userId]];
        [fetchRequest setFetchLimit:1];
        NSError *error = nil;
        NSArray *coreDataPrequals = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (coreDataPrequals.count == 0) {
            return YES;
        }
    }
    return NO;
}

- (void)clearOutNewAndDeletedAreaData
{
    //Clear out Deleted Area Ids array in NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *areaIdsToDeleteEmpty = [[NSArray alloc] init];
    [defaults setObject:areaIdsToDeleteEmpty forKey:kDeletedAreaIds];
}

/* this method creates a dictionary of existing record */
- (void)addExistingRecordsToDictionary:(NSMutableDictionary *)existingRecords fromResult:(NSDictionary *)result inContext:(NSManagedObjectContext *)context
{
    if (result[@"Company"] && [result[@"Company"] count] > 0) {
        
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"departments"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"regions"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"offices"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"areas"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"users"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"slimLeads"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"slimLeadsToDelete"];
        [existingRecords setObject:[NSMutableDictionary dictionary] forKey:@"userLocations"];
        
        NSArray *resultDepartmentIds = [result[@"Company"] allKeys];
        NSMutableArray *resultRegionIds = [NSMutableArray array];
        NSMutableArray *resultOfficeIds = [NSMutableArray array];
        NSMutableArray *resultUserIds = [NSMutableArray array];
        NSMutableArray *resultSlimLeadsToDeleteIds = [NSMutableArray array];
        NSMutableArray *resultAreaIds = [NSMutableArray array];
        
        
        //Departments
        NSFetchRequest *existingDepartmentsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Department"];
        existingDepartmentsRequest.predicate = [NSPredicate predicateWithFormat:@"departmentId IN %@", resultDepartmentIds];
        NSError *existingDepartmentsRequestError = nil;
        
        NSArray *existingDepartments = [context executeFetchRequest:existingDepartmentsRequest error:&existingDepartmentsRequestError];
        if (!existingDepartmentsRequestError) {
            for (Department *department in existingDepartments) {
                
                [existingRecords[@"departments"] setObject:department forKey:department.departmentId];
                [resultRegionIds addObjectsFromArray:[result[@"Company"][department.departmentId][@"Area"] allKeys]];
            }
        }
        else{
            DLog(@"Error fetching Departments: %@", existingDepartmentsRequestError);
        }
        
        
        //Regions
        NSFetchRequest *existingRegionsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        existingRegionsRequest.predicate = [NSPredicate predicateWithFormat:@"regionId IN %@", resultRegionIds];
        NSError *existingRegionsRequestError = nil;
        
        NSArray *existingRegions = [context executeFetchRequest:existingRegionsRequest error:&existingRegionsRequestError];
        if (!existingRegionsRequestError) {
            for (Region *region in existingRegions) {
                
                [existingRecords[@"regions"] setObject:region forKey:region.regionId];
                [resultOfficeIds addObjectsFromArray:[result[@"Company"][region.department.departmentId][@"Area"][region.regionId][@"Office"] allKeys]];
            }
        }
        else{
            DLog(@"Error fetching Regions: %@", existingRegionsRequestError);
        }
        
        
        //Offices
        NSFetchRequest *existingOfficesRequest = [NSFetchRequest fetchRequestWithEntityName:@"Office"];
        existingOfficesRequest.predicate = [NSPredicate predicateWithFormat:@"officeId IN %@", resultOfficeIds];
        NSError *existingOfficesRequestError = nil;
        
        NSArray *existingOffices = [context executeFetchRequest:existingOfficesRequest error:&existingOfficesRequestError];
        if (!existingOfficesRequestError) {
            for (Office *office in existingOffices) {
                
                [existingRecords[@"offices"] setObject:office forKey:office.officeId];
                [resultUserIds addObjectsFromArray:[result[@"Company"][office.region.department.departmentId][@"Area"][office.region.regionId][@"Office"][office.officeId][@"Users"] allKeys]];
                [resultAreaIds addObjectsFromArray:[result[@"Company"][office.region.department.departmentId][@"Area"][office.region.regionId][@"Office"][office.officeId][@"Areas"] allKeys]];
                for (NSString *resultUserId in resultUserIds) {
                    [resultSlimLeadsToDeleteIds addObjectsFromArray:result[@"Company"][office.region.department.departmentId][@"Area"][office.region.regionId][@"Office"][office.officeId][@"Users"][resultUserId][@"LeadsToDelete"]];
                }
                
            }
        }
        else{
            DLog(@"Error fetching Offices: %@", existingOfficesRequestError);
        }
        
        //Users
        NSFetchRequest *existingUsersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        existingUsersRequest.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", resultUserIds];
        existingUsersRequest.returnsObjectsAsFaults = NO;
        [existingUsersRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"slimLeads", @"userLocations", nil]];
        NSError *existingUsersRequestError = nil;
        
        NSArray *existingUsers = [context executeFetchRequest:existingUsersRequest error:&existingUsersRequestError];
        if (!existingOfficesRequestError) {
            for (User *user in existingUsers) {
                
                [existingRecords[@"users"] setObject:user forKey:user.userId];
                
                //Slim Leads
                for (SlimLead *slimLead in user.slimLeads) {
                    if ([resultSlimLeadsToDeleteIds containsObject:[slimLead.leadId stringValue]]) {
#warning Leads don't delete!  (I think I fixed this, but test it.)
                        [self.usersNotificationDict[kDeletedSlimLeads] addObject:slimLead];
                        [user removeSlimLeadsObject:slimLead];
                        [context deleteObject:slimLead];
                    }
                    
                    [existingRecords[@"slimLeads"] setObject:slimLead forKey:slimLead.leadId];
                }
                
                //User Locations
                //Index userLocations by userId then date
                NSMutableArray *locations = [NSMutableArray array];
                
                for (UserLocation *location in user.userLocations) {
                    NSMutableDictionary *locationDict = [NSMutableDictionary dictionary];
                    [locationDict setObject:location forKey:location.dateCreated];
                    [locations addObject:locationDict];
                }
                
                [existingRecords[@"userLocations"] setObject:locations forKey:user.userId];
            }
        }
        else{
            DLog(@"Error fetching Users: %@", existingUsersRequestError);
        }
        
        //Areas
        NSFetchRequest *existingAreasRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
        existingAreasRequest.predicate = [NSPredicate predicateWithFormat:@"areaId IN %@", resultAreaIds];
        NSError *existingAreasRequestError = nil;
        
        NSArray *existingAreas = [context executeFetchRequest:existingAreasRequest error:&existingAreasRequestError];
        if (!existingAreasRequestError) {
            for (Area *area in existingAreas) {
                
                [existingRecords[@"areas"] setObject:area forKey:area.areaId];
            }
        }
        else{
            DLog(@"Error fetching Areas: %@", existingAreasRequestError);
        }
        
    }
//    DLog(@"Got is sorted eh");
}

- (void)updateTempIdsForSyncedAreasWithResult:(NSDictionary *)result
{
    //New Areas
    NSFetchRequest *newAreasRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    newAreasRequest.predicate = [NSPredicate predicateWithFormat:@"(areaId.integerValue < 0)"];
    NSError *newAreasRequestError = nil;
    
    NSArray *newAreas = [[[SRGlobalState singleton] managedObjectContext]
                         executeFetchRequest:newAreasRequest error:&newAreasRequestError];
    
    if (!newAreasRequestError) {
        for (Area *area in newAreas) {
            if ([result[@"TempIDs"] count] > 0 && result[@"TempIDs"][area.areaId]) {
                area.areaId = [NSString stringWithFormat:@"%@", result[@"TempIDs"][area.areaId]];
                assert(area.areaId != nil && area.areaId.integerValue > 0);
            }
        }
    }
    else{
        DLog(@"Error fetching new Areas: %@", newAreasRequestError);
    }
}

- (void)removeUsersInResult:(NSDictionary *)result fromContext:(NSManagedObjectContext *)context
{
    NSArray *removedUserIds = result[@"RemovedUsers"];
    
    NSFetchRequest *removedUsersFetch = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    removedUsersFetch.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", removedUserIds];
    NSError *removedUsersFetchError = nil;
    NSArray *removedUsers = [context executeFetchRequest:removedUsersFetch error:&removedUsersFetchError];
    
    NSString *departmentId = [[SRGlobalState singleton] companyId];
    NSString *officeId = [[SRGlobalState singleton] officeId];
    if (removedUsers && removedUsers.count) {
        NSMutableArray *officesToDelete = [[NSMutableArray alloc] init];
        NSMutableArray *areasToDelete = [[NSMutableArray alloc] init];
        for (User *userToRemove in removedUsers) {
            for (Office* office in userToRemove.offices) {
                
                if ([office.region.department.departmentId isEqualToString:departmentId]) {
                    for (Area* area in userToRemove.inactiveAreas) {
                        if ([area.office.officeId isEqualToString:officeId]) {
                            [areasToDelete addObject:area];
                            //[userToRemove removeInactiveAreasObject:area]; This would cause a crash!!!
                        }
                    }
                    //This is to avoid a mutated while enumerated crash
                    for (Area *area in areasToDelete) {
                        [userToRemove removeInactiveAreasObject:area];
                    }
                    if ([userToRemove.activeArea.office.officeId isEqualToString:officeId]) {
                        [self.usersNotificationDict[kUpdatedAreas] addObject:userToRemove.activeArea];
                        userToRemove.activeArea = nil;
                    }
                    
                    [officesToDelete addObject:office];
                    //[userToRemove removeOfficesObject:office]; This would also cause a crash!!!
                    [self.usersNotificationDict[kDeletedUsers] addObject:userToRemove];
                }
                
            }
            //This is to avoid a mutated while enumerated crash
            for (Office *office in officesToDelete) {
                [userToRemove removeOfficesObject:office];
            }
            if (userToRemove.offices.count == 0) {
                [context deleteObject:userToRemove];
            }
        }
    }
}
/*
 - (void)deleteSlimLeadsInExistingRecords:(NSMutableDictionary *)existingRecords fromContext:(NSManagedObjectContext *)context
 {
 NSMutableDictionary *slimLeadsToDeleteDict = existingRecords[@"leadsToDelete"];
 NSArray *slimLeadsToDeleteIds = [slimLeadsToDeleteDict allKeys];
 
 for (NSString *slimLeadToDeleteId in slimLeadsToDeleteIds) {
 
 SlimLead *slimLeadToDelete = [existingRecords[@"leadsToDelete"] objectForKey:slimLeadToDeleteId];
 
 if (slimLeadToDelete) {
 [self.usersNotificationDict[kDeletedSlimLeads] addObject:slimLeadToDelete];
 [context deleteObject:slimLeadToDelete];
 }
 }
 }*/


#pragma mark - Notifications

- (void)postUsersChangedNotification
{
    if ([self.usersNotificationDict[kAddedUsers] count] > 0 ||
        [self.usersNotificationDict[kUpdatedUsers] count] > 0 ||
        [self.usersNotificationDict[kDeletedUsers] count] > 0 ||
        [self.usersNotificationDict[kAddedSlimLeads] count] > 0 ||
        [self.usersNotificationDict[kUpdatedSlimLeads] count] > 0 ||
        [self.usersNotificationDict[kDeletedSlimLeads] count] > 0 ||
        [self.usersNotificationDict[kAddedUserLocations] count] > 0) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:kUsersChangedNotification object:[self.usersNotificationDict copy]];
        [self.usersNotificationDict[kAddedUsers] removeAllObjects];
        [self.usersNotificationDict[kUpdatedUsers] removeAllObjects];
        [self.usersNotificationDict[kDeletedUsers] removeAllObjects];
        [self.usersNotificationDict[kAddedSlimLeads] removeAllObjects];
        [self.usersNotificationDict[kUpdatedSlimLeads] removeAllObjects];
        [self.usersNotificationDict[kDeletedSlimLeads] removeAllObjects];
        [self.usersNotificationDict[kAddedUserLocations] removeAllObjects];
    }
}

- (void)postAreasChangedNotification
{
    if ([self.areasNotificationDict[kAddedAreas] count] > 0 ||
        [self.areasNotificationDict[kUpdatedAreas] count]  > 0 ||
        [self.areasNotificationDict[kDeletedAreas] count] > 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAreasChangedNotification object:[self.areasNotificationDict copy]];
        [self.areasNotificationDict[kAddedAreas] removeAllObjects];
        [self.areasNotificationDict[kUpdatedAreas] removeAllObjects];
        [self.areasNotificationDict[kDeletedAreas] removeAllObjects];
    }
}


#pragma mark - API methods

/**
 *   https://wiki.mysalesrabbit.com/index.php/web-service/getprequal/
 *
 * Returns the prequal records the user has access to if the system account has the Prequal module.
 *
 * A prequal record is in a sales area if the point of the prequal is encompassed by the polygon of the sales area, and the prequal point is not further than the radius in miles of the center point of the office.
 *
 * An admin gets whatever prequal records for sales areas in the department they are making the call for, a regional gets them for all offices in his region, a manager for his office, and a sales rep only for his active sales area in his current office.
 *
 * If the call has more prequal records than can be received in a single call it will return a cursor that should be sent with the next getPrequal call.
 *
 * NOTE: Currently we aren't utilizing modifiedSince to filter out prequal records on the backend, but we may have to in the future so it should be passed from the modifiedAt in the response.
 */
- (void)getPrequal
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    NSFetchRequest *prequalRequest = [NSFetchRequest fetchRequestWithEntityName:@"Prequal"];
    prequalRequest.predicate = [NSPredicate predicateWithFormat:@"%@ == userId", [[SRGlobalState singleton] userId]];
    NSError *prequalRequestError = nil;
    NSArray *prequalsToDelete = [context executeFetchRequest:prequalRequest error:&prequalRequestError];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeletedAllPrequalsForCurrentUserId object:nil];
    
    DLog(@"\n\nGet Prequal Called for user id: %@\n", [[SRGlobalState singleton] userId]);
    
    if (!prequalRequestError) {
        
        if (prequalsToDelete && [prequalsToDelete count]) {
            for (Prequal *prequal in prequalsToDelete) {
                [context deleteObject:prequal];
            }
        }
    }
    else{
        DLog(@"Error fetching Prequals: %@", prequalRequestError);
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [self getPrequalWithCursor:@0 storeInResultDict:results];
}

/**
 *  Makes the getPrequal service call for prequal records. The service call only returns a set number of records per call and so also returns a cursor to pick up where the last call left off.  When there are no more reords the cursor is be null.
 *
 *  @param cursor  Current position of the service call in returning prequal records.
 *  @param results Dictionary in which returned records are stored.
 */
- (void)getPrequalWithCursor:(NSNumber *)cursor storeInResultDict:(NSMutableDictionary *)results
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //Right now we only get prequal once for an area - we dont expect it to change.
    params[@"modifiedSince"] = @0;
    params[@"cursor"] = cursor;
    
    [self postServiceCall:@"getPrequal" withParameters:params includeDepartment:YES completionHandler:^(BOOL success, NSDictionary *result, NSError *error)
     {
         if (success) {
             if (result[@"Prequal"] && [result[@"Prequal"] count]) {
                 [results addEntriesFromDictionary:result[@"Prequal"]];
             }
             
             if (result[@"Cursor"] != [NSNull null]) {
                 [self getPrequalWithCursor:result[@"Cursor"] storeInResultDict:results];
             }
             else{
                 NSArray *resultPrequalIds = [results allKeys];
                 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Prequal"];
                 request.predicate = [NSPredicate predicateWithFormat:@"%@ == userId AND prequalId IN %@",[[SRGlobalState singleton] userId], resultPrequalIds];
                 NSError *error = nil;
                 NSArray *prequals = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
                 
                 if (!error) {
                     NSMutableArray *existingPrequalIds = [NSMutableArray array];
                     for (Prequal* prequal in prequals) {
                         [existingPrequalIds addObject:prequal.prequalId];
                     }
                     
                     NSArray *prequalIdsToAdd = [resultPrequalIds filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(SELF IN %@)", existingPrequalIds]];
                     for (NSString *prequalId in prequalIdsToAdd) {
                         
                         NSDictionary *prequalJSON = results[prequalId];
                         [self.addedPrequals addObject:[Prequal newPrequalFromJSON:prequalJSON withAreaId:result[@"SalesAreaID"]]];
                     }
                     if (self.addedPrequals && self.addedPrequals.count) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kPrequalsChangedNotification object:[self.addedPrequals copy]];
                     }
                 }
                 else{
                     DLog(@"Error fetching Prequals: %@", error);
                 }
             }
         }
         else{
             DLog(@"Failed to get prequal data: %@ ", error);
         }
     }];
}


#pragma mark - Timestamps

- (void)updateNonPersistingTimestampsWithResult:(NSDictionary *)result
{
    self.lastUserMapSyncServer = [NSDate dateWithTimeIntervalSince1970:[result[@"modifiedAt"] doubleValue]];
}

- (void)updateTimestampsInNSUserDefaults
{
    [super updateTimestampsInNSUserDefaults];
    if (self.lastUserMapSyncServer) {
        
        // Update sync timestamps
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userId = [[SRGlobalState singleton] userId];
        NSString *departmentId = [[SRGlobalState singleton] companyId];

        // Device time
        NSMutableDictionary *lastSyncDeviceDict = [[defaults objectForKey:kLastUserMapSyncDeviceTimestamps] mutableCopy];
        NSMutableDictionary *deviceDepartmentDict = [[NSMutableDictionary dictionaryWithDictionary:lastSyncDeviceDict[userId]] mutableCopy];
        deviceDepartmentDict[departmentId] = self.lastUserMapSyncDevice;
        lastSyncDeviceDict[userId] = deviceDepartmentDict;
        [defaults setObject:lastSyncDeviceDict forKey:kLastUserMapSyncDeviceTimestamps];
        // Server time
        NSMutableDictionary *lastSyncServerDict = [[defaults objectForKey:kLastUserMapSyncServerTimestamps] mutableCopy];
        NSMutableDictionary *serverDepartmentDict = [[NSMutableDictionary dictionaryWithDictionary:lastSyncServerDict[userId]] mutableCopy];
        serverDepartmentDict[departmentId] = self.lastUserMapSyncServer;
        lastSyncServerDict[userId] = serverDepartmentDict;
        [defaults setObject:lastSyncServerDict forKey:kLastUserMapSyncServerTimestamps];
    }
}

@end
