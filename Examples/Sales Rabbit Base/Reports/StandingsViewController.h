//
//  StandingsViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 3/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRServiceCalls.h"
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"
#import "Constants.h"

@interface StandingsViewController : UIViewController <AVSelectionListDelegate, AVSimpleDatePickerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
}

@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *quickDateButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *productsButton;
@property (weak, nonatomic) IBOutlet UIButton *officesButton;
@property (weak, nonatomic) IBOutlet UIButton *domainsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UILabel *domainLabel;
@property (weak, nonatomic) IBOutlet UILabel *productsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickDateLabel;


@property (weak, nonatomic) IBOutlet UIButton *sortNameButton;
@property (weak, nonatomic) IBOutlet UILabel *sortNameArrowsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *productsBtnIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *officesBtnIndicator;

@property (weak, nonatomic) IBOutlet UIToolbar *columnsToolbar;

//Product Properties so the Parent can set them up
@property (strong, nonatomic) NSMutableArray *productList;
@property (strong, nonatomic) AVSelectionListController *productOptions;
@property (strong, nonatomic) NSMutableDictionary *selectedProductDictionary;

//Office Properties so the Parent can set them up
@property (strong, nonatomic) NSMutableArray *officeList;
@property (strong, nonatomic) NSMutableDictionary *selectedOfficeDictionary;
@property (strong, nonatomic) AVSelectionListController *officeOptions;

//Report Properties for Parent to set up
@property (copy, nonatomic) NSString *reportDepth;

//Domain Properties for Parent to set up
@property (strong, nonatomic) NSMutableArray *domainList;
@property (strong, nonatomic) AVSelectionListController *domainOptions;


- (void)updateProductButtonText;
- (void)updateOfficeButtonText;
- (void)updateDomainButtonText;
- (IBAction)columnInfoButtonPressed:(UIButton *)sender;


// Service Call Method
- (void)startNewReportOnlyIfParametersChanged:(BOOL)parameterCheck refreshDataForPullDown:(BOOL)pulledToRefresh;



@end
