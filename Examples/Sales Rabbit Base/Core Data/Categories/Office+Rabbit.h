//
//  Office+Rabbit.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Office.h"

@interface Office (Rabbit)

+ (Office *)newOfficeWithId:(NSString *) officeId region:(Region *)region;
+ (Office *)officeForOfficeId:(NSString *)officeId;

- (void)updateFromJSON:(id)officeDict existingRecords:(NSDictionary *)existingRecords;


@end
