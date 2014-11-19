//
//  CreateGameViewController.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/6/14.
//
//

#import <UIKit/UIKit.h>
#import "Game+SillyWords.h"

@interface CreateGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *facebookFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *randomOpponentButton;
@property (weak, nonatomic) IBOutlet UIButton *findByUserNameButton;

@property (strong, nonatomic) Game *game;

- (IBAction)findByUserNameButtonPressed:(id)sender;
- (IBAction)faceboookFriendsButtonPressed:(id)sender;
- (IBAction)randomOpponentButtonPressed:(id)sender;

@end
