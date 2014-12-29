//
//  AppDelegate.h
//  TutorialBase
//
//  Created by Antonio MG on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceCalls.h"
#import "GlobalState.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ServiceCalls *serviceCalls;
@property (strong, nonatomic) GlobalState *globalState;
+ (instancetype)singleton;

- (void)initializeCoreDataModel;


@end
