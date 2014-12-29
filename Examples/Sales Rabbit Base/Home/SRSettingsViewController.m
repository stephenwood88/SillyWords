//
//  SRSettingsViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 4/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Constants.h"

#define REMINDERS_SECTION 0
#define DEPARTMENTS_SECTION 1
#define FEEDBACK_SECTION 2
#define LOGOUT_SECTION 3

//#define CalendarRow 0
#define RemindMeRow 0
#define CalendarRowHeightIphone 65.0
#define RemindMeRowHeightIphone 79.0

@interface SRSettingsViewController () <AVSelectionListDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *salesDepartmentTitles;
@property (strong, nonatomic) NSDictionary *salesDepartmentIds;
@property (strong, nonatomic) AVSelectionListController *remindMeTimeList;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (weak, nonatomic) UIView *popoverView;

@end

@implementation SRSettingsViewController

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
    [self setupDepartments];
    [self setupDictionaries];
    [self addTapRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Methods

- (void)setupDepartments {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.userID = [[SRGlobalState singleton] userId];
    
    NSString *lastDepartmentTitle = [[userDefaults objectForKey:kUserLastDepartmentDictionary] objectForKey:self.userID];
    //sdf
    NSMutableArray *departmentIds = [[[[SRGlobalState singleton] activeDepartments] allKeys] mutableCopy];
    NSMutableArray *salesDepartments = [NSMutableArray array];
    self.salesDepartmentIds = [NSMutableDictionary dictionary];
    for (NSString *departmentId in departmentIds) {
        NSString* departmentTitle = [[[[SRGlobalState singleton] activeDepartments] objectForKey:departmentId] objectForKey:@"CompanyTitle"];
        [salesDepartments addObject:departmentTitle];
        [self.salesDepartmentIds setValue:departmentId forKey:departmentTitle];
    }

    self.salesDepartmentTitles = [salesDepartments sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    // Find current department
	NSInteger row = [self.salesDepartmentTitles indexOfObject:lastDepartmentTitle];
    self.checkedIndexPath = [NSIndexPath indexPathForRow:row inSection:DEPARTMENTS_SECTION];
}

- (void)setupDictionaries {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kUserSettings] || ![[userDefaults objectForKey:kUserSettings] objectForKey:self.userID]) {
        self.settingsDictionary = [[NSMutableDictionary alloc] init];
        self.userSettingsDictionary = [[NSMutableDictionary alloc] init];
        
        [self.userSettingsDictionary setObject:[NSNumber numberWithBool:YES] forKey:kAppointmentsToCal];
        [self.userSettingsDictionary setObject:[NSNumber numberWithBool:YES] forKey:kRemindByDefault];
        [self.userSettingsDictionary setObject:kRemind5Min forKey:kTimeToRemind];
        
        [self.settingsDictionary setObject:self.userSettingsDictionary forKey:self.userID];
        [userDefaults setObject:self.settingsDictionary forKey:kUserSettings];
    }
    else {
        self.settingsDictionary = [[userDefaults objectForKey:kUserSettings] mutableCopy];
        self.userSettingsDictionary = [[self.settingsDictionary objectForKey:self.userID] mutableCopy];
    }
}

- (void)addTapRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - IBActions

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    [self dismissAll];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutPressed:(UIButton *)sender {
        [self dismissViewControllerAnimated:YES completion:^{
            // Dismiss Home view controller to logout
            [self.delegate logout];
        }];
}

- (IBAction)addCalDefaultSwitched:(id)sender {
    UISwitch *calSwitch = (UISwitch *)sender;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self.userSettingsDictionary setObject:[NSNumber numberWithBool:calSwitch.on] forKey:kAppointmentsToCal];
    [self.settingsDictionary setObject:self.userSettingsDictionary forKey:self.userID];
    [userDefaults setObject:self.settingsDictionary forKey:kUserSettings];
    [userDefaults synchronize];
}

