//
//  CustomerInfoViewController.m
//  Dish Sales
//
//  Created by Jeff on 4/5/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRCustomerInformationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AVTextUtilities.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "CreditCard+Rabbit.h"
#import "Ach+Rabbit.h"
#import "ServiceCalls.h"
#import "AVStateNames.h"
#import "UIImage+TintColor.h"
#import "AVLocationManager.h"

@interface SRCustomerInformationViewController () <GetPlacemarkDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSCharacterSet *numChars;
@property (strong, nonatomic) NSDateFormatter *expirationDateFormatter;

@property (strong, nonatomic) AVSelectionListController *languageCheckList;
@property (strong, nonatomic) AVSimpleDatePickerController *expirationDatePicker;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) UIAlertView *gpsError;
@property (strong, nonatomic) UIAlertView *connectionError;

@end

@implementation SRCustomerInformationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    
    self.languageCheckList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.languageButton contentList:kLanguageList noSelectionTitle:@"Language"];
    self.expirationDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.expirationDateButton datePickerMode:AVDatePickerModeDateNoDays date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:nil];
    self.expirationDatePicker.numericMonth = YES;
    
    self.expirationDateFormatter = [[NSDateFormatter alloc] init];
    [self.expirationDateFormatter setDateFormat:@"M/yyyy"];
    
    //Dynamically set the geolocate buttons tint color
    UIColor *accentColor = [[SRGlobalState singleton] accentColor];
    UIImage * geoImage =[self.geoLocateButton.currentImage tintedImageWithColor:accentColor];
    UIImage * geoLocatedImage =[[self.geoLocateButton imageForState:UIControlStateSelected] tintedImageWithColor:accentColor];
    [self.geoLocateButton setImage:geoImage forState:UIControlStateNormal];
    [self.geoLocateBillingButton setImage:geoImage forState:UIControlStateNormal];
    [self.geoLocateButton setImage:geoLocatedImage forState:UIControlStateSelected];
    [self.geoLocateBillingButton setImage:geoLocatedImage forState:UIControlStateSelected];
}

- (void)viewDidAppear:(BOOL)animated {
    self.agreementModel.person.editingView = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.agreementModel.person.editingView = nil;
}

- (void)setContactInfo {
    
}

- (void)clearErrors {
    
    self.firstNameError.hidden = YES;
    self.lastNameError.hidden = YES;
    self.phonePrimaryError.hidden = YES;
    self.phoneAlternateError.hidden = YES;
    self.emailError.hidden = YES;
    self.addressError.hidden = YES;
    self.cityError.hidden = YES;
    self.stateError.hidden = YES;
    self.zipError.hidden = YES;
    self.addressBillingError.hidden = YES;
    self.cityBillingError.hidden = YES;
    self.stateBillingError.hidden = YES;
    self.zipBillingError.hidden = YES;
    self.creditCardNumberError.hidden = YES;
    self.expirationDateError.hidden = YES;
    self.cvvError.hidden = YES;
    self.financialInstitutionError.hidden = YES;
    self.routingNumberError.hidden = YES;
    self.accountNumberError.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        self.popoverView = nil;
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:NO];
}

