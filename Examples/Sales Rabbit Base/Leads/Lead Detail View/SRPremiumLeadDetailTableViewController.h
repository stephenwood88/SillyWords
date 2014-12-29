//
//  SRPremiumLeadDetailTableViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/27/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRLeadDetailTableViewController.h"
#import "Lead.h"
#import "Address.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
//#import <CoreLocation/CoreLocation.h>


@interface SRPremiumLeadDetailTableViewController : SRLeadDetailTableViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *currentProviderButton;
@property (weak, nonatomic) IBOutlet UIButton *outOfContractDateButton;

@end
