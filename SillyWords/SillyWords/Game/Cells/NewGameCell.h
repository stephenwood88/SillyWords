//
//  NewGameCell.h
//  TutorialBase
//
//  Created by Stephen Wood on 2/26/14.
//
//

#import <UIKit/UIKit.h>
#import "Player+SillyWords.h"

@interface NewGameCell : UITableViewCell

@property (weak, nonatomic) NSString *facebookID;
@property (weak, nonatomic) IBOutlet UILabel *facebookFriendNameLabel;

- (void)setCell:(Player *)player;

@end
