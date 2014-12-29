//
//  TextOverlayViewFront.h
//  Dish Sales
//
//  Created by Jeff on 11/3/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResizingLabel.h"
#import "TextOverlayView.h"
#import "Agreement+Rabbit.h"

@interface TextOverlayViewFront : TextOverlayView

@property (weak, nonatomic) IBOutlet ResizingLabel *retailerName;
@property (weak, nonatomic) IBOutlet ResizingLabel *retailerAddress;
@property (weak, nonatomic) IBOutlet ResizingLabel *retailerCityStateZip;
@property (weak, nonatomic) IBOutlet ResizingLabel *retailerPhone;
@property (weak, nonatomic) IBOutlet ResizingLabel *retailerEmail;

@property (weak, nonatomic) IBOutlet UIImageView *direcTvLogo;
@property (weak, nonatomic) IBOutlet UIImageView *dishLogo;

@property (weak, nonatomic) IBOutlet ResizingLabel *lastName;
@property (weak, nonatomic) IBOutlet ResizingLabel *firstName;
@property (weak, nonatomic) IBOutlet ResizingLabel *businessName;

@property (weak, nonatomic) IBOutlet ResizingLabel *phonePrimary;
@property (weak, nonatomic) IBOutlet ResizingLabel *phoneAlternate;
@property (weak, nonatomic) IBOutlet ResizingLabel *phoneCell;

@property (weak, nonatomic) IBOutlet ResizingLabel *address;
@property (weak, nonatomic) IBOutlet ResizingLabel *aptSuite;
@property (weak, nonatomic) IBOutlet ResizingLabel *city;
@property (weak, nonatomic) IBOutlet ResizingLabel *state;
@property (weak, nonatomic) IBOutlet ResizingLabel *zip;

@property (weak, nonatomic) IBOutlet ResizingLabel *addressBilling;
@property (weak, nonatomic) IBOutlet ResizingLabel *aptSuiteBilling;
@property (weak, nonatomic) IBOutlet ResizingLabel *cityBilling;
@property (weak, nonatomic) IBOutlet ResizingLabel *stateBilling;
@property (weak, nonatomic) IBOutlet ResizingLabel *zipBilling;

@property (weak, nonatomic) IBOutlet ResizingLabel *socialSecurityNumber;
@property (weak, nonatomic) IBOutlet ResizingLabel *email;
@property (weak, nonatomic) IBOutlet ResizingLabel *dateOfBirth;

@property (weak, nonatomic) IBOutlet ResizingLabel *creditCardNumber;
@property (weak, nonatomic) IBOutlet ResizingLabel *expirationDate;
@property (weak, nonatomic) IBOutlet ResizingLabel *cvv;

@property (weak, nonatomic) IBOutlet ResizingLabel *financialInstitution;
@property (weak, nonatomic) IBOutlet ResizingLabel *accountType;
@property (weak, nonatomic) IBOutlet ResizingLabel *routingNumber;
@property (weak, nonatomic) IBOutlet ResizingLabel *accountNumber;

@property (weak, nonatomic) IBOutlet ResizingLabel *tvs;
@property (weak, nonatomic) IBOutlet ResizingLabel *receiverConfiguration;
@property (weak, nonatomic) IBOutlet ResizingLabel *package;
@property (weak, nonatomic) IBOutlet ResizingLabel *autoPay;
@property (weak, nonatomic) IBOutlet ResizingLabel *internetAccess;

@property (weak, nonatomic) IBOutlet ResizingLabel *promoPrice;
@property (weak, nonatomic) IBOutlet ResizingLabel *regularPrice;
@property (weak, nonatomic) IBOutlet ResizingLabel *setupPrice;
@property (weak, nonatomic) IBOutlet ResizingLabel *otherDescription;
@property (weak, nonatomic) IBOutlet ResizingLabel *otherPrice;
@property (weak, nonatomic) IBOutlet ResizingLabel *other2Description;
@property (weak, nonatomic) IBOutlet ResizingLabel *other2Price;

@property (weak, nonatomic) IBOutlet ResizingLabel *notes;

@property (weak, nonatomic) IBOutlet ResizingLabel *termsOfAgreement;

@property (weak, nonatomic) IBOutlet UIButton *signature;

@property (weak, nonatomic) IBOutlet ResizingLabel *signedDate;

@property (weak, nonatomic) IBOutlet ResizingLabel *salesRep;

@end
