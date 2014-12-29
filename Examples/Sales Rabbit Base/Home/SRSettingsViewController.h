//
//  SRSettingsViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 4/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lead+Rabbit.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AVSelectionListController.h"

@protocol SettingsDelegate <NSObject>
@required
- (void) updateNavBarTitle;
- (void) logout;
@end

@interface SRSettingsViewController : UIViewController

@property (weak) id <SettingsDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *settingsDictionary;
@property (nonatomic, retain) NSMutableDictionary *userSettingsDictionary;
@property (nonatomic, retain) NSIndexPath *checkedIndexPath;
@property (strong, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)donePressed:(UIBarButtonItem *)sender;
- (IBAction)logoutPressed:(UIButton *)sender;
- (IBAction)addCalDefaultSwitched:(id)sender;
- (IBAction)remindMeTimePressed:(id)sender;
- (IBAction)sendFeebackPressed:(UIButton *)sender;


@end
