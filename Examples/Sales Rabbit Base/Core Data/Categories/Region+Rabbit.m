//
//  Region+Rabbit.m
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Region+Rabbit.h"
#import "Department+Rabbit.h"
#import "Office+Rabbit.h"
#import "SRGlobalState.h"

@interface Region (PrimitiveAccessor)

- (void)setPrimitiveName:(NSString *)name;

@end

@implementation Region (Rabbit)



+ (Region *)newRegionWithId:(NSString *) regionId department:(Department *)department
{
    Region *region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];
    region.regionId = regionId;
    region.department = department;
    return region;
}

- (void)updateFromJSON:(id)json existingRecords:(NSDictionary *)existingRecords
{
    //Region
    NSAssert(self.regionId, @"Regions should always have a regionId.");
    NSAssert(self.department, @"Updated Regions should always have a department.");

    if (json[@"AreaName"]) {
        [self setNameValue:[self filterNSNull:json[@"AreaName"]]];
    }

    //Add/Update Offices
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSDictionary *officesDict = [json objectForKey:@"Office"];
    if (officesDict && officesDict.count) {

        NSArray *officeIds = [officesDict allKeys];
        if (officeIds && officeIds.count) {
            for (NSString *officeId in officeIds) {

                Office *office = [existingRecords[@"offices"] objectForKey:officeId];

                BOOL toDelete = officesDict[officeId][@"Deleted"];
                if (office) {
                    //Region already exists
                    if (toDelete) {
                        [context delete:office];
                        continue;
                    }
                }
                else{
                    if (toDelete) {
                        //It's already gone man...
                        continue;
                    }
                    office = [Office newOfficeWithId:officeId region:self];
                }
                [office updateFromJSON:officesDict[officeId] existingRecords:existingRecords];
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

@end