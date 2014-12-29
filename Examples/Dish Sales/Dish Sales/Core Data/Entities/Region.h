//
//  Region.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/26/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department, Office;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * regionId;
@property (nonatomic, retain) Department *department;
@property (nonatomic, retain) NSSet *offices;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addOfficesObject:(Office *)value;
- (void)removeOfficesObject:(Office *)value;
- (void)addOffices:(NSSet *)values;
- (void)removeOffices:(NSSet *)values;

@end
