//
//  User+Rabbit.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/10/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "User+Rabbit.h"
#import "UserLocation+Rabbit.h"
#import "SlimLead+Rabbit.h"
#import "Area+Rabbit.h"
#import "Region+Rabbit.h"
#import "Department+Rabbit.h"
#import "Office+Rabbit.h"
#import "SRGlobalState.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRPremiumConstants.h"

@interface User (PrimitiveAccessor)

- (void)setPrimitiveFirstName:(NSString *)firstName;
- (void)setPrimitiveLastName:(NSString *)lastName;
- (void)setPrimitiveUserId:(NSString *)userId;
- (void)setPrimitiveRegionId:(NSString *)regionId;
- (void)setPrimitiveDepartmentId:(NSString *)departmentId;
- (void)setPrimitiveRole:(NSString *)role;

- (void)setPrimitiveRed:(NSNumber *)red;
- (void)setPrimitiveGreen:(NSNumber *)green;
- (void)setPrimitiveBlue:(NSNumber *)blue;

@end

@implementation User (Rabbit)

#pragma mark - New User class methods

+ (User *)newUserWithUserId:(NSString *)userId
{
    if ([userId isEqualToString:[[SRGlobalState singleton] userId]]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
        NSError* error = nil;
        NSArray *userArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
        if (userArray.count > 0) {
            return userArray.firstObject;
        }
    }
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];
    user.userId = userId;
    return user;
}

+ (User *)currentUserWithUserId:(NSString *)userId fromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    NSError* error = nil;
    NSArray *userArray = [context executeFetchRequest:request error:&error];
#ifdef ASSERTS
    NSAssert(userArray.count <= 1, @"We shouldn't have more than one current user record.");
#endif
    if (userArray && userArray.count) {
        return [userArray firstObject];
    }
    else{
        return [User newUserWithUserId:userId];
    }
    
}

- (void)updateFromJSON:(NSDictionary*)usersDict existingRecords:(NSDictionary *)existingRecords office:(Office *)office
{
    
    //Add office but first make sure that an office from that same department doesn't exist, otherwise delete the old office with the same department as the new office to add
    NSArray *currentOffices = [self.offices allObjects];

    for (Office *tmpOffice in currentOffices) {
        if ([tmpOffice.region.department.departmentId isEqualToString:office.region.department.departmentId]) {
            [self removeOfficesObject:tmpOffice];
        }
    }
    [self addOfficesObject:office];
    
    
    NSAssert(self.userId, @"User must have a userId.");
    NSAssert([self.offices count] > 0, @"Updated/newly created users must have an office.");
    NSString *mapColor = usersDict[@"MapColor"];
    if (mapColor) {
        [self setRedValue:[User redFromHex:mapColor]];
        [self setGreen:[User greenFromHex:mapColor]];
        [self setBlue:[User blueFromHex:mapColor]];
    }
    
    if (usersDict[@"FirstName"]) {
        [self setFirstNameValue:[self filterNSNull:usersDict[@"FirstName"]]];
    }
    if (self.firstName == nil) {
        //Break here
    }
    NSAssert(self.firstName != nil, @"Users must have a first name!");
    if (usersDict[@"LastName"]) {
        [self setLastNameValue:[self filterNSNull:usersDict[@"LastName"]]];
    }
    if (usersDict[@"UserType"]) {
        [self setRole:[self filterNSNull:usersDict[@"UserType"]]];
    }
    NSAssert(self.role != nil, @"Users must have a role!");
    
    //Check to see if user location already exists, if not add it (it is possible that another user has synced down the same location)
    
    SRPremiumSalesServiceCalls *serviceCall = [SRPremiumSalesServiceCalls singleton];
    
    //Locations
    
    NSArray *locations = usersDict[@"Locations"];
    if (locations && locations.count > 0) {
        
        for (int i = 0; i < locations.count; i++) {
            
            if (locations[i][@"Latitude"] == [NSNull null] || locations[i][@"Longitude"] == [NSNull null] || locations[i][@"LocationTime"] == [NSNull null]) {
                continue;
            }
            
            NSNumber *latitude = [NSNumber numberWithDouble:[locations[i][@"Latitude"] doubleValue]];
            NSNumber *longitude = [NSNumber numberWithDouble:[locations[i][@"Longitude"] doubleValue]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy'-'MM'-'dd HH':'mm':'ss";
            NSDate *dateCreated = [dateFormatter dateFromString:locations[i][@"LocationTime"]];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate* date = [NSDate date];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setWeek:-1 * kWeeksOldToPurgeUserLocations];
            NSDate* oldestAllowedDate = [calendar dateByAddingComponents:components toDate:date options:0];
            
            if (latitude && longitude && [dateCreated compare:oldestAllowedDate] == NSOrderedDescending) {
                
                if ([existingRecords[@"userLoctions"][self.userId] valueForKey:locations[i][@"LocationTime"]]) {
                    //The location already exists, just skip adding it since user locations aren't updated
                    continue;
                }
                else
                {
                    UserLocation *location = [UserLocation newUserLocationFromJSON:locations[i] forUser:self];
                    
                    if (!([location.user.userId isEqualToString:[[SRGlobalState singleton] userId]])) {
                        
                        [serviceCall.usersNotificationDict[kAddedUserLocations] addObject:location];
                    }
                }
                
            }
        }
    }
    
    //  NSManagedObjectContext* context = [[SRGlobalState singleton] managedObjectContext];
    //
    //    NSArray *slimLeadsToDelete = usersDict[@"LeadsToDelete"];
    //
    //    if (slimLeadsToDelete && slimLeadsToDelete.count) {
    //        NSFetchRequest* slimLeadDeleteRequest = [NSFetchRequest fetchRequestWithEntityName:@"SlimLead"];
    //        slimLeadDeleteRequest.predicate = [NSPredicate predicateWithFormat:@"leadId IN %@", slimLeadsToDelete];
    //        NSError* slimLeadDeleteRequestError = nil;
    //        NSArray *slimLeadToDelete = [context executeFetchRequest:slimLeadDeleteRequest error:&slimLeadDeleteRequestError];
    //
    //        if (slimLeadsToDelete && slimLeadsToDelete.count) {
    //            for (SlimLead* lead in slimLeadToDelete) {
    //                [serviceCall.usersNotificationDict[kDeletedSlimLeads] addObject:lead];
    //                [context deleteObject:lead];
    //            }
    //        }
    //    }
    
    NSArray *slimLeads = usersDict[@"Leads"];
    if (slimLeads && slimLeads.count) {
        for (int i = 0; i < slimLeads.count; i++) {
#warning TEST THIS
            SlimLead *slimLeadToUpdate = [existingRecords[@"slimLeads"] objectForKey:slimLeads[i][@"DashboardLeadID"]];
            if (slimLeadToUpdate) {
                [slimLeadToUpdate updateFromJSON:slimLeads[i]];
                [serviceCall.usersNotificationDict[kUpdatedSlimLeads] addObject:slimLeadToUpdate];
            }
            else if (slimLeads[i][@"Latitude"] != [NSNull null] && slimLeads[i][@"Longitude"] != [NSNull null]){
                
                SlimLead *lead = [SlimLead newSlimLeadFromJSON:slimLeads[i] forUser:self];
                [serviceCall.usersNotificationDict[kAddedSlimLeads] addObject:lead];
            }
        }
    }
}

