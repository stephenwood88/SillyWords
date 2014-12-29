//
//  SRLeadDetailTableViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/27/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

// TODO: fix language "popover" where it is applied to both iPhone and iPad

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "SRLeadDetailTableViewController.h"
#import "Constants.h"
#import "AVStateNames.h"
#import "AppDelegate.h"
#import "SRServiceCalls.h"
#import "Address.h"
#import "UIImage+TintColor.h"

#define digitsInValidZip 5

@interface SRLeadDetailTableViewController ()

@property (strong, nonatomic) AVSelectionListController *statusesList;
@property (strong, nonatomic) AVSelectionListController *rankList;
@property (strong, nonatomic) AVSelectionListController *typeList;
@property (strong, nonatomic) AVSelectionListController *stateList;
@property (strong, nonatomic) AVSelectionListController *windowList;

//@property (strong, nonatomic) AVSimpleDatePickerController *appointmentDatePicker;
//@property (strong, nonatomic) AVSimpleDatePickerController *appointmentTimePicker;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@property (strong, nonatomic) UIAlertView *gpsError;
@property (strong, nonatomic) UIAlertView *connectionError;

@property (strong, nonatomic) UIActionSheet *cancelConfirmation;
@property (strong, nonatomic) UIActionSheet *deleteConfirmation;

@property (strong, nonatomic) NSString *phoneNumberSelected;

@property (nonatomic) BOOL addressChanged;


@end

@implementation SRLeadDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout) name:kLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressUpdated:) name:kAddressUpdatedNotification object:nil];
    
    // Setup current data from selected lead
    if (self.leadToEdit) {
        self.newLead = NO;
    }
    else{
        self.newLead = YES;
        self.leadToEdit = [Lead newLead];
    }
    self.addressChanged = NO;
    //#error needed to add info to new lead here for some reason, I just added it to
    [self setupDateFormatters];
    [self setupTextFields];
    [self addTapRecognizer];
    [self setupSelectionLists];
    [self setupDatePickers];
//    [self setupSwitchValues];
    
    
    //Dynamically set the geolocate buttons tint color
    UIColor *accentColor = [[SRGlobalState singleton] accentColor];
    UIImage * geoImage = [[self.getAddressButton imageForState:UIControlStateNormal] tintedImageWithColor:accentColor];
    UIImage * geoLocatedImage =[[self.getAddressButton imageForState:UIControlStateSelected] tintedImageWithColor:accentColor];
    UIImage * primaryImage = [[self.callPrimaryPhoneButton imageForState:UIControlStateNormal] tintedImageWithColor:accentColor];
    UIImage * alternateImage = [[self.callAlternatePhoneButton imageForState:UIControlStateNormal] tintedImageWithColor:accentColor];
    UIImage * emailImage = [[self.sendEmailButton imageForState:UIControlStateNormal] tintedImageWithColor:accentColor];
    UIImage * getDirectionsImage = [[self.getDirections imageForState:UIControlStateNormal] tintedImageWithColor:accentColor];
    [self.getAddressButton setImage:geoImage forState:UIControlStateNormal];
    [self.getAddressButton setImage:geoLocatedImage forState:UIControlStateSelected];
    [self.callPrimaryPhoneButton setImage:primaryImage forState:UIControlStateNormal];
    [self.callAlternatePhoneButton setImage:alternateImage forState:UIControlStateNormal];
    [self.sendEmailButton setImage:emailImage forState:UIControlStateNormal];
    [self.getDirections setImage:getDirectionsImage forState:UIControlStateNormal];
    
    
    //Nav bar buttons
    self.deleteButton = [[UIBarButtonItem alloc]
                         initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                         target:self
                         action:@selector(deletePressed)];
    
    //TODO: Still need this..??
    //if (self.leadToEdit) {
        self.navigationItem.rightBarButtonItem = self.deleteButton;
    //}
    
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.backButton;
    
    //Enable communication buttons if corresponding fields are valid
    if (![AVTextUtilities isValidPhoneNumber:self.leadToEdit.person.phonePrimary]) {
        self.callPrimaryPhoneButton.enabled = NO;
    }
    else {
        self.callPrimaryPhoneButton.enabled = YES;
    }
    
    if (![AVTextUtilities isValidPhoneNumber:self.leadToEdit.person.phoneAlternate]) {
        self.callAlternatePhoneButton.enabled = NO;
    }
    else {
        self.callAlternatePhoneButton.enabled = YES;
    }
    
    if (![AVTextUtilities isValidEmailAddress:self.leadToEdit.person.email]) {
        self.sendEmailButton.enabled = NO;
    }
    else {
        self.sendEmailButton.enabled = YES;
    }
    
    if ([self leadHasAddress]) {
        self.getDirections.enabled = YES;
    }
    else {
        self.getDirections.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self dismissAll:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    
    if (!self.leadToEdit.saved.boolValue) {
        [self.leadToEdit deleteLeadSync:NO];
        self.leadToEdit = nil;
    }
}

