//
//  Player+SillyWords.m
//  TutorialBase
//
//  Created by Stephen Wood on 8/16/14.
//
//

#import "Player+SillyWords.h"
#import "GlobalState.h"

@implementation Player (SillyWords)

+ (Player *)newPlayer {
    NSManagedObjectContext *context = [[GlobalState singleton] managedObjectContext];
    Player *player = [NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:context];
    // [Person newPersonForLead:lead];
    return player;
}

@end
