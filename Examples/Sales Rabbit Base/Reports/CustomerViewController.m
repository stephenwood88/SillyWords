//
//  CustomerViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 4/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "CustomerViewController.h"
#import "AppDelegate.h"
#import "CustomerCell.h"
#import "SRServiceCalls.h"
#import "Constants.h"
#import "SRProduct.h"

@interface CustomerViewController ()
@property (strong, nonatomic) SRServiceCalls *salesRabbit;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) NSMutableArray *tableList;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) NSString *deviceModel;
@property (strong, nonatomic) AVSelectionListController *statusList;
@property (strong, nonatomic) AVSelectionListController *quickDateList;
@property (strong, nonatomic) AVSimpleDatePickerController *fromDatePicker;
@property (strong, nonatomic) AVSimpleDatePickerController *toDatePicker;
@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@property (copy, nonatomic) NSString *userID;
@property (strong, nonatomic) NSDictionary *previousProducts;
@property (strong, nonatomic) NSDate *previousStartDate;
@property (strong, nonatomic) NSDate *previousEndDate;
@property (strong, nonatomic) NSDictionary *totals;
@property (strong, nonatomic) NSMutableDictionary *accountsDictionary;
@property (copy, nonatomic) NSString *selectedStatus;
@property (copy, nonatomic) NSString *customerSortKey;
@property (nonatomic) BOOL customerSortAscending;

@end

@implementation CustomerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.deviceModel = [[UIDevice currentDevice] model];
    [self setupDateAndTimeFormatters];
    [self setupFilters];
    
    //Set up filter UI
    
    if (!kReportProducts) {
        
        NSUInteger FILTER_DIVISION_WIDTH = self.view.frame.size.width/4;
        
        self.productsButton.hidden = YES;
        self.productsLabel.hidden = YES;
        self.productsActivityIndicator.hidden = YES;
        
        self.statusButton.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.statusButton.frame.size.width/2 , self.statusButton.frame.origin.y, self.statusButton.frame.size.width, self.statusButton.frame.size.height);
        self.statusLabel.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.statusLabel.frame.size.width/2 , self.statusLabel.frame.origin.y, self.statusLabel.frame.size.width, self.statusLabel.frame.size.height);
        
        self.fromDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.fromDateButton.frame.size.width/2 , self.fromDateButton.frame.origin.y, self.fromDateButton.frame.size.width, self.fromDateButton.frame.size.height);
        self.fromDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.fromDateLabel.frame.size.width/2 , self.fromDateLabel.frame.origin.y, self.fromDateLabel.frame.size.width, self.fromDateLabel.frame.size.height);
        
        self.toDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.toDateButton.frame.size.width/2 , self.toDateButton.frame.origin.y, self.toDateButton.frame.size.width, self.toDateButton.frame.size.height);
        self.toDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.toDateLabel.frame.size.width/2 , self.toDateLabel.frame.origin.y, self.toDateLabel.frame.size.width, self.toDateLabel.frame.size.height);
        
        self.quickDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*4 - FILTER_DIVISION_WIDTH/2 - self.quickDateButton.frame.size.width/2 , self.quickDateButton.frame.origin.y, self.quickDateButton.frame.size.width, self.quickDateButton.frame.size.height);
        self.quickDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*4 - FILTER_DIVISION_WIDTH/2 - self.quickDateLabel.frame.size.width/2 , self.quickDateLabel.frame.origin.y, self.quickDateLabel.frame.size.width, self.quickDateLabel.frame.size.height);
        
    }
    
    
    // Tap Recognizer for dismissing popovers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.customerSortKey = kCustomerName;
    self.customerSortAscending = YES;
    
    self.userID = [[SRGlobalState singleton] userId];
    
    [self getDataFromWebService];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPull) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    doNotShowMainIndicator = NO;
    
    UIView *footer = [[UIView alloc] init];
    [self.tableView setTableFooterView:footer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)connectionFailedWithError:(NSError *)error {
    if (![[SRGlobalState singleton] alertViewActive]) {
        UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:kConnectionErrorTitle message:kConnectionErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [connectionError show];
        
        [[SRGlobalState singleton] setAlertViewActive:YES];
    }
    
    [self.activityIndicator stopAnimating];
    [self.refreshControl endRefreshing];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[SRGlobalState singleton] setAlertViewActive:NO];
}

