//
//  Lead+Rabbit.m
//  Dish Sales
//
//  Created by Brady Anderson on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <EventKit/EventKit.h>
#import "Lead+Rabbit.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "Agreement+Rabbit.h"
#import "TextOverlayViewFront.h"
#import "AVTextUtilities.h"
#import "AVStateNames.h"
#import "Constants.h"

@interface Lead (PrimitiveAccessor)

- (void)setPrimitiveAppointmentDate:(NSDate *)appointmentDate;
- (void)setPrimitiveAppointmentTime:(NSDate *)appointmentTime;
- (void)setPrimitiveAppointmentWindow:(NSString *)appointmentWindow;
- (void)setPrimitiveCurrentProvider:(NSString *)currentProvider;
- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveLatitude:(NSNumber *)latitude;
- (void)setPrimitiveLeadId:(NSString *)leadId;
- (void)setPrimitiveLongitude:(NSNumber *)longitude;
- (void)setPrimitiveNotes:(NSString *)notes;
- (void)setPrimitiveOutOfContractDate:(NSDate *)outOfContractDate;
- (void)setPrimitiveRank:(NSString *)rank;
- (void)setPrimitiveStatus:(NSString *)status;
// TODO: Apple seems to have made a method of its own called setPrimitiveType: which results in the following warning when submitting the app: "The app references non-public selectors in Payload/Sales Rabbit.app/Sales Rabbit: setPrimitiveType:" so we may need to migrate the attribute "type" to a newly named attribute that won't result in this warning. Hopefully there isn't a collision with these methods in this entity either.
- (void)setPrimitiveType:(NSString *)type;
- (void)setPrimitiveUserId:(NSString *)userId;
- (void)setPrimitiveWindowSelected:(NSNumber *)windowSelected;

@end

@implementation Lead (Rabbit)

/**
 * Since super can't be called in categories, be sure this method is overwritten
 * in Lead.m when regenerating this class.
 *
 
#import "AppDelegate.h"

@interface Lead (PrimitiveAccessor)

- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveUserId:(NSString *)userId;

@end

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveDateCreated:date];
    [self setPrimitiveDateModified:date];
    [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
}
*/

#pragma mark - New Lead class methods

+ (Lead *)newLead {
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Lead *lead = [NSEntityDescription insertNewObjectForEntityForName:@"Lead" inManagedObjectContext:context];
    [Person newPersonForLead:lead];
    return lead;
}

+ (Lead *)newLeadForPerson:(Person *)person {
    NSAssert(person != nil, @"Person should not be nil");
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Lead *lead = [NSEntityDescription insertNewObjectForEntityForName:@"Lead" inManagedObjectContext:context];
    lead.person = person;
    return lead;
}

#pragma mark Delete Lead

- (void)deleteLeadSync:(BOOL)syncDelete {
    
    // If there isn't a lead ID, it hasn't been synced yet anyway
    if (syncDelete && self.leadId) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableSet *deletedLeadIds = [NSMutableSet setWithArray:[defaults objectForKey:kDeletedLeadIds]];
        [deletedLeadIds addObject:self.leadId];
        [defaults setObject:[deletedLeadIds allObjects] forKey:kDeletedLeadIds];
        [defaults synchronize];
    }
    
    //Cancel scheduled notification
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if (self.leadId && [[notification.userInfo objectForKey:kLeadId] isEqualToString:self.leadId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
        else if (self.leadId == nil && [[notification.userInfo objectForKey:kLeadId] isEqualToString:@"New Lead"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
    }
    
//    //Remove calendar event
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    EKEvent *event = [eventStore eventWithIdentifier:self.iosCalEventId];
//    if (event != nil) {
//        [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
//    }
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    NSAssert(self.person != nil, @"Person should not be nil");
    if (!self.person.agreement) {
        [context deleteObject:self.person];
    }
    [context deleteObject:self];
}

#pragma mark - Geocoding

- (void)setCoordinateFromAddressWithCompletionHandler:(void (^)(BOOL success, Lead *lead, NSError *error))completionHandler {
    
    // TODO: Do we want to require these fields to geocode or can we just get the best location based on what was entered?
    if (self.person.address.street1 && self.person.address.city && self.person.address.state) {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSDictionary *addressDictionary = @{(__bridge NSString *)kABPersonAddressStreetKey:self.person.address.street1 ? self.person.address.street1 : @"",
                                            (__bridge NSString *)kABPersonAddressCityKey:self.person.address.city ? self.person.address.city : @"",
                                            (__bridge NSString *)kABPersonAddressStateKey:self.person.address.state ? self.person.address.state : @"",
                                            (__bridge NSString *)kABPersonAddressZIPKey:self.person.address.zip ? self.person.address.zip : @""};
        
        [geocoder geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && placemarks.count) {
                CLLocationCoordinate2D coordinate = [[(CLPlacemark *)placemarks[0] location] coordinate];
                self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
                self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
                if (completionHandler) {
                    completionHandler(YES, self, nil);
                }
            }
            else {
                if (error) {
                    NSLog(@"Error geocoding address: %@", error.localizedDescription);
                }
                if (completionHandler) {
                    completionHandler(NO, self, error);
                }
            }
        }];
    }
    else {
        if (completionHandler) {
            completionHandler(NO, self, nil);
        }
    }
}

