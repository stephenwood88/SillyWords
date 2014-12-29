//
//  StandingsViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 3/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "StandingsViewController.h"
#import "AppDelegate.h"
#import "SRProduct.h"
#import "Constants.h"
#import "Entity.h"
#import "TechStandingCell.h"


@interface StandingsViewController ()
{
    NSUInteger NAME_COLUMN_WIDTH;
    NSUInteger COLUMN_DIVISION_WIDTH;
    NSUInteger COLUMNS_SECTION_WIDTH;
    
    NSInteger SELECTED_FILTER_INDEX;
    
}
@property (strong, nonatomic) SRServiceCalls *salesRabbit;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) NSMutableArray *tableList;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) AVSelectionListController *filterOnDateList;
@property (strong, nonatomic) AVSelectionListController *quickDateList;
@property (strong, nonatomic) AVSimpleDatePickerController *fromDatePicker;
@property (strong, nonatomic) AVSimpleDatePickerController *toDatePicker;

@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@property (copy, nonatomic) NSString *userID;

@property (strong, nonatomic) NSDictionary *previousOffices;
@property (strong, nonatomic) NSDictionary *previousProducts;
@property (strong, nonatomic) NSDate *previousStartDate;
@property (strong, nonatomic) NSDate *previousEndDate;
@property (strong, nonatomic) NSString *previousDomain;
@property (strong, nonatomic) NSDictionary *totals;

//Reports columns
@property (strong, nonatomic) NSMutableArray *columnNamesList;
@property (strong, nonatomic) NSMutableArray *columnButtonList;
@property (strong, nonatomic) NSMutableArray *columnSortingArrowsLabelsList;
@property (strong, nonatomic) NSMutableArray *columnLabelsList;
@property (strong, nonatomic) NSMutableArray *columnDefinitionList;
@property (strong, nonatomic) UIScrollView *columnScrollView;
@property (strong, nonatomic) NSMutableArray *cellScrollViewList;
@property (strong, nonatomic) UIView *scrollViewShadow;

@end


@implementation StandingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self updateColumns];
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    
    self.cellScrollViewList = [NSMutableArray array];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"M/d/yyyy"];
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"h:mm a"];
    
    
    //Set up filter UI
    
    if (!kReportProducts) {
        
        NSUInteger FILTER_DIVISION_WIDTH = self.view.frame.size.width/4;
        
        self.productsButton.hidden = YES;
        self.productsLabel.hidden = YES;
        self.productsBtnIndicator.hidden = YES;
        
        self.domainsButton.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.domainsButton.frame.size.width/2 , self.domainsButton.frame.origin.y, self.domainsButton.frame.size.width, self.domainsButton.frame.size.height);
        self.domainLabel.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.domainLabel.frame.size.width/2 , self.domainLabel.frame.origin.y, self.domainLabel.frame.size.width, self.domainLabel.frame.size.height);
        
        self.fromDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.fromDateButton.frame.size.width/2 , self.fromDateButton.frame.origin.y, self.fromDateButton.frame.size.width, self.fromDateButton.frame.size.height);
        self.fromDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.fromDateLabel.frame.size.width/2 , self.fromDateLabel.frame.origin.y, self.fromDateLabel.frame.size.width, self.fromDateLabel.frame.size.height);
        
        self.toDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.toDateButton.frame.size.width/2 , self.toDateButton.frame.origin.y, self.toDateButton.frame.size.width, self.toDateButton.frame.size.height);
        self.toDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.toDateLabel.frame.size.width/2 , self.toDateLabel.frame.origin.y, self.toDateLabel.frame.size.width, self.toDateLabel.frame.size.height);
        
        self.quickDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*4 - FILTER_DIVISION_WIDTH/2 - self.quickDateButton.frame.size.width/2 , self.quickDateButton.frame.origin.y, self.quickDateLabel.frame.size.width, self.quickDateButton.frame.size.height);
        self.quickDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*4 - FILTER_DIVISION_WIDTH/2 - self.quickDateLabel.frame.size.width/2 , self.quickDateLabel.frame.origin.y, self.quickDateLabel.frame.size.width, self.quickDateLabel.frame.size.height);
        
    }
    //Just a renaming that was set up later, thi sis so it gets updated in all apps
    self.domainLabel.text = @"Level";
    
    
    // Filters setup
    // TODO: Finish the products button
    
    [self.filterOnDateList selectItem:@"Appointment Date"];
    
    self.fromDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.fromDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    [self.fromDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.toDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.toDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    [self.toDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.quickDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.quickDateButton contentList:kReportsQuickDates noSelectionTitle:kCustom];
    [self.quickDateList selectItem:kToday];
        
    // Tap Recognizer for dismissing popovers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    
    self.userID = [[SRGlobalState singleton] userId];
    
    UIView *footer = [[UIView alloc] init];
    [self.tableView setTableFooterView:footer];
    [self getDataFromWebService];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPull) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    SELECTED_FILTER_INDEX = 0;
    self.sortNameArrowsLabel.tag = -1;
    
    [self.tableView reloadData];

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
    [self.productsBtnIndicator stopAnimating];
    [self.officesBtnIndicator stopAnimating];
    [self.refreshControl endRefreshing];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[SRGlobalState singleton] setAlertViewActive:NO];
}


