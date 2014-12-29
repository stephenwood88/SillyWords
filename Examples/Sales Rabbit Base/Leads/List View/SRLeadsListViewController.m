//
//  SRLeadsListViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SRLeadsListViewController.h"
#import "Lead+Rabbit.h"
#import "AppDelegate.h"
#import "SRLeadsListCell.h"
#import "SRMapViewController.h"
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"
#import "SRSalesConstants.h"
#import "SRConstants.h"
#import "Address+Rabbit.h"
#import "SRSalesServiceCalls.h"
#import "AVLocationManager.h"
#import "Constants.h"

@interface SRLeadsListViewController () <GetLocationDelegate, UIPopoverControllerDelegate, AVSimpleDatePickerDelegate, AVSelectionListDelegate>

@property (strong, nonatomic) NSFetchRequest *request;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) AVSelectionListController *filterOnDateList;
@property (strong, nonatomic) AVSelectionListController *quickDateList;
@property (strong, nonatomic) AVSelectionListController *statusList;
@property (strong, nonatomic) NSArray *selectedStatuses;
@property (strong, nonatomic) AVSimpleDatePickerController *fromDatePicker;
@property (strong, nonatomic) AVSimpleDatePickerController *toDatePicker;

@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;

@property (strong, nonatomic) NSString *filterType;

@property (copy, nonatomic) NSString *leadListSortKey;
@property (nonatomic) BOOL leadListSortAscending;

@property (strong, nonatomic) CLLocation *bestEffortAtLocation;

@property (strong, nonatomic) NSArray *currentSortDescriptors;

@property (weak, nonatomic) Lead *selectedLead;

@end

@implementation SRLeadsListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leadsChanged:) name:kLeadsChangedNotification object:nil];
    
    // Create request
    self.request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
    self.leadListSortKey = @"appointmentDate";
    self.leadListSortAscending = YES;
    [self setSortDescriptorForRequest:self.request];

    
    // Setup date and time formatters
    self.dateFormatter = [[NSDateFormatter alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.dateFormatter setDateFormat:@"M/d/yyyy"];
    }
    else {
        [self.dateFormatter setDateFormat:@"M/d/yy"];
    }
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"h:mm a"];
    
    // Filters setup
    [self initializeFilters];
    
    // Tap Recognizer for dismissing popovers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    UIView *footer = [[UIView alloc] init];
    [self.leadTableView setTableFooterView:footer];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // To show user the lead that was just edited
    [self.leadTableView deselectRowAtIndexPath:[self.leadTableView indexPathForSelectedRow] animated:YES];
    self.leadJustEdited = NO;
    
    // Get current location
    
    if ([(SRMapViewController *)self.parentViewController isLeadListVisible]) {
        [self startLocationUpdate];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self dismissAll:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"ListToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.leadTableView indexPathForCell:cell];
        Lead *selectedLead = [self.currentLeadList objectAtIndex:selectedIndex.row];
        if ([selectedLead.status isEqualToString:kCustomer] && ([kAppType isEqualToString:kSateliteApp] || [kAppType isEqualToString:kPestApp] || [kAppType isEqualToString:kFoodDelivery])) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"ListToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.leadTableView indexPathForCell:cell];
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        Lead *selectedLead = [self.currentLeadList objectAtIndex:selectedIndex.row];
        self.leadJustEdited = YES;
        ldtvc.leadToEdit = selectedLead;
    }
}

#pragma mark - Lead Sync methods

- (void)leadsChanged:(NSNotification *)notification {
    [self updateFetchRequest:self.request];
    [self performFetchWithRequest:self.request];
}


#pragma mark - Setup methods

-(void) initializeFilters{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.filterOnDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.filterDateOnButton contentList:kLeadFilterDateOptions noSelectionTitle:nil];
        [self.filterOnDateList selectItem:@"Date Created"];
    }
    else {
        self.filterOnDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.filterDateOnButton contentList:kLeadFilterDateOptionsIphone noSelectionTitle:nil];
        [self.filterOnDateList selectItem:@"Appt. Date"];
    }
    
    NSMutableDictionary *selectedContent = [[NSMutableDictionary alloc] init];
    [selectedContent setObject:kGoBack forKey:kGoBack];
    [selectedContent setObject:kCallback forKey:kCallback];
    self.statusList = [[AVSelectionListController alloc] initWithContentList:kLeadStatusesCustomer selectedContentDictionary:selectedContent delegate:self allName:[NSString stringWithFormat:@"%@ %@", kAll, kSelected]];
    self.selectedStatuses = [selectedContent allKeys];
    [self.statusButton setTitle:[NSString stringWithFormat:@"2 %@", kSelected] forState:UIControlStateNormal];
    
    self.fromDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.fromDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    [self.fromDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.toDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.toDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    [self.toDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.fromDatePicker.dateFormatter = self.dateFormatter;
        self.toDatePicker.dateFormatter = self.dateFormatter;
    }
    
    self.quickDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.quickDateButton contentList:kLeadQuickDates noSelectionTitle:nil];
    self.quickDateList.selectionIndex = -1;
    [self.quickDateList selectItem:kToday];
    

}

