//
//  Area+Rabbit.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/30/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Area+Rabbit.h"
#import "SRGlobalState.h"
#import "MapPoint+Rabbit.h"
#import "User+Rabbit.h"
#import "Office+Rabbit.h"
#import "SRPremiumConstants.h"
#import "SRPremiumSalesServiceCalls.h"

@interface Area (PrimitiveAccessor)

- (void)setPrimitiveDepartmentId:(NSString *)departmentId;
- (void)setPrimitiveRegionId:(NSString *)regionId;
- (void)setPrimitiveOfficeId:(NSString *)officeId;
- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveUserId:(NSString *)userId;
- (void)setPrimitiveAreaId:(NSString *)areaId;

@end

@implementation Area (Rabbit)

#pragma mark - new Area class method

+ (Area *)newAreaWithAreaId:(NSString *)areaId office:(Office *)office {
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Area *area = [NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:context];
    area.areaId = areaId;
    area.office = office;
    return area;
}

+ (Area *)newAreaWithMapPoints:(NSOrderedSet *)mapPoints andDate:(NSDate *)date
{
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Area *newArea = [NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:context];
    
    newArea.mapPoints = mapPoints;
    newArea.dateCreated = date;
    newArea.userId = [[SRGlobalState singleton] userId];
    
    return newArea;
}

- (UIColor *)getAreaColorWithAlpha:(CGFloat) alpha
{
    NSArray *reps = [self.activeUsers array];

    if (reps.count != 0) {
        User *lastRep = [reps objectAtIndex:0];
        return [UIColor colorWithRed:[lastRep.red floatValue] green:[lastRep.green floatValue] blue:[lastRep.blue floatValue] alpha:alpha];
    }
    else
    {
        return [UIColor colorWithRed:0 green:0 blue:0 alpha:alpha];
    }
}

#pragma mark - JSON Proxies

- (id)proxyForJSON
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];

    json[@"OfficeID"] = self.office.officeId ? self.office.officeId : [NSNull null];
    json[@"SalesAreaID"] = self.areaId ? self.areaId : [NSNull null];
    json[@"Points"] = [self mapPointsProxyForJSON];
    json[@"Users"] = [self activeUsersProxyForJSON];
    json[@"InactiveUsers"] = [self inactiveUsersProxyForJSON];

    return json;
}

- (id)mapPointsProxyForJSON
{
    NSArray *points = [self.mapPoints array];
    
    if (points && points.count) {
        NSMutableArray *pointsJSON = [NSMutableArray arrayWithCapacity:self.mapPoints.count];
        for (MapPoint *point in self.mapPoints) {
            NSMutableDictionary *mapPointsDict = [[NSMutableDictionary alloc] init];
            mapPointsDict[@"Latitude"] = point.latitude;
            mapPointsDict[@"Longitude"] = point.longitude;
            [pointsJSON addObject:mapPointsDict];
        }
        return pointsJSON;
    }
    else {
        return [NSNull null];
    }
}

- (id)activeUsersProxyForJSON
{
    NSArray *users = [self.activeUsers array];

    if (users && users.count) {
        NSMutableArray *usersJSON = [NSMutableArray arrayWithCapacity:self.activeUsers.count];
        for (User *user in users) {
            [usersJSON addObject:user.userId];
        }
        return usersJSON;
    }
    else{
        return [NSNull null];
    }
}

- (id)inactiveUsersProxyForJSON
{
    NSArray *inactiveUsers = [self.inactiveUsers allObjects];

    if (inactiveUsers && inactiveUsers.count) {
        NSMutableArray *inactiveUsersJSON = [NSMutableArray arrayWithCapacity:self.inactiveUsers.count];
        for (User *user in inactiveUsers) {
            [inactiveUsersJSON addObject:user.userId];
        }
        return inactiveUsersJSON;
    }
    else{
        return [NSNull null];
    }
}

