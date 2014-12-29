//
//  ChannelsViewController.h
//  DishTech
//
//  Created by Aaron Brown on 5/29/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelsViewController : UIViewController 
- (IBAction)dishButtonPressed:(id)sender;
- (IBAction)directvButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *dishButton;
@property (strong, nonatomic) IBOutlet UIButton *directvButton;


@end
