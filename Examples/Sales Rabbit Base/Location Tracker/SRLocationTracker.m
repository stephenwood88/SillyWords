//
//  SRLocationTracker.m
//  Security Sales
//
//  Created by Bryan Bryce on 1/20/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRLocationTracker.h"
#import "SRGlobalState.h"
#import "UserLocation.h"
#import "UserLocation+Rabbit.h"
#import "Constants.h"
#import "SRPremiumConstants.h"
#import "SRPremiumSalesServiceCalls.h"

#define REPTYPE 1
#define MANAGERTYPE 3
#define REGIONALTYPE 5
#define ADMINTYPE 12

@interface SRLocationTracker()
{
    NSInteger userType;
}

@property (strong, nonatomic) NSTimer *locationSaveTimer;

- (void)saveAndSyncLocationWithLocation:(CLLocation *) location;

@end

@implementation SRLocationTracker

#pragma mark - Class Methods

+ (SRLocationTracker *)singleton{
    
    static dispatch_once_t once;
    static SRLocationTracker *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Public Methods

- (void)beginSavingLocationData{
    
    self.locationSaveTimer =
    [NSTimer scheduledTimerWithTimeInterval:kSecondsBetweenTrackingUserLocations target:self selector:@selector(saveAndSyncLocation) userInfo:nil repeats:YES];
    
    [self saveAndSyncLocation];
    
    //NSLog(@"Location Tracking Started");
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tracking" message:@"You are now being tracked!" delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
    //[alert show];//Debug
}

- (void)stopSavingLocationData{
    
    [self.locationSaveTimer invalidate];
    //NSLog(@"Location Tracking Stopped");
    [self getUserLocationsForUserId:[[SRGlobalState singleton] userId]];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tracking" message:@"We have stopped tracking you!" delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
    //[alert show];//Debug
}

- (void)saveAndSyncLocation{
    
    [[AVLocationManager singleton] getBestLocationAndUpdate:self];
    //NSLog(@"Location Tracked!");//Debug
}

- (NSArray *)getUserLocationsForUserId:(NSString *) userId{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];
    
    //Fetch UserLocations Based on a user's userId
    request.predicate = [NSPredicate predicateWithFormat:@"user.userId == %@", userId];
    
    //Sort the UserLocations by Date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"dateCreated"
                                        ascending:NO];
    
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSArray *fetchedUserLocations = [context executeFetchRequest:request error:nil];
    
    //Set UserLocation's Alpha based on date created
    float alphaIncrement = 0.9/[fetchedUserLocations count];
    float alpha = 1;
    for (UserLocation *userLocation in fetchedUserLocations) {
        [userLocation setAlpha:[NSNumber numberWithFloat:alpha]];
        alpha -= alphaIncrement;
    }
    
    //Debug Code
    /*for (UserLocation *userLocation in fetchedUserLocations) {
     //NSLog(@"This is the latitude: %@", userLocation.latitude);
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"MM-DD-yyyy HH:mm:ss"];
     NSLog(@"This is the Date Created: %@", [formatter stringFromDate:userLocation.dateCreated]);
     }*/
    
    //NSLog(@"There are %lu user locations tracked", (unsigned long)[fetchedUserLocations count]);
    
    return fetchedUserLocations;
}

- (NSArray *)getUserLocationsForUserIds:(NSArray *)userIds fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserLocation"];
    [request setReturnsObjectsAsFaults:NO];
    [request setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObject:@"alpha"]];
    
    userType = [[[SRGlobalState singleton] userType] integerValue];
    
    if (userType == MANAGERTYPE) {
        request.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.officeId == %@)", userIds, fromDate, toDate, [[SRGlobalState singleton] officeId]];
    }
    else if (userType == REGIONALTYPE){
        request.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.region.regionId == %@)", userIds, fromDate, toDate, [[SRGlobalState singleton] areaId]];
        [request setFetchLimit:500];
    }
    else if (userType == ADMINTYPE){
        request.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.region.department.departmentId == %@)", userIds, fromDate, toDate, [[SRGlobalState singleton] companyId]];
        [request setFetchLimit:500];
    }
    
    //Sort the UserLocations by Date
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"dateCreated"
                                        ascending:NO];
    NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    NSMutableArray *allFetchedUserLocations = [[NSMutableArray alloc] init];
    NSArray *fetchedUserLocations = [context executeFetchRequest:request error:nil];
    for (int i = 0; i < userIds.count; i++) {
        
        NSString *currentId = userIds[i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userId == %@", currentId];
        
        NSArray *userLocations = [fetchedUserLocations filteredArrayUsingPredicate:predicate];
        
        //Set UserLocation's Alpha based on date created and add to allFetchedUserLocationsArray
        float alphaIncrement = 0.9/userLocations.count;
        float alpha = 1;
        for (UserLocation *userLocation in userLocations) {
            [userLocation setAlpha:[NSNumber numberWithFloat:alpha]];
            alpha -= alphaIncrement;
            [allFetchedUserLocations addObject:userLocation];
        }
        
    }
    
    return allFetchedUserLocations;
}

#pragma mark - Private Methods

/**
 Only current user's locations should be saved with this method!
 */

- (void)saveAndSyncLocationWithLocation:(CLLocation *)location
{
    [UserLocation newUserLocationForLocation:location];
    [[SRPremiumSalesServiceCalls singleton] sync];
}

#pragma mark - Get Location Delegate Methods

- (void)currentLocationFound:(CLLocation *)location{
    
    //Here a private method is called to handle getting the location back. If the way the location is recieved changes in the future, the fix should be easier.
    [self saveAndSyncLocationWithLocation:location];
}

- (void)errorFindingLocation
{
    //TODO: Define and code up behavior of location tracking when location can't be acquired
}

@end
