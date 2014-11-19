//
//  FriendsViewController.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import <UIKit/UIKit.h>
#import "Game+SillyWords.h"

@interface FriendsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *inviteContainerView;
@property (weak, nonatomic) IBOutlet UIView *findFriendsContainerView;
@property (strong, nonatomic) Game *game;

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender;

@end
