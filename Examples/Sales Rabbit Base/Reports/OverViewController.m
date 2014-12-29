//
//  OverViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 3/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "OverViewController.h"
#import "AppDelegate.h"
#import "OverviewCell.h"
#import "TotalsCell.h"
#import "SRProduct.h"
#import "Constants.h"
#import "Entity.h"

@interface OverViewController ()
{
    NSUInteger NAME_COLUMN_WIDTH;
    NSUInteger COLUMN_DIVISION_WIDTH;
    NSUInteger COLUMNS_SECTION_WIDTH;
}


@property (strong, nonatomic) SRServiceCalls *salesRabbit;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) NSMutableArray *tableList;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) NSString *deviceModel;
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
@property (strong, nonatomic) NSDictionary *totals;
@property (strong, nonatomic) NSMutableDictionary *accountsDictionary;
@property (weak, nonatomic) Entity *currentEntity;


//Reports columns
@property (strong, nonatomic) NSMutableArray *columnNamesList;
@property (strong, nonatomic) NSMutableArray *columnLabelsList;
@property (strong, nonatomic) NSMutableArray *columnDefinitionList;
@property (strong, nonatomic) UIScrollView *columnScrollView;
@property (strong, nonatomic) NSMutableArray *cellScrollViewList;
@property (strong, nonatomic) UIScrollView *totalsScrollView;
@property (strong, nonatomic) UIView *scrollViewShadow;


@end

@implementation OverViewController

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    [self updateColumns];
    [self.tableView reloadData];
    
}

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
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"M/d/yyyy"];
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"h:mm a"];
    
    
    //Set up filter UI
    
    if (!kReportProducts) {
        
        NSUInteger FILTER_DIVISION_WIDTH = self.view.frame.size.width/3;
        
        self.productsButton.hidden = YES;
        self.productsLabel.hidden = YES;
        self.productsBtnIndicator.hidden = YES;
        
        self.fromDateButton.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.fromDateButton.frame.size.width/2 , self.fromDateButton.frame.origin.y, self.fromDateButton.frame.size.width, self.fromDateButton.frame.size.height);
        self.fromDateLabel.frame = CGRectMake((FILTER_DIVISION_WIDTH)/2 - self.fromDateLabel.frame.size.width/2 , self.fromDateLabel.frame.origin.y, self.fromDateLabel.frame.size.width, self.fromDateLabel.frame.size.height);
        
        self.toDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.toDateButton.frame.size.width/2 , self.toDateButton.frame.origin.y, self.toDateButton.frame.size.width, self.toDateButton.frame.size.height);
        self.toDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*2 - FILTER_DIVISION_WIDTH/2 - self.toDateLabel.frame.size.width/2 , self.toDateLabel.frame.origin.y, self.toDateLabel.frame.size.width, self.toDateLabel.frame.size.height);
        
        self.quickDateButton.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.quickDateButton.frame.size.width/2 , self.quickDateButton.frame.origin.y, self.quickDateButton.frame.size.width, self.quickDateButton.frame.size.height);
        self.quickDateLabel.frame = CGRectMake(FILTER_DIVISION_WIDTH*3 - FILTER_DIVISION_WIDTH/2 - self.quickDateLabel.frame.size.width/2 , self.quickDateLabel.frame.origin.y, self.quickDateLabel.frame.size.width, self.quickDateLabel.frame.size.height);
        
    }
    
    // Filters setup
    // TODO: Finish the products button
    
    self.fromDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.fromDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    [self.fromDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    self.toDatePicker = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.toDateButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:[NSDate date] maximumDate:nil];
    [self.toDateButton setTitle:[self.dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    
    [self.filterOnDateList selectItem:@"Appointment Date"];
    self.quickDateList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.quickDateButton contentList:kReportsQuickDates noSelectionTitle:kCustom];
    [self.quickDateList selectItem:kToday];
    
    // Tap Recognizer for dismissing popovers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [_productsIndicator setHidesWhenStopped:YES];
    
    self.userID = [[SRGlobalState singleton] userId];
    
    [self getDataFromWebService];
    if (kReportProducts) {
        [self.view bringSubviewToFront:self.productsBtnIndicator];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPull) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tag = 99;
    [self.tableView addSubview:self.refreshControl];
    
    UIView *footer = [[UIView alloc] init];
    [self.tableView setTableFooterView:footer];
    //[self rotateLabels];
}

