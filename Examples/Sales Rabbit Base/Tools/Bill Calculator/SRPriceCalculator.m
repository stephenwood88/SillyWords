//
//  PriceCalculator.m
//  Dish Sales
//
//  Created by Aaron Brown on 5/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRPriceCalculator.h"
#import "Constants.h"

@implementation SRPriceCalculator

+ (NSNumber *)priceForHardwareOption:(NSString *)hardwareOption quantity:(NSNumber *)quantity provider:(NSString *)provider{
    float floatPrice = ([[[[kCalculatorDictionary objectForKey:provider] objectForKey:kHardwarePrice] objectForKey:hardwareOption] floatValue] * [quantity floatValue]);
    
    //add extra $6 for Cox HDDVR
    if (hardwareOption == kHDDVR && provider == kCox) {
        floatPrice += 6.0;
    }
    
//    if (hardwareOption == kTVs && provider == kDishNetwork) {
//        floatPrice = 5.0;
//    }
    return [NSNumber numberWithFloat:floatPrice];
}

+ (NSNumber *)direcTVHDPriceDVRs:(NSNumber *)dvrs hd:(NSNumber *)hd tvs:(NSNumber *)tvs{
    if ([dvrs intValue] > 0 && [hd boolValue]) {
        float floatPrice = ([[[[kCalculatorDictionary objectForKey:kDirecTv] objectForKey:kHardwarePrice] objectForKey:kDVRCharge] floatValue] * ([dvrs floatValue] - 1.0));
        return [NSNumber numberWithFloat:floatPrice];
    }
    else{
        
    }
    return @0;
}

+ (NSNumber *)priceForPackage:(NSString *)package provider:(NSString *)provider{
    return [[[kCalculatorDictionary objectForKey:provider] objectForKey:kPackagePrice] objectForKey:package];
}

+ (NSNumber *)priceForPackage:(NSString *)package provider:(NSString *)provider configuration:(NSString *)receiverConfig isPromo:(BOOL)isPromo numberTVs:(NSNumber *)tvs{
    NSString *packagePriceKey;
    if (isPromo) {
        packagePriceKey = kPackagePromoPrice;
    }
    else {
        packagePriceKey = kPackagePrice;
    }
    int totalPrice = [[[[kCalculatorDictionary objectForKey:provider] objectForKey:packagePriceKey] objectForKey:package] intValue];
    totalPrice += [[[[kCalculatorDictionary objectForKey:provider] objectForKey:kReceiverPricing] objectForKey:receiverConfig] intValue];
    
    if ([provider isEqualToString:kDirecTv]) {
        totalPrice += ([tvs intValue]) * 6;
    }
    
    return [NSNumber numberWithInt:totalPrice];
}

+ (NSNumber *)totalPriceForMovieChannels:(NSArray *)channels provider:(NSString *)provider{
    NSDictionary *pricesDict = [SRPriceCalculator pricesForMovieChannels:channels provider:provider];
    int totalPrice = 0;
    for (NSString *key in [pricesDict allKeys]) {
        totalPrice += [[pricesDict objectForKey:key] intValue];
    }
    return [NSNumber numberWithInt:totalPrice];
}

+ (NSDictionary *)pricesForMovieChannels:(NSArray *)channels provider:(NSString *)provider{
    NSMutableDictionary *pricesDict = [[[kCalculatorDictionary objectForKey:provider] objectForKey:kMovieChannelPrice] mutableCopy];
    for (NSString *key in [pricesDict allKeys]) {
        if (![channels containsObject:key]) {
            [pricesDict setObject:@0 forKey:key];
        }
    }
    
    //U-Verse special movie channel pricing
    if (provider == kUverse) {
        if ([channels containsObject:kHBO] && [channels containsObject:kCinemax]) {
            [pricesDict setObject:@13 forKey:kHBO];
            [pricesDict setObject:@13 forKey:kCinemax];
        }
    }
    
    //Multiple movie channel pricing
    if ([[kCalculatorDictionary objectForKey:provider] objectForKey:kMultipleMovieChannelPrice] && [channels count] > 1) {
        //Encore doesn't count in movie channel pricing
        int numMovieChannels = (int)[channels count];
        NSNumber *encorePrice = [pricesDict objectForKey:kEncore];
        if ([channels containsObject:kEncore]) {
            [pricesDict setObject:@0 forKey:kEncore];
            numMovieChannels -= 1;
        }
        
        int totalPrice = [[[[kCalculatorDictionary objectForKey:provider] objectForKey:kMultipleMovieChannelPrice] objectAtIndex:(numMovieChannels - 1)] intValue];
        int priceRemaining = totalPrice;
    
        for (NSString *key in [pricesDict allKeys]) {
            if ([[pricesDict objectForKey:key] intValue] != 0) {
                int priceToSubtract = priceRemaining / numMovieChannels;
                [pricesDict setObject:[NSNumber numberWithInt:priceToSubtract] forKey:key];
                priceRemaining -= priceToSubtract;
                numMovieChannels--;
                
                if ([key isEqualToString:kHBO] && [provider isEqualToString:kDirecTv]) {
                    [pricesDict setObject:[NSNumber numberWithInt:(priceToSubtract + 5)] forKey:key];
                }
            }
        }
        if ([channels containsObject:kEncore]) {
            [pricesDict setObject:encorePrice forKey:kEncore];
        }
    }

    return pricesDict;
}

+ (NSNumber *)priceForWarrantyWithProvider:(NSString *)provider;
{
    if ([provider isEqualToString:kDirecTv]) {
        return @7;
    }
    else{
        return @0;
    }
}

@end
