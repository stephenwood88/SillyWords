//
//  SREditStreetViewController.m
//  Dish Sales
//
//  Created by Aaron Brown on 8/15/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SREditStreetViewController.h"
#import "SREditStreetFieldCell.h"
#import "SREditStreetButtonCell.h"
#import "AVStateNames.h"
#import "AVTextUtilities.h"
#import "AVSelectionListController.h"
#import "Constants.h"

#define StreetIndex 0
#define CityIndex 1
#define StateIndex 2
#define PostalCodeIndex 3
#define DigitsInValidZip 5

@interface SREditStreetViewController () <AVSelectionListDelegate, UIPopoverControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AVSelectionListController *stateList;


@property (weak, nonatomic) SREditStreetFieldCell *streetCell;
@property (weak, nonatomic) SREditStreetFieldCell *cityCell;
@property (weak, nonatomic) SREditStreetButtonCell *stateCell;
@property (weak, nonatomic) SREditStreetFieldCell *zipCell;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

@implementation SREditStreetViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addTapRecognizer];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addTapRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - IBActions

- (IBAction)savePressed:(id)sender {
    [self.view endEditing:NO];
    
    if ([self viewHasErrors]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:kEditStreetErrorTitle message:kEditStreetErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles: nil];
        [errorAlert show];
    }
    else {
        [self.delegate addressEditedStreet:self.streetCell.textField.text city:self.cityCell.textField.text state:[AVStateNames getStateForAbbreviation:self.administrativeArea forCountry:[SRGlobalState singleton].countryCode] zip:self.zipCell.textField.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)statePressed:(UIButton *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:self.stateList];
    }
    else {
        [self createPopover:sender popoverView:self.stateList];
    }
}

- (IBAction)textFieldReturnPressed:(id)sender {
    if (sender == self.streetCell.textField) {
        [self.cityCell.textField becomeFirstResponder];
        if (self.streetCell.textField.text.length == 0) {
            self.streetCell.errorView.hidden = NO;
        }
        else {
            self.streetCell.errorView.hidden = YES;
        }
    }
    else if (sender == self.cityCell.textField) {
        [self.cityCell.textField resignFirstResponder];
        [self statePressed:self.stateCell.button];
        if (self.cityCell.textField.text.length == 0) {
            self.cityCell.errorView.hidden = NO;
        }
        else {
            self.cityCell.errorView.hidden = YES;
        }
    }
    else if (sender == self.zipCell.textField) {
        [self.zipCell.textField resignFirstResponder];
        if (self.zipCell.textField.text.length != DigitsInValidZip) {
            self.zipCell.errorView.hidden = NO;
        }
        else {
            self.zipCell.errorView.hidden = YES;
        }
    }
}

#pragma mark - Error Checking

- (BOOL)viewHasErrors {
    BOOL hasErrors = NO;
    if (self.zipCell.textField.text.length != DigitsInValidZip) {
        self.zipCell.errorView.hidden = NO;
        hasErrors = YES;
    }
    if (self.cityCell.textField.text.length == 0) {
        self.cityCell.errorView.hidden = NO;
        hasErrors = YES;
    }
    if (self.streetCell.textField.text.length == 0) {
        self.streetCell.errorView.hidden = NO;
        hasErrors = YES;
    }
    
    return hasErrors;
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.zipCell.textField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:5]) {
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.streetCell.textField) {
        self.streetCell.errorView.hidden = YES;
    }
    else if (textField == self.cityCell.textField) {
        self.cityCell.errorView.hidden = YES;
    }
    else if (textField == self.zipCell.textField) {
        self.zipCell.errorView.hidden = YES;
    }
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == StreetIndex) {
        SREditStreetFieldCell *streetCell = [tableView dequeueReusableCellWithIdentifier:@"EditStreetTextFieldCell"];
        streetCell.textField.text = self.thoroughfare;
        streetCell.textField.placeholder = kStreet;
        streetCell.textField.returnKeyType = UIReturnKeyNext;
        
        self.streetCell = streetCell;
        return streetCell;
    }
    else if (indexPath.row == CityIndex) {
        SREditStreetFieldCell *cityCell = [tableView dequeueReusableCellWithIdentifier:@"EditStreetTextFieldCell"];
        cityCell.textField.text = self.locality;
        cityCell.textField.placeholder = kCity;
        cityCell.textField.returnKeyType = UIReturnKeyNext;
        
        self.cityCell = cityCell;
        return cityCell;
    }
    else if (indexPath.row == StateIndex) {
        SREditStreetButtonCell *stateCell = [tableView dequeueReusableCellWithIdentifier:@"EditStreetButtonCell"];
        self.stateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:stateCell.button contentList:[AVStateNames getArrayOfStateAbbreviationsforCountry:[SRGlobalState singleton].countryCode] noSelectionTitle:kState];
        [self.stateList selectItem:[AVStateNames getAbbreviationForState:self.administrativeArea forCountry:[SRGlobalState singleton].countryCode]];
        
        self.stateCell = stateCell;
                
        return stateCell;
    }
    else if (indexPath.row == PostalCodeIndex) {
        SREditStreetFieldCell *postalCodeCell = [tableView dequeueReusableCellWithIdentifier:@"EditStreetTextFieldCell"];
        postalCodeCell.textField.text = self.postalCode;
        postalCodeCell.textField.placeholder = kZipcode;
        postalCodeCell.textField.returnKeyType = UIReturnKeyDone;
        postalCodeCell.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.zipCell = postalCodeCell;
        return postalCodeCell;
    }
    
    return nil;
}

#pragma mark - AV Selection List Delegate

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection {
    self.administrativeArea = selection;
    [self dismissAll:YES];
    [self.zipCell.textField becomeFirstResponder];
}

#pragma mark - Popover and Action Sheet Methods

// For popovers (iPads)
- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    }
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    self.popover.delegate = self;
    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    self.popoverView = sender;
    [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
}

- (void)setPopoverLocation {
    
    if (self.popover && self.popoverView.superview.window) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
    }
}

- (void)viewWillLayoutSubviews {
    
    [self setPopoverLocation];
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
    [self.zipCell.textField becomeFirstResponder];
}

@end