// This algorithm should mirror the Agreement+Rabbit isCompleted algorithm. They should both return the same result.
- (BOOL)verifyInfo {
    
    Agreement *agreement = self.agreementModel;
    Person *person = agreement.person;
    Address *address = person.address;
    Address *billingAddress = person.billingAddress;
    CreditCard *creditCard = agreement.creditCard;
    Ach *ach = agreement.ach;
    BOOL valid = YES;
    if (!person.firstName.length) {
        self.firstNameError.hidden = NO; valid = NO;
    }
    if (!person.lastName.length) {
        self.lastNameError.hidden = NO; valid = NO;
    }
    if (![AVTextUtilities isValidPhoneNumber:person.phonePrimary]) {
        self.phonePrimaryError.hidden = NO; valid = NO;
    }
    if (person.phoneAlternate.length && ![AVTextUtilities isValidPhoneNumber:person.phoneAlternate]) {
        self.phoneAlternateError.hidden = NO; valid = NO;
    }
    if (person.email.length && ![AVTextUtilities isValidEmailAddress:person.email]) { // Email not required, but required to be valid
        self.emailError.hidden = NO; valid = NO;
    }
    if (!address.street1.length) {
        self.addressError.hidden = NO; valid = NO;
    }
    if (!address.city.length) {
        self.cityError.hidden = NO; valid = NO;
    }
    if (address.state.length != 2) {
        self.stateError.hidden = NO; valid = NO;
    }
    if (address.zip.length != 5) {
        self.zipError.hidden = NO; valid = NO;
    }
    if (self.sameAsBillingControl.selectedSegmentIndex == 1) {
        if (!billingAddress.street1.length) {
            self.addressBillingError.hidden = NO; valid = NO;
        }
        if (!billingAddress.city.length) {
            self.cityBillingError.hidden = NO; valid = NO;
        }
        if (billingAddress.state.length != 2) {
            self.stateBillingError.hidden = NO; valid = NO;
        }
        if (billingAddress.zip.length != 5) {
            self.zipBillingError.hidden = NO; valid = NO;
        }
    }
    if ([creditCard.number length]) { // Credit card not required, but required to be valid
        if (![AVTextUtilities isValidCreditCardNumber:creditCard.number]) {
            self.creditCardNumberError.hidden = NO; valid = NO;
        }
        if (!creditCard.expirationDate) {
            self.expirationDateError.hidden = NO; valid = NO;
        }
        if (creditCard.cvv.length != 3 && creditCard.cvv.length != 4) {
            self.cvvError.hidden = NO; valid = NO;
        }
    }
    if (self.payWithControl.selectedSegmentIndex == 1) {
        if (!ach.financialInstitution.length) {
            self.financialInstitutionError.hidden = NO; valid = NO;
        }
        if (![AVTextUtilities isValidRoutingNumber:ach.routingNumber]) {
            self.routingNumberError.hidden = NO; valid = NO;
        }
        if (![AVTextUtilities isValidAchAccountNumber:ach.accountNumber]) {
            self.accountNumberError.hidden = NO; valid = NO;
        }
    }
    return valid;
}

- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    }
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    self.popover.delegate = self;
    // Allows touches outside the popover to create events besides just dismissing the popover (e.g. pressing another button)
    self.popover.passthroughViews = @[self.view];
    self.popoverView = sender;
    [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
}

- (UIViewController *)popoverForButton:(UIButton *)button {
    
    if (button == self.languageButton) return self.languageCheckList;
    if (button == self.expirationDateButton) return self.expirationDatePicker;
    return nil;
}

