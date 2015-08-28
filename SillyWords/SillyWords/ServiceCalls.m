//
//  ServiceCalls.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/23/14.
//
//

#import "ServiceCalls.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation ServiceCalls

+ (instancetype)singleton {
    
    static dispatch_once_t once;
    static ServiceCalls *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success, PFUser *user, NSError *error))completionHandler{
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            completionHandler(YES,user,nil);
        } else {
            completionHandler(NO,user,error);
        }
    }];
}

//- (void)getFacebookFriendsWithCompletionHandler:(void (^)(BOOL success, NSArray *allFriends, NSArray *userFriends, NSError *error))completionHandler {
//
//    if ([FBSDKAccessToken currentAccessToken]) {
//        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                if (!error) {
//                    // result will contain an array with your user's friends in the "data" key
//
//                    NSMutableArray *friendObjects = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"data"]];
//                    NSMutableArray *tempFriendObjects = [[NSMutableArray alloc] initWithArray:friendObjects];
//                    NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
//                    // Create a list of friends' Facebook IDs
//                    for (NSDictionary *friendObject in friendObjects) {
//                        [friendIds addObject:[friendObject objectForKey:@"id"]];
//                    }
//
//                    // Construct a PFUser query that will find friends whose facebook ids
//                    // are contained in the current user's friend list.
//                    PFQuery *friendQuery = [PFUser query];
//                    [friendQuery whereKey:@"fbID" containedIn:friendIds];
//
//                    // findObjects will return a list of PFUsers that are friends
//                    // with the current user
//                    NSArray *friendUsers = [friendQuery findObjects];
//                    NSMutableArray *friendUsersReturnArray = [[NSMutableArray alloc] init];
//                    for (PFObject *dictionary in friendUsers) {
//                        for (NSDictionary *friendDict in friendObjects) {
//                            if ([[dictionary objectForKey:@"fbID"] isEqualToString:[NSString stringWithFormat:@"%@", [friendDict objectForKey:@"id"]]]) {
//                                NSDictionary *userDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:friendDict, kFacebookInfo, dictionary.objectId, kUserInfo , nil];
//                                [friendUsersReturnArray addObject:userDictionary];
//                                [tempFriendObjects removeObject:friendDict];
//                            }
//                        }
//                    }
//                    friendObjects = tempFriendObjects;
//                    completionHandler(YES, friendObjects,friendUsersReturnArray, error);
//                }
//     
//                else {
//                    completionHandler(NO, nil, nil, nil);
//                }
//         }];
//    }
//}
//    [FBSDKGraphRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {


//Some kind of sync function is needed here.  It needs to see when the device had last been synced and then query parse for all games that had been created after that sync date.  Then the new synced games need to be loaded to the home view controller.
//- (void)syncGames

@end
