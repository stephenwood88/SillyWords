//
//  Lead.m
//  Dish Sales
//
//  Created by Brady Anderson on 8/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Lead.h"
#import "Person.h"

#import "AppDelegate.h"

@interface Lead (PrimitiveAccessor)

- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveUserId:(NSString *)userId;

@end

@implementation Lead

@dynamic appointmentDate;
@dynamic appointmentTime;
@dynamic appointmentWindow;
@dynamic currentProvider;
@dynamic dateCreated;
@dynamic dateModified;
@dynamic latitude;
@dynamic leadId;
@dynamic longitude;
@dynamic markedToDelete;
@dynamic notes;
@dynamic outOfContractDate;
@dynamic rank;
@dynamic saved;
@dynamic status;
@dynamic subtitle;
@dynamic title;
@dynamic type;
@dynamic userId;
@dynamic windowSelected;
@dynamic person;

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveDateCreated:date];
    [self setPrimitiveDateModified:date];
    [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
}

@end
