//
//  SillyWords+Game.m
//  TutorialBase
//
//  Created by Stephen Wood on 8/16/14.
//
//

#import "Game+SillyWords.h"
#import "GlobalState.h"
#import "GlobalState.h"

@implementation Game (SillyWords)

+ (Game *)newGame {
    NSManagedObjectContext *context = [[GlobalState singleton] managedObjectContext];
    Game *game = [NSEntityDescription insertNewObjectForEntityForName:@"Game" inManagedObjectContext:context];
    return game;
}

- (void)deleteGame {//(BOOL)syncDelete {

//    // If there isn't a lead ID, it hasn't been synced yet anyway
//    if (syncDelete && self.leadId) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSMutableSet *deletedLeadIds = [NSMutableSet setWithArray:[defaults objectForKey:kDeletedLeadIds]];
//        [deletedLeadIds addObject:self.leadId];
//        [defaults setObject:[deletedLeadIds allObjects] forKey:kDeletedLeadIds];
//        [defaults synchronize];
//    }
//    
//    //Cancel scheduled notification
//    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
//        if (self.leadId && [[notification.userInfo objectForKey:kLeadId] isEqualToString:self.leadId]) {
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//            break;
//        }
//        else if (self.leadId == nil && [[notification.userInfo objectForKey:kLeadId] isEqualToString:@"New Lead"]) {
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//            break;
//        }
//    }
    
    //    //Remove calendar event
    //    EKEventStore *eventStore = [[EKEventStore alloc] init];
    //    EKEvent *event = [eventStore eventWithIdentifier:self.iosCalEventId];
    //    if (event != nil) {
    //        [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
    //    }
    
    NSManagedObjectContext *context = [[GlobalState singleton] managedObjectContext];
    
    [context deleteObject:self];
}

@end
