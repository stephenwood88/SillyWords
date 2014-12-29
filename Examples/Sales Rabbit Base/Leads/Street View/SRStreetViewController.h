//
//  SRStreetViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 7/26/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lead+Rabbit.h"
#import "SREditStreetViewController.h"
#import "AVLocationManager.h"

@interface SRStreetViewController : UIViewController <GetPlacemarkDelegate, EditStreetViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *streetTable;

@property (weak, nonatomic) IBOutlet UIButton *geoLocateButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *geoLocateActivity;
@property (weak, nonatomic) IBOutlet UITextField *houseNumberField;
@property (weak, nonatomic) IBOutlet UINavigationBar *streetNavBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *streetSortModeControl;
@property (weak, nonatomic) IBOutlet UIButton *otherStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *customerStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *goBackStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *callbackStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *notInterestedStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *notHomeStatusButton;
@property (weak, nonatomic) IBOutlet UIView *addLeadView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editStreetButton;

@property (strong, nonatomic) NSMutableArray *streetLeads;
@property (strong, nonatomic) NSMutableArray *evenLeads;
@property (strong, nonatomic) NSMutableArray *oddLeads;

@property (nonatomic) BOOL currentAddressExists;

@property (weak, nonatomic) Lead *selectedLead;

@property (strong, nonatomic) CLPlacemark *currentPlacemark;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *administrativeArea;  // State
@property (strong, nonatomic) NSString *locality;  // City
@property (strong, nonatomic) NSString *thoroughfare;  // Street

- (NSMutableArray *)getDataSourceArrayForSection:(NSInteger)section;
- (NSString *)addressNumberFromString:(NSString *)address;
- (void)dismissKeyboard;
- (void)enableStatusButtons;
- (void)createSalesLeadOfStatus:(NSString *)status withHouseNumber:(NSInteger)houseNumber;
@property (weak, nonatomic) Lead *leadForHouseNumber;
@property (nonatomic) BOOL leadJustEdited;

- (IBAction)streetSortModeChanged:(UISegmentedControl *)sender;

- (IBAction)reverseGeolocatePressed:(UIButton *)sender;

- (IBAction)downOnePressed:(UIButton *)sender;
- (IBAction)downTwoPressed:(UIButton *)sender;
- (IBAction)upTwoPressed:(UIButton *)sender;
- (IBAction)upOnePressed:(UIButton *)sender;
- (IBAction)statusButtonPressed:(UIButton *)sender;

- (IBAction)houseNumberDone:(UITextField *)sender;

@end