- (void)setAddressFromCoordinateWithCompletionHandler:(void (^)(BOOL success, Lead *lead, NSError *error))completionHandler {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *touchLocation = [[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]];
    
    [geocoder reverseGeocodeLocation:touchLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        // Update annotation with address
        self.person.address.state = [AVStateNames getAbbreviationForState:placemark.administrativeArea forCountry:[SRGlobalState singleton].countryCode];
        self.person.address.city = placemark.locality;
        NSString *placemarkAddress;
        //Accounts for the possibility of the number or street being null
        if (placemark.subThoroughfare && placemark.thoroughfare){
            placemarkAddress = [NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare, placemark.thoroughfare];
        }
        else if (placemark.thoroughfare){
            placemarkAddress = placemark.thoroughfare;
        }
        self.person.address.street1 = placemarkAddress;
        self.person.address.zip = placemark.postalCode;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressUpdatedNotification object:self.person.address];
        
            completionHandler(YES, self, nil);
        }
        else {
            completionHandler(NO, nil, error);
        }
    }];
}

#pragma mark - Proxy for JSON

- (id)proxyForJson {
    
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (self.leadId) {
        json[@"DashboardLeadID"] = [AVTextUtilities numberForString:self.leadId];
    }
    else { // Include date created on new lead insertions
        json[@"DateCreated"] = [NSNumber numberWithLongLong:[[NSNumber numberWithDouble:self.dateCreated.timeIntervalSince1970 * 1000] longLongValue]];
    }
    json[@"AppointmentDate"] = self.appointmentDate ? [self dateAsString:self.appointmentDate] : [NSNull null];
    json[@"AppointmentTime"] = self.appointmentTime ? [self timeAsString:self.appointmentTime] : [NSNull null];
    json[@"AppointmentWindow"] = self.appointmentWindow.length ? self.appointmentWindow : [NSNull null];
//    json[@"CalEventID"] = self.iosCalEventId.length ? self.iosCalEventId : [NSNull null];
    json[@"CurrentProvider"] = self.currentProvider.length ? self.currentProvider : [NSNull null];
    json[@"Latitude"] = self.latitude ? self.latitude : [NSNull null];
    json[@"Longitude"] = self.longitude ? self.longitude : [NSNull null];
    json[@"Notes"] = self.notes.length ? self.notes : [NSNull null];
    json[@"OutOfContractDate"] = self.outOfContractDate ? [self dateAsString:self.outOfContractDate] : [NSNull null];
    json[@"Rank"] = self.rank.length ? self.rank : [NSNull null];
    json[@"Status"] = self.status.length ? self.status : [NSNull null];
    json[@"Type"] = self.type.length ? self.type : [NSNull null];
    json[@"WindowSelected"] = self.windowSelected ? self.windowSelected : [NSNull null];
    json[@"Email"] = self.person.email.length ? self.person.email : [NSNull null];
    json[@"FirstName"] = self.person.firstName.length ? self.person.firstName : [NSNull null];
    json[@"LastName"] = self.person.lastName.length ? self.person.lastName : [NSNull null];
    json[@"PhonePrimary"] = self.person.phonePrimary.length ? [AVTextUtilities numberForString:self.person.phonePrimary] : [NSNull null];
    json[@"PhoneAlternate"] = self.person.phoneAlternate.length ? [AVTextUtilities numberForString:self.person.phoneAlternate] : [NSNull null];
    json[@"Street1"] = self.person.address.street1.length ? self.person.address.street1 : [NSNull null];
    json[@"Street2"] = self.person.address.street2.length ? self.person.address.street2 : [NSNull null];
    json[@"City"] = self.person.address.city.length ? self.person.address.city : [NSNull null];
    json[@"State"] = self.person.address.state.length ? self.person.address.state : [NSNull null];
    json[@"Zip"] = self.person.address.zip.length ? self.person.address.zip : [NSNull null];
    return json;
}

