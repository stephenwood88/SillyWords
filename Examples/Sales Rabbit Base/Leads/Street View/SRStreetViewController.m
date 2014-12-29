//
//  SRStreetViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 7/26/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRStreetViewController.h"
#import "AppDelegate.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "Constants.h"
#import "AVStateNames.h"
#import "SRLeadDetailTableViewController.h"
#import "SRStreetViewCell.h"
#import "SRSalesServiceCalls.h"
#import "AVTextUtilities.h"
#import "AVLocationManager.h"
#import "SRMaterialsState.h"
#import "SRSalesConstants.h"
#import "UIImage+TintColor.h"

#define OddEvenMode 0
#define SequentialMode 1

@interface SRStreetViewController () 

@property (strong, nonatomic) UIAlertView *gpsError;
@property (strong, nonatomic) UIAlertView *connectionError;

@property (weak, nonatomic) Prequal *prequalForHouseNumber;
@property (weak, nonatomic) Prequal *selectedPrequal;

@end

@implementation SRStreetViewController

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
    
    [self disableStatusButtons];
    [self addTapRecognizer];
    [self registerForNotifications];
    [self reverseGeolocatePressed:self.geoLocateButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // To show user the lead that was just edited
    if (self.leadJustEdited) {
        [self.streetTable deselectRowAtIndexPath:[self.streetTable indexPathForSelectedRow] animated:YES];
        self.leadJustEdited = NO;
        self.selectedLead = nil;
        [self fetchLeadsOnStreet];
        [self.streetTable reloadData];
    }
    
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
    
    self.streetSortModeControl.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Methods

- (void)disableStatusButtons {
    self.otherStatusButton.enabled = NO;
    self.goBackStatusButton.enabled = NO;
    self.callbackStatusButton.enabled = NO;
    self.notHomeStatusButton.enabled = NO;
    self.customerStatusButton.enabled = NO;
    self.notInterestedStatusButton.enabled = NO;
}

- (void)enableStatusButtons {
    self.otherStatusButton.enabled = YES;
    self.customerStatusButton.enabled = YES;
    self.goBackStatusButton.enabled = YES;
    self.callbackStatusButton.enabled = YES;
    self.notHomeStatusButton.enabled = YES;
    self.notInterestedStatusButton.enabled = YES;
}

- (void)addTapRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.streetTable addGestureRecognizer:tap];
    
    UITapGestureRecognizer *addViewtap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    tap.delaysTouchesEnded = NO;
    [self.addLeadView addGestureRecognizer:addViewtap];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leadsChanged:)
                                                 name:kLeadsChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(leadsChanged:)
                                                 name:kPrequalsChangedNotification
                                               object:nil];
}

#pragma mark - Lead notification callback

- (void)leadsChanged:(NSNotification *)notification {
    [self fetchLeadsOnStreet];
    [self.streetTable reloadData];
}

#pragma mark - Segue Methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"StreetToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.streetTable indexPathForCell:cell];
        NSArray *dataSourceArray = [self getDataSourceArrayForSection:selectedIndex.section];
        id object = [dataSourceArray objectAtIndex:selectedIndex.row];
        if ([object isKindOfClass:[Lead class]]) {
            Lead *selectedLead = (Lead *)object;
            if ([selectedLead.status isEqualToString:kCustomer] && !([kAppType isEqualToString:kOriginalApp] || [kAppType isEqualToString:kPremiumApp])) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"StreetToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.streetTable indexPathForCell:cell];
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        NSArray *dataSourceArray = [self getDataSourceArrayForSection:selectedIndex.section];
        id object = [dataSourceArray objectAtIndex:selectedIndex.row];
        self.leadJustEdited = YES;
        
        if ([object isKindOfClass:[Prequal class]]) {
            self.houseNumberField.text = [self addressNumberFromString:[(Prequal *)object address1]];
            ldtvc.prequalForNewLead = (Prequal *)object;
            self.prequalForHouseNumber = (Prequal *)object;
        }else{
            self.houseNumberField.text = [self addressNumberFromString:[(Lead *)object person].address.street1];
            ldtvc.leadToEdit = (Lead *)object;
            self.leadForHouseNumber = (Lead *)object;
        }
    }
    else if ([segue.identifier isEqualToString:@"editStreetSegue"]) {
        SREditStreetViewController *editStreetVC = segue.destinationViewController;
        editStreetVC.thoroughfare = self.thoroughfare;
        editStreetVC.locality = self.locality;
        editStreetVC.administrativeArea = self.administrativeArea;
        editStreetVC.postalCode = self.postalCode;
        editStreetVC.delegate = self;
    }
}

