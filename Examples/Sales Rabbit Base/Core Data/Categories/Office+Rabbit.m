//
//  Office+Rabbit.m
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Office+Rabbit.h"
#import "Region+Rabbit.h"
#import "User+Rabbit.h"
#import "Area+Rabbit.h"
#import "SRGlobalState.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRPremiumConstants.h"

@interface Office (PrimitiveAccessor)

- (void)setPrimitiveName:(NSString *)name;

@end

@implementation Office (Rabbit)

+ (Office *)newOfficeWithId:(NSString *) officeId region:(Region *)region
{
    Office *office = [NSEntityDescription insertNewObjectForEntityForName:@"Office" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];
    office.officeId = officeId;
    office.region = region;

    return  office;
}

- (void)updateFromJSON:(id)officeDict existingRecords:(NSDictionary *)existingRecords
{
    //Office
    NSAssert(self.officeId, @"Offices should always have an officeId.");
    NSAssert(self.region, @"Updated offices should always have an Office.");

    if (officeDict[@"OfficeName"]) {
        [self setNameValue:[self filterNSNull:officeDict[@"OfficeName"]]];
    }

    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    SRPremiumSalesServiceCalls *serviceCall = [SRPremiumSalesServiceCalls singleton];

    //Add and Update Users
    NSDictionary *resultUsers = officeDict[@"Users"];
    if (resultUsers && resultUsers.count) {

        NSArray *resultUserIds = [resultUsers allKeys];
            //Iterate over the returned users by userId
            for (NSString *userId in resultUserIds) {
                //Check to see if the user is currently stored on the device or is new
                User *user = [existingRecords[@"users"] objectForKey:userId];
                if (!user) {
                    user = [User newUserWithUserId:userId];
                    user.userId = userId;

                    [serviceCall.usersNotificationDict[kAddedUsers] addObject:user];
                }
                else{
                    [serviceCall.usersNotificationDict[kUpdatedUsers] addObject:user];
                }
                NSDictionary *resultUserDict = resultUsers[userId];
                //Fill in all the user's information from the JSON result
                [user updateFromJSON:resultUserDict existingRecords:existingRecords office:self];
            }
    }

    //Areas

    NSDictionary *resultAreaIds = officeDict[@"Areas"];

    if (resultAreaIds && resultAreaIds.count) {

        //NSArray *areasToUpdate = existingRecords[@"areas"];
        //NSMutableDictionary *areasToUpdateDict = [NSMutableDictionary dictionaryWithCapacity:areasToUpdate.count];

            //Put the current areas in a dictionary with the key being the areaId and the value being the Area
            /*for (Area* area in areasToUpdate) {
                areasToUpdateDict[area.areaId] = area;
            }*/
            //Iterate over the returned users by userId
            for (NSString *areaId in resultAreaIds) {
                //Check to see if the area is currently stored on the device and needs to be UPDATED or is NEW and if it should be DELETED
                Area *area = existingRecords[@"areas"][areaId];
                
                BOOL toDelete = (resultAreaIds[areaId] && [resultAreaIds[areaId] count])?[resultAreaIds[areaId][@"Deleted"] boolValue]:NO;

                if (!area && !toDelete) {
                    //New Area
                    area = [Area newAreaWithAreaId:areaId office:self];
                    [serviceCall.areasNotificationDict[kAddedAreas] addObject:area];
                    NSDictionary *resultAreaDict = resultAreaIds[areaId];
                    [area newFromJSON:resultAreaDict];
                }
                else if (area && toDelete){
                    //Delete Area
                    [serviceCall.areasNotificationDict[kDeletedAreas] addObject:area];
                    [context deleteObject:area];
                    continue;
                }
                else if (!area && toDelete){
                    //It's already gone man...
                    continue;
                }
                else{
                    //Update Area
                    NSDictionary *resultAreaDict = resultAreaIds[areaId];
                    [area updateFromJSON:resultAreaDict];
                    [serviceCall.areasNotificationDict[kUpdatedAreas] addObject:area];
                }
            }
    }
}

- (void)setNameValue:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
}

- (id)filterNSNull:(id)json {

    if ([json isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return json;
}

/**
    Returns the office for the officeId given. If no office with this id is found then nil is returned.
 */

+ (Office *)officeForOfficeId:(NSString *)officeId
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Office"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"officeId = %@", officeId];
    NSError* error = nil;
    NSArray* offices = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:fetch error:&error];
    NSAssert(offices.count <= 1, @"We shouldn't have duplicate offices");
    if (!error) {
        if (offices && offices.count) {

            return [offices firstObject];
        }
        return [offices firstObject];
    } else {
        NSLog(@"Error fetching Offices: %@", error);
    }
    return nil;
}

@end
