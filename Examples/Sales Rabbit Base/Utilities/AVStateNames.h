//
//  AVStateNames.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVStateNames : NSObject

+ (NSString *)getAbbreviationForState:(NSString *) stateName forCountry:(NSString *)country;
+ (NSString *)getStateForAbbreviation:(NSString *)abbreviation forCountry:(NSString *)country;

+ (NSArray *)getArrayOfStateAbbreviationsforCountry:(NSString *)country;

@end
