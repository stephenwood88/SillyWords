//
//  OverViewController.h
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
//#import "SRSalesMainTabBar.h"
@interface OverViewController : UIViewController <AVSelectionListDelegate, AVSimpleDatePickerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, UITableViewDelegate, UIScrollViewDelegate> {
    
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
    //UIPickerView *
}

@property (nonatomic, retain) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *quickDateButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *productsButton;

@property (weak, nonatomic) IBOutlet UILabel *productsLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *quickDateLabel;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *productsIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *productsBtnIndicator;

@property (weak, nonatomic) IBOutlet UIView *filtersView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *installsLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingLabel;
@property (weak, nonatomic) IBOutlet UILabel *notScheduledLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelledLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeBackLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *columnsToolbar;


//Product properties so the Parent can set them up
@property (strong, nonatomic) NSMutableArray *productList;
@property (strong, nonatomic) NSMutableDictionary *selectedProductDictionary;
@property (strong, nonatomic) AVSelectionListController *productOptions;

// Office properties so the Parent can set them up
@property (strong, nonatomic) NSMutableArray *officeList;
@property (strong, nonatomic) NSMutableDictionary *selectedOfficeDictionary;
@property (strong, nonatomic) AVSelectionListController *officeOptions;

//Report Properties for Parent to set up
@property (copy, nonatomic) NSString *reportDepth;





- (IBAction)filterButtonPressed:(UIButton *)sender;
- (IBAction)columnInfoButtonPressed:(UIButton *)sender;


- (void)updateProductButtonText;
- (void)startNewReportOnlyIfParametersChanged:(BOOL)parameterCheck refreshDataForPullDown:(BOOL)pulledToRefresh;

@end