- (UIImageView *)errorViewForView:(UIView *)view {
    
    if (view == self.firstNameField) return self.firstNameError;
    if (view == self.lastNameField) return self.lastNameError;
    if (view == self.phonePrimaryField) return self.phonePrimaryError;
    if (view == self.phoneAlternateField) return self.phoneAlternateError;
    if (view == self.emailField) return self.emailError;
    if (view == self.addressField) return self.addressError;
    if (view == self.cityField) return self.cityError;
    if (view == self.stateField) return self.stateError;
    if (view == self.zipField) return self.zipError;
    if (view == self.addressBillingField) return self.addressBillingError;
    if (view == self.cityBillingField) return self.cityBillingError;
    if (view == self.stateBillingField) return self.stateBillingError;
    if (view == self.zipBillingField) return self.zipBillingError;
    if (view == self.creditCardNumberField) return self.creditCardNumberError;
    if (view == self.expirationDateButton) return self.expirationDateError;
    if (view == self.cvvField) return self.cvvError;
    if (view == self.financialInstitutionField) return self.financialInstitutionError;
    if (view == self.routingNumberField) return self.routingNumberError;
    if (view == self.accountNumberField) return self.accountNumberError;
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)nextPressed:(id)sender {
    
    UIView *curView = (UIView *) sender;
    NSInteger curTag = curView.tag;
    NSInteger lastTag = 0;
    BOOL enabled;
    BOOL completedSecured;
    do
    {
        curTag++;
        curView = [self.tableView viewWithTag:curTag];
        // Skip views that aren't being displayed (billing address & ACH)
        if (!curView) {
            continue;
        }
        // Skip disabled controls
        enabled = [curView.class isSubclassOfClass:UIControl.class]?[(UIControl *)curView isEnabled]:YES;
        // Check if next field is a secure field that has already been filled out and skip so it doesn't clear the entry
        if (curView == self.creditCardNumberField || curView == self.socialSecurityNumberField || curView == self.accountNumberField) {
            completedSecured = ((UITextField *) curView).text.length && [[self errorViewForView:curView] isHidden];
        }
        else {
            completedSecured = NO;
        }
    }
    while (!curView || ((!enabled || completedSecured) && curTag != lastTag + 1));
    // If last field, just dismiss keyboard
    if (curTag == lastTag + 1) {
        [self dismissAll:YES];
    }
    else {
        if (curView.class == UITextField.class || curView.class == UITextView.class) {
            [curView becomeFirstResponder];
            [self.tableView scrollRectToVisible:[self.tableView convertRect:curView.frame fromView:curView.superview] animated:YES];
        }
        else if ([curView.class isSubclassOfClass:UIButton.class]) {
            [(UIButton *)curView sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (IBAction)popoverButtonPressed:(UIButton *)sender {
    
    [[self errorViewForView:sender] setHidden:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:[self popoverForButton:sender]];
    }
    else {
        [self createPopover:sender popoverView:[self popoverForButton:sender]];
    }
}

- (IBAction)reverseGeolocatePressed:(UIButton *)sender {
    
    if (sender == self.geoLocateButton) {
        self.addressError.hidden = YES;
        self.cityError.hidden = YES;
        self.stateError.hidden = YES;
        self.zipError.hidden = YES;
    }
    else if (sender == self.geoLocateBillingButton) {
        self.addressBillingError.hidden = YES;
        self.cityBillingError.hidden = YES;
        self.stateBillingError.hidden = YES;
        self.zipBillingError.hidden = YES;
    }
    sender.enabled = NO;
    [[self activityForButton:sender] startAnimating];
    [[AVLocationManager singleton] getCurrentPlacemark:self];
}

- (UIActivityIndicatorView *)activityForButton:(UIButton *)button {
    
    if (button == self.geoLocateButton) return self.geoLocateActivity;
    if (button == self.geoLocateBillingButton) return self.geoLocateBillingActivity;
    return nil;
}

- (IBAction)sameAsBillingChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0],[NSIndexPath indexPathForRow:8 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        Address *billingAddress = self.agreementModel.person.billingAddress;
        billingAddress.street1 = nil;
        billingAddress.street2 = nil;
        billingAddress.city = nil;
        billingAddress.state = nil;
        billingAddress.zip = nil;
    }
    else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0],[NSIndexPath indexPathForRow:8 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        Address *billingAddress = self.agreementModel.person.billingAddress;
        billingAddress.street1 = self.addressBillingField.text;
        billingAddress.street2 = self.aptSuiteBillingField.text;
        billingAddress.city = self.cityBillingField.text;
        billingAddress.state = self.stateBillingField.text;
        billingAddress.zip = self.zipBillingField.text;
    }
}

