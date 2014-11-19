//
//  GlobalState.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/23/14.
//
//

#import <Foundation/Foundation.h>

@interface GlobalState : NSObject

+ (instancetype)singleton;

@property (strong, nonatomic) NSArray *userFriends;
@property (strong, nonatomic) NSArray *allFriends;

@property (strong, nonatomic) UIManagedDocument *modelDocument;
// Core data model
- (NSManagedObjectContext *)managedObjectContext;

@end
