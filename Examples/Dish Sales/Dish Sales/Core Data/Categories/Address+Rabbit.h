//
//  Address+Rabbit.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/23/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Address.h"

@interface Address (Rabbit)

- (BOOL)isStarted;
- (BOOL)isCompleted;

- (void)setStreet1Value:(NSString *)street1;
- (void)setStreet2Value:(NSString *)street2;
- (void)setCityValue:(NSString *)city;
- (void)setStateValue:(NSString *)state;
- (void)setZipValue:(NSString *)zip;

@end
