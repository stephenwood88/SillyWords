//
//  SRLeadsListCell.h
//  Dish Sales
//
//  Created by Brady Anderson on 2/12/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>
#import "Lead.h"
#import "Person.h"

@interface SRLeadsListCell : UITableViewCell <UIAlertViewDelegate>

@property (strong, nonatomic) CLLocation *bestEffortAtLocation;

@property (weak, nonatomic) IBOutlet UIView *stationaryContainerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentLabel;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (weak, nonatomic) Lead *lead;

- (IBAction)actionButtonPressed:(UIButton *)sender;

- (void)setupCellWithLead:(Lead *)lead andLocation:(CLLocation *) location;

- (void)stretchToWidth:(CGFloat)width;

@end