- (void)updateFromJson:(NSDictionary *)json withDateModified:(NSDate *)dateModified {
    
    [self setAppointmentDateValue:[self dateFromString:[self filterNSNull:json[@"AppointmentDate"]]]];
    [self setAppointmentTimeValue:[self timeFromString:[self filterNSNull:json[@"AppointmentTime"]]]];
    [self setAppointmentWindowValue:[self filterNSNull:json[@"AppointmentWindow"]]];
    [self setCurrentProviderValue:[self filterNSNull:json[@"CurrentProvider"]]];
//    [self setIosCalEventId:[self filterNSNull:json[@"CalEventID"]]];
//    if (self.iosCalEventId) {
//        self.calendarOn = @YES;
//    }
    [self setDateCreated:[self dateFromMillis:[self filterNSNull:json[@"DateCreated"]]]];
    [self setLatitudeValue:[self filterNSNull:json[@"Latitude"]]];
    [self setLongitudeValue:[self filterNSNull:json[@"Longitude"]]];
    [self setNotesValue:[self filterNSNull:json[@"Notes"]]];
    [self setOutOfContractDateValue:[self dateFromString:[self filterNSNull:json[@"OutOfContractDate"]]]];
    [self setRankValue:[self filterNSNull:json[@"Rank"]]];
    [self setStatusValue:[self filterNSNull:json[@"Status"]]];
    [self setTypeValue:[self filterNSNull:json[@"Type"]]];
    [self setWindowSelectedValue:[self filterNSNull:json[@"WindowSelected"]]];
    [self.person setFirstNameValue:[self filterNSNull:json[@"FirstName"]]];
    [self.person setLastNameValue:[self filterNSNull:json[@"LastName"]]];
    [self.person setPhonePrimaryValue:[AVTextUtilities formattedPhoneNumber:[self filterNSNull:json[@"PhonePrimary"]]]];
    [self.person setPhoneAlternateValue:[AVTextUtilities formattedPhoneNumber:[self filterNSNull:json[@"PhoneAlternate"]]]];
    [self.person setEmailValue:[self filterNSNull:json[@"Email"]]];
    [self.person.address setStreet1Value:[self filterNSNull:json[@"Street1"]]];
    [self.person.address setStreet2Value:[self filterNSNull:json[@"Street2"]]];
    [self.person.address setCityValue:[self filterNSNull:json[@"City"]]];
    [self.person.address setStateValue:[self filterNSNull:json[@"State"]]];
    [self.person.address setZipValue:[self filterNSNull:json[@"Zip"]]];
    
    self.dateModified = dateModified;
}

- (id)filterNSNull:(id)json {
    
    if ([json isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return json;
}

- (NSString *)dateAsString:(NSDate *)date {
    
    if (date == nil) {
        return @"null";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:string];
}

- (NSDate *)dateFromMillis:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:([string doubleValue] / 1000)];
}