#pragma mark - Initialization Methods

- (void)setupDateAndTimeFormatters {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"M/d/yyyy"];
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"h:mm a"];
}

- (void)setupFilters{
    self.statusList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.statusButton contentList:kCustomerStatuses noSelectionTitle:nil];
    //self.statusList.selectionIndex = -1;
    [self.statusList selectItem:kAll];

    
    self.fromDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.fromDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    [self.fromDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.toDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.toDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    [self.toDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    self.quickDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.quickDateButton contentList:kReportsQuickDates noSelectionTitle:kCustom];
    [self.quickDateList selectItem:kToday];
}

- (void)getDataFromWebService {
    [self.activityIndicator startAnimating];
    self.salesRabbit = [SRServiceCalls singleton];
}

- (void)refreshPull {
    [self startNewReportOnlyIfParametersChanged:NO refreshDataForPullDown:YES];
}


#pragma mark Filter Methods

- (void)setQuickDate:(NSString *)quickDateString {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    if ([quickDateString isEqualToString:kToday]) {
        if ([self.fromDateButton.titleLabel.text isEqualToString:@"N/A"]) {
            [self.quickDateButton setTitle:kCustom forState:UIControlStateNormal];
        }
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
         self.fromDate = self.toDate = nil;
        [self.fromDatePicker setPickerDate:today];
        [self.fromDatePicker setMaxDate:today];
        [self.toDatePicker setPickerDate:today];
        [self.toDatePicker setMinDate:today];
        
        [self.toDateButton setTitle:@"N/A" forState:UIControlStateNormal];
        [self.fromDateButton setTitle:@"N/A" forState:UIControlStateNormal];
    }
    
    if(![quickDateString isEqualToString:kAllTime]) {
        [self.fromDatePicker setPickerDate:self.fromDate];
        [self.fromDatePicker setMaxDate:self.toDate];
        [self.toDatePicker setPickerDate:self.toDate];
        [self.toDatePicker setMinDate:self.fromDate];
    }
    
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        [self startNewReportOnlyIfParametersChanged:YES refreshDataForPullDown:NO];
        self.popoverView = nil;
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self dismissAll:animated];
}

#pragma mark - Popover methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popoverView = nil;
    self.popover = nil;
    
    [self startNewReportOnlyIfParametersChanged:YES refreshDataForPullDown:NO];
}

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
}

#pragma mark - IBActions

- (IBAction)filterButtonPressed:(UIButton *)sender {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:[self popoverForButton:sender]];
    }
    else {
        if (sender == self.toDateButton || sender == self.fromDateButton) {
            if(self.toDate == nil || self.fromDate == nil) {
                [self.quickDateList selectItem:kToday];
            }
        }
        [self createPopover:sender popoverView:[self popoverForButton:sender]];
    }
}

- (IBAction)customerNameSortButtonPressed:(id)sender {
    
    [self setCustomerSortForKey:kCustomerName label:self.customerNameSortLabel];
}

- (IBAction)productSortButtonPressed:(id)sender {
    
    [self setCustomerSortForKey:kProductCategories label:self.productSortLabel];
}

- (IBAction)providerSortButtonPressed:(id)sender {
    
    [self setCustomerSortForKey:kProvider label:self.providerSortLabel];
}

- (IBAction)statusSortButtonPressed:(id)sender {
    
    [self setCustomerSortForKey:kInvoiceStatus label:self.statusSortLabel];
}