- (BOOL) leadHasAddress {
    return (self.leadToEdit.person.address.street1 != nil && self.leadToEdit.person.address.street1.length &&
            self.leadToEdit.person.address.city != nil && self.leadToEdit.person.address.city.length
            && self.leadToEdit.person.address.state != nil && self.leadToEdit.person.address.state.length
            && self.leadToEdit.person.address.zip != nil && self.leadToEdit.person.address.zip.length) ||
    (self.leadToEdit.longitude && self.leadToEdit.latitude);
}

#pragma mark - Setup Methods

//- (void)setupSwitchValues {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSMutableDictionary *settingsDictionary;
//    NSMutableDictionary *userSettingsDictionary;
//    
//    NSString *userID = [[SRGlobalState singleton] userId];
//    settingsDictionary = [[userDefaults objectForKey:kUserSettings] mutableCopy];
//    userSettingsDictionary = [[settingsDictionary objectForKey:userID] mutableCopy];
//    
//    if (self.newLead) {
//        if ([userSettingsDictionary objectForKey:kAppointmentsToCal]) {
//            [self.displayOnCalSwitch setOn:[userSettingsDictionary objectForKey:kAppointmentsToCal]];
//        }
//        else {
//            [self.displayOnCalSwitch setOn:YES];
//        }
//    }
//    else {
//        if (self.leadToEdit.iosCalEventId) {
//            [self.displayOnCalSwitch setOn:YES];
//        }
//        else {
//            [self.displayOnCalSwitch setOn:NO];
//        }
//    }
//
//}

- (void)setupDateFormatters {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.dateFormatter setDateFormat:@"M/d/yyyy"];
    }
    else {
        [self.dateFormatter setDateFormat:@"M/d/yy"];
    }
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"h:mm a"];
}

- (void)setupTextFields {
    //Set all text fields for lead
    self.firstNameTextField.text = self.leadToEdit.person.firstName;
    self.lastNameTextField.text = self.leadToEdit.person.lastName;
    self.primaryPhoneTextField.text = self.leadToEdit.person.phonePrimary;
    self.altPhoneTextField.text = self.leadToEdit.person.phoneAlternate;
    self.emailTextField.text = self.leadToEdit.person.email;
    self.addressTextField.text = self.leadToEdit.person.address.street1;
    self.aptSuiteTextField.text = self.leadToEdit.person.address.street2;
    self.cityTextField.text = self.leadToEdit.person.address.city;
    self.zipTextField.text = self.leadToEdit.person.address.zip;
    
    self.notesTextView.text = self.leadToEdit.notes;
    if (![self.notesTextView.text isEqualToString:@""]) {
        self.notesLabel.hidden = YES;
    }
}

- (void)addTapRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

- (void)setupSelectionLists {
    if ([kAppType isEqualToString:@"original"] || [kAppType isEqualToString:@"premium"]) {
        self.statusesList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.statusButton contentList:kLeadStatusesCustomer noSelectionTitle:@"Status"];
    }else{
        self.statusesList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.statusButton contentList:kLeadStatuses noSelectionTitle:@"Status"];
    }
    [self.statusesList selectItem:nil];
    
    if (self.leadToEdit.status) {
        [self.statusesList selectItem:self.leadToEdit.status];
    }
    
    self.rankList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.rankButton contentList:kLeadRanks noSelectionTitle:@"Rank"];
    if (self.leadToEdit.rank) {
        [self.rankList selectItem:self.leadToEdit.rank];
    }
    
    self.typeList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.typeButton contentList:kLeadTypes noSelectionTitle:@"Type"];
    if (self.leadToEdit.type){
        [self.typeList selectItem:self.leadToEdit.type];
    }
    
    self.stateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.stateButton contentList:[AVStateNames getArrayOfStateAbbreviationsforCountry:[SRGlobalState singleton].countryCode] noSelectionTitle:@"State"];
    if (self.leadToEdit.person.address.state){
        [self.stateList selectItem:self.leadToEdit.person.address.state];
    }
}