- (void)viewDidAppear:(BOOL)animated {
    
}
- (void)rotateLabels {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGAffineTransform rotateLabel = CGAffineTransformMakeRotation(-70.0);
        [self.installsLabel setTransform:rotateLabel];
        [self.salesLabel setTransform:rotateLabel];
        [self.pendingLabel setTransform:rotateLabel];
        [self.notScheduledLabel setTransform:rotateLabel];
        [self.cancelledLabel setTransform:rotateLabel];
        [self.chargeBackLabel setTransform:rotateLabel];
    }
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
    
    [self.productsIndicator stopAnimating];
    [self.productsBtnIndicator stopAnimating];
    [self.refreshControl endRefreshing];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[SRGlobalState singleton] setAlertViewActive:NO];
}


#pragma mark - Initialization Methods

- (void)getDataFromWebService {
    
    [self.productsIndicator startAnimating];
    if (kReportProducts) {
        [self.productsBtnIndicator startAnimating];
    }
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

- (void)refreshPull {
    
    [self startNewReportOnlyIfParametersChanged:NO refreshDataForPullDown:YES];
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

- (IBAction)filterButtonPressed:(UIButton *)sender {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:[self popoverForButton:sender]];
    }
    else {
        if (sender == self.toDateButton || sender == self.fromDateButton) {
            if (self.toDate == nil || self.fromDate == nil) {
                [self.quickDateList selectItem:kToday];
            }
        }
        [self createPopover:sender popoverView:[self popoverForButton:sender]];
    }
}

#pragma mark - IBAction Methods

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
        //[self updateOfficeButtonText];
    }
}

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    if (sender == self.quickDateList){
        [self setQuickDate:selection];
    }
    [self dismissAll:YES];
}

- (void)setFilterDateTypeAs:(NSString *) type {
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

- (BOOL)allOfficesSelected {
    
    return [self.officeList count] == [self.selectedOfficeDictionary count];
}

- (BOOL)allProductsSelected {
    
    return [self.productList count] == [self.selectedProductDictionary count];
}

- (void)startNewReportOnlyIfParametersChanged:(BOOL)parameterCheck refreshDataForPullDown:(BOOL)pulledToRefresh{
    
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
        parametersChanged = !((self.previousStartDate == startDate) || [self.previousStartDate isEqualToDate:startDate]) || !((self.previousEndDate == endDate) || [self.previousEndDate isEqualToDate:endDate]) || !((self.previousProducts == products) || [self.previousProducts isEqualToDictionary:products]) || !((self.previousOffices == offices) || [self.previousOffices isEqualToDictionary:offices]);
    }
    if (!parameterCheck || parametersChanged) {
        if(!pulledToRefresh) {
            self.tableList = nil;
            self.totals = nil;
            [self.tableView reloadData];
            [self.productsIndicator startAnimating];
        }
        
        if (self.reportDepth) {
            [self fetchTechStandingsForDepth:self.reportDepth startDate:startDate endDate:endDate products:products];
        }
        
        self.previousOffices = offices?[[NSDictionary alloc] initWithDictionary:offices]:nil;
        self.previousProducts = products?[[NSDictionary alloc] initWithDictionary:products]:nil;
        self.previousStartDate = startDate;
        self.previousEndDate = endDate;
    }
}

- (void)fetchTechStandingsForDepth:(NSString *)depth startDate:(NSDate *)startDate endDate:(NSDate *)endDate products:(NSDictionary *)products {
    
    [self.salesRabbit fetchSalesOverviewForDepth:depth entity:nil startTime:startDate endTime:endDate products:products totals:YES completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            NSDictionary *columnsDefinitions = [result objectForKey:@"definitions"];
            self.columnDefinitionList = [[NSMutableArray alloc] initWithCapacity:columnsDefinitions.count];
            for (int i=0; i<columnsDefinitions.count; i++) {
                [self.columnDefinitionList addObject:[columnsDefinitions objectForKey:[NSString stringWithFormat:@"%d",i+1]]];
            }
            [self updateColumns];
            
            [self loadTopLevelEntityResults:[[result objectForKey:@"report"] mutableCopy] ofType:[Entity entityTypeFromString:depth]];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}


- (void)loadTopLevelEntityResults:(NSMutableDictionary *)result ofType:(EntityType)entityType {
    
    self.totals = [result objectForKey:kTotals];
    [result removeObjectForKey:kTotals];
    self.tableList = [[NSMutableArray alloc] init];
    [self loadEntityResults:result ofType:entityType toList:self.tableList];
    [self.productsIndicator stopAnimating];
    
    if([self.refreshControl isRefreshing]) {
        UIRefreshControl *refcont = (UIRefreshControl *)[self.tableView viewWithTag:99];
        [refcont endRefreshing];
        //[self.refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
    
}

- (void)loadEntityResults:(NSDictionary *)result ofType:(EntityType)entityType toList:(NSMutableArray *)entityList {
    
    for (NSString *entityID in result) {
        //Entity *entity = [[Entity alloc] initWithType:entityType parent:nil dictionary:[result objectForKey:entityID]];
        Entity *entity = [[Entity alloc] initWithType:entityType parent:self.currentEntity dictionary:[result objectForKey:entityID] definition:self.columnDefinitionList];
        [entityList addObject:entity];
    }
    
    [entityList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"installs" ascending:NO]]];
}



