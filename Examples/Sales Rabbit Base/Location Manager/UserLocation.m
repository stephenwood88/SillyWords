//
//  UserLocation.m
//  
//
//  Created by Bryan Bryce on 1/20/14.
//
//

//TODO: THIS ENTITY NEEDS TO BE ADDED TO THE DISH SALES DATA MODEL BEFORE EVERYTHING WILL WORK CORRECTLY
#import "UserLocation.h"
#import "AppDelegate.h"

@interface UserLocation (PrimitiveAccessor)

- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveUserId:(NSString *)userId;

@end

@implementation UserLocation

@dynamic latitude;
@dynamic longitude;
@dynamic dateCreated;
@dynamic userId;
@dynamic userLocationId;
@dynamic alpha;

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveDateCreated:date];
    [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
}

@end