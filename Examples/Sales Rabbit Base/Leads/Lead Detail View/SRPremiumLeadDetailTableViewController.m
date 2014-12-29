//
//  LeadDetailTableViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/27/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

// TODO: fix language "popover" where it is applied to both iPhone and iPad
#import "SRPremiumLeadDetailTableViewController.h"
#import "Person+Rabbit.h"
#import "Constants.h"
#import "SRPremiumConstants.h"
#import "AgreementFormViewController.h"
#import "Agreement+Rabbit.h"
#import "SRGlobalState.h"
#import "UIImage+TintColor.h"

#define digitsInValidZip 5

@interface SRPremiumLeadDetailTableViewController ()

@property (strong, nonatomic) UIActionSheet *cancelConfirmation;
@property (strong, nonatomic) UIActionSheet *deleteConfirmation;
@property (strong, nonatomic) UIActionSheet *agreementConfirmation;

@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *deleteButton;
@property (strong, nonatomic) UIBarButtonItem *agreementButton;

//Only cerain apps will implement this.  Currently only the satelite app.
@property (strong, nonatomic) AVSelectionListController *currentProviderList;
@property (strong, nonatomic) AVSimpleDatePickerController *noContractDatePicker;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@property (strong, nonatomic) NSString *phoneNumberSelected;

@end

@implementation SRPremiumLeadDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Nav bar buttons
    self.deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                      target:self
                                                                      action:@selector(deletePressed)];

    self.agreementButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tab_icon_agreements"]
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(agreementPressed:)];

    
    if (!self.newLead) {
        self.navigationItem.rightBarButtonItems = @[self.agreementButton, self.deleteButton];
    }
    else {
        self.navigationItem.rightBarButtonItem = self.agreementButton;
    }

    if([[SRGlobalState singleton] prequalEnabled]){
        if (self.prequalForNewLead) {
            [self setupLeadToEditWithPrequalInfo];
            [self setupTextFields];
        }
    }

    self.leadToEdit.person.editingView = self;
    self.leadToEdit.person.leadDetailView = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.leadToEdit.person.editingView = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.leadToEdit.person.editingView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSelectionLists {
    [super setupSelectionLists];
    self.currentProviderList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.currentProviderButton contentList:kCurrentProvidersLeads noSelectionTitle:@"Current Provider"];
    if (self.leadToEdit.currentProvider) {
        [self.currentProviderList selectItem:self.leadToEdit.currentProvider];
    }
}

- (void)setupDatePickers {
    [super setupDatePickers];
    if (self.leadToEdit.outOfContractDate) {
        self.noContractDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.outOfContractDateButton datePickerMode:AVDatePickerModeDate date:self.leadToEdit.outOfContractDate minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
        NSString *currentDate = [self.dateFormatter stringFromDate:self.leadToEdit.outOfContractDate];
        [self.outOfContractDateButton setTitle:currentDate forState:UIControlStateNormal];
    }
    else{
        self.noContractDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.outOfContractDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    }
}

- (BOOL) leadHasAddress {
    return (self.leadToEdit.person.address.street1 != nil && self.leadToEdit.person.address.street1.length &&
    self.leadToEdit.person.address.city != nil && self.leadToEdit.person.address.city.length
    && self.leadToEdit.person.address.state != nil && self.leadToEdit.person.address.state.length
    && self.leadToEdit.person.address.zip != nil && self.leadToEdit.person.address.zip.length) ||
    (self.leadToEdit.longitude && self.leadToEdit.latitude);
}

- (void)setupLeadToEditWithPrequalInfo
{
    self.leadToEdit = [Lead newLead];
    self.leadToEdit.person.firstName = self.prequalForNewLead.firstName ? self.prequalForNewLead.firstName : @"";
    self.leadToEdit.person.lastName = self.prequalForNewLead.lastName ? self.prequalForNewLead.lastName : @"";
    self.leadToEdit.longitude = self.prequalForNewLead.longitude;
    self.leadToEdit.latitude = self.prequalForNewLead.latitude;

    [self.leadToEdit.person.address setStreet1: self.prequalForNewLead.address1 ? self.prequalForNewLead.address1 : @""];
    [self.leadToEdit.person.address setStreet2: self.prequalForNewLead.address2 ? self.prequalForNewLead.address2 : @""];
    [self.leadToEdit.person.address setZip: self.prequalForNewLead.zipCode ? self.prequalForNewLead.zipCode : @""];
    [self.leadToEdit.person.address setCity: self.prequalForNewLead.city ? self.prequalForNewLead.city : @""];
    [self.leadToEdit.person.address setState: self.prequalForNewLead.state ? self.prequalForNewLead.state : @""];
}

