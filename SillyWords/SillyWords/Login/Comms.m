//
//  Comms.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/12/14.
//
//

#import "Comms.h"

@implementation Comms

+ (void) login:(id<CommsDelegate>)delegate {
    
    [PFFacebookUtils logInWithPermissions:[NSArray arrayWithObjects:@"basic_info", @"email", nil] block:^(PFUser *user, NSError *error) {
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
           [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
               if (!error) {
                   [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbID"];
                   [[PFUser currentUser] saveInBackground];
               }
           }];
            
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