#pragma mark - Filters, Sorting, and Fetching

- (void)adjustToAndFromDatesForFetchRequest{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *fromComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.fromDate];
    [fromComponents setHour:0];
    [fromComponents setMinute:0];
    [fromComponents setSecond:0];
    self.fromDate = [calendar dateFromComponents:fromComponents];

    NSDateComponents *toComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.toDate];
    [toComponents setHour:23];
    [toComponents setMinute:59];
    [toComponents setSecond:59];
    self.toDate = [calendar dateFromComponents:toComponents];
    
}

- (void)updateFetchRequest:(NSFetchRequest *) request{
    
    // Setup the request predicate
    NSPredicate *userIdPredicate = [NSPredicate predicateWithFormat:@"userId == %@", [[SRGlobalState singleton] userId]];
    
    // Creates the status part of the predicate
    NSPredicate *statusesPredicate;
    
    //if all statuses are selected
    if (self.selectedStatuses.count == kLeadStatusesCustomer.count) {
        statusesPredicate = [NSPredicate predicateWithFormat:@"status != NIL"];
    }
    else {
        NSMutableString *statusPredicateString = [NSMutableString stringWithString:@""];
        for (int i = 0; i < self.selectedStatuses.count; i++) {
            if ([statusPredicateString isEqualToString: @""]) {
                [statusPredicateString appendString:@"status == %@"];
            }
            else {
                [statusPredicateString appendString:@" || status == %@"];
            }
        }
        
        statusesPredicate = [NSPredicate predicateWithFormat:statusPredicateString argumentArray:self.selectedStatuses];
    }
    
    // Creates the date range part of the predicate
    NSPredicate *datePredicate;
    if (!([self.quickDateList.selectedItem isEqualToString:kAllTime])) {
        if ([self.filterType isEqualToString:@"Appointment Date"] || [self.filterType isEqualToString:@"Appt. Date"]) {
            datePredicate = [NSPredicate predicateWithFormat:@"appointmentDate >= %@ && appointmentDate <= %@", self.fromDate, self.toDate];
        }
        else if([self.filterType isEqualToString:@"Date Created"]){
            datePredicate = [NSPredicate predicateWithFormat:@"dateCreated >= %@ && dateCreated <= %@", self.fromDate, self.toDate];
        }
        self.request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:statusesPredicate, datePredicate, userIdPredicate, nil]];
    }
    // Note if the date range is set to "All Time" we do not need to set the date range for the predicate on Date Created searches.
    // Appointment Date searches still have to filter on the date range because otherwise it includes Leads with no appointment date.
    else{
        if ([self.filterType isEqualToString:@"Appointment Date"] || [self.filterType isEqualToString:@"Appt. Date"]) {
            datePredicate = [NSPredicate predicateWithFormat:@"appointmentDate != NIL"];
            self.request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:statusesPredicate, datePredicate, userIdPredicate, nil]];
        }
        else if([self.filterType isEqualToString:@"Date Created"]){
            self.request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:statusesPredicate, userIdPredicate, nil]];
        }
    }
}

- (void)setSortDescriptorForKey:(NSString *)key label:(UILabel *)label {
    
    if ([self.leadListSortKey isEqualToString:key]) {
        self.leadListSortAscending = !self.leadListSortAscending;
    }
    else {
        self.leadListSortKey = key;
        self.leadListSortAscending = YES;
        [self clearLeadListSortLabels];
    }
    [self setSortLabel:label ascending:self.leadListSortAscending];
    [self setSortDescriptorForRequest:self.request];
}

