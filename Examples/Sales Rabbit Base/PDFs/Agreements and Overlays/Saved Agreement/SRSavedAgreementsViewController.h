//
//  SavedAgreementsViewController.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/25/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agreement+Rabbit.h"
#import "AgreementFormViewController.h"

@interface SRSavedAgreementsViewController : UITableViewController

- (id)initWithDelegate:(id <AgreementsDelegate>)delegate;
- (void)refreshAgreements;

@end
