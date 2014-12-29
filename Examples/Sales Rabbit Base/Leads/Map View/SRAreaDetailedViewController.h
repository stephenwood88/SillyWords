//
//  SRAreaDetailedViewController.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/28/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Area+Rabbit.h"
#import "User+Rabbit.h"
#import "SRNewRepViewController.h"

@class SRAreaDetailedViewController;

@protocol SRAreaDetailedViewControllerDelegate <NSObject>

@optional

- (void)isGoingToDeleteArea:(Area *)area andController:(SRAreaDetailedViewController *) sender;
- (void)isGoingToAddNewRep;
- (void)areaDetailed: (SRAreaDetailedViewController *)areaDetailed didDeleteActiveRep:(User *)rep;
- (void)areaDetailedCancelButtonPressed:(SRAreaDetailedViewController *)areaDetailed;

@end

@interface SRAreaDetailedViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) MKPolygonRenderer *polygonToDisplay;
@property (strong, nonatomic) Area *selectedArea;
@property (nonatomic, weak) id <SRAreaDetailedViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *activeRepsArray;
@property (strong, nonatomic) NSMutableArray *inactiveRepsArray;
@property (strong, nonatomic) IBOutlet UISegmentedControl *repsSegmentedControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UITableView *activeRepsTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addRepButton;

- (IBAction)deleteButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)addRepButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)repTypeValueChanged:(UISegmentedControl *)sender;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;

- (void)updateReps;

@end