- (NSString *)addressNumberFromString:(NSString *)address {
    
    // Return number portion at beginning of address string
    NSInteger i;
    for (i = 0; i < address.length && [self isCharNum:[address characterAtIndex:i]]; i++);
    return [address substringToIndex:i];
}

- (BOOL)isCharNum:(unichar)c {
    
    return c >= '0' && c <= '9';
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.streetSortModeControl.selectedSegmentIndex)
    {
        case OddEvenMode:
            return 2;
            break;
        case SequentialMode:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            if (self.streetSortModeControl.selectedSegmentIndex == SequentialMode) {
                sectionName = nil;
            }
            else{
                sectionName = @"Odd";
            }
            break;
        case 1:
            sectionName = @"Even";
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:section];
    return dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
    id object = [dataSourceArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[Prequal class]]) {
        SRStreetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseStreetCell"];
        
        Prequal *prequal = (Prequal *)object;
        
        // To show the user the lead that was just edited
        if (prequal == self.selectedPrequal) {
            [self.streetTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else if (prequal == self.prequalForHouseNumber) {
            [self.streetTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        NSString *name = @"";
        if (prequal.firstName.length > 0 && prequal.lastName.length > 0) {
            name = [NSString stringWithFormat:@"%@ %@", prequal.firstName, prequal.lastName];
        }
        else if (prequal.firstName.length > 0) {
            name = prequal.firstName;
        }
        else if (prequal.lastName.length > 0) {
            name = prequal.lastName;
        }
        cell.nameLabel.text = name;
        cell.houseNumberLabel.text = [AVLocationManager subThoroughfareFromAddress:prequal.address1];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        if ([prequal getColor]) {
            cell.statusIcon.image = [[UIImage imageNamed:@"prequal_silver.png"] tintedImageWithColor:[prequal getColor]];
            
        }else{
            if ([prequal.creditLevel isEqual:@"HIGH"]){
                cell.statusIcon.image = [UIImage imageNamed:@"prequal_gold.png"];
            }
            else //if ([prequal.positionCertainty isEqual:@"MED"]){
            {
                cell.statusIcon.image = [UIImage imageNamed:@"prequal_silver.png"];
            }
        }
        
        return cell;
    }else{
    
        SRStreetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HouseStreetCell"];
        
        Lead *lead = (Lead *)object;

        // To show the user the lead that was just edited
        if (lead == self.selectedLead) {
            [self.streetTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else if (lead == self.leadForHouseNumber) {
            [self.streetTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }

        NSString *name = @"";
        if (lead.person.firstName.length > 0 && lead.person.lastName.length > 0) {
            name = [NSString stringWithFormat:@"%@ %@", lead.person.firstName, lead.person.lastName];
        }
        else if (lead.person.firstName.length > 0) {
            name = lead.person.firstName;
        }
        else if (lead.person.lastName.length > 0) {
            name = lead.person.lastName;
        }
        cell.nameLabel.text = name;
        cell.houseNumberLabel.text = [AVLocationManager subThoroughfareFromAddress:lead.person.address.street1];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;

        if ([lead.status isEqualToString:kGoBack]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_goback"];
        }
        else if ([lead.status isEqualToString:kCallback]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_callback"];
        }
        else if ([lead.status isEqualToString:kNotHome]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_nothome"];
        }
        else if ([lead.status isEqualToString:kNotInterested]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_notinterested"];
        }
        else if ([lead.status isEqualToString:kOther]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_other"];
        }
        else if ([lead.status isEqualToString:kCustomer]) {
            cell.statusIcon.image = [UIImage imageNamed:@"icon_customer"];
            if (![kAppType isEqualToString:@"original"] && ![kAppType isEqualToString:@"premium"]){
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.userInteractionEnabled = NO;
            }
        }

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
    id object = [dataSourceArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[Prequal class]]) {
        cell.backgroundColor = [UIColor colorWithRed:131.0/255.0 green:137.0/255.0 blue:150.0/255.0 alpha:1];
    }else{
        Lead *lead = (Lead *)object;
        
        NSString *leadStatus = lead.status;
        if ([leadStatus isEqualToString:kNotHome]) {
            cell.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:198.0/255.0 blue:137.0/255.0 alpha:1];
        }
        else if ([leadStatus isEqualToString:kNotInterested]){
            cell.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:150.0/255.0 blue:121.0/255.0 alpha:1];
        }
        else if ([leadStatus isEqualToString:kCallback]){
            cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:247.0/255.0 blue:153.0/255.0 alpha:1];
        }
        else if ([leadStatus isEqualToString:kGoBack]){
            cell.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:223.0/255.0 blue:155.0/255.0 alpha:1];
        }
        else if ([leadStatus isEqualToString:kOther]){
            cell.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:140.0/255.0 blue:191.0/255.0 alpha:1];
        }
        else if ([leadStatus isEqualToString:kCustomer]){
            cell.backgroundColor = [UIColor colorWithRed:109.0/255.0 green:207.0/255.0 blue:246.0/255.0 alpha:1];
        }
    }
}

#pragma mark Editing Tableview (deleting cells)
// To support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
    id object = [dataSourceArray objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[Prequal class]]) {
        return NO;
    }else{
        if ([[(Lead *)object status] isEqualToString:kCustomer]) {
            return NO;
        }
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
    id object = [dataSourceArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[Prequal class]]) {
        //For now you can't delete prequals.
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete the lead from the data source
        NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
        Lead *leadToBeDeleted = [dataSourceArray objectAtIndex:indexPath.row];
        [self.streetLeads removeObject:leadToBeDeleted];
        [self.oddLeads removeObject:leadToBeDeleted];
        [self.evenLeads removeObject:leadToBeDeleted];
        //Delete the lead from Core Data
        [leadToBeDeleted deleteLeadSync:YES];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kDeletedLeads:@[leadToBeDeleted]}];
        [[SRSalesServiceCalls singleton] sync];
    }
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *dataSourceArray = [self getDataSourceArrayForSection:indexPath.section];
    id object = [dataSourceArray objectAtIndex:indexPath.row];
    
    if ([object isKindOfClass:[Prequal class]]) {
        self.selectedLead = nil;
        self.selectedPrequal = (Prequal *)object;
    }else{
        self.selectedLead = (Lead *)object;
        self.selectedPrequal = nil;
    }
    self.leadJustEdited = YES;
}

