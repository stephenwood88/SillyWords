//
//  SRSalesHomeViewController.m
//  Original Sales
//
//  Created by Matthew McArthur on 11/25/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSalesHomeViewController.h"
#import "SRMapViewController.h"
#import "SRMaterialsState.h"
#import "SRParentLeadViewController.h"
#import "Constants.h"
#import "SRConstants.h"
#import "Address.h"
#import "Lead.h"
#import "Person.h"

@interface SRSalesHomeViewController()

@property (nonatomic, strong) NSArray *materialsDownloadList;

@end

@implementation SRSalesHomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //----------Check for Sales Materials Updates---------------------
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.salesMaterialTimestamp = [NSDate dateWithTimeIntervalSince1970:[[SRGlobalState singleton] salesMaterialsUpdatedDate]];
    NSDictionary *updateDictionary = [defaults objectForKey:kSalesMaterialsTimestampDictionary];
    NSDate *lastSalesMaterialUpdate = [updateDictionary objectForKey:[[SRGlobalState singleton] systemAccountId]];
    
    //if the timestamp is updated check for new materials and delete any that need deletion
    if (lastSalesMaterialUpdate == nil || [lastSalesMaterialUpdate compare:self.salesMaterialTimestamp] == NSOrderedAscending) {
        [[SRMaterialsState singleton] initializeSalesMaterialsArrays];
        [[SRMaterialsState singleton] checkSalesMaterialsForDownloads:YES];
        [[SRMaterialsState singleton] setDelegate:self];
    }
    
    [self cleanupLeadsWithMissingLocationInformation];
    // TODO: Disable when offline, listen for notification to enable/disable?
    //self.reportsButton.enabled = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    //Check for notification
    NSString *leadId = [[SRGlobalState singleton] leadIdFromNotification];
    if (leadId) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:kLeadsTab];
    }
}

- (void)setupFrames{
    // Collect the frame positions for elements in portrait mode
    NSMutableDictionary *portraitPositions = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 1; i <= 6; i++) {
        UIView *view = [self.view viewWithTag:i];
        
        [portraitPositions setObject:[NSValue valueWithCGRect:view.frame] forKey:[NSNumber numberWithInteger:i]];
    }
    self.portraitFrames = [portraitPositions copy];
    
    // Let's build the landscape frame positions dictionary
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        //Set up frames for variables in iPad version
        self.landscapeFrames = [NSDictionary dictionaryWithObjectsAndKeys:
                                TAG_RECT(1, 348, 121, 329, 120),
                                TAG_RECT(2, 216, 290, 159, 159),
                                TAG_RECT(3, 649, 290, 159, 159),
                                TAG_RECT(4, 216, 506, 159, 159),
                                TAG_RECT(5, 649, 506, 159, 159),
                                nil];
    }
}

#pragma mark - IBActions

- (IBAction)leadsButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:kLeadsTab];
}

- (IBAction)toolsButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:kToolsTab];
}

- (IBAction)reportsButtonPressed:(UIButton *)sender {
    NSLog(@"Tab Bar VC's: %@", self.tabBarController.viewControllers);
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:kReportsTab];
}

- (IBAction)agreementButtonPressed:(UIButton *)sender {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:kAgreementsTab];
}
- (IBAction)dashboardButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://dashboard.mysalesrabbit.com/"];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - SettingsDelegate

- (void)logout
{
    [[SRMaterialsState singleton] setTabBarViewController:nil];
    [super logout];
}

#pragma mark - Sales Materials update

//if there are materials to be downloaded ask the user if they want to download
- (void) salesMaterialsDownloadList:(NSArray *)downloadList {
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:@"Sales Materials Update"
                                                          message:@"Would you like to update your Sales Materials now? (It is highly recommended that you do this over a wifi connection.)"
                                                         delegate:self
                                                cancelButtonTitle:@"Later"
                                                otherButtonTitles:@"Update", nil];
    [updateAlert show];
    self.materialsDownloadList = downloadList;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[SRMaterialsState singleton] startBackgroundDownload:self.materialsDownloadList withNumOfFIles:(int)[self.materialsDownloadList count]];
    }
    self.materialsDownloadList = nil;
}

#pragma mark - Lead Location Cleanup

/**
 This method set cleans up leads that fall into the cases mentioned below by geocoding and reverse geocoding in order to fill in the missing location information.
 
 ##Discussion
 Sometimes a user adds leads when they don't have an internet connection so the lead will have a geocode (latitude/longitude), but the lead's associated person will have no address (assuming the user doesn't manually enter an address).  It may also be the case that a new lead is created and an address entered, also without an internet connection, so that the lead's associated person has an address but the lead has no geocode. (In this case the lead will not show on the map.) Leads without any location information are left alone.
 
 ##Threading Considerations
 Fetching in this method is is done from the parent context in the background. The object id of the objects fetched is then used to reference the corresponding objects in the child context which are then modified.
 */
- (void)cleanupLeadsWithMissingLocationInformation
{
    NSManagedObjectContext *backgroundContext = [[[SRGlobalState singleton] managedObjectContext] parentContext];
    
    [self cleanupLeadsWithMissingGeocodesInContext:backgroundContext];
    [self cleanupPeopleWithMissingAddressesInContext:backgroundContext];
}

