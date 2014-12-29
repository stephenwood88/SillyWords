//
//  Area.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 6/12/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class MapPoint, Office, User;

@interface Area : NSManagedObject

@property (nonatomic, retain) NSString * areaId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) MKPolygonRenderer *polygonReference;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) MKPolygon *overlayReference;
@property (nonatomic, retain) NSOrderedSet *activeUsers;
@property (nonatomic, retain) NSSet *inactiveUsers;
@property (nonatomic, retain) NSOrderedSet *mapPoints;
@property (nonatomic, retain) Office *office;
@end

@interface Area (CoreDataGeneratedAccessors)

- (void)insertObject:(User *)value inActiveUsersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromActiveUsersAtIndex:(NSUInteger)idx;
- (void)insertActiveUsers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeActiveUsersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInActiveUsersAtIndex:(NSUInteger)idx withObject:(User *)value;
- (void)replaceActiveUsersAtIndexes:(NSIndexSet *)indexes withActiveUsers:(NSArray *)values;
- (void)addActiveUsersObject:(User *)value;
- (void)removeActiveUsersObject:(User *)value;
- (void)addActiveUsers:(NSOrderedSet *)values;
- (void)removeActiveUsers:(NSOrderedSet *)values;
- (void)addInactiveUsersObject:(User *)value;
- (void)removeInactiveUsersObject:(User *)value;
- (void)addInactiveUsers:(NSSet *)values;
- (void)removeInactiveUsers:(NSSet *)values;

- (void)insertObject:(MapPoint *)value inMapPointsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMapPointsAtIndex:(NSUInteger)idx;
- (void)insertMapPoints:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMapPointsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMapPointsAtIndex:(NSUInteger)idx withObject:(MapPoint *)value;
- (void)replaceMapPointsAtIndexes:(NSIndexSet *)indexes withMapPoints:(NSArray *)values;
- (void)addMapPointsObject:(MapPoint *)value;
- (void)removeMapPointsObject:(MapPoint *)value;
- (void)addMapPoints:(NSOrderedSet *)values;
- (void)removeMapPoints:(NSOrderedSet *)values;
@end
