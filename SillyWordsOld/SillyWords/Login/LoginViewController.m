//
//  LoginViewController.m
//  TutorialBase
//
//  Created by Antonio MG on 6/23/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ServiceCalls.h"
#import "GlobalState.h"

@interface LoginViewController ()
@property (nonatomic, strong) IBOutlet UITextField *userTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    return wasHandled;
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:NO];
}

#pragma mark - Private methods

-(IBAction)logInPressed:(id)sender
{
    [[ServiceCalls singleton] loginWithUsername:self.userTextField.text password:self.passwordTextField.text completionHandler:^(BOOL success, PFUser *user, NSError *error) {
        if (user) {
            [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
 
}


#pragma mark Comms Delegate

- (void)commsDidLogin:(BOOL)loggedIn {
    [self.fbLogin setEnabled:YES];
    
    if (loggedIn) {
        [[ServiceCalls singleton] getFacebookFriendsWithCompletionHandler:^(BOOL success, NSArray *allFriends, NSArray *userFriends, NSError *error) {
            if (!error) {
               [[GlobalState singleton] setUserFriends:userFriends];
               [[GlobalState singleton] setAllFriends:allFriends];
            }
        }];
        [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
    }
    else {
        // Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)fbLoginPressed:(id)sender {
    
    [self.fbLogin setEnabled:NO];
    [Comms login:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"LoginSuccessful"]) {
//        [[ServiceCalls singleton] getFacebookFriendsWithCompletionHandler:^(BOOL success, id allFriends, id userFriends, NSError *error) {
//        if (!error) {
//            [GlobalState singleton].userFriends = userFriends;
//            [GlobalState singleton].allFriends = allFriends;
//        }
//    }];
//    }
}
@end
