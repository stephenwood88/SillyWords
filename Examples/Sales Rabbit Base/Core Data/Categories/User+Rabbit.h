//
//  User+Rabbit.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/10/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "User.h"

@interface User (Rabbit)

+ (User *)newUserWithUserId:(NSString *)userId;
+ (User *)currentUserWithUserId:(NSString *)userId fromContext:(NSManagedObjectContext *)context;

+ (NSNumber *)redFromHex:(NSString *)hexString;
+ (NSNumber *)greenFromHex:(NSString *)hexString;
+ (NSNumber *)blueFromHex:(NSString *)hexString;

- (void)updateFromJSON:(NSDictionary*)resultUserDict existingRecords:(NSDictionary *)existingRecords office:(Office *)office;
- (id)proxyForJSON;

@end