- (id)filterNSNull:(id)json {
    
    if ([json isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return json;
}

#pragma mark - Custom Setters

- (void)setFirstNameValue:(NSString *)firstName
{
    [self willChangeValueForKey:@"firstName"];
    [self setPrimitiveFirstName:firstName];
    [self didChangeValueForKey:@"firstName"];
}

- (void)setLastNameValue:(NSString *)lastName
{
    [self willChangeValueForKey:@"lastName"];
    [self setPrimitiveLastName:lastName];
    [self didChangeValueForKey:@"lastName"];
}

- (void)setUserIdValue:(NSString *)userId
{
    [self willChangeValueForKey:@"userId"];
    [self setPrimitiveUserId:userId];
    [self didChangeValueForKey:@"userId"];
}

- (void)setRedValue:(NSNumber *)red
{
    [self willChangeValueForKey:@"red"];
    [self setPrimitiveRed:red];
    [self didChangeValueForKey:@"red"];
}

- (void)setGreenValue:(NSNumber *)green
{
    [self willChangeValueForKey:@"green"];
    [self setPrimitiveGreen:green];
    [self didChangeValueForKey:@"green"];
}

- (void)setBlueValue:(NSNumber *)blue
{
    [self willChangeValueForKey:@"blue"];
    [self setPrimitiveBlue:blue];
    [self didChangeValueForKey:@"blue"];
}

- (void)setRegionIdValue:(NSString *)regionId
{
    [self willChangeValueForKey:@"regionId"];
    [self setPrimitiveRegionId:regionId];
    [self didChangeValueForKey:@"regionId"];
}

- (void)setDepartmentIdValue:(NSString *)departmentId
{
    [self willChangeValueForKey:@"departmentId"];
    [self setPrimitiveDepartmentId:departmentId];
    [self didChangeValueForKey:@"departmentId"];
}

- (void)setRoleValue:(NSString *)role
{
    [self willChangeValueForKey:@"role"];
    [self setPrimitiveRole:role];
    [self didChangeValueForKey:@"role"];
}

#pragma mark - JSON Proxy

- (id)proxyForJSON
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    json[@"UserID"] = self.userId ? self.userId : [NSNull null];
    
    return json;
}

#pragma mark - Hex to RGB

+ (NSNumber *)redFromHex:(NSString *)hexString
{
    if (hexString) {
        unsigned hexValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        
        //[scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&hexValue];
        
        //Bit mask then shift the red value out
        unsigned red = (((hexValue & 0xFF0000) >> 16));
        
        return [NSNumber numberWithFloat:(red/255.0)];
    }
    else{
        return nil;
    }
    
}

+ (NSNumber *)greenFromHex:(NSString *)hexString
{
    if (hexString) {
        unsigned hexValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        
        //[scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&hexValue];
        
        //Bit mask then shift the red value out
        unsigned green = (((hexValue & 0x00FF00) >> 8));
        
        return [NSNumber numberWithFloat:(green/255.0)];
    }
    else{
        return nil;
    }
    
}

+ (NSNumber *)blueFromHex:(NSString *)hexString
{
    if (hexString) {
        unsigned hexValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        
        //[scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&hexValue];
        
        //Bit mask then shift the red value out
        unsigned blue = ((hexValue & 0x0000FF));
        
        return [NSNumber numberWithFloat:(blue/255.0)];
    }
    else{
        return nil;
    }
}

@end
