//
//  CustomerInfoViewController.m
//  Dish Sales
//
//  Created by Jeff on 4/5/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "CustomerInfoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "AVTextUtilities.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "CreditCard+Rabbit.h"
#import "Ach+Rabbit.h"
#import "ServiceInfo+Rabbit.h"
#import "TextOverlayViewFront.h"
#import "SRServiceCalls.h"

@interface CustomerInfoViewController ()

@property (strong, nonatomic) AVSimpleDatePickerController *dateOfBirthPicker;
@property (strong, nonatomic) AVSelectionListController *providerCheckList;
@property (strong, nonatomic) AVSelectionListController *tvsCheckList;
@property (strong, nonatomic) AVSelectionListController *receiverConfigurationCheckList;
@property (strong, nonatomic) AVSelectionListController *packageCheckList;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CustomerInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *agreementSettingsUpdatedDictionary = [defaults objectForKey:kAgreementSettingsUpdatedDictionary];
    NSString *systemAccountId = [[SRGlobalState singleton] systemAccountId];
    NSTimeInterval lastUpdate = [agreementSettingsUpdatedDictionary[systemAccountId] timeIntervalSince1970];
    NSTimeInterval updated = [[SRGlobalState singleton] agreementSettingsUpdated];
    if (updated > lastUpdate) {
        [[SRServiceCalls singleton] getAgreementSettingsCompletionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (!error) {
                NSMutableDictionary *agreementContactAndTermsDictionary = [[defaults objectForKey:kAgreementContactAndTermsDictionary] mutableCopy];
                agreementContactAndTermsDictionary[systemAccountId] = result;
                [defaults setObject:agreementContactAndTermsDictionary forKey:kAgreementContactAndTermsDictionary];
                NSMutableDictionary *agreementSettingsUpdatedMutableDictionary = [agreementSettingsUpdatedDictionary mutableCopy];
                agreementSettingsUpdatedMutableDictionary[systemAccountId] = [NSDate dateWithTimeIntervalSince1970:updated];
                [defaults setObject:agreementSettingsUpdatedMutableDictionary forKey:kAgreementSettingsUpdatedDictionary];
                [defaults synchronize];
            }
            else {
                NSLog(@"Error fetching customer agreement contact and terms: %@", error.localizedDescription);
            }
            [self setContactInfoAndAgreementTermsUpdating:YES];
        }];
    }
    else {
        [self setContactInfoAndAgreementTermsUpdating:NO];
    }
    self.textOverlayFront.salesRep.text = [[SRGlobalState singleton] userName];
    
    
    self.dateOfBirthPicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.dateOfBirthButton datePickerMode:AVDatePickerModeDate date:[self defaultBirthDate] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    
    // Create service info checklists in reverse order of dependency since they may be required to check the selection in each other
    self.packageCheckList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.packageButton contentList:@[] noSelectionTitle:kPackage];
    self.receiverConfigurationCheckList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.receiverConfigurationButton contentList:@[] noSelectionTitle:kReceiverConfiguration];
    self.tvsCheckList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.tvsButton contentList:@[] noSelectionTitle:kTvs];
    NSString *satelliteProvider = [[SRGlobalState singleton] satelliteProvider];
    NSArray *providerList;
    if ([satelliteProvider compare:@"all" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        providerList = @[kDishNetwork, kDirecTv];
    }
    else if ([satelliteProvider rangeOfString:@"dish" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        providerList = @[kDishNetwork];
    }
    else if ([satelliteProvider rangeOfString:@"direct" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        providerList = @[kDirecTv];
    }
    else {
        providerList = @[];
    }
    self.providerCheckList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.providerButton contentList:providerList noSelectionTitle:kProvider];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"M/d/yyyy"];
}