- (void)clearLeadListSortLabels {
    
    NSString *sortLabel = [NSString stringWithFormat:@"%@%@", kUpArrowWhite, kDownArrowWhite];
    self.nameSortLabel.text = sortLabel;
    self.rankSortLabel.text = sortLabel;
    self.distanceSortLabel.text = sortLabel;
    self.appointmentSortLabel.text = sortLabel;
}

- (void)setSortLabel:(UILabel *)label ascending:(BOOL)ascending {
    
    if (ascending) {
        label.text = [NSString stringWithFormat:@"%@\n%@", kUpArrowBlack, kDownArrowWhite];
    }
    else {
        label.text = [NSString stringWithFormat:@"%@\n%@", kUpArrowWhite, kDownArrowBlack];
    }
}

- (void)setSortDescriptorForRequest:(NSFetchRequest *) request{
    // Setup the request sortDescriptors
    if ([self.leadListSortKey isEqualToString:@"name"]) {
        NSSortDescriptor *descriptorOne = [NSSortDescriptor sortDescriptorWithKey:@"person.firstName" ascending:self.leadListSortAscending];
        NSSortDescriptor *descriptorTwo = [NSSortDescriptor sortDescriptorWithKey:@"person.lastName" ascending:self.leadListSortAscending];
        self.request.sortDescriptors = [NSArray arrayWithObjects:descriptorOne, descriptorTwo, nil];
        self.currentSortDescriptors = [NSArray arrayWithObjects:descriptorOne, descriptorTwo, nil];
    }
    else if([self.leadListSortKey isEqualToString:@"appointmentDate"]){
        NSSortDescriptor *descriptorOne = [NSSortDescriptor sortDescriptorWithKey:@"appointmentDate" ascending:self.leadListSortAscending];
        NSSortDescriptor *descriptorTwo = [NSSortDescriptor sortDescriptorWithKey:@"appointmentTime" ascending:self.leadListSortAscending];
        self.request.sortDescriptors = [NSArray arrayWithObjects:descriptorOne, descriptorTwo, nil];
        self.currentSortDescriptors = [NSArray arrayWithObjects:descriptorOne, descriptorTwo, nil];
    }
    else if ([self.leadListSortKey isEqualToString:@"distance"]) {
        //can't sort on distance on fetch, do it after fetch
    }
    else{
        self.request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.leadListSortKey ascending:self.leadListSortAscending]];
        self.currentSortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.leadListSortKey ascending:self.leadListSortAscending]];
    }
}

- (void) sortResultsByDistance {
    NSArray *sortedResultsArray = [self.currentLeadList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Lead *lead1 = obj1;
        Lead *lead2 = obj2;
        CLLocation *lead1Location = [[CLLocation alloc] initWithLatitude:[[(Lead *)lead1 latitude] doubleValue]
                                                               longitude:[[(Lead *)lead1 longitude] doubleValue]];
        CLLocation *lead2Location = [[CLLocation alloc] initWithLatitude:[[(Lead *)lead2 latitude] doubleValue]
                                                               longitude:[[(Lead *)lead2 longitude] doubleValue]];
        CLLocationDistance distanceInMeters1 = [self.bestEffortAtLocation distanceFromLocation:lead1Location];
        CLLocationDistance distanceInMeters2 = [self.bestEffortAtLocation distanceFromLocation:lead2Location];
        
        
        if (self.leadListSortAscending) {
            if (distanceInMeters1 > distanceInMeters2 || (!(lead1.longitude && lead1.latitude))) {
                return NSOrderedDescending;
            }
            else {
                return NSOrderedAscending;
            }
        }
        else {
            if (distanceInMeters1 > distanceInMeters2 || (!(lead2.longitude && lead2.latitude))) {
                return NSOrderedAscending;
            }
            else {
                return NSOrderedDescending;
            }
        }
    }];
    self.currentLeadList = [sortedResultsArray mutableCopy];
    [self.leadTableView reloadData];
}

- (void)performFetchWithRequest:(NSFetchRequest *) request{
    // Fetch
    NSError *error = nil;
    NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    self.currentLeadList = [coreDataArray mutableCopy];
    if ([self.leadListSortKey isEqualToString:@"distance"]) {
        [self sortResultsByDistance];
    }
    [self.leadTableView reloadData];
}

#pragma mark - IBAction Methods