- (IBAction)installSortButtonPressed:(id)sender {
    
    [self setCustomerSortForKey:kInstallDate label:self.installDateSortLabel];
}

#pragma mark - CheckListDelegate

- (void)checkListChanged:(id)sender {
    if (sender == self.productOptions) {
        [self updateProductButtonText];
    }
}

// TODO: Combine these two list view controllers into one class! (which handles both single and multi-selection)

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection {
    if (sender == self.quickDateList){
        [self setQuickDate:selection];
    }
    else if (sender == self.statusList){
        if ([selection isEqualToString:kAll]) {
            self.selectedStatus = nil;
        }
        else{
            self.selectedStatus = selection;
        }
        
        [self updateCustomerTable];
    }
    
    [self dismissAll:YES];
}

#pragma mark - AVSimpleDatePickerController Delegate Methods

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date{
    // When from button picker selects a date
    if (sender == self.fromDatePicker) {
        self.fromDate = date;
        [self.toDatePicker setMinDate:date];
        [self.quickDateList selectItem:nil];
    }
    
    // When to button picker selects a date
    if (sender == self.toDatePicker) {
        self.toDate = date;
        [self.fromDatePicker setMaxDate:date];
        [self.quickDateList selectItem:nil];
    }
}

#pragma mark - Update Reports Methods

- (void)updateProductButtonText {
    
    NSString *label;
    NSInteger selectedCount = [self.selectedProductDictionary count];
    if (selectedCount == 1) {
        label = [[[self.selectedProductDictionary allValues] objectAtIndex:0] description];
    }
    else {
        NSString *prefix;
        // TODO: Can self.allProductsSelected be replaced with [self.productOptions allContentSelected]?
        if (self.allProductsSelected) {
            prefix = kAll;
        }
        else {
            prefix = [NSString stringWithFormat:@"%d", (int)selectedCount];
        }
        label = [NSString stringWithFormat:@"%@ %@", prefix, kSelected];
    }
    [self.productsButton setTitle:label forState:UIControlStateNormal];
}

#pragma mark - Helper Methods

/**
 * Returns the specified date stripped of its time components (only year, month and day)
 */
- (NSDate *)dateWithOutTime:(NSDate *)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    return [calendar dateFromComponents:comps];
}

/**
 * Date formatted as a long string for labels
 */
- (NSString *)dateAsLongString:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

/**
 * Date formatted as a short string for labels
 */
- (NSString *)dateAsShortString:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

/**
 * Phone number formatted in (XXX) XXX-XXXX format (10 digit number expected)
 */
- (NSString *)formattedPhoneNumber:(NSString *)unformattedPhoneNumber {
    
    NSAssert([unformattedPhoneNumber length] == 10, @"Expecting a 10 digit phone number");
    return [NSString stringWithFormat:@"(%@) %@-%@", [unformattedPhoneNumber substringToIndex:3], [unformattedPhoneNumber substringWithRange:NSMakeRange(3, 3)], [unformattedPhoneNumber substringWithRange:NSMakeRange(6, 4)]];
}

- (BOOL)allProductsSelected {
    
    return [self.productList count] == [self.selectedProductDictionary count];
}

