//
//  SRPremiumConstants.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumConstants.h"

double kPolygonOptimizationTolerance = 3.2;

//NSUserDefaults
NSString * const kDeletedAreaIds = @"deletedAreaIds";
NSString * const kNewAreaIndex = @"newAreaIndex";

// Time
NSInteger const kSecondsBetweenUserMapSyncs = 30;// 30 seconds

//Notifications
NSString * const kSyncUserMapFinishedWithCurrentUserActiveAreaChanged = @"syncUserMapFinishedWithCurrentUserActiveAreaChanged";
NSString * const kDeletedAllPrequalsForCurrentUserId = @"deletedAllPrequalsForCurrentUserId";
NSString * const kPrequalConvertedToLead = @"prequalConvertedToLead";
NSString * const kAddedPrequals = @"addedPrequals";
NSString * const kSyncUserMapFinishedNotification = @"SyncUserMapFinished";

//User Notifications
NSString * const kUsersChangedNotification = @"usersChangedNotification";
//Added
NSString * const kAddedUsers = @"addedUsers";
NSString * const kAddedSlimLeads = @"addedSlimLeads";
NSString * const kAddedUserLocations = @"addedUserLocations";
//Updated
NSString * const kUpdatedUsers = @"updatedUsers";
NSString * const kUpdatedSlimLeads = @"updatedSlimLeads";
//Deleted
NSString * const kDeletedUsers = @"deletedUsers";
NSString * const kDeletedSlimLeads = @"deletedSlimLeads";
//Area Notifications
NSString * const kAreasChangedNotification = @"areasChangedNotification";
NSString * const kAddedAreas = @"addedAreas";
NSString * const kUpdatedAreas = @"updatedAreas";
NSString * const kDeletedAreas = @"deletedAreas";
//Location Tracking
double const kSecondsBetweenTrackingUserLocations = 1 * 60 * 15; // 15 minutes
//Purging
int const kWeeksOldToPurgeUserLocations = 2;

// No class definition needed unless we need to initialize values

//@implementation SRPremiumConstants

/*+ (void)initValues {
    
    static BOOL valuesInitialized = NO;
    if (!valuesInitialized) {
        valuesInitialized = YES;
    }
}*/

//@end
