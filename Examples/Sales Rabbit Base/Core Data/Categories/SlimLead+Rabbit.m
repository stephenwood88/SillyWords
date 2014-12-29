//
//  SlimLead+Rabbit.m
//  Security Sales
//
//  Created by Bryan Bryce on 2/26/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SlimLead+Rabbit.h"
#import "SRGlobalState.h"
#import "Constants.h"

@implementation SlimLead (Rabbit)

+ (SlimLead *)newSlimLeadFromJSON:(id)json forUser:(User *)user
{
    NSAssert(json != nil, @"json should not be nil");
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    SlimLead *slimLead = [NSEntityDescription insertNewObjectForEntityForName:@"SlimLead"
                                                       inManagedObjectContext:context];
    
    slimLead.latitude = [NSNumber numberWithFloat:[json[@"Latitude"] floatValue]];
    slimLead.longitude = [NSNumber numberWithFloat:[json[@"Longitude"] floatValue]];
    
    if (![json[@"DashboardLeadID"] isKindOfClass:[NSNull class]]) {
        slimLead.leadId = [NSNumber numberWithFloat:[json[@"DashboardLeadID"] floatValue]];
    }
    
    if (![json[@"Status"] isKindOfClass:[NSNull class]]) {
        slimLead.status = json[@"Status"];
    }
    
    if (![json[@"FirstName"] isKindOfClass:[NSNull class]]) {
        slimLead.firstName = json[@"FirstName"];
    }
    
    if (![json[@"LastName"] isKindOfClass:[NSNull class]]) {
        slimLead.lastName = json[@"LastName"];
    }
    
    if (![json[@"City"] isKindOfClass:[NSNull class]]) {
        slimLead.city = json[@"City"];
    }

    if (![json[@"State"] isKindOfClass:[NSNull class]]) {
        slimLead.state = json[@"State"];
    }
    
    if (![json[@"Street1"] isKindOfClass:[NSNull class]]) {
        slimLead.street1 = json[@"Street1"];
    }
    
    if (![json[@"Street2"] isKindOfClass:[NSNull class]]) {
        slimLead.street2 = json[@"Street2"];
    }
    if (![json[@"DateCreated"] isKindOfClass:[NSNull class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy'-'MM'-'dd HH':'mm':'ss";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[json[@"DateCreated"] doubleValue]/1000];
        slimLead.dateCreated = date;
    }

    slimLead.user = user;

    NSAssert(slimLead.latitude != nil, @"Slim Leads locations must have a latitude!");
    NSAssert(slimLead.longitude != nil, @"Slim Leads locations must have a longitude!");
    NSAssert(slimLead.status != nil, @"Slim Leads must have a status!");

    return slimLead;
}

- (void)updateFromJSON:(id)json
{
    NSAssert(json != nil, @"json should not be nil");
    
    NSAssert(json[@"Latitude"] != nil, @"Latitude should not be nil");
    NSAssert(json[@"Longitude"] != nil, @"Longitude should not be nil");
    self.latitude = [NSNumber numberWithFloat:[json[@"Latitude"] floatValue]];
    self.longitude = [NSNumber numberWithFloat:[json[@"Longitude"] floatValue]];
    
    if (![json[@"Status"] isKindOfClass:[NSNull class]]) {
        self.status = json[@"Status"];
    }
    
    if (![json[@"FirstName"] isKindOfClass:[NSNull class]]) {
        self.firstName = json[@"FirstName"];
    }
    
    if (![json[@"LastName"] isKindOfClass:[NSNull class]]) {
        self.lastName = json[@"LastName"];
    }
    
    if (![json[@"City"] isKindOfClass:[NSNull class]]) {
        self.city = json[@"City"];
    }
    
    if (![json[@"State"] isKindOfClass:[NSNull class]]) {
        self.state = json[@"State"];
    }
    
    if (![json[@"Street1"] isKindOfClass:[NSNull class]]) {
        self.street1 = json[@"Street1"];
    }
    
    if (![json[@"Street2"] isKindOfClass:[NSNull class]]) {
        self.street2 = json[@"Street2"];
    }

    NSAssert(self.latitude != nil, @"Slim Leads locations must have a latitude!");
    NSAssert(self.longitude != nil, @"Slim Leads locations must have a longitude!");
    NSAssert(self.status != nil, @"Slim Leads must have a status!");
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
    // Set title based on names if set or on status if there is no name
    if (self.user.firstName.length > 0 || self.user.lastName.length > 0) {
        if (self.user.firstName.length > 0) {
            NSString *tmp = self.user.firstName;
            if (self.user.lastName.length > 0) {
                tmp = [NSString stringWithFormat:@"%@ %@", tmp, self.user.lastName];
                return tmp;
            }
            else{
                return tmp;
            }
        }
        else{
            return self.user.firstName;
        }
    }
    else{
        return @"";
    }
}

- (NSString *)subtitle
{
    NSString *tmp = @"";
    if (self.dateCreated != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM d, yyyy '@' hh:mm a"];
        tmp = [formatter stringFromDate:self.dateCreated];
    }

    return tmp;
}

- (UIImage *)image
{
    if ([self.status isEqual:kGoBack]){
        return [UIImage imageNamed:@"location_green"];
    }
    else if([self.status isEqual:kCallback]){
        return [UIImage imageNamed:@"location_yellow"];
    }
    else if([self.status isEqual:kNotHome]){
        return [UIImage imageNamed:@"location_orange"];
    }
    else if([self.status isEqual:kNotInterested]){
        return [UIImage imageNamed:@"location_red"];
    }
    else if([self.status isEqual:kCustomer]){
        return [UIImage imageNamed:@"location_blue"];
    }
    else {
        return [UIImage imageNamed:@"location_purple"];
    }
}


@end
