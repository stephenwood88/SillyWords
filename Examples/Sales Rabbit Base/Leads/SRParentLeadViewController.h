//
//  SRParentLeadViewController.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 1/7/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMapViewController.h"

@interface SRParentLeadViewController : UIViewController

// Container Views

@property (weak, nonatomic) IBOutlet UIView *leadsViewContainer;
@property (weak, nonatomic) IBOutlet UIView *streetViewContainer;
@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;

@property (weak, nonatomic) SRMapViewController *mapViewVC;

// Container View Segment Controller

@property (weak, nonatomic) IBOutlet UISegmentedControl *viewControl;


- (IBAction)viewControlChanged:(UISegmentedControl *)sender;

- (BOOL)isLeadListVisible;

@end
