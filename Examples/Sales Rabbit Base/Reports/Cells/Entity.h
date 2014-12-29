//
//  Entity.h
//  DishSales
//
//  Created by Jeff Lockhart on 9/8/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    EntityArea,
    EntityOffice,
    EntityManager,
    EntityUser
} EntityType;

@interface Entity : NSObject

@property (nonatomic) EntityType hierarchyEntityType;
@property (nonatomic) EntityType entityType;
// This ID is being returned as strings in the service call, will always be numbers though
@property (nonatomic, copy) NSString *entityId;
@property (nonatomic, copy) NSString *entityAreaId;
@property (nonatomic, copy) NSString *entityOfficeId;
@property (nonatomic, copy) NSString *entityManagerId;
@property (nonatomic, copy) NSString *entityUserId;



@property (nonatomic, copy) NSString *entityName;

@property (nonatomic, copy) NSNumber *installs;
@property (nonatomic, copy) NSNumber *sales;
@property (nonatomic, copy) NSNumber *pending;
@property (nonatomic, copy) NSNumber *notScheduled;
@property (nonatomic, copy) NSNumber *cancel;
@property (nonatomic, copy) NSString *chrgbck;
@property (nonatomic, copy) NSNumber *autoPay;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, weak) Entity *parent;
// Two different arrays, one for sorting purposes and the other one to display on the table view
@property (nonatomic, strong) NSMutableArray *statsStringList;
@property (nonatomic, strong) NSMutableArray *statsList;
@property (nonatomic) NSInteger indexToSort;

@property (nonatomic) BOOL expanded;

- (id)initWithType:(EntityType)entityType parent:(Entity *)parent dictionary:(NSDictionary *)dictionary;
- (id)initWithType:(EntityType)entityType parent:(Entity *)parent dictionary:(NSDictionary *)dictionary definition:(NSArray *)definition;
- (id)key;
- (NSString *)entityTypeString;
+ (EntityType)entityTypeFromString:(NSString *)type;
+ (NSString *)entityNameKeyForEntityType:(EntityType)entityType;
+ (NSString *)mapEntityNameConversionFromString:(NSString *)type;


@end
