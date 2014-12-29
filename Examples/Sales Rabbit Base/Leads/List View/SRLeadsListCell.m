//
//  SRLeadsListCell.m
//  Dish Sales
//
//  Created by Brady Anderson on 2/12/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRLeadsListCell.h"
#import "Address+Rabbit.h"
#import "Lead+Rabbit.h"
#import "Constants.h"
#import "AVTextUtilities.h"

#define CancelButtonIndex 0
#define CallButtonIndex 1
#define DirectionsButtonIndex 2

@implementation SRLeadsListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action button methods (Call/Directions)

- (IBAction)actionButtonPressed:(UIButton *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [self leadHasAddress]) {
        [self getTurnByTurn];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([self leadHasAddress] && [self leadHasPhone]) {
            UIAlertView *directionsCallAlert = [[UIAlertView alloc] initWithTitle:@"Directions or Call"
                                                                          message:@"Would you like to get directions or call this lead?"
                                                                         delegate:self
                                                                cancelButtonTitle:@"Cancel"
                                                                otherButtonTitles:@"Call", @"Directions", nil];
            [directionsCallAlert show];
        }
        else if ([self leadHasPhone]) {
            UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:@"Call Lead"
                                                                message:@"Would you like to call this lead?"
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Call", nil];
            [callAlert show];
        }
        else if ([self leadHasAddress]) {
            [self getTurnByTurn];
        }
    }
}

- (BOOL) leadHasAddress {
    return self.lead.person.address.street1 != nil && self.lead.person.address.street1.length &&
    self.lead.person.address.city != nil && self.lead.person.address.city.length
    && self.lead.person.address.state != nil && self.lead.person.address.state.length
    && self.lead.person.address.zip != nil && self.lead.person.address.zip.length;
}

- (BOOL) leadHasPhone {
    return self.lead.person.phonePrimary != nil && [AVTextUtilities isValidPhoneNumber:self.lead.person.phonePrimary];
}

- (void) getTurnByTurn {
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSDictionary *addressDictionary = @{(__bridge NSString *)kABPersonAddressStreetKey:self.lead.person.address.street1, (__bridge NSString *)kABPersonAddressCityKey:self.lead.person.address.city, (__bridge NSString *)kABPersonAddressStateKey:self.lead.person.address.state, (__bridge NSString *)kABPersonAddressZIPKey:self.lead.person.address.zip};
        [geocoder geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                /*NSLog(@"%d potential geolocation matches", [placemarks count]);
                 for (CLPlacemark *pm in placemarks) {
                 NSLog(@"%@", pm);
                 }*/
                // TODO: Error checking on geocoded address? Apple Maps isn't always accurate
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:[placemarks objectAtIndex:0]];
                MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                mapItem.name = [NSString stringWithFormat:@"%@ %@", [self.lead.person.firstName capitalizedString], [self.lead.person.lastName capitalizedString]];
                mapItem.phoneNumber = [self checkForNSNull:self.lead.person.phonePrimary];
                NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey:[NSNumber numberWithUnsignedInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES};
                if (![mapItem openInMapsWithLaunchOptions:launchOptions]) {
                    NSLog(@"Error opening MKMapItem");
                    UIAlertView *mapAlert = [[UIAlertView alloc] initWithTitle:kOpeningAddressErrorTitle message:kOpeningAddressErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
                    [mapAlert show];
                }
            }
            else {
                NSLog(@"Geocoding error: %@", [error localizedDescription]);
                UIAlertView *geocodeAlert = [[UIAlertView alloc] initWithTitle:kLocatingAddressErrorTitle message:kLocatingAddressErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
                [geocodeAlert show];
            }
        }];
    }
}

- (id)checkForNSNull:(id)object {
    
    if ([object class] == [NSNull class]) {
        return nil;
    }
    return object;
}

#pragma mark - Cell Setup Methods

