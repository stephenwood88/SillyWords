//
//  Agreement.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 5/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ach, CreditCard, Person, ServiceInfo, TextOverlayViewFront;

@interface Agreement : NSManagedObject

@property (nonatomic, retain) NSString * agemniLeadId;
@property (nonatomic, retain) NSString * campaignCode;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * salt;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) UIImage * signature;
@property (nonatomic, retain) NSData * signatureEncrypted;
@property (nonatomic, retain) NSDate * signedDate;
@property (nonatomic, retain) NSNumber * submitted;
@property (nonatomic, retain) NSString * terms;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * agreementId;
@property (nonatomic, retain) Ach *ach;
@property (nonatomic, retain) CreditCard *creditCard;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) ServiceInfo *serviceInfo;

@property (nonatomic, weak) TextOverlayViewFront * textOverlayFront;

@end
