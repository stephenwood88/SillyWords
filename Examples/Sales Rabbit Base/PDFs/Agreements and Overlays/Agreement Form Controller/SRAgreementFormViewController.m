 //
//  AgreementFormViewController.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/12/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRAgreementFormViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "SRSavedAgreementsViewController.h"
#import "ServiceCalls.h"
#import "Flurry.h"
#import "Person+Rabbit.h"
#import "Lead+Rabbit.h"
#import "SRSavedAgreementsViewController.h"

@interface SRAgreementFormViewController() <UIActionSheetDelegate>

@property (strong, nonatomic) SRSavedAgreementsViewController *savedAgreementsController;

@end

@implementation SRAgreementFormViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // TODO: Disable submit button when offline, listen for notification to enable/disable?
    //self.navBar.rightBarButtonItem.enabled = NO;
    NSLog(@"test");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout) name:kLogoutNotification object:nil];
    
    self.savedAgreementsController = [[SRSavedAgreementsViewController alloc] initWithDelegate:self];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list"] style:UIBarButtonItemStylePlain target:self action:@selector(listPressed:)];
        self.navBar.leftBarButtonItems = @[self.listButton];
        
        self.usingiPhone = YES;
    }
    else {
        self.listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list"] style:UIBarButtonItemStylePlain target:self action:@selector(listPressed:)];
        self.startNewButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(newPressed:)];
        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePressed:)];
        self.navBar.leftBarButtonItems = @[self.listButton, self.startNewButton, self.saveButton];
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.savedAgreementsController];
        self.usingiPhone = NO;
    }
    if (self.agreementModel) {
        [self setupCurrentAgreement];
    }
    else {
        self.agreementModel = [Agreement newAgreement];
    }
    
    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    //fixes a bug with ios7 rotation to landscape.
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CustomerInfoSegue"]) {
        self.customerInfoController = [segue destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"AgreementSegue"]) {
        self.agreementPdfController = [segue destinationViewController];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self dismissAll:animated];
}

- (void)dismissAll:(BOOL)animated {
    
    if ([self.popover isPopoverVisible]) {
        [self.popover dismissPopoverAnimated:animated];
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
    [self.customerInfoController dismissAll:animated];
    [self.agreementPdfController dismissAll:animated];
}

- (void)onLogout {
    
    if (!self.agreementModel.saved.boolValue) {
        if (self.agreementModel.isStarted) {
            self.agreementModel.saved = @YES;
        }
        else {
            [self.agreementModel deleteAgreement];
        }
    }
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
    
    [self dismissAll:YES];
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.agreementPdf.hidden = YES;
            self.customerInfo.hidden = NO;
            break;
        case 1:
            self.customerInfo.hidden = YES;
            self.agreementPdf.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)listPressed:(id)sender
{
    if (self.usingiPhone) {
        [self createActionSheet:sender sheetView:self.savedAgreementsController];
    }
    else {
        if (!self.popover.isPopoverVisible) {
            [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }
}

- (void)newPressed:(id)sender {
    
    if (!self.startNewConfirmation) {
        [self dismissAll:YES];
        if ([self confirmSaveNeeded]) {
            self.startNewConfirmation = [[UIActionSheet alloc] initWithTitle:kNewConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:nil];
            if (self.usingiPhone) {
                [self.startNewConfirmation showFromTabBar:self.tabBarController.tabBar];
            }else{
                [self.startNewConfirmation showFromBarButtonItem:sender animated:YES];
            }
        }
        else {
            [self agreementSelected:[Agreement newAgreement] savePrevious:NO];
        }
    }
}

- (void)savePressed:(id)sender {
    
    [self dismissAll:YES];
    if (self.agreementModel.isStarted) {
        [self agreementSelected:[Agreement newAgreement] savePrevious:@YES];
    }
}

- (IBAction)submitPressed:(id)sender {
    
    if (!self.submitConfirmation) {
        [self dismissAll:YES];
        self.submitConfirmation = [[UIActionSheet alloc] initWithTitle:kSubmitConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:nil otherButtonTitles:kYes, nil];
        [self.submitConfirmation showFromBarButtonItem:sender animated:YES];
    }
}

- (void)checkAndSubmit {
        //No default implementation
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.startNewConfirmation) {
        self.startNewConfirmation = nil;
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self agreementSelected:[Agreement newAgreement] savePrevious:NO];
        }
    }
    else if (actionSheet == self.submitConfirmation) {
        self.submitConfirmation = nil;
        if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
            [self checkAndSubmit];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.submissionSuccess) {
        self.submissionView.hidden = YES;
        self.submissionSuccess = nil;
    }
    else if (alertView == self.errorAlert) {
        self.submissionView.hidden = YES;
        self.errorAlert = nil;
    }
}