- (IBAction)remindMeTimePressed:(id)sender {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self createPopover:sender popoverView:self.remindMeTimeList];
    }
    else {
        [self createActionSheet:sender sheetView:self.remindMeTimeList];
    }

}

- (IBAction)sendFeebackPressed:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail]) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        //NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"];
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:@[@"support@mysalesrabbit.com"]];
        NSString *debugInfo = [NSString stringWithFormat:@"Company ID: %@ \nUser: %@ \nUsername: %@ \nUser Type: %@ \nApp Type: %@ \nApp Version: %@ \nSystem Version: %@ \nModel: %@ \nComments:\n", [SRGlobalState singleton].systemAccountId, [SRGlobalState singleton].userName, [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUsername"], [SRGlobalState singleton].userType, kAppType, version, currentDevice.systemVersion, currentDevice.model];
        [mailViewController setSubject:@"Feedback"];
        [mailViewController setMessageBody:debugInfo isHTML:NO];
        [[mailViewController navigationBar] setTintColor: [UIColor whiteColor]]; //white for buttons in navigation bar
        mailViewController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]; //white for nav title
    
        [self presentViewController: mailViewController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
        }];
    }
    else{
        // Unable to email from device
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kEmailErrorTitle message:kEmailErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UIPopoverController Delegate Methods & others
- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
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
    
    if (self.popover) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)viewWillLayoutSubviews {
    [self setPopoverLocation];
}

#pragma mark - ActionSheet
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

#pragma mark - UITableView Data Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == REMINDERS_SECTION) {
        return 1;
    }
    else if (section == DEPARTMENTS_SECTION) {
        return self.salesDepartmentTitles.count;
    }
    else{
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section == REMINDERS_SECTION) {
        return @"Appointments";
    }
    else if (section == DEPARTMENTS_SECTION) {
        return @"Departments";
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == DEPARTMENTS_SECTION) {
        return 45;
    }
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == DEPARTMENTS_SECTION) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45)];
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //create the uilabel for the text
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2-120, 0, 240, 35)];
        versionLabel.backgroundColor = [UIColor clearColor];
        versionLabel.font = [UIFont systemFontOfSize:12];
        versionLabel.numberOfLines = 2;
        versionLabel.textAlignment = NSTextAlignmentCenter;
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        versionLabel.text = [NSString stringWithFormat:@"v%@", version] ;
        versionLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        //add the label to the view  
        [footerView addSubview:versionLabel];
        return footerView;
    }
    else{
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    if (indexPath.section == REMINDERS_SECTION) {
        
        if (indexPath.row == RemindMeRow) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"remindMeCell"];

            UIButton *remindMeButton = (UIButton *)[cell viewWithTag:2];
            
            self.remindMeTimeList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:remindMeButton contentList:kRemindInMins noSelectionTitle:kRemind5Min];
            
            [self.remindMeTimeList selectItem:[self.userSettingsDictionary objectForKey:kTimeToRemind]];
        }
    }
    else if (indexPath.section == DEPARTMENTS_SECTION) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DepartmentCell"];
        cell.textLabel.text = [self.salesDepartmentTitles objectAtIndex:indexPath.row];
        cell.tag = [[self.salesDepartmentIds objectForKey:cell.textLabel.text] integerValue];
        if([self.checkedIndexPath isEqual:indexPath])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == FEEDBACK_SECTION){
        // Send Feedback button
        cell = [tableView dequeueReusableCellWithIdentifier:@"SendFeedbackCell"];
    }
    else{
        // Logout button
        cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
    }

    
    return cell;
}


