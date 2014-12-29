//
//  Region+Rabbit.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Region.h"

@interface Region (Rabbit)

+ (Region *)newRegionWithId:(NSString *) regionId department:(Department *)department;
- (void)updateFromJSON:(id)json existingRecords:(NSDictionary *)existingRecords;

@end