- (NSString *)timeAsString:(NSDate *)date {
    
    if (date == nil) {
        return @"null";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)timeFromString:(NSString *)string {
    
    if ([string isKindOfClass:[NSNull class]]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    return [dateFormatter dateFromString:string];
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
    if (self.person.firstName.length > 0 || self.person.lastName.length > 0) {
        if (self.person.firstName.length > 0) {
            NSString *tmp = self.person.firstName;
            if (self.person.lastName.length >0) {
                return [NSString stringWithFormat:@"%@ %@", tmp, self.person.lastName];
            }
            else{
                return tmp;
            }
        }
        else{
            return self.person.lastName;
        }
    }
    else{
        return self.status;
    }
}

- (NSString *)subtitle
{
    NSString *tmp = @"";
    if (self.person.address.state.length > 0) {
        tmp = self.person.address.state;
    }
    if (self.person.address.city.length > 0){
        tmp = [NSString stringWithFormat:@"%@, %@", self.person.address.city, tmp];
    }
    if (self.person.address.street1.length > 0) {
        tmp = [NSString stringWithFormat:@"%@, %@", self.person.address.street1, tmp];
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

#pragma mark - Reminders (Local Notifications)

- (void)scheduleNotification {
    
    UILocalNotification *existingNotification = nil;
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[notification.userInfo objectForKey:kLeadId] isEqualToString:self.leadId]) {
            existingNotification = notification;
            break;
        }
    }
    
    if (existingNotification != nil) {
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    if (![self.windowSelected boolValue] && self.appointmentTime) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
        NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.appointmentTime];
        
        [dayComps setHour:timeComps.hour];
        [dayComps setMinute:timeComps.minute];
        [dayComps setSecond:timeComps.second];
        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSDate *fireDate = [gregorianCalendar dateFromComponents:dayComps];
        fireDate = [fireDate dateByAddingTimeInterval:-[self secondsToPrescheduleNotification]];
        localNotification.fireDate = fireDate;
    }
    else if ([self.windowSelected boolValue] && self.appointmentWindow){
        localNotification.fireDate = [self dateForReminderWithWindow];
    }
    else if (self.appointmentDate) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
        dayComps.hour = 12;
        dayComps.minute = 0;
        dayComps.second = 0;
        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
        NSDate *fireDate = [gregorianCalendar dateFromComponents:dayComps];
        fireDate = [fireDate dateByAddingTimeInterval:-[self secondsToPrescheduleNotification]];
        localNotification.fireDate = fireDate;
    }
    
    localNotification.timeZone = [NSTimeZone systemTimeZone];
    
    //Compose alert body
    NSString *alertBodyString = @"You have an appointment";
    if (![self.windowSelected boolValue] && self.appointmentTime) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"h:mm";
        alertBodyString = [alertBodyString stringByAppendingFormat:@" at %@", [dateFormatter stringFromDate:self.appointmentTime]];
    }
    else if ([self.windowSelected boolValue] && self.appointmentWindow) {
        alertBodyString = [alertBodyString stringByAppendingFormat:@" at %@", self.appointmentWindow];
    }
    if (self.person.firstName || self.person.lastName) {
        alertBodyString = [alertBodyString stringByAppendingFormat:@" with"];
        if (self.person.firstName) {
            alertBodyString = [alertBodyString stringByAppendingFormat:@" %@", self.person.firstName];
        }
        if (self.person.lastName) {
            alertBodyString = [alertBodyString stringByAppendingFormat:@" %@", self.person.lastName];
        }
    }
    alertBodyString = [alertBodyString stringByAppendingString:@"."];
    
    localNotification.alertBody = alertBodyString;
    localNotification.alertAction =@"OK";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    if (self.leadId) {
        localNotification.userInfo = @{kLeadId: self.leadId};
    }
    else {
        localNotification.userInfo = @{kLeadId: @"New Lead"};
    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (BOOL)notificationDateIsInFuture {
    NSDate *leadDate;
    
    if (![self.windowSelected boolValue] && self.appointmentTime && self.appointmentDate) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
        NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.appointmentTime];
        
        [dayComps setHour:timeComps.hour];
        [dayComps setMinute:timeComps.minute];
        [dayComps setSecond:timeComps.second];
        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
        
        leadDate = [gregorianCalendar dateFromComponents:dayComps];
    }
    else if ([self.windowSelected boolValue] && self.appointmentWindow) {
        leadDate = [self dateForReminderWithWindow];
    }
    else if (self.appointmentDate) {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
        dayComps.hour = 12;
        dayComps.minute = 0;
        dayComps.second = 0;
        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
        leadDate = [gregorianCalendar dateFromComponents:dayComps];
    }
    leadDate = [leadDate dateByAddingTimeInterval:-[self secondsToPrescheduleNotification]];
    
    if (!leadDate) {
        return NO;
    }
    if ([leadDate timeIntervalSinceNow] < 0) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldSetReminder {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (([self.windowSelected boolValue] && self.appointmentWindow && self.appointmentDate) ||
        (![self.windowSelected boolValue] && self.appointmentTime && self.appointmentDate)
        || self.appointmentDate) {
        if ([self notificationDateIsInFuture]) {
            if ([userDefaults objectForKey:kUserSettings]) {
                NSDictionary *userSettingsDictionary = [[userDefaults objectForKey:kUserSettings] objectForKey:[[SRGlobalState singleton] userId]];
                return ![[userSettingsDictionary objectForKey:kTimeToRemind] isEqualToString:kRemindNone];
            }
            else {
                //By default reminders are enabled
                return YES;
            }
        }
        else {
            return NO;
        }
    } 
    
    return NO;
}