- (void)setupDatePickers {
    // Set Appointment Date and Time
    if (self.leadToEdit.appointmentDate) {
        self.appointmentDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.appointmentDateButton datePickerMode:AVDatePickerModeDate date:self.leadToEdit.appointmentDate minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
        NSString *currentDate = [self.dateFormatter stringFromDate:self.leadToEdit.appointmentDate];
        [self.appointmentDateButton setTitle:currentDate forState:UIControlStateNormal];
    }
    else{
        self.appointmentDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.appointmentDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    }
    
    if (self.leadToEdit.appointmentTime && ![self.leadToEdit.windowSelected boolValue]) {
        self.appointmentTimePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.timeOrWindowButton datePickerMode:AVDatePickerModeTime date:self.leadToEdit.appointmentTime minuteInterval:15 minimumDate:nil maximumDate:nil];
    }
    else{
        NSDate *dateToSet = [self.timeFormatter dateFromString:@"6:00 PM"];
        self.appointmentTimePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.timeOrWindowButton datePickerMode:AVDatePickerModeTime date:dateToSet minuteInterval:15 minimumDate:nil maximumDate:nil];
    }
    
    self.windowList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.timeOrWindowButton contentList:kLeadWindows noSelectionTitle:@"Time"];
    [self.windowList selectItem:nil];
    
    if ([self.leadToEdit.windowSelected boolValue] == YES) {
        [self.timeOrWindowControl setSelectedSegmentIndex:1];
        if (self.leadToEdit.appointmentWindow) {
            [self.timeOrWindowButton setTitle:self.leadToEdit.appointmentWindow forState:UIControlStateNormal];
            [self.windowList selectItem:self.leadToEdit.appointmentWindow];
        }
        else{
            [self.timeOrWindowButton setTitle:@"Window" forState:UIControlStateNormal];
        }
    }
    else{
        if (self.leadToEdit.appointmentTime) {
            NSString *currentTime = [self.timeFormatter stringFromDate:self.leadToEdit.appointmentTime];
            [self.timeOrWindowButton setTitle:currentTime forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Local Notification

- (void)scheduleNotificationForDate {
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.leadToEdit.appointmentDate];
    NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.leadToEdit.appointmentTime];
    
    [dayComps setHour:timeComps.hour];
    [dayComps setMinute:timeComps.minute];
    [dayComps setSecond:timeComps.second];

    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
    localNotification.fireDate = [gregorianCalendar dateFromComponents:dayComps];

    NSLog(@"Notification will be shown on: %@",localNotification.fireDate);
    
    localNotification.timeZone = [NSTimeZone systemTimeZone];
    localNotification.alertBody = [NSString stringWithFormat:@"You have an appointment with %@ %@",
                                   self.leadToEdit.person.firstName, self.leadToEdit.person.lastName];
    localNotification.alertAction =@"OK";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Calendar Event

- (void)setCalendarEvent {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (granted){
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *dayComps = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.leadToEdit.appointmentDate];
            NSDateComponents *timeComps = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self.leadToEdit.appointmentTime];
            
            [dayComps setHour:timeComps.hour];
            [dayComps setMinute:timeComps.minute];
            [dayComps setSecond:timeComps.second];
            
            
            [gregorianCalendar setTimeZone:[NSTimeZone systemTimeZone]];
            
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            EKEvent *events = [EKEvent eventWithEventStore:eventStore];
            
            events.title = [NSString stringWithFormat:@"%@ - Sales Rabbit", self.leadToEdit.title];
            NSMutableString *notes = [NSMutableString stringWithString:@""];
            if (self.leadToEdit.status) {
                [notes appendFormat:@"Status - %@", self.leadToEdit.status];
            }
            if (self.leadToEdit.rank) {
                
            }
            events.location = [NSString stringWithFormat:@"%@%@%@ %@ %@",
                               self.leadToEdit.person.address.street1 ?: @"",
                               self.leadToEdit.person.address.street1 ? @"\n" : @"",
                               self.leadToEdit.person.address.city ?: @"",
                               self.leadToEdit.person.address.state ?: @"",
                               self.leadToEdit.person.address.zip ?: @""];
            
            //NSLog(@"%@", [gregorianCalendar dateFromComponents:dayComps]);
            //NSLog(@"Event identifier %@", events.eventIdentifier);
            events.startDate = [gregorianCalendar dateFromComponents:dayComps];
            events.endDate = [events.startDate dateByAddingTimeInterval:kCalendarEventLengthInSeconds];
            events.availability = EKEventAvailabilityFree;
            
            [events setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:events span:EKSpanThisEvent error:&err];
            //NSLog(@"Event identifier %@", events.eventIdentifier);
            //NSLog(@"Error From iCal : %@", [err description]);

            
        }else {
            //----- codes here when user NOT allow your app to access the calendar.
        }
    }];
}

