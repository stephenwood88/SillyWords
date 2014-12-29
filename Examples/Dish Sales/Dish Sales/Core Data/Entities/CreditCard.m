//
//  CreditCard.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "CreditCard.h"
#import "Agreement.h"

#import "Person+Rabbit.h"

@implementation CreditCard

@dynamic cvv;
@dynamic expirationDate;
@dynamic number;
@dynamic salt;
@dynamic numberEncrypted;
@dynamic agreement;

@end