#pragma mark - Initialization Methods
- (void)refreshPull {
    [self startNewReportOnlyIfParametersChanged:NO refreshDataForPullDown:YES];
}

- (void)getDataFromWebService {
    
    [self.activityIndicator startAnimating];
    if (kReportProducts) {
        [self.productsBtnIndicator startAnimating];
    }
    [self.officesBtnIndicator startAnimating];
    self.salesRabbit = [SRServiceCalls singleton];

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
    
    if (![quickDateString isEqualToString:kAllTime]) {
        [self.fromDatePicker setPickerDate:self.fromDate];
        [self.fromDatePicker setMaxDate:self.toDate];
        [self.toDatePicker setPickerDate:self.toDate];
        [self.toDatePicker setMinDate:self.fromDate];
    }
    
}

- (void)setDomainValue:(NSString *)domain {
    
    self.reportDepth = domain;
    
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        [self startNewReportOnlyIfParametersChanged:YES refreshDataForPullDown:NO];
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self dismissAll:animated];
}

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
        if(sender == self.toDateButton || sender == self.fromDateButton) {
            if(self.toDate == nil || self.fromDate == nil) {
                [self.quickDateList selectItem:kToday];
            }
        }
        [self createPopover:sender popoverView:[self popoverForButton:sender]];
    }
}

- (IBAction)sortingButtonPressed:(UIButton *)sender {
    
    UILabel *tempLabel;
    sender.highlighted = YES;
    BOOL ascending = YES;
    
    if (sender == self.sortNameButton) {
        tempLabel = self.sortNameArrowsLabel;
        //SELECTED_FILTER_INDEX = (int)self.columnNamesList.count;
        SELECTED_FILTER_INDEX = -1;
    }
    else{
        tempLabel = [self.columnSortingArrowsLabelsList objectAtIndex:sender.tag];
        SELECTED_FILTER_INDEX = (int)sender.tag;
    }
    
    if ([tempLabel.text isEqualToString:@"△\n▽"]) {
        for (int i=0; i<self.columnSortingArrowsLabelsList.count; i++) {
            [[self.columnSortingArrowsLabelsList objectAtIndex:i] setText:@"△\n▽"];
        }
        [self.sortNameArrowsLabel setText:@"△\n▽"];
        [tempLabel setText:@"△\n▼"];
        ascending = YES;
        
    }
    else if ([tempLabel.text isEqualToString:@"△\n▼"]) {
        [tempLabel setText:@"▲\n▽"];
        ascending = NO;
    }
    else if ([tempLabel.text isEqualToString:@"▲\n▽"]) {
        [tempLabel setText:@"△\n▼"];
        ascending = YES;
    }
    
    [self sortTableRowsWithColumnIndex:SELECTED_FILTER_INDEX ascending:ascending];
    
}

- (IBAction)columnInfoButtonPressed:(UIButton *)sender {
    
    NSString *message = @"";
    
    for (int i=0; i<self.columnDefinitionList.count; i++) {
        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@ - %@\n",[[self.columnDefinitionList objectAtIndex:i] objectForKey:@"Abbreviation"],[[self.columnDefinitionList objectAtIndex:i] objectForKey:@"Description"]]];
    }
    
    UIAlertView *abbreviationInfoAlertView = [[UIAlertView alloc] initWithTitle:@"Stats Key" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [abbreviationInfoAlertView show];
    
}


#pragma mark - CheckListDelegate

- (void)checkListChanged:(id)sender {
    
    if (sender == self.productOptions) {
        [self updateProductButtonText];
    }
    else if (sender == self.officeOptions) {
        [self updateOfficeButtonText];
    }
}

// TODO: Combine these two list view controllers into one class! (which handles both single and multi-selection)

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    if (sender == self.quickDateList){
        [self setQuickDate:selection];
    }
    else if(sender == self.filterOnDateList){
        [self setFilterDateTypeAs:self.filterOnDateList.selectedItem];
    }
    else if (sender == self.domainOptions){
        [self setDomainValue:selection];
    }
    [self dismissAll:YES];
}

