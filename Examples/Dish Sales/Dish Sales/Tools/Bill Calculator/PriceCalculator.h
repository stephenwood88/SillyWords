//
//  PriceCalculator.h
//  Dish Sales
//
//  Created by Aaron Brown on 5/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceCalculator : NSObject

+ (NSNumber *)priceForHardwareOption:(NSString *)hardwareOption quantity:(NSNumber *)quantity provider:(NSString *)provider;
+ (NSNumber *)priceForPackage:(NSString *)package provider:(NSString *)provider;
+ (NSDictionary *)pricesForMovieChannels:(NSArray *)channels provider:(NSString *)provider;
+ (NSNumber *)priceForPackage:(NSString *)package provider:(NSString *)provider configuration:(NSString *)receiverConfig isPromo:(BOOL)isPromo numberTVs:(NSNumber *)tvs;
+ (NSNumber *)totalPriceForMovieChannels:(NSArray *)channels provider:(NSString *)provider;
+ (NSNumber *)priceForWarrantyWithProvider:(NSString *)provider;

@end
