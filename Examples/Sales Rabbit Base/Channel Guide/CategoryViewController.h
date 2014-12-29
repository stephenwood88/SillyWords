//
//  CategoryViewController.h
//  DishTech
//
//  Created by Aaron Brown on 6/6/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelsCell.h"

@interface CategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;
@property (copy, nonatomic) NSString *categorySelected;

@property (nonatomic, copy) NSString* channelType;

@end
