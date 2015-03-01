//
//  HomeViewController.h
//  TutorialBase
//
//  Created by Antonio MG on 6/23/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(IBAction)logoutPressed:(id)sender;

@end