- (void)setFilterDateTypeAs:(NSString *) type {
    //self.filterType = type;
    
    // Call methods to setup new fetch request and display the results in the table view
    if (self.fromDate != nil && self.toDate != nil) {
        [self adjustToAndFromDatesForFetchRequest];
    }
}
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
    
    if ([self.quickDateButton titleForState:UIControlStateNormal] == kAllTime) {
        [self.fromDateButton setTitle:@"N/A" forState:UIControlStateNormal];
        [self.toDateButton setTitle:@"N/A" forState:UIControlStateNormal];
    }
    else if([self.quickDateButton titleForState:UIControlStateNormal] != kCustom){
        [self.fromDatePicker setPickerDate:self.fromDate];
        [self.fromDatePicker setMaxDate:self.toDate];
        [self.toDatePicker setPickerDate:self.toDate];
        [self.toDatePicker setMinDate:self.fromDate];
    }
    
    // Print statement for testing
    /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MMM-dd HH:mm:ss"];
    NSString *strFromDate = [formatter stringFromDate:self.fromDate]; // this will return 2012-Jun-21 00:00:00
    NSString *strToDate = [formatter stringFromDate:self.toDate]; // this will return 2012-Jun-21 00:00:00
    NSLog(@"\nThe fromDate is: %@\nThe toDate is: %@", strFromDate, strToDate);*/
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

- (void)updateOfficeButtonText {
    
    NSString *label;
    NSInteger selectedCount = [self.selectedOfficeDictionary count];
    if (selectedCount == 1) {
        label = [[[self.selectedOfficeDictionary allValues] objectAtIndex:0] description];
    }
    else {
        NSString *prefix;
        // TODO: Can self.allOfficesSelected be replaced with [self.officeOptions allContentSelected]?
        if (self.allOfficesSelected) {
            prefix = kAll;
        }
        else {
            prefix = [NSString stringWithFormat:@"%d", (int)selectedCount];
        }
        label = [NSString stringWithFormat:@"%@ %@", prefix, kSelected];
    }
    [self.officesButton setTitle:label forState:UIControlStateNormal];
}

- (void)updateDomainButtonText {
    [self.domainsButton setTitle:self.reportDepth forState:UIControlStateNormal];
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

- (BOOL)allOfficesSelected {
    
    return [self.officeList count] == [self.selectedOfficeDictionary count];
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
    NSDictionary *offices = self.allOfficesSelected?nil:self.selectedOfficeDictionary;
    
    BOOL parametersChanged;
    if (parameterCheck) {
        parametersChanged = !((self.previousStartDate == startDate) || [self.previousStartDate isEqualToDate:startDate]) || !((self.previousEndDate == endDate) || [self.previousEndDate isEqualToDate:endDate]) || !((self.previousProducts == products) || [self.previousProducts isEqualToDictionary:products]) || !((self.previousOffices == offices) || [self.previousOffices isEqualToDictionary:offices]) || !((self.previousDomain == self.reportDepth) || [self.previousDomain isEqualToString:self.reportDepth]);
    }
    if (!parameterCheck || parametersChanged) {
        if(!pulledToRefresh) {
            self.tableList = nil;
            self.totals = nil;
            [self.tableView reloadData];
            [self.activityIndicator startAnimating];
        }
        // Overview
        [self fetchTechStandingsForDomain:self.reportDepth startDate:startDate endDate:endDate products:products];
        
        self.previousOffices = offices?[[NSDictionary alloc] initWithDictionary:offices]:nil;
        self.previousProducts = products?[[NSDictionary alloc] initWithDictionary:products]:nil;
        self.previousStartDate = startDate;
        self.previousEndDate = endDate;
        self.previousDomain = self.reportDepth;
    }
}

- (void)fetchTechStandingsForDomain:(NSString *)domain startDate:(NSDate *)startDate endDate:(NSDate *)endDate products:(NSDictionary *)products{
    
    if (domain) {
        [self.salesRabbit fetchSalesStandingsForDomain:[Entity mapEntityNameConversionFromString:domain] startTime:startDate endTime:endDate products:products completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (success) {
                NSDictionary *columnsDefinitions = [result objectForKey:@"definitions"];
                self.columnDefinitionList = [[NSMutableArray alloc] initWithCapacity:columnsDefinitions.count];
                for (int i=0; i<columnsDefinitions.count; i++) {
                    [self.columnDefinitionList addObject:[columnsDefinitions objectForKey:[NSString stringWithFormat:@"%d",i+1]]];
                }
                [self updateColumns];
                [self loadTopLevelEntityResults:[[result objectForKey:@"report"] mutableCopy] ofType:[Entity entityTypeFromString:[Entity mapEntityNameConversionFromString:domain]]];
            }
            else {
                [self connectionFailedWithError:error];
            }
        }];
    }
    else{
        UIAlertView *noDomainAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"There are no levels assigned for this Company's reports. In order to view Standing Reports, please go to Dashboard with an Admin account to change this." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [noDomainAlert show];
    }
}


