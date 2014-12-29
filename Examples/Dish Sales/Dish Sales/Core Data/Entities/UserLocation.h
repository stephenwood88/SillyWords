//
//  UserLocation.h
//  Dish Sales
//
//  Created by Bryan Bryce on 3/21/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * alpha;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) User *user;

@end
