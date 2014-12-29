//
//  Office.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/26/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area, Region, User;

@interface Office : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * officeId;
@property (nonatomic, retain) NSSet *areas;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) NSSet *users;
@end

@interface Office (CoreDataGeneratedAccessors)

- (void)addAreasObject:(Area *)value;
- (void)removeAreasObject:(Area *)value;
- (void)addAreas:(NSSet *)values;
- (void)removeAreas:(NSSet *)values;

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
