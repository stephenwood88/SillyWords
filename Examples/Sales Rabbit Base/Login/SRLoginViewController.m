//
//  SRLoginViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 2/15/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SRLoginViewController.h"
#import "Constants.h"
#import "SRServiceCalls.h"
#import "AppDelegate.h"
#import "SRGlobalState.h"

//Use this define to set frames for views
#define TAG_RECT( tag, x, y, width, height ) \
[NSValue valueWithCGRect:CGRectMake(x, y, width, height)], \
[NSNumber numberWithInteger:tag]

@interface SRLoginViewController ()

//Frames for different orientations
@property (nonatomic, strong) NSDictionary *portraitFrames;
@property (nonatomic, strong) NSDictionary *landscapeFrames;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) UIColor *lastAccentColor;

@end

@implementation SRLoginViewController

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
    
    // Add shadow to buttons
    self.loginButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.loginButton.layer.shadowOpacity = 0.52;
    self.loginButton.layer.shadowRadius = 16;
    self.loginButton.layer.shadowOffset = CGSizeMake(10.45f, 14.66f);
    
    UITapGestureRecognizer *dtapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    dtapGestureRecognize.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dtapGestureRecognize];
    
    [self setupFrames];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUsername = [userDefaults objectForKey:@"lastUsername"];
    if (lastUsername) {
        self.usernameField.text = lastUsername;
    }
    
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    [self.passwordField setEnablesReturnKeyAutomatically:YES];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    // Set the accent color a user last logged in on the device before
    if ([self.userDefaults objectForKey:kLastAccentColorValueRed]) {
        self.lastAccentColor = [UIColor colorWithRed:[[self.userDefaults objectForKey:kLastAccentColorValueRed] floatValue] green:[[self.userDefaults objectForKey:kLastAccentColorValueGreen] floatValue] blue:[[self.userDefaults objectForKey:kLastAccentColorValueBlue] floatValue] alpha:1.0];
        [self setAccentColorAs:self.lastAccentColor];
    }
    
    
    // Test autofill login
    
    //self.usernameField.text = @"brady@appvantagemobile.com";
    //self.passwordField.text = @"apps4sale";
    
    //self.usernameField.text = @"demo@mysalesrabbit.com";
    //self.passwordField.text = @"demo";
    
    //self.usernameField.text = @"satellite@mysalesrabbit.com";
    //self.passwordField.text = @"satellite";
}


-(void)didLoginWithDictionary:(NSDictionary *)result
{
    //this method is to be implemented in child class if custom actions are necessary.
}

//disable login button if there is nothing in text field
- (void)viewWillAppear:(BOOL)animated {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCorrectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    
    if((self.usernameField.text.length == 0) || (self.passwordField.text.length == 0)) {
        [self.loginButton setEnabled:NO];
        
    }
    else {
        [self.loginButton setEnabled:YES];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setCorrectOrientation {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {    
        // Lay out for landscape mode
        [self layoutForFrameSet:self.landscapeFrames];
    }
    else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // Lay out for portrait mode
        [self layoutForFrameSet:self.portraitFrames];
    }
}

#pragma mark - Setup methods

- (void)setupFrames {
    
    // Collect the frame positions for elements in portrait mode
    NSMutableDictionary *portraitPositions = [[NSMutableDictionary alloc] init];
	for (NSInteger i = 1; i <= 10; i++) {
        UIView *view = [self.view viewWithTag:i];
        
        [portraitPositions setObject:[NSValue valueWithCGRect:view.frame] forKey:[NSNumber numberWithInteger:i]];
    }
    self.portraitFrames = [portraitPositions copy];
    
    // Let's build the landscape frame positions dictionary
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        //Set up frames for variables in iPad version
        self.landscapeFrames = [NSDictionary dictionaryWithObjectsAndKeys:
                                TAG_RECT(1, 325, 100, 375, 90),     // Sales Rabbit logo
                                TAG_RECT(2, 325, 574, 375, 90),     // Sales Rabbit logo (bottom)
                                TAG_RECT(3, 387, 289, 250, 30),     // Email UITextField
                                TAG_RECT(4, 387, 343, 250, 30),     // Password UITextField
                                TAG_RECT(5, 452, 390, 120, 60),     // Login button
                                TAG_RECT(6, 494, 403, 37, 37),      // Login activity indicator
                                TAG_RECT(7, 598, 409, 22, 22),      // Info button
                                TAG_RECT(8, 325, 542, 92, 24),      // "Powered by" label
                                TAG_RECT(9, 387, 108, 251, 120),    // Winder Farms logo
                                TAG_RECT(10, 452, 460, 120, 30),    // Forgot password button
                                TAG_RECT(11, 210, 107, 614, 122),    // Living Scriptures logo
                                TAG_RECT(12, 210, 107, 614, 122),    // ElitePay Global logo
                                nil];
    }
}

