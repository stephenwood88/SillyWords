//
//  CustomerViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 4/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"
//#import "CheckListViewController.h"

@interface CustomerViewController : UIViewController <AVSelectionListDelegate, AVSimpleDatePickerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate> {
    BOOL doNotShowMainIndicator;
}

@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *quickDateButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *productsButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *customerSummaryLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *productsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickDateLabel;


@property (weak, nonatomic) IBOutlet UILabel *customerNameSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *productSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *providerSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *installDateSortLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *statusActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *productsActivityIndicator;

//Products Properties
@property (strong, nonatomic) NSMutableArray *productList;
@property (strong, nonatomic) AVSelectionListController *productOptions;
@property (strong, nonatomic) NSMutableDictionary *selectedProductDictionary;





- (IBAction)customerNameSortButtonPressed:(id)sender;
- (IBAction)productSortButtonPressed:(id)sender;
- (IBAction)providerSortButtonPressed:(id)sender;
- (IBAction)statusSortButtonPressed:(id)sender;
- (IBAction)installSortButtonPressed:(id)sender;

- (IBAction)filterButtonPressed:(UIButton *)sender;
- (void)refreshPull;

- (void)updateProductButtonText;
- (void)startNewReportOnlyIfParametersChanged:(BOOL)parameterCheck refreshDataForPullDown:(BOOL)pulledToRefresh;

@end