#pragma mark - Address Notification Method

- (void)addressUpdated:(NSNotification *)notification {
    Address *newAddress = notification.object;
    
    if (newAddress.street1.length && !self.addressTextField.text.length) {
        self.addressTextField.text = newAddress.street1;
    }
    if (newAddress.city.length && !self.cityTextField.text.length) {
        self.cityTextField.text = newAddress.city;
    }
    if (newAddress.state.length && self.stateList.selectionIndex == -1) {
        [self.stateList selectItem:newAddress.state];
    }
    if (newAddress.zip.length && !self.zipTextField.text.length) {
        self.zipTextField.text = newAddress.zip;
    }
    self.addressChanged = YES;
}

#pragma mark - Pop Detail Table View method

- (void)popDetailView {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView data source methods

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
            headerLabel.text = kLeadDetailsHeading1;
            break;
        case 1:
            headerLabel.text = kLeadDetailsHeading2;
            break;
        case 2:
            headerLabel.text = kLeadDetailsHeading3;
            break;
        default:
            break;
    }
    return header;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    //TODO: setting animated to NO fixed a bug from going to date/time picker to textView that messed up the popover view, but it should be animating idealy.
    if (self.popover) {
        [self.popover dismissPopoverAnimated:NO];
        self.popoverView = nil;
        self.popover = nil;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length == 0) {
        self.notesLabel.hidden = NO;
    }
    else{
        self.notesLabel.hidden = YES;
        self.leadToEdit.notes = textView.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popoverView = nil;
        self.popover = nil;
    }
    if (textField == self.primaryPhoneTextField) {
        self.primaryPhoneError.hidden = YES;
    }
    else if (textField == self.altPhoneTextField) {
        self.altPhoneError.hidden = YES;
    }
    else if (textField == self.emailTextField) {
        self.emailError.hidden = YES;
    }
    else if (textField == self.zipTextField) {
        self.zipError.hidden = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.primaryPhoneTextField) {
        if (![AVTextUtilities isValidPhoneNumber:textField.text] && self.primaryPhoneTextField.text.length > 0) {
            self.primaryPhoneError.hidden = NO;
        }
        else {
            self.primaryPhoneError.hidden = YES;
        }
    }
    else if (textField == self.altPhoneTextField) {
        if (![AVTextUtilities isValidPhoneNumber:textField.text] && self.altPhoneTextField.text.length > 0) {
            self.altPhoneError.hidden = NO;
        }
        else {
            self.altPhoneError.hidden = YES;
        }
    }
    else if (textField == self.emailTextField) {
        if (![AVTextUtilities isValidEmailAddress:textField.text] && self.emailTextField.text.length > 0) {
            self.emailError.hidden = NO;
        }
        else {
            self.emailError.hidden = YES;
        }
    }
    else if (textField == self.zipTextField) {
        if (self.zipTextField.text.length && ![AVTextUtilities isValidZipcode:self.zipTextField.text forCountryCode:[SRGlobalState singleton].countryCode]) {
            self.zipError.hidden = NO;
        }
        else {
            self.zipError.hidden = YES;
        }
    }
}

