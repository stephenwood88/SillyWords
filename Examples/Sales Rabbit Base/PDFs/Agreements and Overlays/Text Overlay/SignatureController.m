//
//  SignatureController.m
//  Dish Sales
//
//  Created by Jeff on 11/17/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "SignatureController.h"
#import "SignatureView.h"

#define kBox @"\u2610"
#define kCheckedBox @"\u2611"

@interface SignatureController () <SignatureViewDelegate>

@property (weak, nonatomic) UIButton *sourceButton;
@property (nonatomic) SEL saveSelector;
@property (nonatomic) BOOL sourceButtonModified;
@property (nonatomic) BOOL termsAccepted;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

@end

@implementation SignatureController

- (id)initWithSourceButton:(UIButton *)button lineColor:(UIColor *)lineColor signatureType:(SignatureType)signatureType saveSelector:(SEL)saveSelector delegate:(id<SignatureControllerDelegate>)delegate {
    
    self = [self initWithNibName:@"SignatureController" bundle:nil];
    if (self) {
        // Custom initialization
        self.signatureType = signatureType;
        self.lineColor = lineColor;
        self.saveSelector = saveSelector;
        self.delegate = delegate;
        self.sourceButton = button;
        self.termsAccepted = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.signatureView.delegate = self;
    switch (self.signatureType) {
        case initial:
            self.lineLabel.text = @"X_______________";
            [self showPermissionView:NO];
            break;
        case signature:
            self.lineLabel.text = @"X_________________________________";
            [self showPermissionView:NO];
            break;
        case permission:
            self.lineLabel.text = @"X_________________________________";
            [self showPermissionView:YES];
            [self setTermsLabel];
            break;
    }
    [self.navBar setBarTintColor:[UIColor blackColor]];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
    [self.clearButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    attributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    [self.clearButton setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [self.permissionCheckboxButton.titleLabel setFont:[UIFont fontWithName:@"ArialUnicodeMS" size:28]];
    [self.permissionCheckboxButton setTitle:kBox forState:UIControlStateNormal];
    [self.permissionCheckboxButton setTitle:kCheckedBox forState:UIControlStateSelected];
}

-(void)viewWillAppear:(BOOL)animated{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // When selecting signature on a saved signature, there won't be a bezier signature in the signature view.
    // Just clear the signature in the model and start over.
    if ([self.sourceButton imageForState:UIControlStateNormal] && !self.clearButton.enabled) {
        [self clear];
    }
    
    //make sure the signature image button is displayed with correct ratio
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !self.sourceButtonModified) {
        float ratio = self.signatureView.frame.size.width / self.signatureView.frame.size.height;
        
        CGRect sourceButtonBounds = self.sourceButton.bounds;
//        float difference = roundf(sourceButtonBounds.size.height * ratio) - sourceButtonBounds.size.width;
        sourceButtonBounds.size.width = roundf(sourceButtonBounds.size.height * ratio);
        self.sourceButton.bounds = sourceButtonBounds;
        
        //looks more centered without adjusting the frame.
//        CGRect sourceButtonFrame = self.sourceButton.frame;
//        sourceButtonFrame.origin.x = sourceButtonFrame.origin.x - (difference / 2);
//        self.sourceButton.frame = sourceButtonFrame;
//        self.sourceButtonModified = YES;
    }
    if (![self.signatureView isSigned] && self.signatureType == permission) {
        [self showPermissionView:YES];
    }else{
        [self showPermissionView:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clear {
    if (self.termsAccepted) {
        [self.signatureView clear];
        self.clearButton.enabled = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (self.agreementModel) {
            [self.agreementModel performSelector:self.saveSelector withObject:nil];
        }
#pragma clang diagnostic pop
    }else{
       [self.delegate signatureDonePressed:self];
    }
}

- (IBAction)done {
    if (self.termsAccepted) {
        [self.delegate signatureDonePressed:self];
    }else{
        self.termsAccepted = YES;
        [self.permissionView setHidden:YES];
        self.doneButton.title = @"Done";
        self.clearButton.title = @"Clear";
        [self.clearButton setEnabled:NO];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)saveSignatureToButton {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (self.agreementModel) {
        [self.agreementModel performSelector:self.saveSelector withObject:[self.signatureView signatureImage]];
    }
#pragma clang diagnostic pop
}

#pragma mark - AVSignatureViewDelegate

- (void)signatureSigned {
    
    self.clearButton.enabled = YES;
}

- (CGFloat)lineWidth {
    
    switch (self.signatureType) {
        case signature:
            return self.sourceButton.frame.size.width / 90.0;
            break;
        case initial:
            return self.sourceButton.frame.size.width / 20;
            break;
        case permission:
            return self.sourceButton.frame.size.width / 90.0;
            break;
    }
}

#pragma  mark - Custom Accessors

- (void)setSourceButton:(UIButton *)sourceButton {
    
    if (_sourceButton != sourceButton) {
        _sourceButton = sourceButton;
        // Size popover with same proportion as signature button source
        CGSize buttonSize = sourceButton.bounds.size;
        CGFloat proportion = buttonSize.height / buttonSize.width;
        switch (self.signatureType) {
            case signature:
                self.preferredContentSize = CGSizeMake(728.0, (728.0 * proportion) + 44);
                break;
            case initial:
                self.preferredContentSize = CGSizeMake(350.0, (350.0 * proportion) + 44);
                break;
            case permission:
                self.preferredContentSize = CGSizeMake(728.0, (728.0 * proportion) + 44);
                break;
        }
    }
}

#pragma mark - Permission View Methods


-(void)showPermissionView:(BOOL)show{
    if (show) {
        [self.permissionView setHidden:NO];
        [self.clearButton setTitle:@"Cancel"];
        self.doneButton.enabled = NO;
        [self.doneButton setTitle:@"Accept"];
        self.clearButton.enabled = YES;
        self.termsAccepted = NO;
        [self.permissionCheckboxButton setSelected:NO];
    }else{
        [self.permissionView setHidden:YES];
        self.termsAccepted = YES;
    }
    
}

- (IBAction)acceptButtonPressed:(id)sender {
    self.permissionCheckboxButton.selected = !self.permissionCheckboxButton.selected;
    if (self.permissionCheckboxButton.selected) {
        self.doneButton.enabled = YES;
    }else{
        self.doneButton.enabled = NO;
    }
    
}

#define kAgreementSettingsName @"Name"
#define kAgreementSettingsAddress @"Address"
#define kAgreementSettingsCity @"City"
#define kAgreementSettingsState @"State"
#define kAgreementSettingsZip @"Zip"
#define  kAgreementSettingsEmail @"Email"

-(void)setTermsLabel{
    NSString *address = @"___________";
    NSString *email = @"___________";
    if (self.permissionContactInfo) {
        address = [NSString stringWithFormat:@"%@, %@, %@ %@",
                   self.permissionContactInfo[kAgreementSettingsAddress],
                   self.permissionContactInfo[kAgreementSettingsCity],
                   self.permissionContactInfo[kAgreementSettingsState],
                   self.permissionContactInfo[kAgreementSettingsZip]];
        email = self.permissionContactInfo[kAgreementSettingsEmail];
    }
    
    self.termsLabel.text = [self.termsLabel.text stringByReplacingOccurrencesOfString:@"kBussinessEmail" withString:email];
    self.termsLabel.text = [self.termsLabel.text stringByReplacingOccurrencesOfString:@"kBussinessAddress" withString:address];
}

#pragma mark- Supported Orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }else{
        return YES;
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

@end
