//
//  SRSalesHomeViewController.h
//  Original Sales
//
//  Created by Matthew McArthur on 11/25/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRHomeViewController.h"
#import "SRMaterialsState.h"

@interface SRSalesHomeViewController : SRHomeViewController <SalesMaterialsDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *salesLeadsButton;
@property (weak, nonatomic) IBOutlet UIButton *salesToolsButton;
@property (weak, nonatomic) IBOutlet UIButton *reportsButton;
@property (weak, nonatomic) IBOutlet UIButton *paperlessAgreementsButton;

- (void) salesMaterialsDownloadList:(NSArray *)downloadList;

@end