#pragma mark - SavedAgreementsDelegate

- (BOOL)confirmSaveNeeded {
    
    return self.agreementModel.isStarted && ![self.agreementModel.saved boolValue];
}

- (void)agreementSelected:(Agreement *)agreement savePrevious:(BOOL)savePrevious {
    
    if (![self.agreementModel.saved boolValue]) {
        if (savePrevious) {
            self.agreementModel.saved = @YES;
        }
        else {
            [self.agreementModel deleteAgreement];
        }
    }
    if (self.usingiPhone) {
        [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    [self dismissAll:YES];
    self.agreementModel = agreement;
    [self.savedAgreementsController refreshAgreements];
}

- (Agreement *)currentAgreement {
    
    return self.agreementModel;
}

#pragma mark - Custom Accessors

- (void)setAgreementModel:(Agreement *)agreementModel {
    
    _agreementModel = agreementModel;
    [self setupCurrentAgreement];
}

- (void)setupCurrentAgreement {
    
    // Make sure view is loaded first. If agreementModel is set from lead detail view before this view is loaded, need to do this after the view is loaded.
    if (self.isViewLoaded) {
        self.readOnly = [self.agreementModel.submitted boolValue];
        self.customerInfoController.agreementModel = self.agreementModel;
        self.agreementPdfController.agreementModel = self.agreementModel;
        if (!self.usingiPhone) {
            if ([self.agreementModel.saved boolValue]) {
                self.navBar.leftBarButtonItems = @[self.listButton, self.startNewButton];
            }
            else {
                self.navBar.leftBarButtonItems = @[self.listButton, self.startNewButton, self.saveButton];
            }
        }
    }
}

- (void)setReadOnly:(BOOL)readOnly {
    
    _readOnly = readOnly;
    [self readOnlyChanged];
}

-(void)readOnlyChanged{
    if (self.readOnly) {
        self.navBar.rightBarButtonItem.enabled = NO;
        [self.agreementPdfController allowSignature:NO];
        [self.segmentedControl setEnabled:NO forSegmentAtIndex:0];
        self.segmentedControl.selectedSegmentIndex = 1;
        self.customerInfo.hidden = YES;
        self.agreementPdf.hidden = NO;
    }
    else {
        self.navBar.rightBarButtonItem.enabled = YES;
        [self.agreementPdfController allowSignature:YES];
        [self.segmentedControl setEnabled:YES forSegmentAtIndex:0];
        self.segmentedControl.selectedSegmentIndex = 0;
        self.customerInfo.hidden = NO;
        self.agreementPdf.hidden = YES;
    }
}

- (void) flurryTrack {
    NSString *username = [[SRGlobalState singleton] userName];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
    
    [Flurry logEvent:@"An Agreement has been submitted successfully" withParameters:articleParams timed:YES];
}

#pragma mark ActionSheet

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
    
    UISegmentedControl *newButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:kNew]];
    newButton.momentary = YES;
    newButton.frame = CGRectMake(5, 7, ACTION_DONE_BTN_WIDTH, 30);
    newButton.tintColor = [UIColor blackColor];
    [newButton addTarget:self action:@selector(newPressed:) forControlEvents:UIControlEventValueChanged];
    [self.actionSheet addSubview:newButton];
    
    if (![self.agreementModel.saved boolValue]) {
        UISegmentedControl *saveButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:kSave]];
        saveButton.momentary = YES;
        saveButton.frame = CGRectMake(5 + ACTION_DONE_BTN_WIDTH + 8, 7, ACTION_DONE_BTN_WIDTH, 30);
        saveButton.tintColor = [UIColor blackColor];
        [saveButton addTarget:self action:@selector(savePressed:) forControlEvents:UIControlEventValueChanged];
        [self.actionSheet addSubview:saveButton];
    }
    NSString *doneButtonText = kCancel;
    UISegmentedControl *doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
    doneButton.momentary = YES;
    doneButton.tintColor = [UIColor blackColor];
    doneButton.frame = CGRectMake(screenFrame.size.width - ACTION_CANCEL_BTN_WIDTH - 5, 7, ACTION_CANCEL_BTN_WIDTH, 30);
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

-(void)refreshSavedAgreements{
    [self.savedAgreementsController refreshAgreements];
}

@end
