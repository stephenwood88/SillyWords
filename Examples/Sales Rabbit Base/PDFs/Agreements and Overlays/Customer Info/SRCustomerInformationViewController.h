//
//  InformationViewController.h
//  Recruit
//
//  Created by Matthew McArthur on 9/10/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agreement+Rabbit.h"
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"

@interface SRCustomerInformationViewController : UITableViewController <UITextViewDelegate, AVSelectionListDelegate, AVSimpleDatePickerDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UIImageView *firstNameError;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UIImageView *lastNameError;
@property (weak, nonatomic) IBOutlet UITextField *businessNameField;

@property (weak, nonatomic) IBOutlet UITextField *phonePrimaryField;
@property (weak, nonatomic) IBOutlet UIImageView *phonePrimaryError;
@property (weak, nonatomic) IBOutlet UITextField *phoneAlternateField;
@property (weak, nonatomic) IBOutlet UIImageView *phoneAlternateError;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIImageView *emailError;

@property (weak, nonatomic) IBOutlet UIButton *geoLocateButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *geoLocateActivity;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIImageView *addressError;
@property (weak, nonatomic) IBOutlet UITextField *aptSuiteField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UIImageView *cityError;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UIImageView *stateError;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UIImageView *zipError;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sameAsBillingControl;

@property (weak, nonatomic) IBOutlet UIButton *geoLocateBillingButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *geoLocateBillingActivity;
@property (weak, nonatomic) IBOutlet UITextField *addressBillingField;
@property (weak, nonatomic) IBOutlet UIImageView *addressBillingError;
@property (weak, nonatomic) IBOutlet UITextField *aptSuiteBillingField;
@property (weak, nonatomic) IBOutlet UITextField *cityBillingField;
@property (weak, nonatomic) IBOutlet UIImageView *cityBillingError;
@property (weak, nonatomic) IBOutlet UITextField *stateBillingField;
@property (weak, nonatomic) IBOutlet UIImageView *stateBillingError;
@property (weak, nonatomic) IBOutlet UITextField *zipBillingField;
@property (weak, nonatomic) IBOutlet UIImageView *zipBillingError;

@property (weak, nonatomic) IBOutlet UITextField *socialSecurityNumberField;
@property (weak, nonatomic) IBOutlet UIImageView *socialSecurityNumberError;
@property (weak, nonatomic) IBOutlet UIButton *languageButton;

@property (weak, nonatomic) IBOutlet UITextField *creditCardNumberField;
@property (weak, nonatomic) IBOutlet UIImageView *creditCardNumberError;
@property (weak, nonatomic) IBOutlet UIImageView *americanExpressImage;
@property (weak, nonatomic) IBOutlet UIImageView *discoverImage;
@property (weak, nonatomic) IBOutlet UIImageView *masterCardImage;
@property (weak, nonatomic) IBOutlet UIImageView *visaImage;
@property (weak, nonatomic) IBOutlet UIButton *expirationDateButton;
@property (weak, nonatomic) IBOutlet UIImageView *expirationDateError;
@property (weak, nonatomic) IBOutlet UITextField *cvvField;
@property (weak, nonatomic) IBOutlet UIImageView *cvvError;
@property (weak, nonatomic) IBOutlet UISegmentedControl *payWithControl;

@property (weak, nonatomic) IBOutlet UITextField *financialInstitutionField;
@property (weak, nonatomic) IBOutlet UIImageView *financialInstitutionError;
@property (weak, nonatomic) IBOutlet UITextField *routingNumberField;
@property (weak, nonatomic) IBOutlet UIImageView *routingNumberError;
@property (weak, nonatomic) IBOutlet UITextField *accountNumberField;
@property (weak, nonatomic) IBOutlet UIImageView *accountNumberError;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accountTypeControl;

@property (weak, nonatomic) Agreement *agreementModel;

- (IBAction)nextPressed:(id)sender;
- (IBAction)popoverButtonPressed:(UIButton *)sender;
- (IBAction)reverseGeolocatePressed:(UIButton *)sender;

- (IBAction)sameAsBillingChanged:(UISegmentedControl *)sender;
- (IBAction)payWithChanged:(UISegmentedControl *)sender;
- (IBAction)accountTypeChanged:(UISegmentedControl *)sender;

- (IBAction)textFieldChanged:(UITextField *)sender;
- (IBAction)editingDidBegin:(UITextField *)sender;
- (IBAction)editingDidEnd:(UITextField *)sender;

- (UIViewController *)popoverForButton:(UIButton *)button;

- (void)dismissAll:(BOOL)animated;

//Methods to override
- (void)clearErrors;
- (UIImageView *)errorViewForView:(UIView *)view;
- (BOOL)verifyInfo;
- (void)setValuesFromAgreement:(Agreement *)agreement;

@end

