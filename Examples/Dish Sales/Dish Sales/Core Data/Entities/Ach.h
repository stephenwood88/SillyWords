//
//  Ach.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 5/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Agreement;

@interface Ach : NSManagedObject

@property (nonatomic, retain) NSString * accountNumber;
@property (nonatomic, retain) NSData * accountNumberEncrypted;
@property (nonatomic, retain) NSString * accountType;
@property (nonatomic, retain) NSString * financialInstitution;
@property (nonatomic, retain) NSString * routingNumber;
@property (nonatomic, retain) NSString * salt;
@property (nonatomic, retain) Agreement *agreement;

@end
