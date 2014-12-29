//
//  SRLeadsListViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SRLeadDetailTableViewController.h"

@interface SRLeadsListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *leadTableView;

@property (weak, nonatomic) IBOutlet UIView *stationaryContentView;

@property (weak, nonatomic) IBOutlet UIButton *filterDateOnButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDateButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateButton;
@property (weak, nonatomic) IBOutlet UIButton *quickDateButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@property (weak, nonatomic) IBOutlet UILabel *nameSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceSortLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointmentSortLabel;

@property (weak, nonatomic) IBOutlet UIButton *nameSortButton;
@property (weak, nonatomic) IBOutlet UIButton *rankSortButton;
@property (weak, nonatomic) IBOutlet UIButton *distanceSortButton;
@property (weak, nonatomic) IBOutlet UIButton *appointmentSortButton;

@property (nonatomic) BOOL leadJustEdited;
@property (strong, nonatomic) NSMutableArray *currentLeadList;

- (IBAction)sortButtonPressed:(UIButton *)sender;

- (void)performFetchWithRequest:(NSFetchRequest *)request;

- (IBAction)filterButtonPressed:(UIButton *)sender;

- (void)startLocationUpdate;

@end
