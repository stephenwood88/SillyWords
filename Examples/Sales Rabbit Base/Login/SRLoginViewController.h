//
//  SRLoginViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 2/15/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;
@property (strong, nonatomic) NSDate *logoTimestamp;
@property (strong, nonatomic) NSDate *salesMaterialTimestamp;

- (IBAction)loginPressed:(id)sender;
- (IBAction)usernameDone:(id)sender;
- (IBAction)passwordDone:(id)sender;
- (IBAction)infoButtonPressed:(id)sender;
- (IBAction)twitterPressed:(UIButton *)sender;
- (IBAction)facebookPressed:(UIButton *)sender;
- (IBAction)googlePressed:(UIButton *)sender;
- (IBAction)forgotPasswordPressed:(id)sender;

- (void)didLoginWithDictionary:(NSDictionary *)result;
- (void)handleDepartments:(NSArray *)userDepartments;

- (void)displayLoginError;
- (void)displayConnectionError;

@end
