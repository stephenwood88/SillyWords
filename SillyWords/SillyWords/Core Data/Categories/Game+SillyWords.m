//
//  SillyWords+Game.m
//  TutorialBase
//
//  Created by Stephen Wood on 8/16/14.
//
//

#import "Game+SillyWords.h"
#import "GlobalState.h"

@implementation Game (SillyWords)

+ (Game *)newGame {
    NSManagedObjectContext *context = [[GlobalState singleton] managedObjectContext];
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
    return game;
}

@end
