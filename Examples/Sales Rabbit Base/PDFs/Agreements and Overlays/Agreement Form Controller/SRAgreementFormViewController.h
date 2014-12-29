//
//  AgreementFormViewController.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/12/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agreement+Rabbit.h"
#import "CustomerInfoViewController.h"
#import "SRPDFViewController.h"


@protocol AgreementsDelegate <NSObject>

- (BOOL)confirmSaveNeeded;
- (void)agreementSelected:(Agreement *)agreement savePrevious:(BOOL)savePrevious;
- (Agreement *)currentAgreement;

@end

@interface SRAgreementFormViewController : UIViewController <AgreementsDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *customerInfo;
@property (weak, nonatomic) IBOutlet UIView *agreementPdf;
@property (weak, nonatomic) IBOutlet UIView *submissionView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) CustomerInfoViewController *customerInfoController;
@property (weak, nonatomic) SRPDFViewController *agreementPdfController;
@property (strong, nonatomic) Agreement *agreementModel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender;
- (IBAction)submitPressed:(id)sender;

@property (strong, nonatomic) UIActionSheet *startNewConfirmation;
@property (strong, nonatomic) UIActionSheet *submitConfirmation;
@property (strong, nonatomic) UIAlertView *submissionSuccess;
@property (strong, nonatomic) UIAlertView *errorAlert;
@property (nonatomic) BOOL readOnly;
@property BOOL usingiPhone;

@property (strong, nonatomic) UIBarButtonItem *listButton;
@property (strong, nonatomic) UIBarButtonItem *startNewButton;
@property (strong, nonatomic) UIBarButtonItem *saveButton;

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (weak, nonatomic) IBOutlet UINavigationBar *myNavBar;
- (void)refreshSavedAgreements;
- (void)readOnlyChanged;
- (void)dismissActionSheet:(id)sender;
- (void) flurryTrack;

@end