#pragma mark - IBAction methods

- (IBAction)streetSortModeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case OddEvenMode:
            [self.streetTable reloadData];
            [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
            break;
        case SequentialMode:
            [self.streetTable reloadData];
            [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)reverseGeolocatePressed:(UIButton *)sender {
    sender.enabled = NO;
    self.editStreetButton.enabled = NO;
    [self.geoLocateActivity startAnimating];
    [[AVLocationManager singleton] getCurrentPlacemark:self];
    [self dismissKeyboard];
}

- (IBAction)downOnePressed:(UIButton *)sender {
    [self editHouseNumberBy:-1];
}

- (IBAction)downTwoPressed:(UIButton *)sender {
    [self editHouseNumberBy:-2];
}

- (IBAction)upTwoPressed:(UIButton *)sender {
    [self editHouseNumberBy:2];
}

- (IBAction)upOnePressed:(UIButton *)sender {
    [self editHouseNumberBy:1];
}

- (IBAction)statusButtonPressed:(UIButton *)sender {
    
    [self dismissKeyboard];
    
    //If the current address doesn't exist, create a lead for that address
    if (!self.currentAddressExists) {
        if (sender == self.goBackStatusButton) {
            [self createSalesLeadOfStatus:kGoBack withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.callbackStatusButton){
            [self createSalesLeadOfStatus:kCallback withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.notHomeStatusButton){
            [self createSalesLeadOfStatus:kNotHome withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.notInterestedStatusButton){
            [self createSalesLeadOfStatus:kNotInterested withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.customerStatusButton){
            [self createSalesLeadOfStatus:kCustomer withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.otherStatusButton){
            [self createSalesLeadOfStatus:kOther withHouseNumber:[self.houseNumberField.text integerValue]];
        }
    }
    //If there is a lead at the current address, change the lead status
    else if(self.leadForHouseNumber) {
        // Only one button can be selected at a time
        self.goBackStatusButton.selected = NO;
        self.callbackStatusButton.selected = NO;
        self.notHomeStatusButton.selected = NO;
        self.notInterestedStatusButton.selected = NO;
        self.customerStatusButton.selected = NO;
        self.otherStatusButton.selected = NO;
        
        if (sender == self.goBackStatusButton) {
            self.leadForHouseNumber.status = kGoBack;
            self.goBackStatusButton.selected = YES;
        }
        else if (sender == self.callbackStatusButton){
            self.leadForHouseNumber.status = kCallback;
            self.callbackStatusButton.selected = YES;
        }
        else if (sender == self.notHomeStatusButton){
            self.leadForHouseNumber.status = kNotHome;
            self.notHomeStatusButton.selected = YES;
        }
        else if (sender == self.notInterestedStatusButton){
            self.leadForHouseNumber.status = kNotInterested;
            self.notInterestedStatusButton.selected = YES;
        }
        else if(sender == self.customerStatusButton){
            self.leadForHouseNumber.status = kCustomer;
            self.customerStatusButton.selected = YES;
        }
        else if (sender == self.otherStatusButton){
            self.leadForHouseNumber.status = kOther;
            self.otherStatusButton.selected = YES;
        }
        
        NSIndexPath *selectedIndex = [self.streetTable indexPathForSelectedRow];
        [self.streetTable reloadRowsAtIndexPaths:@[selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.streetTable selectRowAtIndexPath:selectedIndex animated:YES scrollPosition:UITableViewScrollPositionNone];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kUpdatedLeads:@[self.leadForHouseNumber]}];
        [[SRSalesServiceCalls singleton] sync];
    }
    //If there is a prequal at the current address, create the lead
    else if(self.prequalForHouseNumber) {
        // Only one button can be selected at a time
        self.goBackStatusButton.selected = NO;
        self.callbackStatusButton.selected = NO;
        self.notHomeStatusButton.selected = NO;
        self.notInterestedStatusButton.selected = NO;
        self.customerStatusButton.selected = NO;
        self.otherStatusButton.selected = NO;
        
        if (sender == self.goBackStatusButton) {
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kGoBack withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.callbackStatusButton){
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kCallback withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.notHomeStatusButton){
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kNotHome withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.notInterestedStatusButton){
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kNotInterested withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.customerStatusButton){
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kCustomer withHouseNumber:[self.houseNumberField.text integerValue]];
        }
        else if (sender == self.otherStatusButton){
            [self createSalesLeadFromPrequal:self.prequalForHouseNumber ofStatus:kOther withHouseNumber:[self.houseNumberField.text integerValue]];
        }
    }
}

- (IBAction)houseNumberDone:(UITextField *)sender {
    
    [sender resignFirstResponder];
}

#pragma mark  Keyboard

//Methods to move the bottom "add leads" view and shrink the table view to accomodate the keyboard.
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];

    CGSize keyboardSize = [self.view convertRect:[[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:nil].size;
    
    
    // Move bottom view and shrink table view
    CGRect viewFrame = self.addLeadView.frame;
    viewFrame.origin.y += (keyboardSize.height - [[SRMaterialsState singleton] mainTabBar].tabBar.frame.size.height);
    CGRect tableViewFrame = self.streetTable.frame;
    tableViewFrame.size.height += (keyboardSize.height - [[SRMaterialsState singleton] mainTabBar].tabBar.frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.addLeadView setFrame:viewFrame];
    [self.streetTable setFrame:tableViewFrame];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize keyboardSize = [self.view convertRect:[[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] fromView:nil].size;

    
    CGRect viewFrame = self.addLeadView.frame;
    viewFrame.origin.y -= (keyboardSize.height - [[SRMaterialsState singleton] mainTabBar].tabBar.frame.size.height);
    CGRect tableViewFrame = self.streetTable.frame;
    tableViewFrame.size.height -= (keyboardSize.height - [[SRMaterialsState singleton] mainTabBar].tabBar.frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [self.addLeadView setFrame:viewFrame];
    [self.streetTable setFrame:tableViewFrame];
    [UIView commitAnimations];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:NO];
}

#pragma mark - Helper methods

- (void)editHouseNumberBy:(NSInteger)number {
    
    if (number) {
        NSInteger houseNumber = [self.houseNumberField.text integerValue];
        houseNumber = houseNumber + number;
        // Don't allow negative addresses
        if (houseNumber < 0) {
            return;
        }
        self.geoLocateButton.selected = NO;
        self.houseNumberField.text = [NSString stringWithFormat:@"%ld", (long)houseNumber];
        
        //Check for already existing address
        [self selectCellForHouseNumber:houseNumber animated:YES];
    }
}

- (NSMutableArray *)getDataSourceArrayForSection:(NSInteger)section {
    
    if (self.streetSortModeControl.selectedSegmentIndex == SequentialMode) {
        return self.streetLeads;
    }
    else{
        switch (section)
        {
            case 0:
                return self.oddLeads;
                break;
            case 1:
                return self.evenLeads;
                break;
            default:
                return nil;
                break;
        }
    }
}

- (void)selectCellForHouseNumber:(NSInteger) houseNumber animated:(BOOL)animated {
    
    BOOL buttonsWereEnabled = self.goBackStatusButton.enabled;
    NSMutableArray *dataSourceArray;
    NSInteger section;
    
    if (self.streetSortModeControl.selectedSegmentIndex == SequentialMode) {
        dataSourceArray = self.streetLeads;
        section = 0;
    }
    else if (self.streetSortModeControl.selectedSegmentIndex == OddEvenMode) {
        if (houseNumber % 2 == 0) {
            dataSourceArray = self.evenLeads;
            section = 1;
        }
        else {
            dataSourceArray = self.oddLeads;
            section = 0;
        }
    }
    
    self.goBackStatusButton.selected = NO;
    self.callbackStatusButton.selected = NO;
    self.notHomeStatusButton.selected = NO;
    self.notInterestedStatusButton.selected = NO;
    self.customerStatusButton.selected = NO;
    self.otherStatusButton.selected = NO;
    
    int index = 0;
    for (id object in dataSourceArray) {
        NSString *address;
        Lead *lead = nil;
        Prequal *prequal = nil;
        if ([object isKindOfClass:[Lead class]]) {
            lead = (Lead *)object;
            address = lead.person.address.street1;
        }else{
            prequal = (Prequal *)object;
            address = prequal.address1;
        }
        if ([[AVLocationManager subThoroughfareFromAddress:address] integerValue] == houseNumber) {
            
            [[self.streetTable cellForRowAtIndexPath:[self.streetTable indexPathForSelectedRow]] setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            //change selection to blue
            [[self.streetTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]] setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
            if (animated) {
                [self.streetTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
            else {
                [self.streetTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            self.leadForHouseNumber = lead;
            self.prequalForHouseNumber = prequal;
            
            if (lead) {
                if ([lead.status isEqualToString:kGoBack]) {
                    self.goBackStatusButton.selected = YES;
                }
                else if ([lead.status isEqualToString:kCallback]) {
                    self.callbackStatusButton.selected = YES;
                }
                else if ([lead.status isEqualToString:kNotHome]) {
                    self.notHomeStatusButton.selected = YES;
                }
                else if ([lead.status isEqualToString:kNotInterested]) {
                    self.notInterestedStatusButton.selected = YES;
                }
                else if ([lead.status isEqualToString:kCustomer]) {
                    self.customerStatusButton.selected = YES;
                }
                else if ([lead.status isEqualToString:kOther]) {
                    self.otherStatusButton.selected = YES;
                }
            }
            self.currentAddressExists = YES;
            return;
        }
        index++;
    }
    
    //If no matching lead was found deselect cells and enable status buttons
    if (buttonsWereEnabled) {
        [self enableStatusButtons];
    }
    self.leadForHouseNumber = nil;
    [self.streetTable deselectRowAtIndexPath:[self.streetTable indexPathForSelectedRow] animated:NO];
    self.currentAddressExists = NO;
}

#pragma mark - CoreData methods

- (void)fetchLeadsOnStreet {
    
    //For premium apps we should alos check for Prequal Leads
    
    // All required fields for the fetch should be in this if statement
    if (self.locality.length > 0 && self.thoroughfare.length > 0) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
        NSPredicate *userIdPredicate = [NSPredicate predicateWithFormat:@"userId == %@", [[SRGlobalState singleton] userId]];
        NSPredicate *statePredicate = [NSPredicate predicateWithFormat:@"person.address.state ==[c] %@", [AVStateNames getAbbreviationForState:self.administrativeArea forCountry:[SRGlobalState singleton].countryCode]];
        NSPredicate *cityPredicate = [NSPredicate predicateWithFormat:@"person.address.city ==[c] %@", self.locality];
        NSPredicate *streetPredicate = [NSPredicate predicateWithFormat:@"person.address.street1 CONTAINS[c] %@", self.thoroughfare];
        
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:userIdPredicate, statePredicate, cityPredicate, streetPredicate, nil]];
        
        NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
        
        NSError *error = nil;
        NSMutableArray *coreDataArray = [[context executeFetchRequest:request error:&error] mutableCopy];
        if (![kAppType isEqualToString:kOriginalApp]) {
            NSFetchRequest *requestPrequal = [NSFetchRequest fetchRequestWithEntityName:@"Prequal"];
            NSPredicate *userIdPrequalPredicate = [NSPredicate predicateWithFormat:@"userId == %@", [[SRGlobalState singleton] userId]];
            NSPredicate *statePrequalPredicate = [NSPredicate predicateWithFormat:@"state ==[c] %@", [AVStateNames getAbbreviationForState:self.administrativeArea forCountry:[SRGlobalState singleton].countryCode]];
            NSPredicate *cityPrequalPredicate = [NSPredicate predicateWithFormat:@"city ==[c] %@", self.locality];
            NSPredicate *streetPrequalPredicate = [NSPredicate predicateWithFormat:@"address1 CONTAINS[c] %@", self.thoroughfare];
            
            requestPrequal.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:userIdPrequalPredicate, statePrequalPredicate, cityPrequalPredicate, streetPrequalPredicate, nil]];
            
            error = nil;
            [coreDataArray addObjectsFromArray:[[context executeFetchRequest:requestPrequal error:&error] mutableCopy]];
        }
        
        [coreDataArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSComparisonResult comparisonresult;
            
            if ([obj1 isKindOfClass:[Prequal class]] && [obj2 isKindOfClass:[Prequal class]]) {
                Prequal *lead1 = obj1;
                Prequal *lead2 = obj2;
                comparisonresult = [[NSNumber numberWithInt:(int)[lead1.address1 integerValue]] compare:[NSNumber numberWithInt:(int)[lead2.address1 integerValue]]];
                if (comparisonresult == NSOrderedSame) {
                    comparisonresult = [lead1.firstName caseInsensitiveCompare:lead2.firstName];
                }
            }else if ([obj1 isKindOfClass:[Lead class]] && [obj2 isKindOfClass:[Prequal class]]) {
                Lead *lead1 = obj1;
                Prequal *lead2 = obj2;
                comparisonresult = [[NSNumber numberWithInt:(int)[lead1.person.address.street1 integerValue]] compare:[NSNumber numberWithInt:(int)[lead2.address1 integerValue]]];
                if (comparisonresult == NSOrderedSame) {
                    comparisonresult = [lead1.title caseInsensitiveCompare:lead2.firstName];
                }
            }else if ([obj1 isKindOfClass:[Prequal class]] && [obj2 isKindOfClass:[Lead class]]) {
                Prequal *lead1 = obj1;
                Lead *lead2 = obj2;
                comparisonresult = [[NSNumber numberWithInt:(int)[lead1.address1 integerValue]] compare:[NSNumber numberWithInt:(int)[lead2.person.address.street1 integerValue]]];
                if (comparisonresult == NSOrderedSame) {
                    comparisonresult = [lead1.firstName caseInsensitiveCompare:lead2.title];
                }
            }else if ([obj1 isKindOfClass:[Lead class]] && [obj2 isKindOfClass:[Lead class]]) {
                Lead *lead1 = obj1;
                Lead *lead2 = obj2;
                comparisonresult = [[NSNumber numberWithInt:(int)[lead1.person.address.street1 integerValue]] compare:[NSNumber numberWithInt:(int)[lead2.person.address.street1 integerValue]]];
                if (comparisonresult == NSOrderedSame) {
                    comparisonresult = [lead1.title caseInsensitiveCompare:lead2.title];
                }
            }else{
                comparisonresult = NSOrderedSame;
            }
            return comparisonresult;
        }];
        
        self.streetLeads = [coreDataArray mutableCopy];
        
        // Even and Odd datasource arrays
        self.oddLeads = [[NSMutableArray alloc] init];
        self.evenLeads = [[NSMutableArray alloc] init];
        for (id lead in self.streetLeads) {
            NSInteger houseNumber;
            if ([lead isKindOfClass:[Prequal class]]){
                houseNumber = [[AVLocationManager subThoroughfareFromAddress:[(Prequal *)lead address1]] integerValue];
            }else{
                houseNumber = [[AVLocationManager subThoroughfareFromAddress:[(Lead *)lead person].address.street1] integerValue];
            }
            
            if (houseNumber % 2){
                // odd
                [self.oddLeads addObject:lead];
            }
            else {
                // even
                [self.evenLeads addObject:lead];
            }
        }
    }
}

- (void)createSalesLeadOfStatus:(NSString *)status withHouseNumber:(NSInteger)houseNumber {
    
    self.selectedLead = nil;
    self.leadForHouseNumber = nil;
    
    // Creates annotation
    Lead *newLead = [Lead newLead];
    newLead.status = status;
    newLead.saved = @YES;
    newLead.dateCreated = [NSDate date];
    newLead.person.address.state = [AVStateNames getAbbreviationForState:self.administrativeArea forCountry:[SRGlobalState singleton].countryCode];
    newLead.person.address.city = self.locality;
    newLead.person.address.zip = self.postalCode;
    newLead.person.address.street1 = [NSString stringWithFormat:@"%ld %@", (long)houseNumber, self.thoroughfare];
    // Add to tableview list
    //TODO: May be better to insert the lead instead of doing a new fetch
    [self fetchLeadsOnStreet];
    [self.streetTable reloadData];
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
    
    [newLead setCoordinateFromAddressWithCompletionHandler:^(BOOL success, Lead *lead, NSError *error) {
        if (error == nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kUpdatedLeads: @[lead]}];
        }
        [[SRSalesServiceCalls singleton] sync];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads: @[newLead]}];
}

- (void)createSalesLeadFromPrequal:(Prequal *)prequal ofStatus:(NSString *)status withHouseNumber:(NSInteger)houseNumber {
    
    self.selectedLead = nil;
    self.leadForHouseNumber = nil;
    
    // Creates annotation
    Lead *newLead = [Lead newLead];
    newLead.status = status;
    newLead.saved = @YES;
    newLead.dateCreated = [NSDate date];
    newLead.person.address.state = prequal.state ? prequal.state : @"";
    newLead.person.address.city = prequal.city ? prequal.city : @"";
    newLead.person.address.zip = prequal.zipCode ? prequal.zipCode : @"";
    newLead.person.address.street1 = prequal.address1 ? prequal.address1 : @"";
    newLead.person.address.street2 = prequal.address2 ? prequal.address2 : @"";
    newLead.person.firstName = prequal.firstName ? prequal.firstName : @"";
    newLead.person.lastName = prequal.lastName ? prequal.lastName : @"";
    newLead.longitude = prequal.longitude;
    newLead.latitude = prequal.latitude;
    
    [[[SRGlobalState singleton] managedObjectContext] deleteObject:prequal];
    
    // Add to tableview list
    //TODO: May be better to insert the lead instead of doing a new fetch
    [self fetchLeadsOnStreet];
    [self.streetTable reloadData];
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads: @[newLead]}];
}