//Regulate text field entry as well as update core data as they type
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.primaryPhoneTextField || textField == self.altPhoneTextField) {
        if ([AVTextUtilities phoneNumberTextField:textField shouldChangeCharactersInRange:range replacementString:string]) {
            if (textField == self.primaryPhoneTextField) {
                self.leadToEdit.person.phonePrimary = textField.text;
                
                if (![AVTextUtilities isValidPhoneNumber:textField.text]) {
                    self.callPrimaryPhoneButton.enabled = NO;
                }
                else {
                    self.callPrimaryPhoneButton.enabled = YES;
                }
            }
            else if (textField == self.altPhoneTextField) {
                self.leadToEdit.person.phoneAlternate = textField.text;
                
                if (![AVTextUtilities isValidPhoneNumber:textField.text]) {
                    self.callAlternatePhoneButton.enabled = NO;
                }
                else {
                    self.callAlternatePhoneButton.enabled = YES;
                }
            }
        }
        return NO;
    }
    else if (textField == self.zipTextField) {
        int maxZipcodeLength = [AVTextUtilities maxZipcodeLength:[[SRGlobalState singleton] countryCode]];
        if ([[[SRGlobalState singleton] countryCode] isEqualToString:@"CAN"]){
            NSInteger insert = string.length - range.length;
            NSMutableString *current = [textField.text mutableCopy];
            [current deleteCharactersInRange:range];
            if (textField.text.length + insert > maxZipcodeLength) {
                return NO;
            }
            [current insertString:string atIndex:range.location];
            if (![textField.text isEqualToString:current]) {
                NSInteger cursorOffset = range.location + string.length;
                textField.text = current;
                UITextPosition *newCursor = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
                UITextRange *newCursorRange = [textField textRangeFromPosition:newCursor toPosition:newCursor];
                textField.selectedTextRange = newCursorRange;
            }

            self.leadToEdit.person.address.zip = textField.text;
        }
        else if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:maxZipcodeLength]) {
            self.leadToEdit.person.address.zip = textField.text;
            if ([self leadHasAddress]) {
                self.getDirections.enabled = YES;
            }
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if (theTextField == self.lastNameTextField) {
        [self.primaryPhoneTextField becomeFirstResponder];
    }
    else if (theTextField == self.primaryPhoneTextField) {
        [self.altPhoneTextField becomeFirstResponder];
    }
    else if (theTextField == self.altPhoneTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    else if (theTextField == self.emailTextField) {
        [self.addressTextField becomeFirstResponder];
    }
    else if (theTextField == self.addressTextField) {
        [self.aptSuiteTextField becomeFirstResponder];
    }
    else if (theTextField == self.aptSuiteTextField) {
        [self.cityTextField becomeFirstResponder];
    }
    else if (theTextField == self.cityTextField) {
        [self.cityTextField resignFirstResponder];
    }
    else if (theTextField == self.zipTextField) {
        [self.zipTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    self.getAddressButton.selected = NO;
    if (sender == self.aptSuiteTextField) {
        self.leadToEdit.person.address.street2 = sender.text;
        self.addressChanged = YES;
    }
    else if (sender == self.addressTextField) {
        self.leadToEdit.person.address.street1 = sender.text;
        self.addressChanged = YES;
    }
    else if (sender == self.cityTextField) {
        self.leadToEdit.person.address.city = sender.text;
        self.addressChanged = YES;
    }
    else if (sender == self.zipTextField) {
        self.leadToEdit.person.address.zip = sender.text;
        self.addressChanged = YES;
    }
    else if (sender == self.firstNameTextField) {
        self.leadToEdit.person.firstName = sender.text;
    }
    else if (sender == self.lastNameTextField) {
        self.leadToEdit.person.lastName = sender.text;
    }
    else if (sender == self.primaryPhoneTextField) {
        self.leadToEdit.person.phonePrimary = sender.text;
    }
    else if (sender == self.altPhoneTextField) {
        self.leadToEdit.person.phoneAlternate = sender.text;
    }
    else if (sender == self.emailTextField) {
        self.leadToEdit.person.email = sender.text;
        
        if (![AVTextUtilities isValidEmailAddress:sender.text]) {
            self.sendEmailButton.enabled = NO;
        }
        else {
            self.sendEmailButton.enabled = YES;
        }
    }
    if ([self leadHasAddress]) {
        self.getDirections.enabled = YES;
    }
}

#pragma mark - IBAction methods

- (IBAction)popoverButtonPressed:(UIButton *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:[self popoverForButton:sender]];
    }
    else {
        [self createPopover:sender popoverView:[self popoverForButton:sender]];
    }
    if (sender == self.appointmentDateButton) {
        if ([sender.titleLabel.text isEqualToString:@"Date"]) {
            [self dateChanged:self.appointmentDatePicker toDate:[NSDate date]];
        }
    }
    else if (sender == self.timeOrWindowButton) {
        if ([sender.titleLabel.text isEqualToString:@"Time"] || [sender.titleLabel.text isEqualToString:@"Window"]) {
            [self dateChanged:self.appointmentTimePicker toDate:[NSDate date]];
        }
    }
}

- (IBAction)timeOrWindowChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        //Switch from window to time
        case 0:
            self.leadToEdit.windowSelected = @NO;

            if (self.leadToEdit.appointmentTime) {
                NSString *currentTime = [self.timeFormatter stringFromDate:self.leadToEdit.appointmentTime];
                [self.timeOrWindowButton setTitle:currentTime forState:UIControlStateNormal];
            }
            else{
                [self.timeOrWindowButton setTitle:@"Time" forState:UIControlStateNormal];
            }
            break;
        //Switch from time to window
        case 1:
            self.leadToEdit.windowSelected = @YES;
            
            if (self.leadToEdit.appointmentWindow) {
                [self.timeOrWindowButton setTitle:self.leadToEdit.appointmentWindow forState:UIControlStateNormal];
            }
            else{
                [self.timeOrWindowButton setTitle:@"Window" forState:UIControlStateNormal];
            }
            break;
        default:
            break;
    }
}