- (IBAction)payWithChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        Ach *ach = self.agreementModel.ach;
        ach.financialInstitution = nil;
        ach.accountType = nil;
        ach.routingNumber = nil;
        ach.accountNumber = nil;
        self.financialInstitutionField.text = nil;
        self.accountTypeControl.selectedSegmentIndex = 0;
        self.routingNumberField.text = nil;
        self.accountNumberField.text = nil;
    }
    else {
        self.accountTypeControl.selectedSegmentIndex = 0;
        self.agreementModel.ach.accountType = kChecking;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (IBAction)accountTypeChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.agreementModel.ach.accountType = kChecking;
    }
    else {
        self.agreementModel.ach.accountType = kSavings;
    }
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    if (sender == self.firstNameField) {
        self.agreementModel.person.firstName = sender.text;
    }
    else if (sender == self.lastNameField) {
        self.agreementModel.person.lastName = sender.text;
    }
    else if (sender == self.businessNameField) {
        self.agreementModel.person.businessName = sender.text;
    }
    else if (sender == self.emailField) {
        self.agreementModel.person.email = sender.text;
    }
    else if (sender == self.addressField) {
        self.geoLocateButton.selected = NO;
        self.agreementModel.person.address.street1 = sender.text;
    }
    else if (sender == self.aptSuiteField) {
        self.agreementModel.person.address.street2 = sender.text;
    }
    else if (sender == self.cityField) {
        self.geoLocateButton.selected = NO;
        self.agreementModel.person.address.city = sender.text;
    }
    else if (sender == self.addressBillingField) {
        self.geoLocateBillingButton.selected = NO;
        self.agreementModel.person.billingAddress.street1 = sender.text;
    }
    else if (sender == self.aptSuiteBillingField) {
        self.agreementModel.person.billingAddress.street2 = sender.text;
    }
    else if (sender == self.cityBillingField) {
        self.geoLocateBillingButton.selected = NO;
        self.agreementModel.person.billingAddress.city = sender.text;
    }
    else if (sender == self.financialInstitutionField) {
        self.agreementModel.ach.financialInstitution = sender.text;
    }
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    
    if (sender == self.creditCardNumberField || sender == self.socialSecurityNumberField || sender == self.accountNumberField) {
        if ([[self errorViewForView:sender] isHidden]) {
            sender.text = nil;
            if (sender == self.creditCardNumberField) {
                self.agreementModel.creditCard.number = nil;
                [self selectCreditCardTypeFromNumber:nil];
            }
            else if (sender == self.socialSecurityNumberField) {
                self.agreementModel.person.ssn = nil;
            }
            else if (sender == self.accountNumberField) {
                self.agreementModel.ach.accountNumber = nil;
            }
        }
    }
    [[self errorViewForView:sender] setHidden:YES];
}