- (NSDate *)dateForReminderWithWindow {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
    
    [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
    
    if (self.appointmentWindow == kAnytime) {
        dayComps.hour = 12;
        dayComps.minute = 0;
        dayComps.second = 0;
        return [gregorianCalendar dateFromComponents:dayComps];
    }
    else if (self.appointmentWindow == kWindow8toNoon) {
        dayComps.hour = 8;
        dayComps.minute = 0;
        dayComps.second = 0;
        return [gregorianCalendar dateFromComponents:dayComps];
    }
    else if (self.appointmentWindow == kWindowNoonto5) {
        dayComps.hour = 12;
        dayComps.minute = 0;
        dayComps.second = 0;
        return [gregorianCalendar dateFromComponents:dayComps];
    }
    else if (self.appointmentWindow == kWindowAfter5) {
        dayComps.hour = 17;
        dayComps.minute = 0;
        dayComps.second = 0;
        return [gregorianCalendar dateFromComponents:dayComps];
    }
    
    //Default to noon
    dayComps.hour = 12;
    dayComps.minute = 0;
    dayComps.second = 0;
    return [gregorianCalendar dateFromComponents:dayComps];
    return nil;
}

//Returns the number of seconds before an appointment to show the notification.  Returns -1 if reminders are disabled.
- (NSInteger)secondsToPrescheduleNotification {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kUserSettings]) {
        NSDictionary *userSettingsDictionary = [[userDefaults objectForKey:kUserSettings] objectForKey:[[SRGlobalState singleton] userId]];
        NSString *remindertime = [userSettingsDictionary objectForKey:kTimeToRemind];
        if ([remindertime isEqualToString:kRemind0Min]) {
            return 0;
        }
        else if ([remindertime isEqualToString:kRemind5Min]) {
            return kSecondsIn5Minutes;
        }
        else if ([remindertime isEqualToString:kRemind15Min]) {
            return kSecondsIn15Minutes;
        }
        else if ([remindertime isEqualToString:kRemind30Min]) {
            return kSecondsIn30Minutes;
        }
        else if ([remindertime isEqualToString:kRemind1Hr]) {
            return kSecondsIn1Hour;
        }
    }
    //By default return 5 minutes;
    return kSecondsIn5Minutes;
}

