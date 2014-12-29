//
//  PackageDetailViewController.h
//  DishTech
//
//  Created by Brady Anderson on 1/8/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageDetailViewController : UIViewController

@property (strong, nonatomic) NSString *csvFileName;
@property (strong, nonatomic) NSString *packageName;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *packageDetailTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)sortControlChanged:(UISegmentedControl *)sender;

@end