- (void)loadTopLevelEntityResults:(NSMutableDictionary *)result ofType:(EntityType)entityType {
    
    self.totals = [result objectForKey:kTotals];
    [result removeObjectForKey:kTotals];
    self.tableList = [[NSMutableArray alloc] init];
    [self loadEntityResults:result ofType:entityType toList:self.tableList];
    [self.activityIndicator stopAnimating];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)loadEntityResults:(NSDictionary *)result ofType:(EntityType)entityType toList:(NSMutableArray *)entityList {
    
    for (NSString *entityID in result) {
        //Entity *entity = [[Entity alloc] initWithType:entityType parent:nil dictionary:[result objectForKey:entityID]];
        Entity *entity = [[Entity alloc] initWithType:entityType parent:nil dictionary:[result objectForKey:entityID] definition:self.columnDefinitionList];
        [entityList addObject:entity];
    }
    
    [self sortTableRowsWithColumnIndex:SELECTED_FILTER_INDEX ascending:YES];

}

- (void)updateColumns{
    
    if (self.columnDefinitionList.count > 0) {
        
        self.columnNamesList = [[NSMutableArray alloc] initWithCapacity:self.columnDefinitionList.count];
        
        //Get the Abbreviations
        for (int i=0; i<self.columnDefinitionList.count; i++) {
            [self.columnNamesList addObject:[[self.columnDefinitionList objectAtIndex:i] objectForKey:@"Abbreviation"]];
        }
        
        //Remove all the columns to add new ones
        for (int i=0; i<self.columnButtonList.count; i++) {
            [[self.columnButtonList objectAtIndex:i] removeFromSuperview];
            [[self.columnSortingArrowsLabelsList objectAtIndex:i] removeFromSuperview];
            [[self.columnLabelsList objectAtIndex:i] removeFromSuperview];
        }
        
        [self.columnScrollView removeFromSuperview];
        [self.scrollViewShadow removeFromSuperview];
        
        self.columnButtonList = [[NSMutableArray alloc] initWithCapacity:self.columnNamesList.count];
        self.columnSortingArrowsLabelsList = [[NSMutableArray alloc] initWithCapacity:self.columnNamesList.count];
        self.columnLabelsList = [[NSMutableArray alloc] initWithCapacity:self.columnNamesList.count];
        
        //Set a way to access the Name column
        //self.sortNameButton.tag = self.columnNamesList.count;
        //self.sortNameArrowsLabel.tag = self.columnNamesList.count;
        
        //This means the last columns had more than the new list of columns
        if (SELECTED_FILTER_INDEX > self.columnNamesList.count - 1) {
            SELECTED_FILTER_INDEX = self.columnNamesList.count - 1;
        }
        
        // *********************************** FOR IPAD *****************************************

        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            
            //Set all the constraints
            NAME_COLUMN_WIDTH = kStandingsReportsNameColumnWidthPad;
            COLUMNS_SECTION_WIDTH = self.view.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/self.columnNamesList.count;
            
            //Set all the UI Programtically
            for (int i=0; i<self.columnNamesList.count; i++) {
                UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - (kColumnStatLabelWidthPad + kColumnArrowButtonWidthPad)/2, self.columnsToolbar.frame.origin.y, kColumnStatLabelWidthPad, self.columnsToolbar.frame.size.height)];
                UILabel *newArrowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x+kColumnStatLabelWidthPad, self.columnsToolbar.frame.origin.y, kColumnArrowButtonWidthPad, self.columnsToolbar.frame.size.height)];
                UIButton *newButton = [[UIButton alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x, newLabel.frame.origin.y, newLabel.frame.size.width+newArrowsLabel.frame.size.width, newLabel.frame.size.height)];
                newArrowsLabel.numberOfLines = 2;
                if (SELECTED_FILTER_INDEX == i){
                    [newArrowsLabel setText:@"△\n▼"];
                }
                else {
                    [newArrowsLabel setText:@"△\n▽"];
                }
                [newArrowsLabel setTextColor:[UIColor whiteColor]];
                [newArrowsLabel setFont:[newArrowsLabel.font fontWithSize:10]];
                newArrowsLabel.tag = i;
                [newLabel setText:[self.columnNamesList objectAtIndex:i]];
                [newLabel setTextColor:[UIColor whiteColor]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:15]];
                newButton.tag = i;
                [newButton addTarget:self action:@selector(sortingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                newButton.showsTouchWhenHighlighted = YES;
                [self.view addSubview:newLabel];
                [self.view addSubview:newArrowsLabel];
                [self.view addSubview:newButton];
                [self.columnButtonList addObject:newButton];
                [self.columnSortingArrowsLabelsList addObject:newArrowsLabel];
                [self.columnLabelsList addObject:newLabel];
                
            }
        }
        else{ //************************** FOR IPHONE ***************************************
            
            
            //Set all the constraints
            NAME_COLUMN_WIDTH = kStandingsReportsNameColumnWidthPhone;
            
            COLUMNS_SECTION_WIDTH = self.view.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/self.columnNamesList.count;
            
            //Set a ScrollView in case they are not going to fit
            if (self.columnNamesList.count > kColumnsPerPagePhone) {
                self.columnScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(NAME_COLUMN_WIDTH, self.columnsToolbar.frame.origin.y, COLUMNS_SECTION_WIDTH , self.columnsToolbar.frame.size.height)];
                self.columnScrollView.contentSize = CGSizeMake(self.columnNamesList.count*(kColumnStatLabelWidthPhone+kColumnArrowButtonWidthPhone), self.columnsToolbar.frame.size.height);
                self.columnScrollView.delegate = self;
                self.columnScrollView.showsHorizontalScrollIndicator = NO;
                
                self.scrollViewShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.columnsToolbar.frame.origin.y, NAME_COLUMN_WIDTH, self.columnsToolbar.frame.size.height)];
                self.scrollViewShadow.layer.shadowOffset = CGSizeMake(7, 0);
                self.scrollViewShadow.layer.shadowRadius = 2;
                self.scrollViewShadow.layer.shadowOpacity = .4;
                self.scrollViewShadow.backgroundColor = self.columnsToolbar.backgroundColor;

                [self.view addSubview:self.columnScrollView];
                [self.view insertSubview:self.scrollViewShadow aboveSubview:self.columnsToolbar];
                
                COLUMN_DIVISION_WIDTH = self.columnScrollView.contentSize.width/self.columnNamesList.count;
            }
            
            
            //Set all the UI Programtically
            for (int i=0; i<self.columnNamesList.count; i++) {
                UILabel *newLabel;
                UILabel *newArrowsLabel;
                UIButton *newButton;
                //Set Up UI Depending if there is a need for a ScrollView or Not
                if (self.columnNamesList.count > kColumnsPerPagePhone) {
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - (kColumnStatLabelWidthPhone + kColumnArrowButtonWidthPhone)/2, 0, kColumnStatLabelWidthPhone, self.columnScrollView.contentSize.height)];
                    newArrowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x+kColumnStatLabelWidthPhone, 0, kColumnArrowButtonWidthPhone, self.columnScrollView.contentSize.height)];
                    newButton = [[UIButton alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x, newLabel.frame.origin.y, newLabel.frame.size.width+newArrowsLabel.frame.size.width, newLabel.frame.size.height)];
                    [self.columnScrollView addSubview:newLabel];
                    [self.columnScrollView addSubview:newArrowsLabel];
                    [self.columnScrollView addSubview:newButton];
                }
                else{
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - (kColumnStatLabelWidthPhone + kColumnArrowButtonWidthPhone)/2, self.columnsToolbar.frame.origin.y, kColumnStatLabelWidthPhone, self.columnsToolbar.frame.size.height)];
                    newArrowsLabel = [[UILabel alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x+kColumnStatLabelWidthPhone, self.columnsToolbar.frame.origin.y, kColumnArrowButtonWidthPhone, self.columnsToolbar.frame.size.height)];
                    newButton = [[UIButton alloc] initWithFrame:CGRectMake(newLabel.frame.origin.x, newLabel.frame.origin.y, newLabel.frame.size.width+newArrowsLabel.frame.size.width, newLabel.frame.size.height)];
                    [self.view addSubview:newLabel];
                    [self.view addSubview:newArrowsLabel];
                    [self.view addSubview:newButton];
                }
                
                newArrowsLabel.numberOfLines = 2;
                if (SELECTED_FILTER_INDEX == i){
                    [newArrowsLabel setText:@"△\n▼"];
                }
                else {
                    [newArrowsLabel setText:@"△\n▽"];
                }
                [newArrowsLabel setTextColor:[UIColor whiteColor]];
                [newArrowsLabel setFont:[newArrowsLabel.font fontWithSize:7]];
                newArrowsLabel.tag = i;
                [newLabel setText:[self.columnNamesList objectAtIndex:i]];
                [newLabel setTextColor:[UIColor whiteColor]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:10]];
                newButton.tag = i;
                [newButton addTarget:self action:@selector(sortingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                newButton.showsTouchWhenHighlighted = YES;
                
                [self.columnButtonList addObject:newButton];
                [self.columnSortingArrowsLabelsList addObject:newArrowsLabel];
                [self.columnLabelsList addObject:newLabel];
            }
        }
    }
}

