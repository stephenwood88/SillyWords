//
//  SlimLead.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/18/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface SlimLead : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * leadId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * street1;
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) User *user;

@end
