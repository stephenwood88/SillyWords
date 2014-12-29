//
//  ServiceInfo.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 5/7/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Agreement;

@interface ServiceInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * autoPay;
@property (nonatomic, retain) NSNumber * internetAccess;
@property (nonatomic, retain) NSString * otherDescription;
@property (nonatomic, retain) NSString * otherPrice;
@property (nonatomic, retain) NSString * package;
@property (nonatomic, retain) NSString * promoPrice;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSString * receiverConfiguration;
@property (nonatomic, retain) NSString * regularPrice;
@property (nonatomic, retain) NSNumber * tvs;
@property (nonatomic, retain) NSString * setupPrice;
@property (nonatomic, retain) NSString * other2Description;
@property (nonatomic, retain) NSString * other2Price;
@property (nonatomic, retain) Agreement *agreement;

@end
