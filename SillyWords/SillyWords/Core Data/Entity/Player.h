//
//  Player.h
//  TutorialBase
//
//  Created by Stephen Wood on 8/6/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;
@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * points;
@property (nonatomic, retain) NSString * sillyWord;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * partName;
@property (nonatomic, retain) Game * game;

@end