- (void)cleanupLeadsWithMissingGeocodesInContext:(NSManagedObjectContext *)backgroundContext
{
    [backgroundContext performBlock:^
     {//NSAssert(dispatch_get_current_queue() != dispatch_get_main_queue(), @"Error, should be background queue!");
         
         NSFetchRequest *backgroundFetch = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
         
         backgroundFetch.predicate = [NSPredicate predicateWithFormat:@"((latitude == nil) OR (longitude == nil)) AND (person.address.street1 != nil) AND ((person.address.city != nil) OR (person.address.zip != nil))"];
         NSError *backgroundError = nil;
         
         NSArray *backgroundObjects = [backgroundContext executeFetchRequest:backgroundFetch error:&backgroundError];
         
         if (backgroundError) {
             NSLog(@"Error fetching Leads in cleanupLeadsWithMissingGeocodesInContext: %@", backgroundError.localizedDescription);
         }
         else {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                            NSManagedObjectContext *mainContext = [[SRGlobalState singleton] managedObjectContext];
                            NSMutableArray *mainLeads = [NSMutableArray arrayWithCapacity:backgroundObjects.count];
                            //NSLog(@"Get all objects by ID...");
                            // Get objects from main context by ID
                            for (Lead *backgroundLead in backgroundObjects) {
                                Lead *mainLead = (Lead *)[mainContext objectWithID:backgroundLead.objectID];
                                [mainLeads addObject:mainLead];
                            }
                            
                            //NSLog(@"%lu leads found with missing geocode.", (unsigned long)[mainLeads count]);
                            for (Lead* lead in mainLeads)
                                {
                                
                                NSString *addressString = [self getAddressStringForAddress: lead.person.address];
                                
                                //NSLog(@"Attempting to geocode address: %@", addressString);
                                
                                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                [geocoder geocodeAddressString: addressString completionHandler:^(NSArray *placemarks, NSError *error)
                                 {
                                 CLPlacemark *placemark = [placemarks firstObject];
                                 lead.latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
                                 lead.longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
                                 
                                 }];
                                }
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTitleAttributesChangedNotification object:@{kUpdatedLeads: mainLeads}];
                            
                            });
         }
     }];
}

- (NSString *) getAddressStringForAddress:(Address *)address
{
    NSString *addressString;
    
    if (address.city != nil && address.zip != nil)
        {
        addressString = [[NSString alloc] initWithFormat:@"%@ %@, %@, %@", address.street1, address.street2, address.city, address.zip];
        }
    else if (address.city != nil)
        {
        addressString = [[NSString alloc] initWithFormat:@"%@ %@, %@", address.street1, address.street2, address.city];
        }
    else if (address.zip != nil)
        {
        addressString = [[NSString alloc] initWithFormat:@"%@ %@, %@", address.street1, address.street2, address.zip];
        }
    
    return addressString;
}


- (void)cleanupPeopleWithMissingAddressesInContext:(NSManagedObjectContext *)backgroundContext
{
    [backgroundContext performBlock:^
     {//NSAssert(dispatch_get_current_queue() != dispatch_get_main_queue(), @"Error, should be background queue!");
         
         NSFetchRequest *backgroundFetch = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
         
         backgroundFetch.predicate = [NSPredicate predicateWithFormat:@"((latitude != nil) AND (longitude != nil)) AND ((person.address.street1 == nil) OR (person.address.city == nil) OR (person.address.zip == nil))"];
         NSError *backgroundError = nil;
         
         NSArray *backgroundObjects = [backgroundContext executeFetchRequest:backgroundFetch error:&backgroundError];
         
         if (backgroundError) {
             NSLog(@"Error fetching Leads in cleanupLeadsWithMissingGeocodesInContext: %@", backgroundError.localizedDescription);
         }
         else {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                            NSManagedObjectContext *mainContext = [[SRGlobalState singleton] managedObjectContext];
                            NSMutableArray *mainLeads = [NSMutableArray arrayWithCapacity:backgroundObjects.count];
                            //NSLog(@"Get all objects by ID...");
                            // Get objects from main context by ID
                            for (Lead *backgroundLead in backgroundObjects) {
                                Lead *mainLead = (Lead *)[mainContext objectWithID:backgroundLead.objectID];
                                [mainLeads addObject:mainLead];
                            }
                            
                           
                            
                            //NSLog(@"%lu leads found with missing address.", (unsigned long)[mainLeads count]);
                            for (Lead* lead in mainLeads)
                                {
                                CLLocation *location = [[CLLocation alloc] initWithLatitude:[lead.latitude doubleValue] longitude:[lead.longitude doubleValue]];
                                
                               // NSLog(@"Attempting to reverse geocode geocode: %@, %@", lead.latitude, lead.longitude);
                                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
                                 {
                                 CLPlacemark *placemark = [placemarks firstObject];
                                 Address *address = lead.person.address;
                                 
                                 address.street1 = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
                                 address.city = placemark.locality;
                                 address.zip = placemark.postalCode;
                                 address.state = placemark.administrativeArea;
                                 
                                 }];
                                
                                }
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTitleAttributesChangedNotification object:@{kUpdatedLeads: mainLeads}];
                            
                            });
         }
     }];
}

@end
