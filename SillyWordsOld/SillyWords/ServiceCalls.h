//
//  ServiceCalls.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/23/14.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ServiceCalls : NSObject

+ (instancetype)singleton;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void (^)(BOOL success, PFUser *user, NSError *error))completionHandler;

- (void)getFacebookFriendsWithCompletionHandler:(void (^)(BOOL success, NSArray *allFriends, NSArray *userFriends, NSError *error))completionHandler;

@end
