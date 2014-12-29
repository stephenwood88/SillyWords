//
//  SRPremiumConstants.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesConstants.h"

FOUNDATION_EXPORT double kPolygonOptimizationTolerance;

// NSUserDefaults
FOUNDATION_EXPORT NSString * const kDeletedAreaIds;
FOUNDATION_EXPORT NSInteger const kSecondsBetweenUserMapSyncs;
FOUNDATION_EXPORT NSString * const kNewAreaIndex;

//Notifications
FOUNDATION_EXPORT NSString * const kSyncUserMapFinishedWithCurrentUserActiveAreaChanged;
FOUNDATION_EXPORT NSString * const kPrequalConvertedToLead;
FOUNDATION_EXPORT NSString * const kDeletedAllPrequalsForCurrentUserId;
FOUNDATION_EXPORT NSString * const kAddedPrequals;

//User Notifications
FOUNDATION_EXPORT NSString * const kUsersChangedNotification;
FOUNDATION_EXPORT NSString * const kSyncUserMapFinishedNotification;

//Added
FOUNDATION_EXPORT NSString * const kAddedUsers;
FOUNDATION_EXPORT NSString * const kAddedSlimLeads;
FOUNDATION_EXPORT NSString * const kAddedUserLocations;
//Updated
FOUNDATION_EXPORT NSString * const kUpdatedUsers;
FOUNDATION_EXPORT NSString * const kUpdatedSlimLeads;
//Deleted
FOUNDATION_EXPORT NSString * const kDeletedUsers;
FOUNDATION_EXPORT NSString * const kDeletedSlimLeads;
//Area Notifications
FOUNDATION_EXPORT NSString * const kAreasChangedNotification;
FOUNDATION_EXPORT NSString * const kAddedAreas;
FOUNDATION_EXPORT NSString * const kUpdatedAreas;
FOUNDATION_EXPORT NSString * const kDeletedAreas;
//Location Tracking
FOUNDATION_EXPORT double const kSecondsBetweenTrackingUserLocations;
//Purging
FOUNDATION_EXPORT int const kWeeksOldToPurgeUserLocations;

// No class definition needed unless we need to initialize values

//@interface SRPremiumConstants : NSObject

/**
 * Call this method on app launch to initialize collection constants
 */
//+ (void)initValues;

//@end