- (id)filterNSNull:(id)json {
    
    if ([json isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return json;
}

#pragma mark - Updates from JSON

- (void)updateFromJSON:(NSDictionary *)json
{
    // Hold on to your date modifed, and reset it after you update
    NSDate *dateModified = self.dateModified;

    //Add Active and Inactive Users
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *usersFetch = [NSFetchRequest fetchRequestWithEntityName:@"User"];

    NSArray *activeUserIds = (json.count && json)?json[@"Users"]:nil;
    //Add Active Users
    if (activeUserIds && activeUserIds.count) {
        usersFetch.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", activeUserIds];
        NSError *usersFetchError = nil;
        NSArray *activeUsers = [context executeFetchRequest:usersFetch error:&usersFetchError];
        if (!usersFetchError) {
            for (User *user in activeUsers) {
                if ([self.inactiveUsers member:user]) {
                    [user removeInactiveAreasObject:self];
                }
                if ([user.inactiveAreas member:self]) {
                    [self removeInactiveUsersObject:user];
                }

                [self addActiveUsersObject:user];
                user.activeArea = self;
            }
        }
        else{
            NSLog(@"Error fetching Users: %@", usersFetch);
        }
    }
    //Add Inactive Users
    NSArray *inactiveUsersFromResponse = (json && json.count)?json[@"RemovedUsers"]:@[];
    NSMutableArray *inactiveUsersIds = [[NSMutableArray alloc] initWithCapacity:inactiveUsersFromResponse.count];
    
    for (int i=0; i<inactiveUsersFromResponse.count; i++) {
        [inactiveUsersIds addObject:[inactiveUsersFromResponse[i] objectForKey:@"UserID"]];
    }
    
    if (inactiveUsersIds && inactiveUsersIds.count) {
        usersFetch.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", inactiveUsersIds];
        NSError *inactiveUsersFetchError = nil;
        NSArray* inactiveUsers = [context executeFetchRequest:usersFetch error:&inactiveUsersFetchError];
        
        
        //Some Users might not be on the device yet so insert them on Core Data
        if (inactiveUsers.count != inactiveUsersFromResponse.count) {
            for (int i =0; i<inactiveUsersIds.count; i++) {
                usersFetch.predicate = [NSPredicate predicateWithFormat:@"userId == %@", inactiveUsersIds[i]];
                NSError *inactiveUsersExistFetchError = nil;
                NSArray *userToCheck = [context executeFetchRequest:usersFetch error:&inactiveUsersExistFetchError];
                if (userToCheck.count == 0) {
                    User *newUser = [User newUserWithUserId:inactiveUsersIds[i]];
                    newUser.firstName = [inactiveUsersFromResponse[i] objectForKey:@"FirstName"];
                    newUser.lastName = [inactiveUsersFromResponse[i] objectForKey:@"LastName"];
                    newUser.red = [User redFromHex:[inactiveUsersFromResponse[i] objectForKey:@"MapColor"]];
                    newUser.green = [User greenFromHex:[inactiveUsersFromResponse[i] objectForKey:@"MapColor"]];
                    newUser.blue = [User blueFromHex:[inactiveUsersFromResponse[i] objectForKey:@"MapColor"]];
                }
            }
        }
        
        if (!inactiveUsersFetchError) {
            for (User* user in inactiveUsers) {
                if ([self.activeUsers containsObject:user]) {
                    NSMutableOrderedSet* newActiveUserOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.activeUsers];
                    [newActiveUserOrderedSet removeObject:user];
                    self.activeUsers = [NSOrderedSet orderedSetWithOrderedSet:newActiveUserOrderedSet];
                }
                if ([user.activeArea isEqual:self]) {
                    user.activeArea = nil;
                }
                [self addInactiveUsersObject:user];
                [user addInactiveAreasObject:self];
            }
        } else {
            NSLog(@"Error fetching Users: %@", inactiveUsersFetchError);
        }
    }
    
    // Reset your date modified to what it was before update.
    self.dateModified = dateModified;
}

- (void)newFromJSON:(NSDictionary *)json
{
    NSAssert(self.areaId, @"Areas must have an areaId.");
    NSAssert(self.office, @"Areas mush have an office.");

    if (json[@"DateCreated"]) {
        [self setDateCreatedValue:[self dateFromString:json[@"DateCreated"]]];
    }
    if (json[@"CreatedBy"]) {
        [self setUserIdValue:[self filterNSNull:json[@"CreatedBy"]]];
    }
#warning update to include office/user relationship

    NSArray *points = json[@"Points"];
    
    if (points && points.count) {
        NSMutableOrderedSet* orderedSetMapPoints = [[NSMutableOrderedSet alloc] init];
        for (int i = 0; i < points.count; i++) {
            if (points[i][@"Latitude"] != [NSNull null] && points[i][@"Longitude"] != [NSNull null]){
                MapPoint *point = [MapPoint newMapPointFromJSON:points[i] forArea:self];
                [orderedSetMapPoints addObject:point];
            }
        }
        self.mapPoints = [NSOrderedSet orderedSetWithOrderedSet:orderedSetMapPoints];
    }
    
    //Add Active and Inactive Users
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *usersFetch = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    NSArray *activeUserIds = json[@"Users"];
    
    //Add Active Users
    if (activeUserIds && activeUserIds.count) {

        usersFetch.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", activeUserIds];
        NSError *usersFetchError = nil;
        NSArray *activeUsers = [context executeFetchRequest:usersFetch error:&usersFetchError];
        if (!usersFetchError) {
            for (User *user in activeUsers)
            {
                user.activeArea = self;
            }
        }
        else{
            NSLog(@"Error fetching Users: %@", usersFetch);
        }
    }
    
    //Add Inactive Users
    NSArray *inactiveUsersIds = json[@"RemovedUsers"];
    if (inactiveUsersIds && inactiveUsersIds.count) {
        usersFetch.predicate = [NSPredicate predicateWithFormat:@"userId IN %@", inactiveUsersIds];
        NSError *inactiveUsersFetchError = nil;
        NSArray* inactiveUsers = [context executeFetchRequest:usersFetch error:&inactiveUsersFetchError];
        if (!inactiveUsersFetchError) {
            for (User* user in inactiveUsers) {
                [self addInactiveUsersObject:user];
                [user addInactiveAreasObject:self];
            }
        } else {
            NSLog(@"Error fetching Users: %@", inactiveUsersFetchError);
        }
    }
    self.dateModified = [[SRPremiumSalesServiceCalls singleton] lastUserMapSyncDevice];
}


#pragma mark - Custom Setters
     
- (void)setDateCreatedValue:(NSDate *)dateCreated
{
    [self willChangeValueForKey:@"dateCreated"];
    [self setPrimitiveDateCreated:dateCreated];
    [self didChangeValueForKey:@"dateCreated"];
}

- (void)setDateModifiedValue:(NSDate *)dateModified
{
    [self willChangeValueForKey:@"dateModified"];
    [self setPrimitiveDateModified:dateModified];
    [self didChangeValueForKey:@"dateModified"];
}

- (void)setAreaIdValue:(NSString *)areaId
{
    [self willChangeValueForKey:@"areaId"];
    [self setPrimitiveUserId:areaId];
    [self didChangeValueForKey:@"areaId"];
}

- (void)setDepartmentIdValue:(NSString *)departmentId
{
    [self willChangeValueForKey:@"departmentId"];
    [self setPrimitiveDepartmentId:departmentId];
    [self didChangeValueForKey:@"departmentId"];
}

- (void)setRegionIdValue:(NSString *)regionId
{
    [self willChangeValueForKey:@"regionId"];
    [self setPrimitiveRegionId:regionId];
    [self didChangeValueForKey:@"regionId"];
}

- (void)setOfficeIdValue:(NSString *)officeId
{
    [self willChangeValueForKey:@"officeId"];
    [self setPrimitiveOfficeId:officeId];
    [self didChangeValueForKey:@"officeId"];
}

- (void)setUserIdValue:(NSString *)userId
{
    [self willChangeValueForKey:@"userId"];
    [self setPrimitiveUserId:userId];
    [self didChangeValueForKey:@"userId"];
}

- (void)setActiveUsers:(NSOrderedSet *)activeUsers
{
    [self willChangeValueForKey:@"activeUsers"];
    [self setPrimitiveValue:activeUsers forKey:@"activeUsers"];
    [self didChangeValueForKey:@"activeUsers"];
    self.dateModified = [NSDate date];
}

- (void)setInactiveUsers:(NSSet *)inactiveUsers
{
    [self willChangeValueForKey:@"inactiveUsers"];
    [self setPrimitiveValue:inactiveUsers forKey:@"inactiveUsers"];
    [self didChangeValueForKey:@"inactiveUsers"];
    self.dateModified = [NSDate date];
}

- (void)addActiveUsersObject:(User *)value
{
    [self willChangeValueForKey:@"activeUsers"];
    NSMutableOrderedSet* tempSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.activeUsers];
    [tempSet addObject:value];
    self.activeUsers = tempSet;
    [self didChangeValueForKey:@"activeUsers"];
}

#pragma mark - Helper Methods

- (NSDate *)dateFromString:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date =[dateFormatter dateFromString:string];
    return date;
}

+ (NSString *)generateTempAreaId
{
    //Set area id to a temporary negative number by referencing user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* newAreaIndex;
    NSString* userId = [[SRGlobalState singleton] userId];
    if (![[defaults objectForKey:kNewAreaIndex] objectForKey:userId]) {
        newAreaIndex = @-1;
        NSMutableDictionary *newAreaIndexDict = [NSMutableDictionary dictionaryWithObject:newAreaIndex forKey:userId];
        [defaults setObject:newAreaIndexDict forKey:kNewAreaIndex];
    }
    else{
        NSMutableDictionary *newAreaIndexDict = [[defaults objectForKey:kNewAreaIndex] mutableCopy];
        int areaIndex = [(NSNumber *)newAreaIndexDict[userId] intValue];
        newAreaIndex = [NSNumber numberWithInt:(--areaIndex)];
        newAreaIndexDict[userId] = newAreaIndex;
        [defaults setObject:newAreaIndexDict forKey:kNewAreaIndex];
    }
    return [newAreaIndex stringValue];
}

@end