#pragma mark - Calendar Events
//
//- (void)setCalendarEvent {
//    static BOOL settingCalEvent;
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    
//    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        
//        if (granted && !settingCalEvent){
//            settingCalEvent = YES;
//            EKEventStore *eventStore = [[EKEventStore alloc] init];
//            EKEvent *event = [eventStore eventWithIdentifier:self.iosCalEventId];
//            
//            //Create new event if event doesn't already exist
//            if (event == nil) {
//                event = [EKEvent eventWithEventStore:eventStore];
//            }
//            
//            event.title = [NSString stringWithFormat:@"%@ - Sales Rabbit", self.title];
//            
//            NSMutableString *notes = [NSMutableString stringWithString:@""];
//            if (self.status) {
//                [notes appendFormat:@"Status - %@\n", self.status];
//            }
//            if (self.rank) {
//                [notes appendFormat:@"Rank - %@\n", self.rank];
//            }
//            if (self.type) {
//                [notes appendFormat:@"Type - %@\n", self.type];
//            }
//            if (self.notes) {
//                [notes appendFormat:@"Notes - %@", self.notes];
//            }
//            event.notes = notes;
//            
//            
//            event.location = [NSString stringWithFormat:@"%@%@%@ %@ %@",
//                               self.person.address.street1 ?: @"",
//                               self.person.address.street1 ? @"\n" : @"",
//                               self.person.address.city ?: @"",
//                               self.person.address.state ?: @"",
//                               self.person.address.zip ?: @""];
//            
//            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
//            if (self.appointmentTime) {
//                NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.appointmentTime];
//                
//                [dayComps setHour:timeComps.hour];
//                [dayComps setMinute:timeComps.minute];
//                [dayComps setSecond:timeComps.second];
//            }
//            [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
//    
//            if (![self.windowSelected boolValue] && self.appointmentTime && self.appointmentDate) {
//                event.allDay = NO;
//                event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                event.endDate = [event.startDate dateByAddingTimeInterval:kCalendarEventLengthInSeconds];
//            }
//            else if ([self.windowSelected boolValue] && self.appointmentWindow) {
//                event.allDay = NO;
//                if (self.appointmentWindow == kAnytime) {
//                    event.allDay = YES;
//                    event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                    event.endDate = event.startDate;
//                }
//                else if (self.appointmentWindow == kWindow8toNoon) {
//                    dayComps.hour = 8;
//                    dayComps.minute = 0;
//                    dayComps.second = 0;
//                    event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                    event.endDate = [event.startDate dateByAddingTimeInterval:(60 * 60 * 4)];
//                }
//                else if (self.appointmentWindow == kWindowNoonto5) {
//                    dayComps.hour = 12;
//                    dayComps.minute = 0;
//                    dayComps.second = 0;
//                    event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                    event.endDate = [event.startDate dateByAddingTimeInterval:(60 * 60 * 5)];
//                }
//                else if (self.appointmentWindow == kWindowAfter5) {
//                    dayComps.hour = 17;
//                    dayComps.minute = 0;
//                    dayComps.second = 0;
//                    event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                    event.endDate = [event.startDate dateByAddingTimeInterval:(60 * 60 * 5)];
//                }
//            }
//            else if (self.appointmentDate) {
//                event.allDay = YES;
//                event.startDate = [gregorianCalendar dateFromComponents:dayComps];
//                event.endDate = event.startDate;
//            }
//            
//            event.availability = EKEventAvailabilityFree;
//            
//            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//            NSError *err;
//            [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
//            self.iosCalEventId = event.eventIdentifier;
//            settingCalEvent = NO;
//        }
//    }];
//}
//
//- (BOOL)calendarDateIsInFuture {
//    NSDate *leadDate;
//    
//    if (![self.windowSelected boolValue] && self.appointmentTime && self.appointmentDate) {
//        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
//        NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.appointmentTime];
//        
//        [dayComps setHour:timeComps.hour];
//        [dayComps setMinute:timeComps.minute];
//        [dayComps setSecond:timeComps.second];
//        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
//        
//        leadDate = [gregorianCalendar dateFromComponents:dayComps];
//    }
//    else if ([self.windowSelected boolValue] && self.appointmentWindow) {
//        leadDate = [self dateForReminderWithWindow];
//    }
//    else if (self.appointmentDate) {
//        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.appointmentDate];
//        dayComps.hour = 23;
//        dayComps.minute = 59;
//        dayComps.second = 59;
//        [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
//        leadDate = [gregorianCalendar dateFromComponents:dayComps];
//    }
//    leadDate = [leadDate dateByAddingTimeInterval:-[self secondsToPrescheduleNotification]];
//    
//    if (!leadDate) {
//        return NO;
//    }
//    if ([leadDate timeIntervalSinceNow] < 0) {
//        return NO;
//    }
//    return YES;
//}
//
//- (BOOL)shouldSetCalendarEvent {
//    if (self.iosCalEventId || self.calendarOn.boolValue) {
//        if (([self.windowSelected boolValue] && self.appointmentWindow && self.appointmentDate) ||
//            (![self.windowSelected boolValue] && self.appointmentTime && self.appointmentDate) ||
//            self.appointmentDate) {
//            
//            if ([self calendarDateIsInFuture]) {
//                return [self.calendarOn boolValue];
//            }
//            else {
//                return NO;
//            }
//        }
//        else {
//            return NO;
//        }
//    }
//    return NO;
//}
//
//- (void)removeCalendarEvent {
//    EKEventStore *eventStore = [[EKEventStore alloc] init];
//    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        
//        if (granted){
//            EKEventStore *eventStore = [[EKEventStore alloc] init];
//            EKEvent *event = [eventStore eventWithIdentifier:self.iosCalEventId];
//            
//            if (event != nil) {
//                [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
//            }
//        }
//    }];
//}
//
//- (void)setCalendarEventIfNecessary {
//    if ([self shouldSetCalendarEvent]) {
//        [self setCalendarEvent];
//    }
//}

