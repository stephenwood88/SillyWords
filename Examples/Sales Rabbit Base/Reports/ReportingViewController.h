//
//  ReportingViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 2/5/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ReportingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *overViewContainer;
@property (weak, nonatomic) IBOutlet UIView *salesStandingsContainer;
@property (weak, nonatomic) IBOutlet UIView *customerContainer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)selectionChanged:(id)sender;

@end