- (IBAction)currentLocationPressed:(UIButton *)sender {
    
    self.getAddressButton.enabled = NO;
    [self.gettingLocationIndicator startAnimating];
    [[AVLocationManager singleton] getCurrentPlacemark:self];
    self.getDirections.enabled = YES;
}

//- (IBAction)displayOnCalSwitched:(UISwitch *)sender {
//    
//    if (sender.on) {
//        self.leadToEdit.calendarOn = @YES;
//        [self.leadToEdit setCalendarEventIfNecessary];
//    }
//    else {
//        self.leadToEdit.calendarOn = @NO;
//        [self.leadToEdit removeCalendarEvent];
//    }
//}

#pragma mark - Button selectors

- (void)deletePressed {
    // Delete confirmation
    self.deleteConfirmation = [[UIActionSheet alloc] initWithTitle:kLeadDeleteConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:nil];
    [self.deleteConfirmation showFromBarButtonItem:self.deleteButton animated:YES];
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
            [self geocodeIfNecessaryAndPostNotification];
            
            [self popDetailView];
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

    if (sender == self.appointmentDatePicker) {
        self.leadToEdit.appointmentDate = date;
    }
    else if (sender == self.appointmentTimePicker && self.timeOrWindowControl.selectedSegmentIndex == 0) {
        if ([self.timeOrWindowButton.titleLabel.text isEqualToString:@"Time"]) {
            [self.timeOrWindowButton setTitle:@"6:00 PM" forState:UIControlStateNormal];
            self.leadToEdit.appointmentTime = [self.timeFormatter dateFromString:@"6:00 PM"];
        }
        else {
            self.leadToEdit.appointmentTime = date;
        }
        //Set the date picker if the time picker is chosen with no date set
        if ([self.appointmentDateButton.titleLabel.text isEqual:@"Date"]) {
            [self.appointmentDatePicker setPickerDate:[NSDate date]];
            self.leadToEdit.appointmentDate = [NSDate date];
        }
    }
    
    // Modify date in here
}

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    
    //Save result to Lead
    if (sender == self.stateList) {
        if (![self.leadToEdit.person.address.state isEqualToString:selection]) {
            self.leadToEdit.person.address.state = selection;
        }
    }
    // If the status has been set it is now a valid lead
    else if (sender == self.statusesList) {
        self.leadToEdit.saved = @YES;
        if (![self.leadToEdit.status isEqualToString:selection]) {
            self.leadToEdit.status = selection;
        }
    }
    else if (sender == self.rankList) {
        if (![self.leadToEdit.rank isEqualToString:selection]) {
            self.leadToEdit.rank = selection;
        }
    }
    else if (sender == self.typeList) {
        if (![self.leadToEdit.type isEqualToString:selection]) {
            self.leadToEdit.type = selection;
        }
    }
    else if (sender == self.windowList) {
        if (![self.leadToEdit.appointmentWindow isEqualToString:selection]) {
            self.leadToEdit.appointmentWindow = selection;
        }
        //If appointment date is not set it should be set to today
        if ([self.appointmentDateButton.titleLabel.text isEqual:@"Date"]) {
            NSString *todaysDate = [self.dateFormatter stringFromDate:[NSDate date]];
            [self.appointmentDateButton setTitle:todaysDate forState:UIControlStateNormal];
            self.leadToEdit.appointmentDate = [NSDate date];
        }
    }
        if ([self leadHasAddress]) {
        self.getDirections.enabled = YES;
    }
    [self dismissAll:YES];
}

