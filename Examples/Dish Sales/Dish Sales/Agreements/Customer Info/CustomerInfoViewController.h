//
//  CustomerInfoViewController.h
//  Dish Sales
//
//  Created by Jeff on 4/5/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRCustomerInformationViewController.h"

@interface CustomerInfoViewController : SRCustomerInformationViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneCellField;
@property (weak, nonatomic) IBOutlet UIImageView *phoneCellError;

@property (weak, nonatomic) IBOutlet UIButton *dateOfBirthButton;
@property (weak, nonatomic) IBOutlet UIImageView *dateOfBirthError;

@property (weak, nonatomic) IBOutlet UIButton *providerButton;
@property (weak, nonatomic) IBOutlet UIImageView *providerError;
@property (weak, nonatomic) IBOutlet UIButton *tvsButton;
@property (weak, nonatomic) IBOutlet UIImageView *tvsError;
@property (weak, nonatomic) IBOutlet UIButton *receiverConfigurationButton;
@property (weak, nonatomic) IBOutlet UIImageView *receiverConfigurationError;

@property (weak, nonatomic) IBOutlet UIButton *packageButton;
@property (weak, nonatomic) IBOutlet UIImageView *packageError;
@property (weak, nonatomic) IBOutlet UISegmentedControl *internetAccessControl;
@property (weak, nonatomic) IBOutlet UIImageView *internetAccessError;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoPayControl;
@property (weak, nonatomic) IBOutlet UIImageView *autoPayError;

@property (weak, nonatomic) IBOutlet UITextField *promoPriceField;
@property (weak, nonatomic) IBOutlet UIImageView *promoPriceError;
@property (weak, nonatomic) IBOutlet UITextField *regularPriceField;
@property (weak, nonatomic) IBOutlet UIImageView *regularPriceError;
@property (weak, nonatomic) IBOutlet UITextField *setupPriceField;
@property (weak, nonatomic) IBOutlet UITextField *otherDescriptionField;
@property (weak, nonatomic) IBOutlet UIImageView *otherDescriptionError;
@property (weak, nonatomic) IBOutlet UITextField *otherPriceField;
@property (weak, nonatomic) IBOutlet UITextField *other2DescriptionField;
@property (weak, nonatomic) IBOutlet UIImageView *other2DescriptionError;
@property (weak, nonatomic) IBOutlet UITextField *other2PriceField;

@property (weak, nonatomic) IBOutlet UITextView *notesField;
@property (weak, nonatomic) IBOutlet UILabel *notesPlaceholderLabel;

@property (weak, nonatomic) TextOverlayViewFront *textOverlayFront;

- (IBAction)internetAccessChanged:(UISegmentedControl *)sender;
- (IBAction)autoPayChanged:(UISegmentedControl *)sender;
-(BOOL)verifyQualifyInfo;

@end