- (IBAction)editingDidEnd:(UITextField *)sender {
    
    if (sender == self.creditCardNumberField) {
        if (sender.text.length) {
            if ([AVTextUtilities isValidCreditCardNumber:sender.text]) {
                sender.text = [AVTextUtilities obfuscatedNumber:sender.text showNumDigits:4];
            }
            else {
                self.creditCardNumberError.hidden = NO;
            }
        }
    }
    else if (sender == self.cvvField) {
        if (sender.text.length && sender.text.length != 3 && sender.text.length != 4) {
            self.cvvError.hidden = NO;
        }
    }
    else if (sender == self.routingNumberField) {
        if (sender.text.length && ![AVTextUtilities isValidRoutingNumber:self.routingNumberField.text]) {
            self.routingNumberError.hidden = NO;
        }
    }
    else if (sender == self.accountNumberField) {
        if (sender.text.length) {
            if ([AVTextUtilities isValidAchAccountNumber:sender.text]) {
                sender.text = [AVTextUtilities obfuscatedNumber:self.accountNumberField.text showNumDigits:4];
            }
            else {
                self.accountNumberError.hidden = NO;
            }
        }
    }
    else if (sender == self.emailField) {
        if (sender.text.length && ![AVTextUtilities isValidEmailAddress:self.emailField.text]) {
            self.emailError.hidden = NO;
        }
    }
    else if (sender == self.socialSecurityNumberField) {
        if (sender.text.length) {
            if ([AVTextUtilities isValidSocialSecurityOrIndividualTaxIdNumber:sender.text]) {
                sender.text = [AVTextUtilities obfuscatedNumber:self.socialSecurityNumberField.text showNumDigits:0];
            }
            else {
                self.socialSecurityNumberError.hidden = NO;
            }
        }
    }
    else if (sender == self.phonePrimaryField || sender == self.phoneAlternateField) {
        if (sender.text.length && ![AVTextUtilities isValidPhoneNumber:sender.text]) {
            [[self errorViewForView:sender] setHidden:NO];
        }
    }
    else if (sender == self.stateField || sender == self.stateBillingField) {
        if (sender.text.length && sender.text.length != 2) {
            [[self errorViewForView:sender] setHidden:NO];
        }
    }
    else if (sender == self.zipField || sender == self.zipBillingField) {
        if (sender.text.length && sender.text.length != 5) {
            [[self errorViewForView:sender] setHidden:NO];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popoverView = nil;
    self.popover = nil;
}

#pragma mark - AVCheckListDelegate

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection {
    
    if (sender.sourceButton == self.languageButton) {
        if (self.agreementModel) {
            self.agreementModel.person.language = selection;
        }
    }
    [self dismissAll:YES];
}

#pragma mark - AVDatePickerDelegate

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date {
    
    if (sender == self.expirationDatePicker) {
        if ([self.expirationDateButton.titleLabel.text isEqualToString:kExpDate]) {
            [self.expirationDateButton setTitle:[self.expirationDateFormatter stringFromDate:date] forState:UIControlStateNormal];
        }
        self.agreementModel.creditCard.expirationDate = date;
    }
}

#pragma mark - GetPlacemarkDelegate methods

- (void)currentPlacemarkFound:(CLPlacemark *)placemark {
    
    [self setAddressFromPlacemark:placemark];
}

- (void)errorFindingPlacemark {
    if (!self.connectionError) {
        self.connectionError = [[UIAlertView alloc] initWithTitle:kConnectionErrorTitle message:kConnectionErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [self.connectionError show];
    }
    if (!self.geoLocateButton.enabled) {
        [self.geoLocateActivity stopAnimating];
        self.geoLocateButton.enabled = YES;
    }
    if (!self.geoLocateBillingButton.enabled) {
        [self.geoLocateBillingActivity stopAnimating];
        self.geoLocateBillingButton.enabled = YES;
    }
}

- (void)setAddressFromPlacemark:(CLPlacemark *)placemark {
    
    NSString *state = [AVStateNames getAbbreviationForState:placemark.administrativeArea forCountry:[SRGlobalState singleton].countryCode];
    NSString *zip = placemark.postalCode;
    
    if (!self.geoLocateButton.enabled) {
        Address *address = self.agreementModel.person.address;
        self.addressField.text = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        address.street1 = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        self.aptSuiteField.text = nil;
        address.street2 = nil;
        self.cityField.text = placemark.locality;
        address.city = placemark.locality;
        self.stateField.text = state;
        address.state = state;
        self.zipField.text = zip;
        address.zip = zip;
        self.geoLocateButton.selected = YES;
    }
    if (!self.geoLocateBillingButton.enabled) {
        Address *billingAddress = self.agreementModel.person.billingAddress;
        self.addressBillingField.text = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        billingAddress.street1 = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        self.aptSuiteBillingField.text = nil;
        billingAddress.street2 = nil;
        self.cityBillingField.text = placemark.locality;
        billingAddress.city = placemark.locality;
        self.stateBillingField.text = state;
        billingAddress.state = state;
        self.zipBillingField.text = zip;
        billingAddress.zip = zip;
        self.geoLocateBillingButton.selected = YES;
    }
    
    //TODO: Why are these seperate from the if statements above?
    if (!self.geoLocateButton.enabled) {
        [self.geoLocateActivity stopAnimating];
        self.geoLocateButton.enabled = YES;
    }
    if (!self.geoLocateBillingButton.enabled) {
        [self.geoLocateBillingActivity stopAnimating];
        self.geoLocateBillingButton.enabled = YES;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.gpsError) {
        self.gpsError = nil;
    }
    else if (alertView == self.connectionError) {
        self.connectionError = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 && self.sameAsBillingControl.selectedSegmentIndex == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            return 7;
        }
        else {
            return 4;
        }
    }
    if (section == 1 && self.payWithControl.selectedSegmentIndex == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            return 2;
        }
        else {
            return 1;
        }
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 20 : 55, 0, 250, 30)];
    headerLabel.font = [UIFont fontWithName:kFont2 size:17];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:headerLabel];
    switch (section) {
        case 0:
            headerLabel.text = kAgreementHeading1;
            break;
        case 1:
            headerLabel.text = kAgreementHeading2;
            break;
        case 2:
            headerLabel.text = kAgreementHeading3;
            break;
        default:
            break;
    }
    return header;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self setPopoverLocation];
}

- (void)viewWillLayoutSubviews {
    
    [self setPopoverLocation];
}