#pragma mark - GetPlacemarkDelegate methods

- (void)currentPlacemarkFound:(CLPlacemark *)placemark {
    
    self.getAddressButton.enabled = YES;
    self.getAddressButton.selected = YES;
    [self.gettingLocationIndicator stopAnimating];
    [self setAddressFromPlacemark:placemark];
}

- (void)errorFindingPlacemark {
    if (!self.connectionError) {
        self.connectionError = [[UIAlertView alloc] initWithTitle:kConnectionErrorTitle message:kConnectionErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [self.connectionError show];
    }
    [self.gettingLocationIndicator stopAnimating];
    self.getAddressButton.enabled = YES;
}

- (void)setAddressFromPlacemark:(CLPlacemark *)placemark {
    
    self.addressTextField.text = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
    self.leadToEdit.person.address.street1 = self.addressTextField.text;
    self.cityTextField.text = placemark.locality;
    self.leadToEdit.person.address.city = self.cityTextField.text;
    NSString *state = [AVStateNames getAbbreviationForState:placemark.administrativeArea forCountry:[SRGlobalState singleton].countryCode];
    [self.stateButton setTitle:state forState:UIControlStateNormal];
    self.leadToEdit.person.address.state = state;
    self.zipTextField.text = placemark.postalCode;
    self.leadToEdit.person.address.zip = placemark.postalCode;
    self.addressChanged = YES;
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

#pragma mark - Popover and Action Sheet Methods

// Selects the approriate list or picker
- (UIViewController *)popoverForButton:(UIButton *)button {
    
    if (button == self.statusButton) return self.statusesList;
    if (button == self.rankButton) return self.rankList;
    if (button == self.typeButton) return self.typeList;
    if (button == self.stateButton) return self.stateList;
    if (button == self.appointmentDateButton) return self.appointmentDatePicker;
    if (button == self.timeOrWindowButton){
        if (self.timeOrWindowControl.selectedSegmentIndex == 1) {
            return self.windowList;
        }
        else {
            return self.appointmentTimePicker;
        }
    }
    
    return nil;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self setPopoverLocation];
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
        [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        self.actionSheet = nil;
    }
    if (self.cancelConfirmation) {
        [self.cancelConfirmation dismissWithClickedButtonIndex:0 animated:YES];
        self.cancelConfirmation = nil;
    }
    if (self.deleteConfirmation) {
        [self.deleteConfirmation dismissWithClickedButtonIndex:0 animated:YES];
        self.deleteConfirmation = nil;
    }
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:NO];
}

#pragma mark - IBAction methods
- (IBAction)callOrText:(id)sender {
    
    if (self.callPrimaryPhoneButton == sender) {
        self.phoneNumberSelected = self.leadToEdit.person.phonePrimary;
    }
    else if (self.callAlternatePhoneButton == sender){
        self.phoneNumberSelected = self.leadToEdit.person.phoneAlternate;
    }
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to call or text this person?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call",@"Text", nil];
    
    message.delegate = self;
    
    [message show];
}

