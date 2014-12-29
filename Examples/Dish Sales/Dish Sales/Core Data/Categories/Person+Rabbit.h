//
//  Person+Rabbit.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/23/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Person.h"

@interface Person (Rabbit)

+ (Person *)newPersonForLead:(Lead *)lead;
+ (Person *)newPersonForAgreement:(Agreement *)agreement;

- (BOOL)isStarted;
- (BOOL)isCompleted;

- (void)setFirstNameValue:(NSString *)firstName;
- (void)setLastNameValue:(NSString *)lastName;
- (void)setPhonePrimaryValue:(NSString *)phonePrimary;
- (void)setPhoneAlternateValue:(NSString *)phoneAlternate;
- (void)setEmailValue:(NSString *)email;

@end
