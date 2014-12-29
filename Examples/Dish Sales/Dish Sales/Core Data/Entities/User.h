//
//  User.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area, Office, SlimLead, UserLocation;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) UIColor * color;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) Area *activeArea;
@property (nonatomic, retain) NSSet *inactiveAreas;
@property (nonatomic, retain) NSSet *slimLeads;
@property (nonatomic, retain) NSSet *userLocations;
@property (nonatomic, retain) NSSet *offices;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addInactiveAreasObject:(Area *)value;
- (void)removeInactiveAreasObject:(Area *)value;
- (void)addInactiveAreas:(NSSet *)values;
- (void)removeInactiveAreas:(NSSet *)values;

- (void)addSlimLeadsObject:(SlimLead *)value;
- (void)removeSlimLeadsObject:(SlimLead *)value;
- (void)addSlimLeads:(NSSet *)values;
- (void)removeSlimLeads:(NSSet *)values;

- (void)addUserLocationsObject:(UserLocation *)value;
- (void)removeUserLocationsObject:(UserLocation *)value;
- (void)addUserLocations:(NSSet *)values;
- (void)removeUserLocations:(NSSet *)values;

- (void)addOfficesObject:(Office *)value;
- (void)removeOfficesObject:(Office *)value;
- (void)addOffices:(NSSet *)values;
- (void)removeOffices:(NSSet *)values;

@end