- (void)setContactInfoAndAgreementTermsUpdating:(BOOL)updatingTerms {
    NSAssert(self.textOverlayFront, @"Expect the text overlay view to be set here");
    NSDictionary *contactAndTerms = [[NSUserDefaults standardUserDefaults] objectForKey:kAgreementContactAndTermsDictionary][[[SRGlobalState singleton] systemAccountId]];
    NSString *satelliteProvider = [[SRGlobalState singleton] satelliteProvider];
    NSDictionary *contactInfo;
    NSString *orderTerms;
    if ([satelliteProvider compare:@"all" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        if ([self.providerButton.titleLabel.text isEqualToString:kDishNetwork]) {
            contactInfo = contactAndTerms[@"DishNetwork"][@"Contact"];
            orderTerms = contactAndTerms[@"DishNetwork"][@"OrderTerms"];
        }else if ([self.providerButton.titleLabel.text isEqualToString:kDirecTv])
        {
            contactInfo = contactAndTerms[@"DirecTV"][@"Contact"];
            orderTerms = contactAndTerms[@"DirecTV"][@"OrderTerms"];
        }
    }
    else if ([satelliteProvider rangeOfString:@"dish" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        contactInfo = contactAndTerms[@"DishNetwork"][@"Contact"];
        orderTerms = contactAndTerms[@"DishNetwork"][@"OrderTerms"];
    }
    else if ([satelliteProvider rangeOfString:@"direct" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        contactInfo = contactAndTerms[@"DirecTV"][@"Contact"];
        orderTerms = contactAndTerms[@"DirecTV"][@"OrderTerms"];
    }
    self.textOverlayFront.retailerName.text = contactInfo[kAgreementSettingsName];
    self.textOverlayFront.retailerAddress.text = contactInfo[kAgreementSettingsAddress];
    self.textOverlayFront.retailerCityStateZip.text = [NSString stringWithFormat:@"%@, %@ %@", contactInfo[kAgreementSettingsCity] ? contactInfo[kAgreementSettingsCity] : @"", contactInfo[kAgreementSettingsState] ? contactInfo[kAgreementSettingsState] : @"", contactInfo[kAgreementSettingsZip] ? contactInfo[kAgreementSettingsZip] : @""];
    self.textOverlayFront.retailerPhone.text = contactInfo[kAgreementSettingsPhone];
    self.textOverlayFront.retailerEmail.text = contactInfo[kAgreementSettingsEmail];
    
    if ((self.agreementModel && !self.agreementModel.signature) || !updatingTerms) {
        self.agreementModel.terms = orderTerms;
    }
}

- (NSDate *)defaultBirthDate {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
    components.month = 1;
    components.day = 1;
    components.year = components.year - 30;
    return [calendar dateFromComponents:components];
}

- (void)clearErrors {
    self.phoneCellError.hidden = YES;
    self.dateOfBirthError.hidden = YES;
    self.socialSecurityNumberError.hidden = YES;
    self.providerError.hidden = YES;
    self.tvsError.hidden = YES;
    self.receiverConfigurationError.hidden = YES;
    self.packageError.hidden = YES;
    //self.internetAccessError.hidden = YES;
    self.autoPayError.hidden = YES;
    self.promoPriceError.hidden = YES;
    self.regularPriceError.hidden = YES;
    self.otherDescriptionError.hidden = YES;
    self.other2DescriptionError.hidden = YES;
    [super clearErrors];
}

// This algorithm should mirror the Agreement+Rabbit isCompleted algorithm. They should both return the same result.
- (BOOL)verifyInfo {
    
    Agreement *agreement = self.agreementModel;
    Person *person = agreement.person;
    ServiceInfo *serviceInfo = agreement.serviceInfo;
    BOOL valid = [super verifyInfo];
    
    if (person.phoneCell.length && ![AVTextUtilities isValidPhoneNumber:person.phoneCell]) {
        self.phoneCellError.hidden = NO; valid = NO;
    }
    if (!serviceInfo.provider.length) {
        self.providerError.hidden = NO; valid = NO;
    }
    else if ([serviceInfo.provider isEqualToString:kDishNetwork]) { // Only require date of birth and SSN for DISH
        if (!person.dateOfBirth) {
            self.dateOfBirthError.hidden = NO; valid = NO;
        }
        if (![AVTextUtilities isValidSocialSecurityOrIndividualTaxIdNumber:person.ssn]) {
            self.socialSecurityNumberError.hidden = NO; valid = NO;
        }
    }
    if (!serviceInfo.tvs.integerValue > 0) {
        self.tvsError.hidden = NO; valid = NO;
    }
    if (!serviceInfo.receiverConfiguration.length) {
        self.receiverConfigurationError.hidden =  NO; valid = NO;
    }
    if (!serviceInfo.package.length) {
        self.packageError.hidden = NO; valid = NO;
    }
    /*if (!serviceInfo.internetAccess) { // Not requiring internet access be selected
        self.internetAccessError.hidden = NO; valid = NO;
    }*/
    if (!serviceInfo.autoPay) {
        self.autoPayError.hidden = NO; valid = NO;
    }
    if (!serviceInfo.promoPrice.length) {
        self.promoPriceError.hidden = NO; valid = NO;
    }
    if (!serviceInfo.regularPrice.length) {
        self.regularPriceError.hidden = NO; valid = NO;
    }
    if (serviceInfo.otherPrice.length && !serviceInfo.otherDescription.length) {
        self.otherDescriptionError.hidden = NO; valid = NO;
    }
    if (serviceInfo.other2Price.length && !serviceInfo.other2Description.length) {
        self.other2DescriptionError.hidden = NO; valid = NO;
    }
    return valid;
}

-(BOOL)verifyQualifyInfo{
    Agreement *agreement = self.agreementModel;
    Person *person = agreement.person;
    Address *address = person.address;
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
    if (!agreement.serviceInfo.provider.length) {
        self.providerError.hidden = NO; valid = NO;
    }
    return valid;
}

- (UIViewController *)popoverForButton:(UIButton *)button {
    
    if (button == self.dateOfBirthButton) return self.dateOfBirthPicker;
    if (button == self.providerButton) return self.providerCheckList;
    if (button == self.tvsButton) return self.tvsCheckList;
    if (button == self.receiverConfigurationButton) return self.receiverConfigurationCheckList;
    if (button == self.packageButton) return self.packageCheckList;
    else return [super popoverForButton:button];
}

- (UIImageView *)errorViewForView:(UIView *)view {
    
    if ([super errorViewForView:view]) {
        return [super errorViewForView:view];
    }
    if (view == self.phoneCellField) return self.phoneCellError;
    if (view == self.dateOfBirthButton) return self.dateOfBirthError;
    if (view == self.socialSecurityNumberField) return self.socialSecurityNumberError;
    if (view == self.providerButton) return self.providerError;
    if (view == self.tvsButton) return self.tvsError;
    if (view == self.receiverConfigurationButton) return self.receiverConfigurationError;
    if (view == self.packageButton) return self.packageError;
    //if (view == self.internetAccessControl) return self.internetAccessError;
    if (view == self.autoPayControl) return self.autoPayError;
    if (view == self.promoPriceField) return self.promoPriceError;
    if (view == self.regularPriceField) return self.regularPriceError;
    if (view == self.otherDescriptionField) return self.otherDescriptionError;
    if (view == self.other2DescriptionField) return self.other2DescriptionError;
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)internetAccessChanged:(UISegmentedControl *)sender {
    
    //self.internetAccessError.hidden = YES;
    self.agreementModel.serviceInfo.internetAccess = [NSNumber numberWithBool:!sender.selectedSegmentIndex];
}

- (IBAction)autoPayChanged:(UISegmentedControl *)sender {
    
    self.autoPayError.hidden = YES;
    [self.textOverlayFront clearSignature];
    self.agreementModel.serviceInfo.autoPay = [NSNumber numberWithBool:!sender.selectedSegmentIndex];
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    if (sender == self.otherDescriptionField) {
        self.agreementModel.serviceInfo.otherDescription = sender.text;
    }
    else if (sender == self.other2DescriptionField) {
        self.agreementModel.serviceInfo.other2Description = sender.text;
    }else{
         [super textFieldChanged:sender];
    }
}

- (IBAction)editingDidBegin:(UITextField *)sender {
    
    [super editingDidBegin:sender];
}

- (IBAction)editingDidEnd:(UITextField *)sender {
    
    if (sender == self.phoneCellField) {
        if (sender.text.length && ![AVTextUtilities isValidPhoneNumber:sender.text]) {
            [[self errorViewForView:sender] setHidden:NO];
        }
    }else{
        [super editingDidEnd:sender];
    }
    
}

#pragma mark - AVCheckListDelegate

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection {
    
    if (sender.sourceButton == self.providerButton) {
        if (self.agreementModel) {
            [self.textOverlayFront clearSignature];
            ServiceInfo *serviceInfo = self.agreementModel.serviceInfo;
            serviceInfo.provider = selection;
            serviceInfo.tvs = nil;
            serviceInfo.receiverConfiguration = nil;
            serviceInfo.package = nil;
            [self setContactInfoAndAgreementTermsUpdating:NO];
        }
        self.tvsCheckList.contentList = kServiceDictionary[selection][kTvs];
        [self.tvsCheckList selectItem:nil];
        self.tvsButton.enabled = YES;
        
        self.receiverConfigurationCheckList.contentList = @[];
        [self.receiverConfigurationCheckList selectItem:nil];
        self.receiverConfigurationButton.enabled = NO;
        
        self.packageCheckList.contentList = kServiceDictionary[selection][kPackage];
        [self.packageCheckList selectItem:nil];
        self.packageButton.enabled = YES;
    }
    else if (sender.sourceButton == self.tvsButton) {
        if (self.agreementModel) {
            [self.textOverlayFront clearSignature];
            ServiceInfo *serviceInfo = self.agreementModel.serviceInfo;
            serviceInfo.tvs = [NSNumber numberWithInteger:sender.selectionIndex + 1];
            serviceInfo.receiverConfiguration = nil;
        }
        self.receiverConfigurationCheckList.contentList = kServiceDictionary[self.providerCheckList.selectedItem][kReceiverConfiguration][self.tvsCheckList.selectionIndex];
        [self.receiverConfigurationCheckList selectItem:nil];
        self.receiverConfigurationButton.enabled = YES;
    }
    else if (sender.sourceButton == self.receiverConfigurationButton) {
        if (self.agreementModel) {
            [self.textOverlayFront clearSignature];
            self.agreementModel.serviceInfo.receiverConfiguration = selection;
        }
    }
    else if (sender.sourceButton == self.packageButton) {
        if (self.agreementModel) {
            [self.textOverlayFront clearSignature];
            self.agreementModel.serviceInfo.package = selection;
        }
    }
    else {
        [super checkListSelectionChanged:sender selection:selection];
    }
    [self dismissAll:YES];
}

#pragma mark - AVDatePickerDelegate

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date {
    
    if (sender == self.dateOfBirthPicker) {
        if ([self.dateOfBirthButton.titleLabel.text isEqualToString:kDateOfBirth]) {
            [self.dateOfBirthButton setTitle:[self.dateFormatter stringFromDate:date] forState:UIControlStateNormal];
        }
        self.agreementModel.person.dateOfBirth = date;
    }
    else{
        [super dateChanged:sender toDate:date];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView == self.notesField) {
        if (textView.text.length) {
            self.notesPlaceholderLabel.hidden = YES;
        }
        else {
            self.notesPlaceholderLabel.hidden = NO;
        }
        self.agreementModel.notes = textView.text;
    }
}

// Allow enter for line feeds in notes (last field, so don't need a next button here)
/*- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self nextPressed:textView];
        return NO;
    }
    else {
        return YES;
    }
}*/

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow next (done/return) button presses
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    if (textField == self.phoneCellField) {
        if ([AVTextUtilities phoneNumberTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            self.agreementModel.person.phoneCell = textField.text;
        }
        return NO;
    }
    else if (textField == self.promoPriceField || textField == self.regularPriceField || textField == self.setupPriceField || textField == self.otherPriceField || textField == self.other2PriceField) {
        if ([AVTextUtilities priceTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            [self.textOverlayFront clearSignature];
            if (textField == self.promoPriceField) {
                self.agreementModel.serviceInfo.promoPrice = textField.text;
            }
            else if (textField == self.regularPriceField) {
                self.agreementModel.serviceInfo.regularPrice = textField.text;
            }
            else if (textField == self.setupPriceField) {
                self.agreementModel.serviceInfo.setupPrice = textField.text;
            }
            else if (textField == self.otherPriceField) {
                self.agreementModel.serviceInfo.otherPrice = textField.text;
            }
            else if (textField == self.other2PriceField) {
                self.agreementModel.serviceInfo.other2Price = textField.text;
            }
        }
        return NO;
    }else
    {
        return [super textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
}

#pragma mark - Helper Methods

- (void)setAgreementModel:(Agreement *)agreementModel {
    
    [super setAgreementModel:agreementModel];
    if (!agreementModel.serviceInfo.provider && self.providerCheckList.contentList.count == 1) {
        agreementModel.serviceInfo.provider = self.providerCheckList.contentList[0];
    }
    self.agreementModel.person.customerInfoView = self;
    self.agreementModel.person.editingView = self;
}

- (void)setValuesFromAgreement:(Agreement *)agreement {
    
    Person *person = agreement.person;
    ServiceInfo *serviceInfo = agreement.serviceInfo;
    self.phoneCellField.text = person.phoneCell;
    if (person.dateOfBirth) {
        [self.dateOfBirthPicker setPickerDate:person.dateOfBirth];
    }
    else {
        [self.dateOfBirthPicker setPickerDate:[self defaultBirthDate]];
        [self.dateOfBirthButton setTitle:kDateOfBirth forState:UIControlStateNormal];
    }
    
    if (serviceInfo.provider) {
        [self.providerCheckList selectItem:serviceInfo.provider];
        if (serviceInfo.tvs) {
            NSInteger index = [serviceInfo.tvs integerValue] - 1;
            if (index >= self.tvsCheckList.contentList.count) {
                index = self.tvsCheckList.contentList.count - 1;
            }
            [self.tvsCheckList selectItem:self.tvsCheckList.contentList[index]];
            if (serviceInfo.receiverConfiguration) {
                [self.receiverConfigurationCheckList selectItem:serviceInfo.receiverConfiguration];
            }
            else {
                [self.receiverConfigurationCheckList selectItem:nil];
            }
        }
        else {
            [self.tvsCheckList selectItem:nil];
            
            self.receiverConfigurationCheckList.contentList = @[];
            [self.receiverConfigurationCheckList selectItem:nil];
            self.receiverConfigurationButton.enabled = NO;
        }
        if (serviceInfo.package) {
            [self.packageCheckList selectItem:serviceInfo.package];
        }
        else {
            [self.packageCheckList selectItem:nil];
        }
    }
    else {
        if (self.providerCheckList.contentList.count > 1) {
            [self.providerCheckList selectItem:nil];
            self.tvsCheckList.contentList = @[];
            self.tvsButton.enabled = NO;
            self.packageCheckList.contentList = @[];
            self.packageButton.enabled = NO;
        }
        [self.tvsCheckList selectItem:nil];
        [self.packageCheckList selectItem:nil];
        
        self.receiverConfigurationCheckList.contentList = @[];
        [self.receiverConfigurationCheckList selectItem:nil];
        self.receiverConfigurationButton.enabled = NO;
    }
    if (serviceInfo.internetAccess) {
        if ([serviceInfo.internetAccess boolValue]) {
            self.internetAccessControl.selectedSegmentIndex = 0;
        }
        else {
            self.internetAccessControl.selectedSegmentIndex = 1;
        }
    }
    else {
        self.internetAccessControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
    if (serviceInfo.autoPay) {
        if ([serviceInfo.autoPay boolValue]) {
            self.autoPayControl.selectedSegmentIndex = 0;
        }
        else {
            self.autoPayControl.selectedSegmentIndex = 1;
        }
    }
    else {
        self.autoPayControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    }
    self.promoPriceField.text = serviceInfo.promoPrice;
    self.regularPriceField.text = serviceInfo.regularPrice;
    self.setupPriceField.text = serviceInfo.setupPrice;
    self.otherDescriptionField.text = serviceInfo.otherDescription;
    self.otherPriceField.text = serviceInfo.otherPrice;
    self.other2DescriptionField.text = serviceInfo.other2Description;
    self.other2PriceField.text = serviceInfo.other2Price;
    self.notesField.text = agreement.notes;
    if (self.notesField.text.length) {
        self.notesPlaceholderLabel.hidden = YES;
    }
    
    [super setValuesFromAgreement:agreement];
}

@end
