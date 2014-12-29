//
//  ServiceInfo+Rabbit.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "ServiceInfo.h"

@interface ServiceInfo (Rabbit)

- (BOOL)isStarted;
- (BOOL)isCompleted;
- (NSDictionary *)serviceCallDictionary;

@end
