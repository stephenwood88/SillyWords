//
//  Agreement.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 5/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Agreement.h"
#import "Ach.h"
#import "CreditCard.h"
#import "Person.h"
#import "ServiceInfo.h"
#import "AppDelegate.h"

@interface Agreement (PrimitiveAccessor)

- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveUserId:(NSString *)userId;

@end

@implementation Agreement

@dynamic agemniLeadId;
@dynamic campaignCode;
@dynamic dateCreated;
@dynamic dateModified;
@dynamic notes;
@dynamic salt;
@dynamic saved;
@dynamic signature;
@dynamic signatureEncrypted;
@dynamic signedDate;
@dynamic submitted;
@dynamic terms;
@dynamic userId;
@dynamic agreementId;
@dynamic ach;
@dynamic creditCard;
@dynamic person;
@dynamic serviceInfo;

@synthesize textOverlayFront;

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveDateCreated:date];
    [self setPrimitiveDateModified:date];
    [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
}

@end