- (void)updateColumns{
    
    if (self.columnDefinitionList.count > 0) {
        
        self.columnNamesList = [[NSMutableArray alloc] initWithCapacity:self.columnDefinitionList.count];
        
        //Get the Abbreviations
        for (int i=0; i<self.columnDefinitionList.count; i++) {
            [self.columnNamesList addObject:[[self.columnDefinitionList objectAtIndex:i] objectForKey:@"Abbreviation"]];
        }
        
        //Remove all the columns to add new ones
        for (int i=0; i<self.columnLabelsList.count; i++) {
            [[self.columnLabelsList objectAtIndex:i] removeFromSuperview];
        }
        
        [self.columnScrollView removeFromSuperview];
        [self.scrollViewShadow removeFromSuperview];
        
        self.columnLabelsList = [[NSMutableArray alloc] initWithCapacity:self.columnNamesList.count];
        
        //Set a way to access the Name column
        //    self.sortNameButton.tag = self.columnNamesList.count;
        //    self.sortNameArrowsLabel.tag = self.columnNamesList.count;
        
        // *********************************** FOR IPAD *****************************************
        
        
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            
            //Set all the constraints
            NAME_COLUMN_WIDTH = kOverviewReportsNameColumnWidthPad;
            COLUMNS_SECTION_WIDTH = self.view.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/self.columnNamesList.count;
            
            //Set all the UI Programtically
            for (int i=0; i<self.columnNamesList.count; i++) {
                UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPad/2, self.columnsToolbar.frame.origin.y, kColumnStatLabelWidthPad, self.columnsToolbar.frame.size.height)];
                [newLabel setText:[self.columnNamesList objectAtIndex:i]];
                [newLabel setTextColor:[UIColor whiteColor]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:15]];
                [self.view addSubview:newLabel];
                [self.columnLabelsList addObject:newLabel];
            }
        }
        else{ //************************** FOR IPHONE ***************************************
            
            
            //Set all the constraints
            NAME_COLUMN_WIDTH = kOverviewReportsNameColumnWidthPhone;
            
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
                //Set Up UI Depending if there is a need for a ScrollView or Not
                if (self.columnNamesList.count > kColumnsPerPagePhone) {
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, 0, kColumnStatLabelWidthPhone, self.columnScrollView.contentSize.height)];
                    [self.columnScrollView addSubview:newLabel];
                }
                else{
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, self.columnsToolbar.frame.origin.y, kColumnStatLabelWidthPhone, self.columnsToolbar.frame.size.height)];
                    [self.view addSubview:newLabel];
                }
                
                [newLabel setText:[self.columnNamesList objectAtIndex:i]];
                [newLabel setTextColor:[UIColor whiteColor]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:10]];
                
                [self.columnLabelsList addObject:newLabel];
            }
            
        }
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Entity *selectedEntity = [self.tableList objectAtIndex:indexPath.row];
    
    // Make sure there is not a pending update from previous selection
    if (!self.currentEntity && selectedEntity.entityType != EntityUser) {
        if (!selectedEntity.expanded) {
            [self expandEntity:selectedEntity index:indexPath.row];
        }
        else {
            [self collapseEntity:selectedEntity index:indexPath.row];
            
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger depth = 0;
    if ([self.reportDepth isEqualToString:kOffice]) {
        depth = 1;
    }
    else if ([self.reportDepth isEqualToString:kManager]) {
        depth = 2;
    }
    NSInteger indentation;
    switch ([[self.tableList objectAtIndex:indexPath.row] hierarchyEntityType]) {
        case EntityArea:
            indentation = 0;
            break;
        case EntityOffice:
            indentation = 1;
            break;
        case EntityManager:
            indentation = 2;
            break;
        case EntityUser:
            indentation = 3;
            break;
        default:
            break;
    }
    NSAssert(indentation - depth >= 0, @"Indentation should not be negative");
    return indentation - depth;
}

#define kCellHeight 44

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (self.totals) {
        TotalsCell *footer = [tableView dequeueReusableCellWithIdentifier:@"TotalsCell"];
        [footer.contentView setFrame:CGRectMake(0, 0, self.view.frame.size.width, kCellHeight)];
        [footer updateLabelsWithTotals:self.totals definitionList:self.columnDefinitionList];
        if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && self.columnDefinitionList.count > kColumnsPerPagePhone) {
            [self.cellScrollViewList addObject:footer.columnsScrollView];
            footer.columnsScrollView.delegate = self;
            self.totalsScrollView = footer.columnsScrollView;
        }
        return footer.contentView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (self.totals) {
        return kCellHeight;
    }
    return 0;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OverviewCell"];
    [cell.contentView setFrame:CGRectMake(0, 0, self.view.frame.size.width, kCellHeight)];
    [cell updateLabelsWithEntity:[self.tableList objectAtIndex:indexPath.row] row:indexPath.row columnDefinitons:self.columnDefinitionList];
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && self.columnDefinitionList.count > kColumnsPerPagePhone) {
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

- (void)insertNewRows {
    
    NSUInteger numInsert = [self.currentEntity.children count];
    NSUInteger startIndex = [self.tableList indexOfObject:self.currentEntity] + 1;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, numInsert)];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:numInsert];
    for (NSUInteger i = 0; i < numInsert; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex + i inSection:0]];
    }
    [self.tableList insertObjects:self.currentEntity.children atIndexes:indexes];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    self.currentEntity = nil;
}