#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Uncheck the previous checked row
        if(self.checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        
        // Set new currentDepartment
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userLastDepartmentDictionary = [[userDefaults objectForKey:kUserLastDepartmentDictionary] mutableCopy];
        [userLastDepartmentDictionary setObject:cell.textLabel.text forKey:self.userID];
        [userDefaults setObject:userLastDepartmentDictionary forKey:kUserLastDepartmentDictionary];
        [userDefaults synchronize];
        [self.delegate updateNavBarTitle];

        SRGlobalState *globalState = [SRGlobalState singleton];
        NSMutableDictionary *newLoginInfoDict = [globalState.loginInfoDictionary mutableCopy];
        newLoginInfoDict[@"CompanyID"] = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%ld", (long)cell.tag]];
        globalState.loginInfoDictionary = [newLoginInfoDict copy];
        [[SRServiceCalls singleton] getDomainIncludeDepartment:YES completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {

            SRGlobalState *globalState = [SRGlobalState singleton];
            NSMutableDictionary *newLoginInfoDict = [globalState.loginInfoDictionary mutableCopy];
            newLoginInfoDict[@"CompanyID"] = [NSString stringWithFormat:@"%@", result[@"CompanyID"]];
            newLoginInfoDict[@"OfficeID"] = [NSString stringWithFormat:@"%@",  result[@"OfficeID"]];
            newLoginInfoDict[@"AreaID"] = [NSString stringWithFormat:@"%@", result[@"AreaID"]];
            newLoginInfoDict[@"UserType"] = [NSString stringWithFormat:@"%@",  result[@"UserType"]];
            globalState.loginInfoDictionary = [newLoginInfoDict copy];

        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:kDepartmentChangedNotification object:nil userInfo:nil];

        [[SRSalesServiceCalls singleton] sync];
    }
}

#pragma mark - AVSelectionList Delegate methods
- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection {
    
    NSString *oldReminderTime = [self.userSettingsDictionary objectForKey:kTimeToRemind];
    NSString *newReminderTime = selection;
    
    if(sender == self.remindMeTimeList) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [self.userSettingsDictionary setObject:selection forKey:kTimeToRemind];
        [self.settingsDictionary setObject:self.userSettingsDictionary forKey:self.userID];
        [userDefaults setObject:self.settingsDictionary forKey:kUserSettings];
        [userDefaults synchronize];
    }
    
    //Change all notification times
    int oldReminderSeconds = [kReminderTimeDictionary[oldReminderTime] intValue];
    int newReminderSeconds = [kReminderTimeDictionary[newReminderTime] intValue];
    
    if (oldReminderSeconds == newReminderSeconds) {
        //do nothing if there was no change in the value
    }
    else if (oldReminderSeconds >= 0 && newReminderSeconds >= 0) {
        dispatch_async([[SRGlobalState singleton] appointmentQueue], ^{
            int timeIntervalChange = oldReminderSeconds - newReminderSeconds;
            
            for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                NSDate *fireDate = [notification.fireDate dateByAddingTimeInterval:timeIntervalChange];
                if ([fireDate timeIntervalSinceNow] > 0) {
                    UILocalNotification *newNotification = [notification copy];
                    newNotification.fireDate = fireDate;
                    [[UIApplication sharedApplication] cancelLocalNotification:notification];
                    [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
                }
            }
        });
    }
    //set notification for leads if the reminder was previously set to no reminder
    else if (oldReminderSeconds == -1) {
        
        dispatch_async([[SRGlobalState singleton] appointmentQueue], ^{
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
            NSDate *fireDateCheck = [NSDate dateWithTimeIntervalSinceNow:newReminderSeconds];
            NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"appointmentDate >= %@", fireDateCheck];
            request.predicate = datePredicate;
            NSError *error;
            NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
            if (!error) {
                for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                    BOOL foundMatch = NO;
                    for (Lead *lead in coreDataArray) {
                        if ([lead.leadId isEqualToString:[notification.userInfo objectForKey:kLeadId]]) {
                            foundMatch = YES;
                            [lead scheduleNotification];
                            break;
                        }
                    }
                }
            }
        });
    }
    //if new setting is no reminder, cancel all notifications
    else if (newReminderSeconds == -1) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    [self dismissAll];
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:  (NSError*)error {
    // Maybe handle errors, then dismiss view
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Supported Orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }else{
        return (interfaceOrientation & UIInterfaceOrientationMaskAll);
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

@end