#pragma mark - Custom Setters

- (void)setAppointmentDate:(NSDate *)appointmentDate {
    
    [self setAppointmentDateValue:appointmentDate];
    self.dateModified = [NSDate date];
//    if ([self shouldSetCalendarEvent]) {
//        [self setCalendarEvent];
//    }
}

- (void)setAppointmentDateValue:(NSDate *)appointmentDate {
    
    [self willChangeValueForKey:@"appointmentDate"];
    [self setPrimitiveAppointmentDate:appointmentDate];
    [self didChangeValueForKey:@"appointmentDate"];
    if ([self shouldSetReminder]) {
        [self scheduleNotification];
    }
}

- (void)setAppointmentTime:(NSDate *)appointmentTime {
    
    [self setAppointmentTimeValue:appointmentTime];
    self.dateModified = [NSDate date];
//    if ([self shouldSetCalendarEvent]) {
//        [self setCalendarEvent];
//    }
}

- (void)setAppointmentTimeValue:(NSDate *)appointmentTime {
    
    [self willChangeValueForKey:@"appointmentTime"];
    [self setPrimitiveAppointmentTime:appointmentTime];
    [self didChangeValueForKey:@"appointmentTime"];
    if ([self shouldSetReminder]) {
        [self scheduleNotification];
    }
}

- (void)setAppointmentWindow:(NSString *)appointmentWindow {
    
    [self setAppointmentWindowValue:appointmentWindow];
    self.dateModified = [NSDate date];
//    if ([self shouldSetCalendarEvent]) {
//        [self setCalendarEvent];
//    }
}

- (void)setAppointmentWindowValue:(NSString *)appointmentWindow {
    
    [self willChangeValueForKey:@"appointmentWindow"];
    [self setPrimitiveAppointmentWindow:appointmentWindow];
    [self didChangeValueForKey:@"appointmentWindow"];
    if ([self shouldSetReminder]) {
        [self scheduleNotification];
    }
}

- (void)setCurrentProvider:(NSString *)currentProvider {
    
    [self setCurrentProviderValue:currentProvider];
    self.dateModified = [NSDate date];
}

- (void)setCurrentProviderValue:(NSString *)currentProvider {
    
    [self willChangeValueForKey:@"currentProvider"];
    [self setPrimitiveCurrentProvider:currentProvider];
    [self didChangeValueForKey:@"currentProvider"];
}

