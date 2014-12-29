//
//  AgreementFormViewController.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/12/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AgreementFormViewController.h"
#import "SRPDFViewController.h"
#import "TextOverlayViewFront.h"
#import "Person+Rabbit.h"
#import "Lead+Rabbit.h"
#import "ServiceCalls.h"
#import "Constants.h"
#import "Address+Rabbit.h"
#import "ServiceInfo+Rabbit.h"
#import "AVTextUtilities.h"

@interface AgreementFormViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) TextOverlayViewFront *agreementOverlay;
@property (nonatomic, strong) UIBarButtonItem *qualifyButton;

@end

@implementation AgreementFormViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    if ([[SRGlobalState singleton] integratedWithAgemni]) {
        self.qualifyButton = [[UIBarButtonItem alloc] initWithTitle:@"Qualify" style:UIBarButtonItemStylePlain target:self action:@selector(qualifyPressed:)];
        self.navBar.rightBarButtonItems = @[self.submitButton,self.qualifyButton];
        self.usingiPhone = YES;
    }
    // Call to supers viewDidLoad placed after above code to avoid a weird UI bug that occurrs otherwise when you select saved agreements.
    [super viewDidLoad];
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
        self.agreementPdfController.pdfFileName = @"sales_rabbit_agreement_ipad.pdf";
        self.agreementOverlay = [[[NSBundle mainBundle] loadNibNamed:@"PdfTextOverlayViewFront" owner:self options:nil] lastObject];
        self.agreementPdfController.textOverlayViews = @{@1:self.agreementOverlay};
        self.agreementPdfController.activeOverlayViews = @[self.agreementOverlay];
        self.agreementOverlay.parentView = self;
    }
    if (self.customerInfoController && self.agreementPdfController) {
        self.customerInfoController.textOverlayFront = self.agreementOverlay;
        self.customerInfoController.agreementModel = self.agreementModel;
    }
}