- (IBAction)sendEmailButtonPressed:(id)sender {
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    NSArray *recipients = [NSArray arrayWithObjects:self.leadToEdit.person.email, nil];
    
    [mc setToRecipients:recipients];
    
    [self presentViewController:mc animated:YES completion:NULL];
    mc.topViewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)getDirectionsButtonPressed:(id)sender {
    
    //This may end being called from a separate class since SRLeadsListCell does the same thing
    
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        if (!self.leadToEdit.latitude || !self.leadToEdit.longitude) {
            [self.leadToEdit setCoordinateFromAddressWithCompletionHandler:^(BOOL success, Lead *lead, NSError *error) {
                if (success) {
                }
                else {
                    NSLog(@"Geocoding error\n%@", [error localizedDescription]);
                    UIAlertView *geocodeAlert = [[UIAlertView alloc] initWithTitle:@"Error Locating Address" message:@"There was an error locating the customer's address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [geocodeAlert show];
                }
            }];
        }
        if (self.leadToEdit.latitude && self.leadToEdit.longitude) {
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([self.leadToEdit.latitude doubleValue], [self.leadToEdit.longitude doubleValue]) addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            mapItem.name = [NSString stringWithFormat:@"%@ %@", [self.leadToEdit.person.firstName capitalizedString], [self.leadToEdit.person.lastName capitalizedString]];
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey:[NSNumber numberWithUnsignedInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES};
            
            if (![mapItem openInMapsWithLaunchOptions:launchOptions]) {
                NSLog(@"Error opening MKMapItem");
                UIAlertView *mapAlert = [[UIAlertView alloc] initWithTitle:@"Error Opening Address in Maps" message:@"There was an error opening the customer's address in maps." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [mapAlert show];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *cleanedString = [[self.phoneNumberSelected componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    
    //Call Button Pressed
    if (buttonIndex == 1) {
        
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedString]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
    //Text Button Pressed
    else if (buttonIndex == 2) {
        NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", cleanedString]];
        [[UIApplication sharedApplication] openURL:smsURL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail Cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        case MFMailComposeResultSaved:
            NSLog(@"Saved");
        case MFMailComposeResultSent:
            NSLog(@"Sent");
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIActionSheet

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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.cancelConfirmation) {
        self.cancelConfirmation = nil;
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // Delete lead from core data and map
            [self.leadToEdit deleteLeadSync:NO];
            self.leadToEdit = nil;
            [self popDetailView];
        }
    }
    else if (actionSheet == self.deleteConfirmation) {
        self.deleteConfirmation = nil;
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            // Delete lead from core data and map
            [self.leadToEdit deleteLeadSync:YES];
            
            //post notification
            NSArray *deletedLeads = [NSArray arrayWithObject:self.leadToEdit];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kDeletedLeads: deletedLeads}];
            self.leadToEdit = nil;
            
            // Go back to previous view
            [self popDetailView];
        }
    }
}


#pragma mark - Map re-drop pin method

- (void)geocodeIfNecessaryAndPostNotification {
    
    // Geocode if necessary
    if (self.leadToEdit.saved.boolValue) {
        // If coordinate has not been set for lead try to get it from the address
        if (!self.leadToEdit.latitude || !self.leadToEdit.longitude || self.addressChanged) {
            BOOL newLead = self.newLead;
            [self.leadToEdit setCoordinateFromAddressWithCompletionHandler:^(BOOL success, Lead *lead, NSError *error) {
                if (success) {
                    
                }
                else {
                    DLog(@"Geocode/Reverse Geocode failed: %@", error);
                }
                
                if (newLead) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads:@[lead], kAnimateLeadChanges: @YES}];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kUpdatedLeads:@[lead], kAnimateLeadChanges: @YES}];
                }
            }];
        }
        else {
            if (self.newLead) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads:@[self.leadToEdit], kAnimateLeadChanges: @YES}];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kUpdatedLeads:@[self.leadToEdit], kAnimateLeadChanges: @YES}];
            }
        }
    }
}

#pragma mark - Error check

- (BOOL)hasErrors {
    
    BOOL error = NO;
    if (![AVTextUtilities isValidPhoneNumber:self.primaryPhoneTextField.text] && self.primaryPhoneTextField.text.length > 0) {
        self.primaryPhoneError.hidden = NO;
        error = YES;
    }
    else {
        self.primaryPhoneError.hidden = YES;
    }
    if (![AVTextUtilities isValidPhoneNumber:self.altPhoneTextField.text] && self.altPhoneTextField.text.length > 0) {
        self.altPhoneError.hidden = NO;
        error = YES;
    }
    else {
        self.altPhoneError.hidden = YES;
    }
    if (![AVTextUtilities isValidEmailAddress:self.emailTextField.text] && self.emailTextField.text.length > 0) {
        self.emailError.hidden = NO;
        error = YES;
    }
    else {
        self.emailError.hidden = YES;
    }
    if (![AVTextUtilities isValidZipcode:self.zipTextField.text forCountryCode:[[SRGlobalState singleton] countryCode]] && self.zipTextField.text.length > 0) {
        self.zipError.hidden = NO;
        error = YES;
    }
    else {
        self.zipError.hidden = YES;
    }
    return error;
}

@end
    