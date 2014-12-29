//
//  Game.h
//  TutorialBase
//
//  Created by Stephen Wood on 7/31/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Player+SillyWords.h"


@interface Game : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *players;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSNumber * judge;
@property (nonatomic, retain) NSDate * dateOfTurn;
@property (nonatomic, retain) NSString * gameId;

@end
@interface Game (CoreDataGeneratedAccessors)

- (void)insertObject:(Player *)value inPlayersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPlayersAtIndex:(NSUInteger)idx;
- (void)insertPlayers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePlayersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPlayersAtIndex:(NSUInteger)idx withObject:(Player *)value;
- (void)replacePlayersAtIndexes:(NSIndexSet *)indexes withPlayers:(NSArray *)values;
- (void)addPlayersObject:(Player *)value;
- (void)removePlayerObject:(Player *)value;
- (void)addPlayers:(NSOrderedSet *)values;
- (void)removePlayers:(NSOrderedSet *)values;

@end
