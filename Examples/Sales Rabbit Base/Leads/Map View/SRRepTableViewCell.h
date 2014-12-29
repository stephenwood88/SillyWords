//
//  SRRepTableViewCell.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/10/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRRepTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *repPicture;
@property (weak, nonatomic) IBOutlet UILabel *repName;
@property (weak, nonatomic) IBOutlet UIView *repColorView;

//Properties for a New Rep View Controller

@property (strong, nonatomic) UILabel *activeAreaStatus;
@property (strong, nonatomic) UIColor *statusColor;
@property (nonatomic) BOOL displayStatus;

@end
