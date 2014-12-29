//
//  CreditCard.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Agreement;

@interface CreditCard : NSManagedObject

@property (nonatomic, retain) NSString * cvv;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * salt;
@property (nonatomic, retain) NSData * numberEncrypted;
@property (nonatomic, retain) Agreement *agreement;

@end