#pragma mark - GetPlacemarkDelegate methods

- (void)currentPlacemarkFound:(CLPlacemark *)placemark {
    
    self.currentPlacemark = placemark;
    [self setAddressFromPlacemark:placemark];
    // TODO: May want to keep track of previous placemark to see if a new fetch is required
    [self fetchLeadsOnStreet];
    [self.streetTable reloadData];
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
}

- (void)errorFindingPlacemark {
    
    if (!self.connectionError) {
        self.connectionError = [[UIAlertView alloc] initWithTitle:@"Unable to Locate Your Device" message:kConnectionErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [self.connectionError show];
    }
    if (!self.geoLocateButton.enabled) {
        [self.geoLocateActivity stopAnimating];
        self.geoLocateButton.enabled = YES;
        self.editStreetButton.enabled = YES;
    }
}

- (void)setAddressFromPlacemark:(CLPlacemark *)placemark {
        
    if (!self.geoLocateButton.enabled) {
        self.administrativeArea = placemark.administrativeArea;
        self.locality = placemark.locality;
        self.thoroughfare = placemark.thoroughfare;
        self.postalCode = placemark.postalCode;
        self.houseNumberField.text = [self addressNumberFromString:placemark.subThoroughfare];
        self.streetNavBar.topItem.title = placemark.thoroughfare;
        

        self.geoLocateButton.selected = YES;
        [self.geoLocateActivity stopAnimating];
        self.geoLocateButton.enabled = YES;
        self.editStreetButton.enabled = YES;
        [self enableStatusButtons];
    }
}

#pragma mark - Edit Street Delegate

- (void)addressEditedStreet:(NSString *)street city:(NSString *)city state:(NSString *)state zip:(NSString *)zip {
    
    self.geoLocateButton.selected = NO;
    self.thoroughfare = street;
    self.locality = city;
    self.administrativeArea = state;
    self.postalCode = zip;
    self.streetNavBar.topItem.title = street;
    
    self.leadForHouseNumber = nil;
    [self fetchLeadsOnStreet];
    [self.streetTable reloadData];
    [self selectCellForHouseNumber:self.houseNumberField.text.integerValue animated:YES];
    [self enableStatusButtons];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Allow next (done/return) button presses
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    if (textField == self.houseNumberField) {
        if ([AVTextUtilities digitTextField:textField shouldChangeCharactersInRange:range replacementString:string maximumDigits:0]) {
            self.geoLocateButton.selected = NO;
            [self selectCellForHouseNumber:[textField.text integerValue] animated:YES];
        }
        return NO;
    }
    return YES;
}

@end
