//
//  Agreement.h
//  Pods
//
//  Created by Brady Anderson on 4/20/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Agreement : NSManagedObject

@property (nonatomic, retain) NSString * campaignCode;
@property (nonatomic, retain) NSString * package;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * receiverConfiguration;
@property (nonatomic, retain) NSNumber * tvs;
@property (nonatomic, retain) Person *person;

@end
