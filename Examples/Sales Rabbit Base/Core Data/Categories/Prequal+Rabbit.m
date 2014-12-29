//
//  Prequal+Rabbit.m
//  DishOne Sales
//
//  Created by Bryan J Bryce on 4/3/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "Prequal+Rabbit.h"
#import "SRGlobalState.h"

@implementation Prequal (Rabbit)

+ (Prequal *) newPrequalFromJSON:(NSDictionary *)json withAreaId:(NSString *)areaId
{
    Prequal* newPrequal = [NSEntityDescription insertNewObjectForEntityForName:@"Prequal" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];

    NSAssert(json != nil, @"json should not be nil");
    if (areaId) {
        newPrequal.areaId = [NSString stringWithFormat:@"%@",areaId];
    }
    newPrequal.userId = [[SRGlobalState singleton] userId];
    NSAssert(newPrequal.userId, @"userId for Prequal should not be nil!");

    newPrequal.latitude = [NSNumber numberWithFloat:[json[@"Latitude"] doubleValue]];
    newPrequal.longitude = [NSNumber numberWithFloat:[json[@"Longitude"] doubleValue]];
    NSAssert(newPrequal.latitude != nil, @"Prequals must have a latitude!");
    NSAssert(newPrequal.longitude != nil, @"Prequals must have a longitude!");
    if (![areaId isKindOfClass:[NSNull class]]) {
        newPrequal.prequalId = json[@"PrequalID"];
    }
    if (![json[@"PrequalID"] isKindOfClass:[NSNull class]]) {
        newPrequal.prequalId = json[@"PrequalID"];
    }
    if (![json[@"PositionCertainty"] isKindOfClass:[NSNull class]]) {
        newPrequal.creditLevel = json[@"CreditLevel"];
    }
    if (![json[@"FirstName"] isKindOfClass:[NSNull class]]) {
        newPrequal.firstName = json[@"FirstName"];
    }
    if (![json[@"LastName"] isKindOfClass:[NSNull class]]) {
        newPrequal.lastName = json[@"LastName"];
    }
    if (![json[@"Address1"] isKindOfClass:[NSNull class]]) {
        newPrequal.address1 = json[@"Address1"];
    }
    if (![json[@"Address2"] isKindOfClass:[NSNull class]]) {
        newPrequal.address2 = json[@"Address2"];
    }
    if (![json[@"City"] isKindOfClass:[NSNull class]]) {
        newPrequal.city = json[@"City"];
    }
    if (![json[@"State"] isKindOfClass:[NSNull class]]) {
        newPrequal.state = json[@"State"];
    }
    if (![json[@"ZipCode"] isKindOfClass:[NSNull class]]) {
        newPrequal.zipCode = json[@"ZipCode"];
    }
    if (![json[@"PromoCode"] isKindOfClass:[NSNull class]]) {
        newPrequal.promoCode = json[@"PromoCode"];
    }
    if (![json[@"BuildersName"] isKindOfClass:[NSNull class]]) {
        newPrequal.buildersName = json[@"BuildersName"];
    }
    if (![json[@"Color"] isKindOfClass:[NSNull class]]) {
        newPrequal.color = json[@"Color"];
    }
    if (![json[@"CensusBlockGroup"] isKindOfClass:[NSNull class]]) {
        newPrequal.censusBlockGroup = json[@"CensusBlockGroup"];
    }
    if (![json[@"Subdivision"] isKindOfClass:[NSNull class]]) {
        newPrequal.subdivision = json[@"Subdivision"];
    }
    if (![json[@"SaleDate"] isKindOfClass:[NSNull class]]) {
        newPrequal.saleDate = [Prequal stringToDate:json[@"SaleDate"]];
    }
 

    return newPrequal;
}

+ (Prequal *) generateTestPrequalWithId:(NSString *)prequalId firstName:(NSString *)firstName lastName:(NSString *)lastName lat:(NSNumber *)lattitude long:(NSNumber *)longitude creditLevel:(NSString *)creditLevel
{
    Prequal* newPrequal = [NSEntityDescription insertNewObjectForEntityForName:@"Prequal" inManagedObjectContext:[[SRGlobalState singleton] managedObjectContext]];

    newPrequal.prequalId = prequalId;
    newPrequal.firstName = firstName;
    newPrequal.lastName = lastName;
    newPrequal.latitude = lattitude;
    newPrequal.longitude = longitude;
    newPrequal.creditLevel = creditLevel;

    return newPrequal;
}