- (void)startNewReportOnlyIfParametersChanged:(BOOL)parameterCheck refreshDataForPullDown:(BOOL)pulledToRefresh {
    
    if (!self.userID) {
        return; // Make sure initial web service calls have completed
    }
    
    NSDate *startDate, *endDate;
    if (self.fromDate && self.toDate) {
        startDate = self.fromDate;
        endDate = self.toDate;
    }
    
    NSDictionary *products = self.allProductsSelected?nil:self.selectedProductDictionary;
    
    BOOL parametersChanged;
    if (parameterCheck) {
        parametersChanged = !((self.previousStartDate == startDate) || [self.previousStartDate isEqualToDate:startDate]) || !((self.previousEndDate == endDate) || [self.previousEndDate isEqualToDate:endDate]) || !((self.previousProducts == products) || [self.previousProducts isEqualToDictionary:products]);
    }
    if (!parameterCheck || parametersChanged) {
        if(!pulledToRefresh) {
            self.tableList = nil;
            self.totals = nil;
            [self.tableView reloadData];
            [self.activityIndicator startAnimating];
        }
        self.customerSummaryLabel.text = nil;
        [self fetchCustomerReportStartDate:startDate endDate:endDate products:products withPullToRefresh:pulledToRefresh];
        [self.statusButton setTitle:self.selectedStatus?self.selectedStatus:kAll forState:UIControlStateNormal];
        self.previousProducts = products?[[NSDictionary alloc] initWithDictionary:products]:nil;
        self.previousStartDate = startDate;
        self.previousEndDate = endDate;
    }
}

- (void)loadEntityResults:(NSDictionary *)result ofType:(EntityType)entityType toList:(NSMutableArray *)entityList {
    
    for (NSString *entityID in result) {
        Entity *entity = [[Entity alloc] initWithType:entityType parent:nil dictionary:[result objectForKey:entityID]];
        [entityList addObject:entity];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Make sure there is not a pending update from previous selection
    NSDictionary *account = [self.tableList objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@, %@ %@\n%@", [self formattedPhoneNumber:[account objectForKey:kPhone]], [account objectForKey:kAddress], [account objectForKey:kCity], [account objectForKey:kState], [account objectForKey:kZipcode], [account objectForKey:kEmail]];
    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:[account objectForKey:kCustomerName] message:message delegate:nil cancelButtonTitle:kClose otherButtonTitles:nil];
    [detailAlert show];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerCell"];
    [cell setLabelsWithDictionary:[self.tableList objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.tableList count];
}

#pragma mark - Customer Report

- (void)fetchCustomerReportStartDate:(NSDate *)startDate endDate:(NSDate *)endDate products:(NSDictionary *)products withPullToRefresh:(BOOL)pullToRefresh{
    if(!pullToRefresh)
        [self.activityIndicator startAnimating];
    
    [self.salesRabbit accountsSalesReport:self.userID startTime:startDate endTime:endDate products:products completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            self.accountsDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
            [self.accountsDictionary setObject:[[NSMutableArray alloc] init] forKey:kCompleted];
            [self.accountsDictionary setObject:[[NSMutableArray alloc] init] forKey:kPending];
            [self.accountsDictionary setObject:[[NSMutableArray alloc] init] forKey:kNotScheduled];
            [self.accountsDictionary setObject:[[NSMutableArray alloc] init] forKey:kCancelled];
            [self.accountsDictionary setObject:[[NSMutableArray alloc] init] forKey:kChargeback];
            for (NSString *key in result) {
                NSMutableDictionary *account = [[result objectForKey:key] mutableCopy];
//                NSAssert([[account objectForKey:kPhone] length] == 10, @"Phone number expected to be 10 digits");
//                NSAssert([self.accountsDictionary objectForKey:[account objectForKey:kInvoiceStatus]], @"Invoice status \"%@\" not found in dictionary", [account objectForKey:kInvoiceStatus]);
                if ([[account objectForKey:kInstallDate] class] != [NSNull class]) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *installDate = [dateFormatter dateFromString:[account objectForKey:kInstallDate]];
                    [account setObject:installDate forKey:kInstallDate];
                }
                [[self.accountsDictionary objectForKey:[account objectForKey:kInvoiceStatus]] addObject:account];
            }
            NSMutableArray *suffixList = [[NSMutableArray alloc] initWithCapacity:6];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[result count]]];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[[self.accountsDictionary objectForKey:kCompleted] count]]];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[[self.accountsDictionary objectForKey:kPending] count]]];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[[self.accountsDictionary objectForKey:kNotScheduled] count]]];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[[self.accountsDictionary objectForKey:kCancelled] count]]];
            [suffixList addObject:[NSString stringWithFormat:@" (%d)", (int)[[self.accountsDictionary objectForKey:kChargeback] count]]];
            
            self.statusList.suffixList = suffixList;
            [self updateCustomerTable];

            [self.salesRabbit userSalesReport:self.userID startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
                if (success) {
                    self.customerSummaryLabel.text = [NSString stringWithFormat:kCustomerSummary, [result objectForKey:kInstallCount], [result objectForKey:kPendingCount], [result objectForKey:kNotScheduledCount], [result objectForKey:kCancelCount], [result objectForKey:kChargebackCount]];//Need chargeback count
                }
                else {
                    [self connectionFailedWithError:error];
                }
                
                [self.activityIndicator stopAnimating];
                [self.refreshControl endRefreshing];
                doNotShowMainIndicator = NO;
            }];
        }
        else {
            [self connectionFailedWithError:error];
            [self.activityIndicator stopAnimating];
            [self.refreshControl endRefreshing];
            doNotShowMainIndicator = NO;
        }
    }];
}