#pragma mark - Button selectors

- (void)deletePressed {
    // Delete confirmation
    self.deleteConfirmation = [[UIActionSheet alloc] initWithTitle:kLeadDeleteConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:nil];
    [self.deleteConfirmation showFromBarButtonItem:self.deleteButton animated:YES];
}

- (void)agreementPressed:(UIBarButtonItem *)sender {
    
    [self dismissAll:YES];
    
    AgreementFormViewController *agreementController = self.tabBarController.viewControllers[2];
    if ([agreementController confirmSaveNeeded]) {
        self.agreementConfirmation = [[UIActionSheet alloc] initWithTitle:kAgreementConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:kSave, nil];
        [self.agreementConfirmation showFromBarButtonItem:sender animated:YES];
    }
    else {
        [self goToAgreementSave:NO];
    }
}

- (void)goToAgreementSave:(BOOL)save {
    
    // Pop if lead has status set and no errors
    if ([self.leadToEdit.saved boolValue]) {
        //Check for errors
        if ([self hasErrors]) {
            UIAlertView *leadErrorAlert = [[UIAlertView alloc] initWithTitle:kLeadErrorTitle message:kLeadErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
            [leadErrorAlert show];
        }
        else {
            [self geocodeIfNecessaryAndPostNotification];
            
            AgreementFormViewController *agreementController = self.tabBarController.viewControllers[2];
            
            if (!self.leadToEdit.person.agreement) {
                [agreementController agreementSelected:[Agreement newAgreementForPerson:self.leadToEdit.person] savePrevious:save];
            }
            else {
                [agreementController agreementSelected:self.leadToEdit.person.agreement savePrevious:save];
            }
            
            self.tabBarController.selectedViewController = agreementController;
            
            UIView*  everyView;
            for(everyView in [self.view subviews]) {
                [everyView removeFromSuperview];
            }
            self.leadToEdit.person.leadDetailView = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    // Else check if the user wants to save lead
    else {
        UIAlertView *noStatusAlert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Lead status must be set" delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
        [noStatusAlert show];
    }
}

- (void)backButtonPressed {

    // Pop if lead has status set
    if ([self.leadToEdit.saved boolValue]) {
        //Check for errors
        if ([self hasErrors]) {
            UIAlertView *leadErrorAlert = [[UIAlertView alloc] initWithTitle:kLeadErrorTitle message:kLeadErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
            [leadErrorAlert show];
        }
        else {
            self.leadToEdit.person.leadDetailView = nil;

            if([[SRGlobalState singleton] prequalEnabled]){
                if (self.prequalForNewLead) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPrequalConvertedToLead object:self.prequalForNewLead];
                    self.prequalForNewLead = nil;
                }
            }

            [self geocodeIfNecessaryAndPostNotification];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    // Else check if the user wants to save lead
    else {
        if (!self.cancelConfirmation) {
            self.cancelConfirmation = [[UIActionSheet alloc] initWithTitle:kLeadCancelConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:nil];
            [self.cancelConfirmation showFromBarButtonItem:self.backButton animated:YES];
        }
    }
}


#pragma mark - AVSimpleDatePickerController Delegate Methods

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date{
    [super dateChanged:sender toDate:date];
    
    if (sender == self.noContractDatePicker) {
        self.leadToEdit.outOfContractDate = date;
    }
    
    // Modify date in here
}

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    [super checkListSelectionChanged:sender selection:selection];
    //Save result to Lead
    if (sender == self.currentProviderList){
        if (![self.leadToEdit.currentProvider isEqualToString:selection]) {
            self.leadToEdit.currentProvider = selection;
        }
    }
    
}

#pragma mark - Popover and Action Sheet Methods

// Selects the approriate list or picker
- (UIViewController *)popoverForButton:(UIButton *)button {
    if (button == self.currentProviderButton) return self.currentProviderList;
    if (button == self.outOfContractDateButton) return self.noContractDatePicker;
    return [super popoverForButton:button];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    if (self.agreementConfirmation == actionSheet && buttonIndex == 0) {
        [self goToAgreementSave:NO];
    }else if (self.agreementConfirmation == actionSheet && buttonIndex == 1) {
        [self goToAgreementSave:YES];
    }
    self.agreementConfirmation = NULL;
}


@end

