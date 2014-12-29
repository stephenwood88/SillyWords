//
//  TextOverlayViewFront.m
//  Dish Sales
//
//  Created by Jeff on 11/3/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "TextOverlayViewFront.h"
#import "ReaderContentTile.h"
#import "SignatureController.h"
#import "SignatureView.h"
#import "Agreement+Rabbit.h"
#import "Person+Rabbit.h"
#import "Address+Rabbit.h"
#import "ServiceInfo+Rabbit.h"
#import "CreditCard+Rabbit.h"
#import "Ach+Rabbit.h"
#import "AVTextUtilities.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface TextOverlayViewFront () <UIPopoverControllerDelegate, SignatureControllerDelegate>

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIView *disableTouchesView;

@property (strong, nonatomic) SignatureController *signatureController;

@end

@implementation TextOverlayViewFront

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.signatureController = [[SignatureController alloc] initWithSourceButton:self.signature lineColor:[UIColor blueColor] signatureType:signature saveSelector:@selector(setSignature:) delegate:self];
    self.signatureControllers = @[self.signatureController];
    self.signatureButtons = @[self.signature];
    self.allowSignature = YES;
    
}

- (void)setAgreementModel:(Agreement *)agreementModel {
    
    [super setAgreementModel:agreementModel];
    
    self.signatureController.agreementModel = nil;
    [self.signatureController clear];
    self.signatureController.agreementModel = agreementModel;
    agreementModel.textOverlayFront = self;
    
    Person *person = agreementModel.person;
    Address *address = person.address;
    Address *billingAddress = person.billingAddress;
    ServiceInfo *serviceInfo = agreementModel.serviceInfo;
    CreditCard *creditCard = agreementModel.creditCard;
    Ach *ach = agreementModel.ach;
    
    self.termsOfAgreement.text = agreementModel.terms;
    self.notes.text = agreementModel.notes;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yyyy";
    self.signedDate.text = [formatter stringFromDate:agreementModel.signedDate];
    [self.signature setImage:agreementModel.signature forState:UIControlStateNormal];
    
    self.lastName.text = person.lastName;
    self.firstName.text = person.firstName;
    self.businessName.text = person.businessName;
    
    self.phonePrimary.text = person.phonePrimary;
    self.phoneAlternate.text = person.phoneAlternate;
    self.phoneCell.text = person.phoneCell;
    
    self.address.text = address.street1;
    self.aptSuite.text = address.street2;
    self.city.text = address.city;
    self.state.text = address.state;
    self.zip.text = address.zip;
    
    self.addressBilling.text = billingAddress.street1;
    self.aptSuiteBilling.text = billingAddress.street2;
    self.cityBilling.text = billingAddress.city;
    self.stateBilling.text = billingAddress.state;
    self.zipBilling.text = billingAddress.zip;
    
    self.socialSecurityNumber.text = [AVTextUtilities obfuscatedNumber:person.ssn showNumDigits:0];
    self.email.text = agreementModel.person.email;
    formatter.dateFormat = @"M/d/yyyy";
    self.dateOfBirth.text = [formatter stringFromDate:person.dateOfBirth];
    
    self.creditCardNumber.text = [AVTextUtilities obfuscatedNumber:creditCard.number showNumDigits:4];
    formatter.dateFormat = @"MM/yy";
    self.expirationDate.text = [formatter stringFromDate:creditCard.expirationDate];
    self.cvv.text = creditCard.cvv;
    
    self.financialInstitution.text = ach.financialInstitution;
    self.accountType.text = ach.accountType;
    self.routingNumber.text = ach.routingNumber;
    self.accountNumber.text = [AVTextUtilities obfuscatedNumber:ach.accountNumber showNumDigits:4];
    
    self.dishLogo.hidden = YES;
    self.direcTvLogo.hidden = YES;
    if (serviceInfo.provider && ![[SRGlobalState singleton] isAppleTester]) {
        if ([serviceInfo.provider isEqualToString:kDishNetwork]) {
            self.dishLogo.hidden = NO;
        }
        else if ([serviceInfo.provider isEqualToString:kDirecTv]) {
            self.direcTvLogo.hidden = NO;
        }
    }
    self.tvs.text = serviceInfo.tvs ? [serviceInfo.tvs stringValue] : nil;
    self.receiverConfiguration.text = serviceInfo.receiverConfiguration;
    self.package.text = serviceInfo.package;
    self.autoPay.text = serviceInfo.autoPay ? ([serviceInfo.autoPay boolValue] ? kYes : kNo) : nil;
    self.internetAccess.text = serviceInfo.internetAccess ? ([serviceInfo.internetAccess boolValue] ? kYes : kNo) : nil;
    
    self.promoPrice.text = serviceInfo.promoPrice;
    self.regularPrice.text = serviceInfo.regularPrice;
    self.setupPrice.text = serviceInfo.setupPrice;
    
    if (serviceInfo.otherDescription) {
        self.otherDescription.text = [NSString stringWithFormat:@"%@:", serviceInfo.otherDescription];
    }
    else {
        self.otherDescription.text = [NSString stringWithFormat:@"Other:"];
    }
    
    self.otherPrice.text = serviceInfo.otherPrice;
    
    if (serviceInfo.otherDescription) {
        self.other2Description.text = [NSString stringWithFormat:@"%@:", serviceInfo.other2Description];
    }
    else {
        self.other2Description.text = [NSString stringWithFormat:@"Other:"];
    }
    
    self.other2Price.text = serviceInfo.other2Price;
}

@end
