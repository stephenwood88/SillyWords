//
//  Address.h
//  Dish Sales
//
//  Created by Matthew McArthur on 1/31/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * street1;
@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) Person *billingPerson;

@end
