//
//  GlobalState.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/23/14.
//
//

#import "GlobalState.h"
#import "AppDelegate.h"

@implementation GlobalState

+ (instancetype)singleton {
    
    static dispatch_once_t once;
    static GlobalState *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    return self.modelDocument.managedObjectContext;
}

@end