- (void)setLatitude:(NSNumber *)latitude {
    
    [self setLatitudeValue:latitude];
    self.dateModified = [NSDate date];
}

- (void)setLatitudeValue:(NSNumber *)latitude {
    
    [self willChangeValueForKey:@"latitude"];
    [self setPrimitiveLatitude:latitude];
    [self didChangeValueForKey:@"latitude"];
}

- (void)setLongitude:(NSNumber *)longitude {
    
    [self setLongitudeValue:longitude];
    self.dateModified = [NSDate date];
}

- (void)setLongitudeValue:(NSNumber *)longitude {
    
    [self willChangeValueForKey:@"longitude"];
    [self setPrimitiveLongitude:longitude];
    [self didChangeValueForKey:@"longitude"];
}

- (void)setNotes:(NSString *)notes {
    
    [self setNotesValue:notes];
    self.dateModified = [NSDate date];
//    [self setCalendarEventIfNecessary];
}

- (void)setNotesValue:(NSString *)notes {
    
    [self willChangeValueForKey:@"notes"];
    [self setPrimitiveNotes:notes];
    [self didChangeValueForKey:@"notes"];
}

- (void)setOutOfContractDate:(NSDate *)outOfContractDate {
    
    [self setOutOfContractDateValue:outOfContractDate];
    self.dateModified = [NSDate date];
}

- (void)setOutOfContractDateValue:(NSDate *)outOfContractDate {
    
    [self willChangeValueForKey:@"outOfContractDate"];
    [self setPrimitiveOutOfContractDate:outOfContractDate];
    [self didChangeValueForKey:@"outOfContractDate"];
}

- (void)setRank:(NSString *)rank {
    
    [self setRankValue:rank];
    self.dateModified = [NSDate date];
//    [self setCalendarEventIfNecessary];
}

- (void)setRankValue:(NSString *)rank {
    
    [self willChangeValueForKey:@"rank"];
    [self setPrimitiveRank:rank];
    [self didChangeValueForKey:@"rank"];
}

- (void)setStatus:(NSString *)status {
    
    [self setStatusValue:status];
    self.dateModified = [NSDate date];
    
//    [self setCalendarEventIfNecessary];
    
    //post notification for title change
    if (!self.person.lastName.length && !self.person.firstName.length) {
        NSArray *editedLeads = [NSArray arrayWithObject:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTitleAttributesChangedNotification object:@{kUpdatedLeads: editedLeads}];
    }
}

- (void)setStatusValue:(NSString *)status {
    
    if ([self.status isEqualToString:kCustomer] && ![status isEqualToString:kCustomer]) {
        NSLog(@"ERROR: Attempt to change lead status from customer to %@", status);
        NSAssert(NO, @"Customer lead statuses are not allowed to be changed!");
        return;
    }
    [self willChangeValueForKey:@"status"];
    [self setPrimitiveStatus:status];
    [self didChangeValueForKey:@"status"];
    if (status != nil) {
        self.saved = @YES;
    }
}

- (void)setType:(NSString *)type {
    
    [self setTypeValue:type];
    self.dateModified = [NSDate date];
    
//    [self setCalendarEventIfNecessary];
}

- (void)setTypeValue:(NSString *)type {
    
    [self willChangeValueForKey:@"type"];
    [self setPrimitiveType:type];
    [self didChangeValueForKey:@"type"];
}

- (void)setWindowSelected:(NSNumber *)windowSelected {
    
    [self setWindowSelectedValue:windowSelected];
    self.dateModified = [NSDate date];
//    if ([self shouldSetCalendarEvent]) {
//        [self setCalendarEvent];
//    }
}

- (void)setWindowSelectedValue:(NSNumber *)windowSelected {
    
    [self willChangeValueForKey:@"windowSelected"];
    [self setPrimitiveWindowSelected:windowSelected];
    [self didChangeValueForKey:@"windowSelected"];
    if ([self shouldSetReminder]) {
        [self scheduleNotification];
    }
}

@end
