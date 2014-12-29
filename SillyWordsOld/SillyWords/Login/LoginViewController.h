//
//  LoginViewController.h
//  TutorialBase
//
//  Created by Antonio MG on 6/23/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <CommsDelegate>

@property (weak, nonatomic) IBOutlet UIButton *fbLogin;

- (IBAction)fbLoginPressed:(id)sender;

@end
