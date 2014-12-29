//
//  Entity.m
//  DishSales
//
//  Created by Jeff Lockhart on 9/8/12.
//
//

#import "Entity.h"
#import "Constants.h"

@implementation Entity

- (id)initWithType:(EntityType)entityType parent:(Entity *)parent dictionary:(NSDictionary *)dictionary definition:(NSArray *)definition
{
    self = [super init];
    if (self) {
        self.parent = parent;
        self.hierarchyEntityType = entityType;
        // These IDs are being returned as strings in the service call, will always be numbers though
        NSString *userId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kUser, kID]]];
        NSString *managerId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kManager, kID]]];
        NSString *officeId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kOffice, kID]]];
        NSString *areaId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kArea, kID]]];
        [self setEntityTypeAndIdFromType:entityType userId:userId managerId:managerId officeId:officeId areaId:areaId];
        
        self.statsStringList = [[NSMutableArray alloc] initWithCapacity:definition.count];
        self.statsList = [[NSMutableArray alloc] initWithCapacity:definition.count];
        
        self.indexToSort = 0;
        
        for (int i=0; i<definition.count; i++) {
            NSString *stat;
            NSNumber *statNumber;
            id newStat = [dictionary objectForKey:[[definition objectAtIndex:i] objectForKey:@"Name"]];
            if ([newStat isKindOfClass:[NSString class]]) {
                stat = newStat;
                statNumber = [NSNumber numberWithInteger:[newStat integerValue]];
            }
            else{
                stat = [NSString stringWithFormat:@"%@",newStat];
                statNumber = newStat;
            }
            if (stat && statNumber) {
                [self.statsStringList addObject:stat];
                [self.statsList addObject:statNumber];
            }
        }
        
       self.entityName = [self checkForNSNull:[dictionary objectForKey:[Entity entityNameKeyForEntityType:entityType]]];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *temp = [self checkForNSNull:[dictionary objectForKey:kCancelRate]];
        temp = [temp substringToIndex:[temp length] - 1];
        self.cancel = [numberFormatter numberFromString:temp];
        
        self.children = [[NSMutableArray alloc] init];
        self.expanded = NO;
    }
    return self;
}


- (id)initWithType:(EntityType)entityType parent:(Entity *)parent dictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        self.parent = parent;
        self.hierarchyEntityType = entityType;
        // These IDs are being returned as strings in the service call, will always be numbers though
        NSString *userId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kUser, kID]]];
        NSString *managerId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kManager, kID]]];
        NSString *officeId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kOffice, kID]]];
        NSString *areaId = [self checkForNSNull:dictionary[[NSString stringWithFormat:@"%@%@", kArea, kID]]];
        [self setEntityTypeAndIdFromType:entityType userId:userId managerId:managerId officeId:officeId areaId:areaId];
        self.entityName = [self checkForNSNull:[dictionary objectForKey:[Entity entityNameKeyForEntityType:entityType]]];
        self.installs = [self checkForNSNull:[dictionary objectForKey:kInstallCount]];
        self.sales = [self checkForNSNull:[dictionary objectForKey:kSaleCount]];
        self.pending = [self checkForNSNull:[dictionary objectForKey:kPendingCount]];
        self.notScheduled = [self checkForNSNull:[dictionary objectForKey:kNotScheduledCount]];
        self.chrgbck = [self checkForNSNull:[dictionary objectForKey:kChargebackRate]];
        self.autoPay = [self checkForNSNull:[dictionary objectForKey:kAutoPay]];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *temp = [self checkForNSNull:[dictionary objectForKey:kCancelRate]];
        temp = [temp substringToIndex:[temp length] - 1];
        self.cancel = [numberFormatter numberFromString:temp];
        
        self.children = [[NSMutableArray alloc] init];
        self.expanded = NO;
    }
    return self;
}

/**
 * Returns the key used to map this object in a dictionary
 */
- (id)key {
    
    return self.entityId;
}

- (NSString *)entityTypeString {
    
    switch (self.entityType) {
        case EntityArea:
            return kArea;
        case EntityOffice:
            return kOffice;
        case EntityManager:
            return kManager;
        case EntityUser:
            return kUser;
    }
}

- (NSString *)description {
    
    return self.entityName;
}

#pragma mark - Private Methods

#pragma mark - Helper Methods

- (void)setEntityTypeAndIdFromType:(EntityType)entityType userId:(NSString *)userId managerId:(NSString *)managerId officeId:(NSString *)officeId areaId:(NSString *)areaId {
    
    switch (entityType) {
        case EntityUser:
            self.entityType = EntityUser;
            self.entityId = userId ? userId : @"0";
            self.entityAreaId = areaId ? areaId : @"0";
            self.entityOfficeId = officeId ? officeId : @"0";
            self.entityManagerId = managerId ? managerId : @"0";
            break;
        case EntityManager:
            //if (managerId && ![managerId isEqualToString:@"0"]) {
                self.entityType = EntityManager;
                self.entityId = managerId ? managerId : @"0";
                self.entityAreaId = areaId ? areaId : @"0";
                self.entityOfficeId = officeId ? officeId : @"0";
            //}
            break;
        case EntityOffice:
            //if (officeId && ![officeId isEqualToString:@"0"]) {
                self.entityType = EntityOffice;
                self.entityId = officeId? officeId : @"0";
                self.entityAreaId = areaId ? areaId : @"0";
            //}
            break;
        case EntityArea:
            self.entityType = EntityArea;
            self.entityId = areaId ? areaId : @"0";
    }
}

- (id)checkForNSNull:(id)object {
    
    if ([object class] == [NSNull class]) {
        return nil;
    }
    return object;
}

#pragma mark - Static Methods

+ (NSString *)entityNameKeyForEntityType:(EntityType)entityType {
    
    switch (entityType) {
        case EntityArea:
            return [NSString stringWithFormat:@"%@%@", kArea, kName];
        case EntityOffice:
            return [NSString stringWithFormat:@"%@%@", kOffice, kName];
        case EntityManager:
            return [NSString stringWithFormat:@"%@%@", kManager, kName];
        case EntityUser:
            return [NSString stringWithFormat:@"%@%@", kUser, kName];
    }
}

+ (EntityType)entityTypeFromString:(NSString *)type {

    if ([type isEqualToString:@"Area"]) {
        return EntityArea;
    }
    else if([type isEqualToString:@"Office"]){
        return EntityOffice;
    }
    else if ([type isEqualToString:@"Manager"]){
        return EntityManager;
    }
    else if ([type isEqualToString:@"User"]){
        return EntityUser;
    }
    else{
        return nil;
    }
}

+ (NSString *)mapEntityNameConversionFromString:(NSString *)type
{
    if ([type isEqualToString:@"Area"]) {
        return @"Region";
    }
    else if([type isEqualToString:@"Office"]){
        return type;
    }
    else if ([type isEqualToString:@"Manager"]){
        return @"Team";
    }
    else if ([type isEqualToString:@"User"]){
        return @"Rep";
    }
    else if([type isEqualToString:@"Region"]){
        return @"Area";
    }
    else if ([type isEqualToString:@"Team"]){
        return @"Manager";
    }
    else if ([type isEqualToString:@"Rep"]){
        return @"User";
    }
    else{
        return nil;
    }

}

@end
