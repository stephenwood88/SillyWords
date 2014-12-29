//
//  Department.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/26/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Region;

@interface Department : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * departmentId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *regions;
@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addRegionsObject:(Region *)value;
- (void)removeRegionsObject:(Region *)value;
- (void)addRegions:(NSSet *)values;
- (void)removeRegions:(NSSet *)values;

@end