-(void)qualifyPressed:(id)sender{
    if ([self.customerInfoController verifyQualifyInfo]) {
        [self.qualifyButton setEnabled:NO];
        NSString *phonenumber = self.agreementModel.person.phonePrimary;
        phonenumber = [phonenumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phonenumber = [phonenumber stringByReplacingOccurrencesOfString:@")" withString:@""];
        phonenumber = [phonenumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        phonenumber = [phonenumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSMutableDictionary *fields = [@{@"fname":self.agreementModel.person.firstName,
                                         @"lname":self.agreementModel.person.lastName,
                                         @"phone":phonenumber,
                                         @"street":self.agreementModel.person.address.street1,
                                         @"city":self.agreementModel.person.address.city,
                                         @"state":self.agreementModel.person.address.state,
                                         @"zip":self.agreementModel.person.address.zip,
                                         @"contactdate":[self dateAsString:[NSDate date]]} mutableCopy];
        if ([AVTextUtilities isValidSocialSecurityNumber:self.agreementModel.person.ssn]) {
            fields[@"ssn"] = self.agreementModel.person.ssn;
        }
        if (self.agreementModel.person.address.street2.length) {
            fields[@"street2"] = self.agreementModel.person.address.street2;
        }
        if (self.agreementModel.person.dateOfBirth) {
            
            fields[@"dob"] = [self dateAsString:self.agreementModel.person.dateOfBirth];
        }
        if (self.agreementModel.agemniLeadId.length) {
            fields[@"leadID"] = self.agreementModel.agemniLeadId;
        }
        
        NSString *provider = [self.agreementModel.serviceInfo.provider isEqualToString:kDishNetwork] ? @"dishnetwork" : @"directv";
        [[ServiceCalls singleton] putCustomerAgreementFields:[fields copy] provider:provider completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
            [self.qualifyButton setEnabled:YES];
            if (success) {
                self.agreementModel.agemniLeadId = [NSString stringWithFormat:@"%@", result[kAgemniLeadId]];
                self.errorAlert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Lead was created in Agemni and is ready to qualify." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.errorAlert show];
            }else{
                self.errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to qualify" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [self.errorAlert show];
            }
        }];
    }else{
        self.errorAlert = [[UIAlertView alloc] initWithTitle:@"Unable to qualify" message:@"Required fields are missing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self.errorAlert show];
    }
}

- (void)readOnlyChanged{
    [super readOnlyChanged];
    if (self.readOnly) {
        [self.qualifyButton setEnabled:NO];
    }
    else {
        [self.qualifyButton setEnabled:YES];
    }
}

- (void)checkAndSubmit {
    
    if (![self.customerInfoController verifyInfo]) {
        [self.segmentedControl setSelectedSegmentIndex:0];
        self.agreementPdf.hidden = YES;
        self.customerInfo.hidden = NO;
        self.errorAlert = [[UIAlertView alloc] initWithTitle:kErrorTitle message:kErrorCustomerInfoMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [self.errorAlert show];
    }
    else if (!self.agreementModel.signature) {
        [self.segmentedControl setSelectedSegmentIndex:1];
        self.customerInfo.hidden = YES;
        self.agreementPdf.hidden = NO;
        self.errorAlert = [[UIAlertView alloc] initWithTitle:kErrorTitle message:kErrorAgreementPdfMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [self.errorAlert show];
    }
    else {
        self.submissionView.hidden = NO;
        self.progressView.progress = 0.0;
        [self.activityIndicator startAnimating];
        //NSLog(@"Generating PDF...");
        dispatch_queue_t pdfQueue = dispatch_queue_create("com.mysalesrabbit.pdf", 0);
        dispatch_async(pdfQueue, ^{
            NSData *pdf = [self.agreementPdfController agreementPdfFile];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:0.1 animated:YES];
                [[ServiceCalls singleton] putCustomerAgreement:self.agreementModel pdf:pdf uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                    float progress = (((float) (totalBytesWritten * 9) / (float) (totalBytesExpectedToWrite * 10)) + 0.05);
                    [self.progressView setProgress:progress animated:YES];
                } completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
                    [self.progressView setProgress:1.0 animated:YES];
                    [self.activityIndicator stopAnimating];
                    if (success) {
                        self.submissionSuccess = [[UIAlertView alloc] initWithTitle:kAgreementSubmissionSuccessTitle message:kAgreementSubmissionSuccessMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        [self.submissionSuccess show];
                        self.agreementModel.saved = @YES;
                        self.agreementModel.submitted = @YES;
                        [self setReadOnly:YES];
                        [self refreshSavedAgreements];
                        self.agreementModel.agemniLeadId = [NSString stringWithFormat:@"%@", result[kAgemniLeadId]];
                        self.agreementModel.agreementId = [NSString stringWithFormat:@"%@", result[kagreementId]];
                        // TODO: Put lead ID from response onto agreement to aid search over phone?
                        if (!self.agreementModel.person.lead) {
                            [Lead newLeadForPerson:self.agreementModel.person];
                        }
                        self.agreementModel.person.lead.status = kCustomer;
                        [self.agreementModel.person.lead setCoordinateFromAddressWithCompletionHandler:nil];
                        // TODO: Do we need a completion handler here? What should be the behavior if this call fails? Won't have a coordinate on the lead. Do we need to call something to update this lead on the map? Brady says the map will update when switching tabs.
                        [self flurryTrack];
                    }
                    else {
                        
                        if ([error.localizedFailureReason isEqualToString:@"ExistsInSalesRabbit"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kAgreementSubmissionDuplicateTitle message:kAgreementSubmissionDuplicateMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"noRepID"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kAgreementSubmissionNoRepIdTitle message:kAgreementSubmissionNoRepIdMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"cURLCallFailed"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kCURLCallFailedTitle message:kCURLCallFailedMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"orderFormNotPDF"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kOrderFormNotPDFTitle message:kOrderFormNotPDFMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"invalidParams"] || [error.localizedFailureReason isEqualToString:@"invalidProviderCode"] || [error.localizedFailureReason isEqualToString:@"unauthorized"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kInvalidCallErrorTitle message:kInvalidCallErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"EntityAlreadyExists"] || [error.localizedFailureReason isEqualToString:@"EntityExists"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kDuplicateCustomerErrorTitle message:kDuplicateCustomerErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        else if ([error.localizedFailureReason isEqualToString:@"EntityCreationFailed"]) {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kCustomerCreationFailureTitle message:kCustomerCreationFailureMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        // TODO: Mat needs to make an error code for the situation that the server has an unrecoverable error and the user needs to contact support to have it resolved. The following generic error should only be returned for temporary errors like a bad network connection. Anything that repeatedly causes an error on the server side needs to either have a specific error code that points to the user error (like phone number exists already in Sales Rabbit or no rep ID associated with user).
                        else {
                            self.errorAlert = [[UIAlertView alloc] initWithTitle:kAgreementSubmissionFailureTitle message:kAgreementSubmissionFailureMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
                        }
                        [self.errorAlert show];
                    }
                }];
            });
        });
    }
}

- (NSString *)dateAsString:(NSDate *)date {
    
    if (date == nil) {
        return @"null";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"M/d/yyy";
    return [dateFormatter stringFromDate:date];
}

@end
