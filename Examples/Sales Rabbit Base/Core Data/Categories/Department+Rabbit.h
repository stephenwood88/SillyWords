//
//  Department+Rabbit.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 3/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Department.h"

@interface Department (Rabbit)

+ (Department *)newDepartmentWithId:(NSString *) departmentId;

- (void)updateFromJSON:(id)json existingRecords:(NSDictionary *)existingRecords;

@end