- (void)setPopoverLocation {
    
    if (self.popover && self.popoverView.superview.window) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.popover) {
        //TODO: setting animated to NO fixed a bug from going to DOB picker to textView, but it should be animating idealy.
        [self.popover dismissPopoverAnimated:NO];
        self.popoverView = nil;
        self.popover = nil;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popoverView = nil;
        self.popover = nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow next (done/return) button presses
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    if (textField == self.phonePrimaryField || textField == self.phoneAlternateField) {
        if ([AVTextUtilities phoneNumberTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            if (textField == self.phonePrimaryField) {
                self.agreementModel.person.phonePrimary = textField.text;
            }
            else if (textField == self.phoneAlternateField) {
                self.agreementModel.person.phoneAlternate = textField.text;
            }
        }
        return NO;
    }
    else if (textField == self.stateField || textField == self.stateBillingField) {
        if ([AVTextUtilities alphaTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumCharacters:2 characterCase:CharacterCaseUppercase]) {
            if (textField == self.stateField) {
                self.geoLocateButton.selected = NO;
                self.agreementModel.person.address.state = textField.text;
            }
            else if (textField == self.stateBillingField) {
                self.geoLocateBillingButton.selected = NO;
                self.agreementModel.person.billingAddress.state = textField.text;
            }
        }
        return NO;
    }
    else if (textField == self.zipField || textField == self.zipBillingField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:5]) {
            if (textField == self.zipField) {
                self.geoLocateButton.selected = NO;
                self.agreementModel.person.address.zip = textField.text;
            }
            else if (textField == self.zipBillingField) {
                self.geoLocateBillingButton.selected = NO;
                self.agreementModel.person.billingAddress.zip = textField.text;
            }
        }
        return NO;
    }
    else if (textField == self.socialSecurityNumberField) {
        if ([AVTextUtilities socialSecurityNumberTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            self.agreementModel.person.ssn = textField.text;
        }
        return NO;
    }
    else if (textField == self.creditCardNumberField) {
        if ([AVTextUtilities creditCardNumberTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            [self selectCreditCardTypeFromNumber:textField.text];
            self.agreementModel.creditCard.number = textField.text;
        }
        return NO;
    }
    else if (textField == self.cvvField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:4]) {
            self.agreementModel.creditCard.cvv = textField.text;
        }
        return NO;
    }
    else if (textField == self.routingNumberField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:9]) {
            self.agreementModel.ach.routingNumber = textField.text;
        }
        return NO;
    }
    else if (textField == self.accountNumberField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:17]) {
            self.agreementModel.ach.accountNumber = textField.text;
        }
        return NO;
    }
    return YES;
}

#pragma mark - Helper Methods

- (void)selectCreditCardTypeFromNumber:(NSString *)creditCardNumber {
    
    self.americanExpressImage.hidden = YES;
    self.discoverImage.hidden = YES;
    self.masterCardImage.hidden = YES;
    self.visaImage.hidden = YES;
    if (creditCardNumber.length) {
        if ([AVTextUtilities isAmericanExpressIIN:creditCardNumber]) {
            self.americanExpressImage.hidden = NO;
        }
        else if ([AVTextUtilities isDiscoverIIN:creditCardNumber]) {
            self.discoverImage.hidden = NO;
        }
        else if ([AVTextUtilities isMasterCardIIN:creditCardNumber]) {
            self.masterCardImage.hidden = NO;
        }
        else if ([AVTextUtilities isVisaIIN:creditCardNumber]) {
            self.visaImage.hidden = NO;
        }
    }
}

- (void)setAgreementModel:(Agreement *)agreementModel {
    
    self.agreementModel.person.editingView = nil;
    self.agreementModel.person.customerInfoView = nil;
    _agreementModel = nil; // Clear to prevent sideaffects being applied during initialization
    [self clearErrors];
    self.geoLocateButton.selected = NO;
    self.geoLocateBillingButton.selected = NO;
     _agreementModel = agreementModel;
    [self setValuesFromAgreement:agreementModel];
}

