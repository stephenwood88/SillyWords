//
//  Comms.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/12/14.
//
//

#import "Comms.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GlobalState.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ServiceCalls.h"


@implementation Comms

+ (void) login:(id<CommsDelegate>)delegate {
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:[NSArray arrayWithObjects:@"public_profile", @"user_friends", nil] block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"User cancelled Facebook login");
            }
            else  {
                NSLog(@"An error ocurred: %@", error.localizedDescription);
            }
            
            if ([delegate respondsToSelector:@selector(commsDidLogin:)]) {
                [delegate commsDidLogin:NO];
            }
        }
        else {
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbID"];
                         [[PFUser currentUser] saveInBackground];
                         [GlobalState singleton].username = [result objectForKey:@"name"];
                         //NSLog(@"fetched user:%@", result);
//                         [[ServiceCalls alloc] getFacebookFriendsWithCompletionHandler:^(BOOL success, NSArray *allFriends, NSArray *userFriends, NSError *error) {
//                             
//                         }];
                     }
                 }];
                if (![PFFacebookUtils isLinkedWithUser:user]) {
                    [PFFacebookUtils linkUserInBackground:user withReadPermissions:nil block:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Woohoo, user is linked with Facebook!");
                        }
                    }];
                }
            }
            
            if ([delegate respondsToSelector:@selector(commsDidLogin:)]) {
                [delegate commsDidLogin:YES];
            }
        }
    }];
}

//[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//    if (!error) {
//        // result will contain an array with your user's friends in the "data" key
//        NSArray *friendObjects = [result objectForKey:@"data"];
//        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
//        // Create a list of friends' Facebook IDs
//        for (NSDictionary *friendObject in friendObjects) {
//            [friendIds addObject:[friendObject objectForKey:@"id"]];
//        }
//        
//        // Construct a PFUser query that will find friends whose facebook ids
//        // are contained in the current user's friend list.
//        PFQuery *friendQuery = [PFUser query];
//        [friendQuery whereKey:@"fbId" containedIn:friendIds];
//        
//        // findObjects will return a list of PFUsers that are friends
//        // with the current user
//        NSArray *friendUsers = [friendQuery findObjects];
//    }
//}];
@end