#pragma mark - Helper Methods

+ (NSDate *)stringToDate:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date =[dateFormatter dateFromString:string];
    return date;
}

#pragma mark - MKAnnotation methods

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D newcoordinate = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    return newcoordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    self.latitude = [NSNumber numberWithDouble:newCoordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:newCoordinate.longitude];
}

- (NSString *)title
{
    NSString *defaultTitle = @"Prequal";
    // Set title based on names otherwise just give a default title
    if (self.firstName.length > 0 || self.lastName.length > 0) {
        if (self.firstName.length > 0) {
            NSString *tmp = self.firstName;
            if (self.lastName.length > 0) {
                tmp = [NSString stringWithFormat:@"%@ %@", tmp, self.lastName];
            }
            return tmp;
        }
        else if(self.lastName.length > 0){
            return self.lastName;
        }
        else{
            return defaultTitle;
        }
    }
    else{
        return defaultTitle;
    }
}

- (NSString *)subtitle
{
    NSString *subtitle = @"";
    if (self.address1) {
        subtitle = [NSString stringWithString:self.address1];
    }
    if (self.address2) {
        subtitle = [subtitle stringByAppendingString:@" "];
        subtitle = [subtitle stringByAppendingString:self.address2];
    }
    if (self.city) {
        subtitle = [subtitle stringByAppendingString:@" "];
        subtitle = [subtitle stringByAppendingString:self.city];
    }
    if (self.state) {
        subtitle = [subtitle stringByAppendingString:@" "];
        subtitle = [subtitle stringByAppendingString:self.state];
    }
    if (self.zipCode) {
        subtitle = [subtitle stringByAppendingString:@", "];
        subtitle = [subtitle stringByAppendingString:self.zipCode];
    }


    return subtitle;
}

- (UIColor *)getColor
{
    if (!self.color) {
        return nil;
    }else if ([self.color caseInsensitiveCompare:@"black"] == NSOrderedSame) {
        return [UIColor blackColor];
    }
    else if ([self.color caseInsensitiveCompare:@"darkGray"] == NSOrderedSame) {
        return [UIColor darkGrayColor];
    }
    else if ([self.color caseInsensitiveCompare:@"lightGray"] == NSOrderedSame) {
        return [UIColor lightGrayColor];
    }
    else if ([self.color caseInsensitiveCompare:@"white"] == NSOrderedSame) {
        return [UIColor whiteColor];
    }
    else if ([self.color caseInsensitiveCompare:@"gray"] == NSOrderedSame) {
        return [UIColor grayColor];
    }
    else if ([self.color caseInsensitiveCompare:@"red"] == NSOrderedSame) {
        return [UIColor redColor];
    }
    else if ([self.color caseInsensitiveCompare:@"green"] == NSOrderedSame) {
        return [UIColor greenColor];
    }
    else if ([self.color caseInsensitiveCompare:@"blue"] == NSOrderedSame) {
        return [UIColor blueColor];
    }
    else if ([self.color caseInsensitiveCompare:@"cyan"] == NSOrderedSame) {
        return [UIColor cyanColor];
    }
    else if ([self.color caseInsensitiveCompare:@"yellow"] == NSOrderedSame) {
        return [UIColor yellowColor];
    }
    else if ([self.color caseInsensitiveCompare:@"magenta"] == NSOrderedSame) {
        return [UIColor magentaColor];
    }
    else if ([self.color caseInsensitiveCompare:@"orange"] == NSOrderedSame) {
        return [UIColor orangeColor];
    }
    else if ([self.color caseInsensitiveCompare:@"purple"] == NSOrderedSame) {
        return [UIColor purpleColor];
    }
    else if ([self.color caseInsensitiveCompare:@"brown"] == NSOrderedSame) {
        return [UIColor brownColor];
    }
    else{
        return nil;
    }
}

@end