#pragma mark - Login button

- (IBAction)loginPressed:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    SRServiceCalls *salesRabbit = [SRServiceCalls singleton];
    
    if (self.usernameField.text.length && self.passwordField.text.length) {
        [self.loginIndicator startAnimating];
        self.loginButton.enabled = NO;
        [salesRabbit loginUsername:self.usernameField.text password:self.passwordField.text completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            if (success) {
                //Check that there are at least one user department
                if ([[result objectForKey:@"userDepartments"] count] != 0) {
                    // Add login dictionary to Global State
                    [[SRGlobalState singleton] setLoginInfoDictionary:result];
                    
                    self.logoTimestamp = [NSDate dateWithTimeIntervalSince1970:[[result objectForKey:@"logoTimestamp"] doubleValue]];
                    
                    //needs to be called before handle departments, where last username is reset.
                    [self didLoginWithDictionary:result];
                    
                    [self handleDepartments:[result objectForKey:@"userDepartments"]];
                    self.loginButton.enabled = YES;
                    [self.loginIndicator stopAnimating];
                    [[SRGlobalState singleton] setLoggedIn:YES];
                    
                    // Set accent color for entire app if it has changed and save color in userDefaults as well
                    UIColor *accentColor = [[SRGlobalState singleton] accentColor];
                    if (![accentColor isEqual:self.lastAccentColor]) {
                        [self setAccentColorAs:accentColor];
                        [self.userDefaults setObject:[NSNumber numberWithFloat:[[SRGlobalState singleton] accentColorValueRed]] forKey:kLastAccentColorValueRed];
                        [self.userDefaults setObject:[NSNumber numberWithFloat:[[SRGlobalState singleton] accentColorValueGreen]] forKey:kLastAccentColorValueGreen];
                        [self.userDefaults setObject:[NSNumber numberWithFloat:[[SRGlobalState singleton] accentColorValueBlue]] forKey:kLastAccentColorValueBlue];
                    }
                    
                    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
                    self.passwordField.text = nil;
                }
                else {
                    UIAlertView *noDepartmentsAlert = [[UIAlertView alloc] initWithTitle:kNoDepartmentsTitle
                                                                                 message:kNoDepartmentsMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles: nil];
                    [noDepartmentsAlert show];
                    self.loginButton.enabled = YES;
                    [self.loginIndicator stopAnimating];
                }
                //No Sales Departments
                //You must be assigned to a sales department in order to log in to Sales Rabbit
            }
            else {
                if ([error.localizedFailureReason isEqualToString:@"fail_userpass"]) {
                    [self displayLoginError];
                }
                else if ([error.localizedFailureReason isEqualToString:@"fail_userstatus]"]){
                    [self displayInactiveError];
                }
                else if ([error.localizedFailureReason isEqualToString:@"fail_module"]){
                    [self displayWrongAppError];
                }
                else if([error.localizedDescription rangeOfString:@"offline" options:NSCaseInsensitiveSearch].location != NSNotFound){
                    [self displayConnectionError];
                }
                else if ([error.localizedFailureReason isEqualToString:@"fail_passExpired"]) {
                    [self displayExpirationError];
                }
                else if ([error.localizedFailureReason isEqualToString:@"fail_passPolicy"]) {
                    [self displayMinimumRequirementsError];
                }
                else{
                    [self displayUnknownError:error.localizedDescription];
                }
                self.loginButton.enabled = YES;
                [self.loginIndicator stopAnimating];
            }
        }];
    }
    else {
        [self displayLoginError];
    }
}

- (void)displayLoginError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoginErrorTitle message:kLoginErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayInactiveError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoginInactiveTitle message:kLoginInactiveMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayWrongAppError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kIncorrectModuleTitle message:kIncorrectModuleMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayConnectionError {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kConnectionErrorTitle message:kConnectionErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayExpirationError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kExpirationErrorTitle message:kExpirationErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayMinimumRequirementsError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMinimumRequirementsErrorTitle message:kMinimumRequirementsErrorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

- (void)displayUnknownError:(NSString *)errorMessage {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUnknownErrorTitle message:errorMessage delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
    [alert show];
}

#pragma mark - IBActions

- (IBAction)usernameDone:(id)sender {
    
    [self.passwordField becomeFirstResponder];
}

- (IBAction)passwordDone:(id)sender {
    if (self.usernameField.text.length != 0) {
        [self loginPressed:sender];
    }
}

- (IBAction)infoButtonPressed:(id)sender {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    [[[UIAlertView alloc] initWithTitle:kInfoTitle message:[NSString stringWithFormat:@"%@\n\nv%@", kInfoMessage, version] delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil] show];
}

- (IBAction)twitterPressed:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=sales_rabbit"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=sales_rabbit"]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/sales_rabbit"]];
    }
}