- (IBAction)sortButtonPressed:(UIButton *)sender {
    if (sender == self.nameSortButton) {
        [self setSortDescriptorForKey:@"name" label:self.nameSortLabel];
    }
    else if (sender == self.rankSortButton){
        [self setSortDescriptorForKey:@"rank" label:self.rankSortLabel];
    }
    //not implemented at the moment because distance is not a property on Lead
    else if (sender == self.distanceSortButton){
        [self setSortDescriptorForKey:@"distance" label:self.distanceSortLabel];
    }
    else if (sender == self.appointmentSortButton){
        [self setSortDescriptorForKey:@"appointmentDate" label:self.appointmentSortLabel];
    }
    
    if (sender != self.distanceSortButton) {
        NSArray *sortedResultsArray = [self.currentLeadList sortedArrayUsingDescriptors:self.currentSortDescriptors];
        self.currentLeadList = [sortedResultsArray mutableCopy];
        [self.leadTableView reloadData];
    }
    else {
        [self sortResultsByDistance];
    }
}

- (IBAction)filterButtonPressed:(UIButton *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:[self selectionForButton:sender]];
    }
    else {
        [self createPopover:sender popoverView:[self selectionForButton:sender]];
    }
}

#pragma mark - Popover and Action Sheet Methods

// Selects the approriate list or picker
- (UIViewController *)selectionForButton:(UIButton *)button {
    
    if (button == self.filterDateOnButton) return self.filterOnDateList;
    if (button == self.fromDateButton){
        if ([self.quickDateList.selectedItem isEqualToString:kAllTime]) {
            [self.quickDateList selectItem:kToday];
            self.fromDate = [NSDate date];
            [self.fromDatePicker setPickerDate:self.fromDate];
            self.toDate = [NSDate date];
            [self.toDatePicker setPickerDate:self.toDate];
        }
        return self.fromDatePicker;
    }
    if (button == self.toDateButton){
        // If AllTime is selected then default to "Today"
        if ([self.quickDateList.selectedItem isEqualToString:kAllTime]) {
            [self.quickDateList selectItem:kToday];
            self.fromDate = [NSDate date];
            [self.fromDatePicker setPickerDate:self.fromDate];
            self.toDate = [NSDate date];
            [self.toDatePicker setPickerDate:self.toDate];
        }
        return self.toDatePicker;
    }
    if (button == self.quickDateButton){
        if ([[self.quickDateButton titleForState:UIControlStateNormal] isEqual:kCustom]) {
            self.quickDateList.selectionIndex = -1;
            [self.quickDateList reloadList];
        }
        return self.quickDateList;
    }
    if (button == self.statusButton) {
        return self.statusList;
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
    [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)setPopoverLocation {
    
    if (self.popover && self.popoverView.superview.window) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)viewWillLayoutSubviews {
    
    [self setPopoverLocation];
    [self stretchCellsToWidth];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popoverView = nil;
    self.popover = nil;
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
    [self updateFetchRequest:self.request];
    [self performFetchWithRequest:self.request];
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    self.actionSheet = nil;
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        if (self.popoverView == self.statusButton) {
            [self updateFetchRequest:self.request];
            [self performFetchWithRequest:self.request];
        }
        
        [self.popover dismissPopoverAnimated:animated];
        self.popoverView = nil;
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
}

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    if (sender == self.quickDateList){
        [self setQuickDate:selection];
    }
    else if(sender == self.filterOnDateList){
        [self setFilterDateTypeAs:self.filterOnDateList.selectedItem];
    }
    
    [self dismissAll:YES];
}

- (void)checkListChanged:(AVSelectionListController *)sender {
    
    if (sender == self.statusList) {
        self.selectedStatuses = [[sender selectedContentDictionary] allKeys];
        
        NSString *label;
        NSInteger selectedCount = [self.selectedStatuses count];
        if (selectedCount == 1) {
            label = [self.selectedStatuses objectAtIndex:0];
        }
        else {
            NSString *prefix;
            if ([sender allContentSelected]) {
                prefix = kAll;
            }
            else {
                prefix = [NSString stringWithFormat:@"%ld", (long)selectedCount];
            }
            label = [NSString stringWithFormat:@"%@ %@", prefix, kSelected];
        }
        [self.statusButton setTitle:label forState:UIControlStateNormal];
    }
}

#pragma mark - AVSimpleDatePickerController Delegate Methods

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date{
    // When from button picker selects a date
    if (sender == self.fromDatePicker) {
        self.fromDate = date;
        [self.toDatePicker setMinDate:date];
        [self.quickDateButton setTitle:kCustom forState:UIControlStateNormal];
    }
    
    // When to button picker selects a date
    if (sender == self.toDatePicker) {
        self.toDate = date;
        [self.fromDatePicker setMaxDate:date];
        [self.quickDateButton setTitle:kCustom forState:UIControlStateNormal];
    }
    
    // Call methods to setup new fetch request and display the results in the table view
    [self adjustToAndFromDatesForFetchRequest];
    [self updateFetchRequest:self.request];
    [self performFetchWithRequest:self.request];
}

#pragma mark - Quick Date

- (void)setQuickDate:(NSString *)quickDateString {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    if ([quickDateString isEqualToString:kToday]) {
        self.fromDate = self.toDate = today;
    }
    else if ([quickDateString isEqualToString:kYesterday]) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = -1;
        self.fromDate = self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    else if ([quickDateString isEqualToString:kTomorrow]) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = 1;
        self.fromDate = self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    else if ([quickDateString isEqualToString:kThisWeek]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfMonthCalendarUnit) fromDate:today];
        comps.weekday = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        comps.weekday = 7;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kThisMonth]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
        comps.day = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:today];
        comps.day = dayRange.length;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kThisYear]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit) fromDate:today];
        comps.month = 1;
        comps.day = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        NSRange monthRange = [calendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:today];
        comps.month = monthRange.length;
        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[calendar dateFromComponents:comps]];
        comps.day = dayRange.length;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kAllTime]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        self.fromDate = [dateFormatter dateFromString:kMinimumDate];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = 1;
        self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    
    //adjust button titles
    if ([self.quickDateButton titleForState:UIControlStateNormal] == kAllTime) {
        [self.fromDateButton setTitle:kNA forState:UIControlStateNormal];
        [self.toDateButton setTitle:kNA forState:UIControlStateNormal];
    }
    else if([self.quickDateButton titleForState:UIControlStateNormal] != kCustom){
        [self.fromDatePicker setPickerDate:self.fromDate];
        [self.fromDatePicker setMaxDate:self.toDate];
        [self.toDatePicker setPickerDate:self.toDate];
        [self.toDatePicker setMinDate:self.fromDate];
    }
    
    // Call methods to setup new fetch request and display the results in the table view
    [self adjustToAndFromDatesForFetchRequest];
    [self updateFetchRequest:self.request];
    [self performFetchWithRequest:self.request];
}

