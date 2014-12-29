//
//  Lead.h
//  Dish Sales
//
//  Created by Brady Anderson on 8/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Lead : NSManagedObject

@property (nonatomic, retain) NSDate * appointmentDate;
@property (nonatomic, retain) NSDate * appointmentTime;
@property (nonatomic, retain) NSString * appointmentWindow;
@property (nonatomic, retain) NSString * currentProvider;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * leadId;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * markedToDelete;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSDate * outOfContractDate;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * windowSelected;
@property (nonatomic, retain) Person *person;

@end
