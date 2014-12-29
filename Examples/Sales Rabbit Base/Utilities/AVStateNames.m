//
//  self.stateNames.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AVStateNames.h"

@implementation AVStateNames

static NSArray *stateNamesUSA;
static NSArray *stateAbbreviationsUSA;
static NSArray *stateNamesCAN;
static NSArray *stateAbbreviationsCAN;
static NSArray *stateNamesAUS;
static NSArray *stateAbbreviationsAUS;

+ (void)initialize {
    stateNamesUSA = [[NSArray alloc] initWithObjects:
                  @"Alabama",
                  @"Alaska",
                  @"Arizona",
                  @"Arkansas",
                  @"California",
                  @"Colorado",
                  @"Connecticut",
                  @"Delaware",
                  @"District of Columbia",
                  @"Florida",
                  @"Georgia",
                  @"Hawaii",
                  @"Idaho",
                  @"Illinois",
                  @"Indiana",
                  @"Iowa",
                  @"Kansas",
                  @"Kentucky",
                  @"Louisiana",
                  @"Maine",
                  @"Maryland",
                  @"Massachusetts",
                  @"Michigan",
                  @"Minnesota",
                  @"Mississippi",
                  @"Missouri",
                  @"Montana",
                  @"Nebraska",
                  @"Nevada",
                  @"New Hampshire",
                  @"New Jersey",
                  @"New Mexico",
                  @"New York",
                  @"North Carolina",
                  @"North Dakota",
                  @"Ohio",
                  @"Oklahoma",
                  @"Oregon",
                  @"Pennsylvania",
                  @"Rhode Island",
                  @"South Carolina",
                  @"South Dakota",
                  @"Tennessee",
                  @"Texas",
                  @"Utah",
                  @"Vermont",
                  @"Virginia",
                  @"Virgin Islands",
                  @"Washington",
                  @"West Virginia",
                  @"Wisconsin",
                  @"Wyoming",
                  nil];
    
    stateAbbreviationsUSA = [[NSArray alloc] initWithObjects:
                          @"AL",
                          @"AK",
                          @"AZ",
                          @"AR",
                          @"CA",
                          @"CO",
                          @"CT",
                          @"DE",
                          @"DC",
                          @"FL",
                          @"GA",
                          @"HI",
                          @"ID",
                          @"IL",
                          @"IN",
                          @"IA",
                          @"KS",
                          @"KY",
                          @"LA",
                          @"ME",
                          @"MD",
                          @"MA",
                          @"MI",
                          @"MN",
                          @"MS",
                          @"MO",
                          @"MT",
                          @"NE",
                          @"NV",
                          @"NH",
                          @"NJ",
                          @"NM",
                          @"NY",
                          @"NC",
                          @"ND",
                          @"OH",
                          @"OK",
                          @"OR",
                          @"PA",
                          @"RI",
                          @"SC",
                          @"SD",
                          @"TN",
                          @"TX",
                          @"UT",
                          @"VT",
                          @"VI",
                          @"VA",
                          @"WA",
                          @"WV",
                          @"WI",
                          @"WY",
                          nil];
    
    // Canadian Provinces
    stateNamesCAN = [[NSArray alloc] initWithObjects:
                  @"Alberta",
                  @"British Columbia",
                  @"Manitoba",
                  @"New Brunswick",
                  @"Newfoundland and Labrador",
                  @"Nova Scotia",
                  @"Northwest Territories",
                  @"Nunavut",
                  @"Ontario",
                  @"Prince Edward Island",
                  @"Québec",
                  @"Saskatchewan",
                  @"Yukon",
                  nil];
    
    stateAbbreviationsCAN = [[NSArray alloc] initWithObjects:
                @"AB",
                @"BC",
                @"MB",
                @"NB",
                @"NL",
                @"NS",
                @"NT",
                @"NU",
                @"ON",
                @"PE",
                @"QC",
                @"SK",
                @"YT",
                nil];
    
    // Australian Provinces
    stateNamesAUS = [[NSArray alloc] initWithObjects:
                  @"Australian Capital Territory",
                  @"New South Wales",
                  @"Northern Territory",
                  @"Queensland",
                  @"South Australia",
                  @"Tasmania",
                  @"Victoria",
                  @"Western Australia",
                  nil];
    
    stateAbbreviationsAUS = [[NSArray alloc] initWithObjects:
                          @"ACT",
                          @"NSW",
                          @"NT",
                          @"QLD",
                          @"SA",
                          @"TAS",
                          @"VIC",
                          @"WA",
                          nil];
}

+ (NSString *)getAbbreviationForState:(NSString *) stateName forCountry:(NSString *)country {
    if ([country isEqualToString:@"USA"]) {
        int index = (int)[stateNamesUSA indexOfObject:stateName];
        if (index >= 0 && index < stateAbbreviationsUSA.count) {
            return [stateAbbreviationsUSA objectAtIndex:index];
        }
        else {
            return stateName;
        }
    }
    else if ([country isEqualToString:@"CAN"]) {
        int index = (int)[stateNamesCAN indexOfObject:stateName];
        if (index >= 0 && index < stateAbbreviationsCAN.count) {
            return [stateAbbreviationsCAN objectAtIndex:index];
        }
        else {
            return stateName;
        }
    }
    else if([country isEqualToString:@"AUS"]) {
        int index = (int)[stateNamesAUS indexOfObject:stateName];
        if (index >= 0 && index < stateAbbreviationsAUS.count) {
            return [stateAbbreviationsAUS objectAtIndex:index];
        }
        else {
            return stateName;
        }
    }
    return stateName;
}

+ (NSString *)getStateForAbbreviation:(NSString *)abbreviation forCountry:(NSString *)country {
    if ([country isEqualToString:@"USA"]) {
        int index = (int)[stateAbbreviationsUSA indexOfObject:abbreviation];
        if (index >= 0 && index < stateNamesUSA.count) {
            return [stateNamesUSA objectAtIndex:index];
        }
    }
    else if ([country isEqualToString:@"CAN"]) {
        int index = (int)[stateAbbreviationsCAN indexOfObject:abbreviation];
        if (index >= 0 && index < stateNamesCAN.count) {
            return [stateNamesCAN objectAtIndex:index];
        }
    }
    else if ([country isEqualToString:@"AUS"]) {
        int index = (int)[stateAbbreviationsAUS indexOfObject:abbreviation];
        if (index >= 0 && index < stateNamesAUS.count) {
            return [stateNamesAUS objectAtIndex:index];
        }
    }
    return nil;
}

+ (NSArray *)getArrayOfStateAbbreviationsforCountry:(NSString *)country{
    if ([country isEqualToString:@"USA"])
        return stateAbbreviationsUSA;
    else if ([country isEqualToString:@"CAN"])
        return stateAbbreviationsCAN;
    else if ([country isEqualToString:@"AUS"])
        return stateAbbreviationsAUS;
    return nil;
}

@end
