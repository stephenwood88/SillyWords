//
//  ProviderAgreementViewController.h
//  DishTech
//
//  Created by Brown Family on 6/18/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "ReaderViewController.h"
#import "TextOverlayView.h"

@interface SRPDFViewController : ReaderViewController

@property (weak, nonatomic) NSManagedObject *agreementModel;

@property (strong, nonatomic) NSArray *activeOverlayViews;

- (void)dismissAll:(BOOL)animated;
- (BOOL)verifySignature;
- (NSData *)agreementPdfFile;
- (void)setAgreementModel:(NSManagedObject *)agreementModel;
- (void)allowSignature:(BOOL)allowed;

@end