- (IBAction)facebookPressed:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/410538409033954"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/410538409033954"]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/SalesRabbit"]];
    }
}

- (IBAction)googlePressed:(UIButton *)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://plus.google.com/u/0/b/111061798556588396339/111061798556588396339/posts"]];
}

- (IBAction)forgotPasswordPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://dashboard.mysalesrabbit.com/changePass.php"]];
}

- (void)singleTapGestureRecognizer:(id)sender {
    
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

#pragma mark - Departments

- (void)handleDepartments:(NSArray *)userDepartments {

    // Update list of active departments
    NSMutableDictionary *returnedDepartmentsDictionary = [[NSMutableDictionary alloc] init];
    for (NSDictionary *department in userDepartments) {
        NSMutableDictionary *companyIdDict = [[NSMutableDictionary alloc] initWithCapacity:2];
        [companyIdDict setObject:[department objectForKey:@"CompanyCode"] forKey:@"CompanyCode"];
        [companyIdDict setObject:[department objectForKey:@"CompanyTitle"] forKey:@"CompanyTitle"];
        NSString *companyId = [NSString stringWithFormat:@"%@", [department objectForKey:@"CompanyID"]];
        [returnedDepartmentsDictionary setObject:companyIdDict forKey:companyId];
    }
    [[SRGlobalState singleton] setActiveDepartments:returnedDepartmentsDictionary];

    //Update the list of active department titles
    NSArray *departmentIds = [returnedDepartmentsDictionary allKeys];
    NSMutableArray *departmentTitlesList = [[NSMutableArray alloc] init];
    for (NSString *departmentId in departmentIds) {
        [departmentTitlesList addObject:[[returnedDepartmentsDictionary objectForKey:departmentId] objectForKey:@"CompanyTitle"]];
    }

    //Set department to the department that matches CompanyID returned in the login service call
    NSString *lastDepartment = [[SRGlobalState singleton] departmentTitle];

    NSMutableDictionary *userLastDepartmentDictionary = [[self.userDefaults objectForKey:kUserLastDepartmentDictionary] mutableCopy];

    [userLastDepartmentDictionary setObject:lastDepartment forKey:[[SRGlobalState singleton] userId]];
    [self.userDefaults setObject:userLastDepartmentDictionary forKey:kUserLastDepartmentDictionary];
    [self.userDefaults setObject:self.usernameField.text forKey:@"lastUsername"];
    [self.userDefaults synchronize];

    // !!!: Deprecated
    //[[SRServiceCalls singleton] setDepartment:[returnedDepartmentsDictionary objectForKey:lastDepartment]];
}

#pragma mark - Accent Color
- (void)setAccentColorAs:(UIColor *)color {
    [[UINavigationBar appearance] setBarTintColor:color];
    [[UITextField appearance] setTintColor:color];
    [[UITextView appearance] setTintColor:color];
    [[UITabBar appearance] setTintColor:color];
    [[UIButton appearance] setTintColor:color];
    [[UIButton appearance] setTitleColor:color forState:UIControlStateNormal];
    [[UIActivityIndicatorView appearance] setColor:color];
    [[UISwitch appearance] setTintColor:color];
    [[UISwitch appearance] setOnTintColor:color];
    [[UISegmentedControl appearance] setTintColor:color];
    [[UIProgressView appearance] setProgressTintColor:color];
    //NSLog(@"Color: %@", color);
}

#pragma mark - Autorotation orientation

- (void)viewWillLayoutSubviews {
    [self setCorrectOrientation];
}

- (void)layoutForFrameSet:(NSDictionary *)frames {
    for (NSNumber *key in frames.allKeys) {
        [self.view viewWithTag:[key integerValue]].frame = [[frames objectForKey:key] CGRectValue];
    }
}

#pragma mark - TextField action methods

- (IBAction)usernameFieldChanged:(id)sender {
    if (self.usernameField.text.length == 0 || self.passwordField.text.length == 0) {
        [self.loginButton setEnabled:NO];
    }
    else {
        if(self.passwordField.text.length != 0)
            [self.loginButton setEnabled:YES];
    }
}

- (IBAction)passwordFieldChanged:(id)sender {
    if (self.passwordField.text.length == 0 || self.usernameField.text.length == 0) {
        [self.loginButton setEnabled:NO];
    }
    else {
        if(self.usernameField.text.length != 0)
            [self.loginButton setEnabled:YES];
    }
}

#pragma mark- Supported Orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }else{
        return YES;
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

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setCorrectOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setCorrectOrientation];
}

@end
