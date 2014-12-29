//
//  PackageViewController.h
//  DishTech
//
//  Created by Aaron Brown on 6/6/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChannelsCell.h"

@interface PackageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *packageTableView;
@property (strong, nonatomic) NSArray *packages;
@property (strong, nonatomic) NSString *channelType;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *packageSelected;

@end
