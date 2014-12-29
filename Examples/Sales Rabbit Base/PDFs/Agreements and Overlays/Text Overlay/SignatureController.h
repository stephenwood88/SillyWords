//
//  SignatureController.h
//  Dish Sales
//
//  Created by Jeff on 11/17/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SignatureView, ProviderAgreement, DealerAgreement;

@protocol SignatureControllerDelegate <NSObject>

- (void)signatureDonePressed:(id)sender;

@end

typedef enum {
    signature,
    initial,
    permission
} SignatureType;

@interface SignatureController : UIViewController

@property (strong, nonatomic) UIColor *lineColor;
@property (nonatomic) SignatureType signatureType;
@property (weak, nonatomic) IBOutlet UIView *permissionView;
@property (weak, nonatomic) IBOutlet UIButton *permissionCheckboxButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet SignatureView *signatureView;

@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) id<SignatureControllerDelegate> delegate;

@property (nonatomic, weak) NSManagedObject *agreementModel;
@property (nonatomic, strong)NSDictionary *permissionContactInfo;

- (id)initWithSourceButton:(UIButton *)button lineColor:(UIColor *)lineColor signatureType:(SignatureType)signatureType saveSelector:(SEL)saveSelector delegate:(id<SignatureControllerDelegate>)delegate;
- (IBAction)clear;
- (IBAction)done;
- (void)saveSignatureToButton;

@end