#pragma mark - Filters, Sorting, and Fetching

- (void)setFilterDateTypeAs:(NSString *) type{
    self.filterType = type;
    
    // Call methods to setup new fetch request and display the results in the table view
    if (self.fromDate != nil && self.toDate != nil) {
        [self adjustToAndFromDatesForFetchRequest];
        [self updateFetchRequest:self.request];
        [self performFetchWithRequest:self.request];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentLeadList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SRLeadsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListLeadCell"];
    
    Lead *lead = [self.currentLeadList objectAtIndex:indexPath.row];
        
    // To show the user the lead that was just edited
    if (lead == self.selectedLead && self.leadJustEdited) {
        [self.leadTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.leadJustEdited = NO;
    }
    
    //Setup the cell
    [cell setupCellWithLead:lead andLocation:self.bestEffortAtLocation];
    
    return cell;
}

#pragma mark Editing Tableview (deleting cells)
// To support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Lead *lead = [self.currentLeadList objectAtIndex:indexPath.row];
    
    if ([lead.status isEqualToString:kCustomer]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete the row from the data source
        Lead *leadToBeDeleted = [self.currentLeadList objectAtIndex:indexPath.row];
        [self.currentLeadList removeObjectAtIndex:indexPath.row];
        //Delete the lead from Core Data
        [leadToBeDeleted deleteLeadSync:YES];
        // Animate the deletion
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        //Send notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kDeletedLeads:@[leadToBeDeleted]}];
        [[SRSalesServiceCalls singleton] sync];
    }
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedLead = [self.currentLeadList objectAtIndex:[indexPath row]];
}

#pragma mark - Location

- (void)startLocationUpdate {
    self.bestEffortAtLocation = [[AVLocationManager singleton] getBestLocationAndUpdate:self];
}

#pragma mark CLLocationManagerDelegate

- (void)currentLocationFound:(CLLocation *)location {
    self.bestEffortAtLocation = location;
    [self.leadTableView reloadData];
}

#pragma mark - Orientation

- (void)stretchCellsToWidth {
    
    for (SRLeadsListCell *cell in self.leadTableView.visibleCells) {
        [cell stretchToWidth:self.leadTableView.frame.size.width];
    }
}

@end
