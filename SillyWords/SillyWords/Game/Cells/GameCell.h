//
//  NewGameCell.h
//  TutorialBase
//
//  Created by Stephen Wood on 2/26/14.
//
//

#import <UIKit/UIKit.h>
#import "Player+SillyWords.h"

@interface GameCell : UITableViewCell

@property (weak, nonatomic) NSString *facebookID;
@property (weak, nonatomic) IBOutlet UILabel *facebookFriendNameLabel;

- (void)setCell:(Game *)game;

@end
