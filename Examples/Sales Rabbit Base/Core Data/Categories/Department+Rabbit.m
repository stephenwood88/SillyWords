//
//  Department+Rabbit.m
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Department+Rabbit.h"
#import "Region+Rabbit.h"
#import "SRGlobalState.h"

@implementation Department (Rabbit)

+ (Department *)newDepartmentWithId:(NSString *) departmentId
{
    Department *department = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];
    department.departmentId = departmentId;
    return department;
}

- (void)updateFromJSON:(id)json existingRecords:(NSDictionary *)existingRecords
{
    //Add/Update Regions
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSDictionary *regionsDict = [json objectForKey:@"Area"];
    NSArray *regionIds = [regionsDict allKeys];
    if (regionIds && regionIds.count) {
        for (NSString *regionId in regionIds) {
            //Check if regions already have existing records. If not, add them; if so update them.
            Region *region = [existingRecords[@"regions"] objectForKey:regionId];
            BOOL toDelete = (BOOL)regionsDict[regionId][@"Deleted"];
            if (region) {
                //Region already exists
                if (toDelete) {
                    [context delete:region];
                    continue;
                }
            }
            else{
                if (toDelete) {
                    //It's already gone man...
                    continue;
                }
                region = [Region newRegionWithId:regionId department:self];
            }
            [region updateFromJSON:regionsDict[regionId] existingRecords:existingRecords];
        }
    }
}

@end