- (void)setCustomerSortForKey:(NSString *)key label:(UILabel *)label {
    
    if ([self.customerSortKey isEqualToString:key]) {
        self.customerSortAscending = !self.customerSortAscending;
    }
    else {
        self.customerSortKey = key;
        self.customerSortAscending = YES;
        [self clearCustomerSortLabels];
    }
    [self setSortLabel:label ascending:self.customerSortAscending];
    [self.tableList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:self.customerSortAscending]]];
    [self.tableView reloadData];
}

- (void)clearCustomerSortLabels {
    
    NSString *sortLabel = [NSString stringWithFormat:@"%@\n%@", kUpArrowWhite, kDownArrowWhite];
    self.customerNameSortLabel.text = sortLabel;
    self.productSortLabel.text = sortLabel;
    self.providerSortLabel.text = sortLabel;
    self.statusSortLabel.text = sortLabel;
    self.installDateSortLabel.text = sortLabel;
}

- (void)setSortLabel:(UILabel *)label ascending:(BOOL)ascending {
    
    if (ascending) {
        label.text = [NSString stringWithFormat:@"%@\n%@", kUpArrowBlack, kDownArrowWhite];
    }
    else {
        label.text = [NSString stringWithFormat:@"%@\n%@", kUpArrowWhite, kDownArrowBlack];
    }
}

- (void)updateCustomerTable {
    if (self.selectedStatus) {
        [self.statusList selectItem:self.selectedStatus];
        self.tableList = [self.accountsDictionary objectForKey:self.selectedStatus];
    }
    else {
        [self.statusList selectItem:kAll];
        self.tableList = [[NSMutableArray alloc] init];
        for (NSString *key in self.accountsDictionary) {
            [self.tableList addObjectsFromArray:[self.accountsDictionary objectForKey:key]];
        }
    }
    [self.tableList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.customerSortKey ascending:self.customerSortAscending]]];
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
    [self.refreshControl endRefreshing];
    doNotShowMainIndicator = NO;
}

#pragma mark - Custom Accessors
- (void)setSelectedStatus:(NSString *)selectedStatus {
    
    if (self.selectedStatus != selectedStatus) {
        _selectedStatus = [selectedStatus copy];
        [self updateCustomerTable];
    }
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
    [self startNewReportOnlyIfParametersChanged:YES refreshDataForPullDown:NO];
}

- (UIViewController *)popoverForButton:(UIButton *)button {
    
    if (button == self.productsButton) return self.productOptions;
    else if(button == self.statusButton) return self.statusList;
    else if(button == self.toDateButton) return self.toDatePicker;
    else if(button == self.fromDateButton) return self.fromDatePicker;
    else if(button == self.quickDateButton) return self.quickDateList;
    return nil;
}

@end