- (void)expandEntity:(Entity *)entity index:(NSUInteger)row {
    
    entity.expanded = YES;
    OverviewCell *selectedCell = (OverviewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    selectedCell.expanded = YES;
    self.currentEntity = entity;
    if (![entity.children count]) {
        [selectedCell startActivityIndicator];
        switch (self.currentEntity.hierarchyEntityType) {
            case EntityArea:
                [self expandArea];
                break;
            case EntityOffice:
                [self expandOffice];
                break;
            case EntityManager:
                [self expandManager];
                break;
            default:
                break;
        }
    }
    else {
        [self insertNewRows];
    }
}

- (void)expandArea {
    
    //[self.salesRabbit officesSalesReportForEntity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
    [self.salesRabbit fetchSalesOverviewForDepth:kOffice entity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            //[self loadTopLevelEntityResults:[[result objectForKey:@"report"] mutableCopy] ofType:[Entity entityTypeFromString:depth]];
            [self loadEntityResults:[result objectForKey:@"report"] ofType:EntityOffice toList:self.currentEntity.children];
            [self stopCurrentRowActivityIndicator];
            [self insertNewRows];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)expandOffice {
    
    //[self.salesRabbit managersSalesReportForEntity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
    [self.salesRabbit fetchSalesOverviewForDepth:kManager entity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            [self loadEntityResults:[result objectForKey:@"report"] ofType:EntityManager toList:self.currentEntity.children];
            [self stopCurrentRowActivityIndicator];
            [self insertNewRows];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)expandManager {
    
    //[self.salesRabbit usersSalesReportForEntity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
    [self.salesRabbit fetchSalesOverviewForDepth:kUser entity:self.currentEntity startTime:self.previousStartDate endTime:self.previousEndDate products:self.previousProducts totals:NO completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            [self loadEntityResults:[result objectForKey:@"report"] ofType:EntityUser toList:self.currentEntity.children];
            [self stopCurrentRowActivityIndicator];
            [self insertNewRows];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)collapseEntity:(Entity *)entity index:(NSUInteger)row {
    
    NSUInteger numRemove = [entity.children count];
    NSUInteger startIndex = row + 1;
    for (NSUInteger i = 0; i < numRemove; i++) {
        Entity *childEntity = [entity.children objectAtIndex:i];
        if (childEntity.expanded) {
            [self collapseEntity:childEntity index:startIndex + i];
        }
    }
    entity.expanded = NO;
    OverviewCell *selectedCell = (OverviewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    selectedCell.expanded = NO;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startIndex, numRemove)];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:numRemove];
    for (NSUInteger i = 0; i < numRemove; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startIndex + i inSection:0]];
    }
    [self.tableList removeObjectsAtIndexes:indexes];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

- (void)stopCurrentRowActivityIndicator {
    
    NSUInteger activeIndex = [self.tableList indexOfObject:self.currentEntity];
    OverviewCell *activeCell = (OverviewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:activeIndex inSection:0]];
    [activeCell stopActivityIndicator];
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
    [self startNewReportOnlyIfParametersChanged:YES refreshDataForPullDown:NO];
}

- (UIViewController *)popoverForButton:(UIButton *)button {
    
    if (button == self.productsButton) return self.productOptions;
    else if (button == self.toDateButton) return self.toDatePicker;
    else if (button == self.fromDateButton) return self.fromDatePicker;
    else if (button == self.quickDateButton) return self.quickDateList;
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
                OverviewCell *cell = (OverviewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                [cell.columnsScrollView setContentOffset:scrollView.contentOffset];
            }
        }
        [self.columnScrollView setContentOffset:scrollView.contentOffset];
        [self.totalsScrollView setContentOffset:scrollView.contentOffset];
    }
}


@end
