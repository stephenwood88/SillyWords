//
//  SRPremiumPurger.m
//  Dish Sales
//
//  Created by Bryan J Bryce on 3/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumPurger.h"
#import "SRPremiumConstants.h"
#import "User+Rabbit.h"
#import "Area+Rabbit.h"
#import "UserLocation+Rabbit.h"
#import "SRGlobalState.h"

@implementation SRPremiumPurger

/**
 If the calling user's domain (team, office, region, or department) changes or his/her user role, they need to have all of his/her user and sales area information purged and retrieved fresh.
 
 DO NOT CALL THIS METHOD BEFORE THE GLOBAL STATE HAS BEEN SETUP!
 */
+ (BOOL)isPurgeRequired
{
    /*
    User *loggedInUser = [[SRPremiumGlobalState singleton] user];

    NSAssert(loggedInUser != nil, @"Global user should not be nil! Make sure Global State is setup before calling this method.");

    BOOL officeChanged = ![[[SRGlobalState singleton] officeId] isEqualToString:loggedInUser.officeId];
    BOOL regionChanged = ![[[SRGlobalState singleton] areaId] isEqualToString:loggedInUser.regionId];
    BOOL departmentChanged = ![[[SRGlobalState singleton] companyId] isEqualToString:loggedInUser.departmentId];
    BOOL roleChanged = ![[[SRGlobalState singleton] userType] isEqualToString:loggedInUser.role];
    if (officeChanged || regionChanged || departmentChanged || roleChanged)
    {
        return YES;
    }
    else
    {
        return NO;
    }*/
    return NO;
}

+ (void)purgeUsers
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *usersDeleteFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSError *error;
    NSArray *usersToBeDeleted = [context executeFetchRequest:usersDeleteFetchRequest error:&error];

    if (!error) {
        for (User *userToBeDeleted in usersToBeDeleted) {
            [context deleteObject:userToBeDeleted];
            //NSLog(@"User object deleted");
        }
    }
    else{
        NSLog(@"Error fetching Users to delete: %@", error);
    }
}

+ (void)purgeAreas
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *areasDeleteFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    NSError *error;
    NSArray *areasToBeDeleted = [context executeFetchRequest:areasDeleteFetchRequest error:&error];

    if (!error) {
        for (Area *areaToBeDeleted in areasToBeDeleted) {
            [context deleteObject:areaToBeDeleted];
            //NSLog(@"Area object deleted");
        }
    }
    else{
        NSLog(@"Error fetching Areas to delete: %@", error);
    }
}

+ (void)purgeUserLocationsOlderThan:(int)numberOfWeeks
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate* date = [NSDate date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeek:(-1 * numberOfWeeks)];
    NSDate* deletionDate = [calendar dateByAddingComponents:components toDate:date options:0];

    NSFetchRequest *userLocationDeletionFetch = [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];
    userLocationDeletionFetch.predicate = [NSPredicate predicateWithFormat:@"dateCreated < %@", deletionDate];
    NSError* error = nil;

    NSArray *userLocationsToBeDeleted = [context executeFetchRequest:userLocationDeletionFetch error:&error];

    if (!error) {
        for (UserLocation* userLocationToDelete in userLocationsToBeDeleted) {
            [context deleteObject:userLocationToDelete];
            //NSLog(@"User Location object deleted for being too old");
        }
    }
    else{
        NSLog(@"Error fetching User Locations to delete: %@", error);
    }
}

+ (void)purgeTimeStamps
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kLastUserMapSyncDeviceTimestamps];
    [defaults removeObjectForKey:kLastUserMapSyncServerTimestamps];
}

@end
