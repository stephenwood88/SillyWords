//
//  SRStreetViewCell.h
//  Dish Sales
//
//  Created by Aaron Brown on 8/19/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRStreetViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *houseNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

@end
