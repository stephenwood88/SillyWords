//
//  Prequal.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 6/12/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Prequal : NSManagedObject

@property (nonatomic, retain) NSString * address1;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * areaId;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * creditLevel;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * prequalId;
@property (nonatomic, retain) NSString * promoCode;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * subdivision;
@property (nonatomic, retain) NSDate * saleDate;
@property (nonatomic, retain) NSString * buildersName;
@property (nonatomic, retain) NSString * censusBlockGroup;

@end