- (void)setValuesFromAgreement:(Agreement *)agreement {
    
    Person *person = agreement.person;
    Address *address = person.address;
    Address *billingAddress = person.billingAddress;
    CreditCard *creditCard = agreement.creditCard;
    Ach *ach = agreement.ach;
    
    self.firstNameField.text = person.firstName;
    self.lastNameField.text = person.lastName;
    self.businessNameField.text = person.businessName;
    self.phonePrimaryField.text = person.phonePrimary;
    self.phoneAlternateField.text = person.phoneAlternate;
    self.emailField.text = person.email;
    self.socialSecurityNumberField.text = [AVTextUtilities obfuscatedNumber:person.ssn showNumDigits:0];
    [self.languageCheckList selectItem:person.language];
    
    self.addressField.text = address.street1;
    self.aptSuiteField.text = address.street2;
    self.cityField.text = address.city;
    self.stateField.text = address.state;
    self.zipField.text = address.zip;
    
    if (billingAddress.street1.length || billingAddress.street2.length || billingAddress.city.length ||
        billingAddress.state.length || billingAddress.zip.length) {
        self.sameAsBillingControl.selectedSegmentIndex = 1;
    }
    else {
        self.sameAsBillingControl.selectedSegmentIndex = 0;
    }
    self.addressBillingField.text = billingAddress.street1;
    self.aptSuiteBillingField.text = billingAddress.street2;
    self.cityBillingField.text = billingAddress.city;
    self.stateBillingField.text = billingAddress.state;
    self.zipBillingField.text = billingAddress.zip;
    
    self.creditCardNumberField.text = [AVTextUtilities obfuscatedNumber:creditCard.number showNumDigits:4];
    [self selectCreditCardTypeFromNumber:creditCard.number];
    if (creditCard.expirationDate) {
        [self.expirationDatePicker setPickerDate:creditCard.expirationDate];
    }
    else {
        [self.expirationDatePicker setPickerDate:[NSDate date]];
        [self.expirationDateButton setTitle:kExpDate forState:UIControlStateNormal];
    }
    self.cvvField.text = creditCard.cvv;
    
    if (ach.financialInstitution.length || ach.accountType.length || ach.routingNumber.length || ach.accountNumber.length) {
        self.payWithControl.selectedSegmentIndex = 1;
    }
    else {
        self.payWithControl.selectedSegmentIndex = 0;
    }
    self.financialInstitutionField.text = ach.financialInstitution;
    if ([ach.accountType isEqualToString:kChecking]) {
        self.accountTypeControl.selectedSegmentIndex = 0;
    }
    else if ([ach.accountType isEqualToString:kSavings]) {
        self.accountTypeControl.selectedSegmentIndex = 1;
    }
    self.routingNumberField.text = ach.routingNumber;
    self.accountNumberField.text = [AVTextUtilities obfuscatedNumber:ach.accountNumber showNumDigits:4];
    
    [self.tableView reloadData]; // Refresh the toggled sections
}

#pragma mark- Action Sheet

- (void)createActionSheet:(id)sender sheetView:(UIViewController *)sheetView {
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    if (!sheetView.isViewLoaded) {
        [sheetView view]; // Load view so that its metrics will be available
    }
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect actionSheetFrame = screenFrame;
    if (sheetView.preferredContentSize.height + 44 < actionSheetFrame.size.height) {
        actionSheetFrame.size.height = sheetView.preferredContentSize.height + 44;
        actionSheetFrame.origin.y = actionSheetFrame.origin.y + screenFrame.size.height - actionSheetFrame.size.height;
    }
    CGRect sheetViewFrame = actionSheetFrame;
    sheetViewFrame.origin.y = 44;
    sheetViewFrame.size.height = actionSheetFrame.size.height - 44;
    
    [self.actionSheet addSubview:sheetView.view];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, 44)];
    background.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    [self.actionSheet addSubview:background];
    
    //Only show cancel button if it is a one-item list picker, otherwise show done button
    UISegmentedControl *doneButton;
    CGFloat buttonWidth;
    if ([sheetView isKindOfClass:[AVSelectionListController class]]) {
        NSString *doneButtonText = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? kDone : kCancel;
        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
        doneButton.momentary = YES;
        doneButton.tintColor = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1] : [UIColor blackColor];
        buttonWidth = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? ACTION_DONE_BTN_WIDTH : ACTION_CANCEL_BTN_WIDTH;
    }
    else {
        NSString *doneButtonText = kDone;
        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
        doneButton.momentary = YES;
        doneButton.tintColor = [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1];
        buttonWidth = ACTION_DONE_BTN_WIDTH;
    }
    
    doneButton.frame = CGRectMake(screenFrame.size.width - buttonWidth - 5, 7, buttonWidth, 30);
    [doneButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [self.actionSheet addSubview:doneButton];
    
    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    // Set these frames after showing because the showInView method messes the frames up
    self.actionSheet.frame = actionSheetFrame;
    sheetView.view.frame = sheetViewFrame;
}

- (void)dismissActionSheet:(id)sender {
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    self.actionSheet = nil;
}

@end
