//
//  SRLeadDetailTableViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/27/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lead.h"
#import "Lead+Rabbit.h"
#import "AVTextUtilities.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "AVSimpleDatePickerController.h"
#import "AVSelectionListController.h"
#import "AVLocationManager.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
#import "Prequal+Rabbit.h"

@interface SRLeadDetailTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, AVSelectionListDelegate, AVSimpleDatePickerDelegate, UIAlertViewDelegate, GetPlacemarkDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) Lead *leadToEdit;
@property (strong, nonatomic) Prequal *prequalForNewLead;

//These can be moved back to the .m file if all the apps will employ directions from the Lead Detail View
@property (strong, nonatomic) AVSimpleDatePickerController *appointmentDatePicker;
@property (strong, nonatomic) AVSimpleDatePickerController *appointmentTimePicker;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *primaryPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *altPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *aptSuiteTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;

@property (weak, nonatomic) IBOutlet UIButton *callPrimaryPhoneButton;
@property (weak, nonatomic) IBOutlet UIButton *callAlternatePhoneButton;
@property (weak, nonatomic) IBOutlet UIButton *sendEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *getDirections;
@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UIButton *getAddressButton;

@property (weak, nonatomic) IBOutlet UIButton *appointmentDateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeOrWindowControl;
@property (weak, nonatomic) IBOutlet UIButton *timeOrWindowButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *rankButton;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *primaryPhoneError;
@property (weak, nonatomic) IBOutlet UIImageView *altPhoneError;
@property (weak, nonatomic) IBOutlet UIImageView *emailError;
@property (weak, nonatomic) IBOutlet UIImageView *zipError;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *gettingLocationIndicator;

//@property (weak, nonatomic) IBOutlet UISwitch *displayOnCalSwitch;


- (UIViewController *)popoverForButton:(UIButton *)button;
- (IBAction)timeOrWindowChanged:(UISegmentedControl *)sender;
- (IBAction)currentLocationPressed:(UIButton *)sender;
- (IBAction)popoverButtonPressed:(UIButton *)sender;
- (IBAction)callOrText:(id)sender;
- (IBAction)sendEmailButtonPressed:(id)sender;
- (IBAction)getDirectionsButtonPressed:(id)sender;
- (IBAction)textFieldChanged:(UITextField *)sender;

- (void)createActionSheet:(id)sender sheetView:(UIViewController *)sheetView;
- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView;

//subclassed methods
- (void)setupDatePickers;
- (void)setupSelectionLists;
- (void)setupTextFields;
- (void)dismissAll:(BOOL)animated;
//- (IBAction)displayOnCalSwitched:(UISwitch *)sender;

- (void)geocodeIfNecessaryAndPostNotification;
- (BOOL)hasErrors;

- (void)backButtonPressed;

@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *deleteButton;

@property (nonatomic) BOOL newLead;

@end