- (void)sortTableRowsWithColumnIndex:(NSInteger)index ascending:(BOOL)ascending{
    //If the Name column was selected
    if (index < 0) {
        [self.tableList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"entityName" ascending:ascending]]];
    }
    else{
        //Sort by the Selected Index, the Key is the statList on the entity objects
        [self.tableList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"statsList" ascending:ascending comparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSMutableArray *statList1 = (NSMutableArray *)obj1;
            NSMutableArray *statList2 = (NSMutableArray *)obj2;
            
            if (statList1 && statList2 && (statList1.count == self.columnNamesList.count) && statList2.count == self.columnNamesList.count) {
                if ([[statList1 objectAtIndex:index] isKindOfClass:[NSNull class]] || [[statList2 objectAtIndex:index] isKindOfClass:[NSNull class]]) {
                    return NSOrderedSame;
                }
                else if ([[statList1 objectAtIndex:index] floatValue] > [[statList2 objectAtIndex:index] floatValue]) {
                    return NSOrderedAscending;
                }
                else if ([[statList1 objectAtIndex:index] floatValue] < [[statList2 objectAtIndex:index] floatValue]){
                    return NSOrderedDescending;
                }
                else{
                    return NSOrderedSame;
                }
            }
            else{
                return NSOrderedSame;
            }
            
            
            
        }]]];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Make sure there is not a pending update from previous selection
    
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TechStandingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TechStandingCell"];
    [cell updateLabelsWithEntity:[self.tableList objectAtIndex:indexPath.row] row:indexPath.row columnDefinitons:self.columnDefinitionList];
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && self.columnDefinitionList.count > kColumnsPerPagePhone && cell.columnsScrollView) {
        [self.cellScrollViewList addObject:cell.columnsScrollView];
        cell.columnsScrollView.delegate = self;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.tableList count];
}



#pragma mark- Action Sheet and PopOver

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
    else if(button == self.officesButton) return self.officeOptions;
    else if(button == self.toDateButton) return self.toDatePicker;
    else if(button == self.fromDateButton) return self.fromDatePicker;
    else if(button == self.quickDateButton) return self.quickDateList;
    else if(button == self.domainsButton) return self.domainOptions;
    return nil;
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    // When This happens look for all the scrollviews within every table view cell and shift the content offset
    if (scrollView != self.tableView) {
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
            {
                TechStandingCell *cell = (TechStandingCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                [cell.columnsScrollView setContentOffset:scrollView.contentOffset];
            }
        }
        [self.columnScrollView setContentOffset:scrollView.contentOffset];
    }
}


@end