- (void)setupCellWithLead:(Lead *)lead andLocation:(CLLocation *) location {
    
    self.lead = lead;
    
    [self setupName];
    [self setupRank];
    [self setupAppointmentTime];
    [self setupStatus];
    [self setupDistanceWithLocation:location];
    
    if (![self.lead.status isEqualToString:kCustomer]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setupName {
    NSString *name = @"";
    if (self.lead.person.firstName.length > 0) {
        name = self.lead.person.firstName;
        if (self.lead.person.lastName.length > 0) {
            name = [name stringByAppendingFormat:@" %@", self.lead.person.lastName];
        }
    }
    else{
        name = self.lead.person.lastName;
    }
    self.nameLabel.text = name;
}

- (void)setupRank {
    
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.rankLabel.text = self.lead.rank;
    }
    else {*/
        self.rankLabel.text = [self.lead.rank substringToIndex:1];
    //}
}

- (void)setupAppointmentTime {
    
    // Setup date and time formatters
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *separator;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [dateFormatter setDateFormat:@"M/d/yyyy"];
        separator = @"  ";
    }
    else {
        [dateFormatter setDateFormat:@"M/d/yy"];
        separator = @"\n";
    }
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSString *appointmentString = [dateFormatter stringFromDate:self.lead.appointmentDate];
    if ([self.lead.windowSelected boolValue]) {
        if (self.lead.appointmentWindow) {
            appointmentString = [appointmentString stringByAppendingFormat:@"%@%@", separator, self.lead.appointmentWindow];
        }
    }
    else{
        if (self.lead.appointmentTime) {
            appointmentString = [appointmentString stringByAppendingFormat:@"%@%@", separator, [timeFormatter stringFromDate:self.lead.appointmentTime]];
        }
    }
    self.appointmentLabel.text = appointmentString;
}

- (void)setupStatus {
    
    UIImage *actionImage;
    if ([self.lead.status isEqualToString:kGoBack]) {
        actionImage = [UIImage imageNamed:@"button_location_green"];
    }
    else if ([self.lead.status isEqualToString:kCallback]){
        actionImage = [UIImage imageNamed:@"button_location_yellow"];
    }
    else if ([self.lead.status isEqualToString:kNotHome]){
        actionImage = [UIImage imageNamed:@"button_location_orange"];
    }
    else if ([self.lead.status isEqualToString:kNotInterested]){
        actionImage = [UIImage imageNamed:@"button_location_red"];
    }
    else if ([self.lead.status isEqualToString:kOther]){
        actionImage = [UIImage imageNamed:@"button_location_purple"];
    }
    else if ([self.lead.status isEqualToString:kCustomer]){
        actionImage = [UIImage imageNamed:@"button_location_blue"];
    }
    [self.actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
}

- (void)setupDistanceWithLocation:(CLLocation *)location {
    
    self.bestEffortAtLocation = location;
    if (self.lead.latitude && self.lead.longitude) {
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:[self.lead.latitude doubleValue] longitude:[self.lead.longitude doubleValue]];
        
        // Set distance
        CLLocationDistance distanceInMeters = [self.bestEffortAtLocation distanceFromLocation:currentLocation];
        double distanceInMiles = distanceInMeters/1609.34;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSString *distanceString = [NSString stringWithFormat: @"%.1f mi", distanceInMiles];
            self.distanceLabel.text = distanceString;
        }
        else {
            if (distanceInMiles < 100.0) {
                NSString *distanceString = [NSString stringWithFormat: @"%.1f mi", distanceInMiles];
                self.distanceLabel.text = distanceString;
            }
            else {
                NSString *distanceString = [NSString stringWithFormat: @"%.1f", distanceInMiles];
                self.distanceLabel.text = distanceString;
                
            }
        }
    }
    else {
        self.distanceLabel.text = @"";
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == CallButtonIndex) {
        NSString *phoneNumber = self.lead.person.phonePrimary;
        NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
    else if (buttonIndex == DirectionsButtonIndex) {
        [self getTurnByTurn];
    }
}

#pragma mark - Orientation

// Adjust stationaryContainerView to width of table
- (void)stretchToWidth:(CGFloat)width {
    
    CGRect frame = self.stationaryContainerView.frame;
    frame.size.width = width;
    self.stationaryContainerView.frame = frame;
}

@end
