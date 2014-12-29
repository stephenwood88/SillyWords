//
//  TableViewController.h
//  TutorialBase
//
//  Created by Stephen Wood on 8/24/14.
//
//

#import <UIKit/UIKit.h>
#import "Game+SillyWords.h"

@interface GamePrepViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Game *gameToEdit;
@property (weak, nonatomic) IBOutlet UIButton *playGameButton;
- (IBAction)playNewGame:(UIButton *)sender;

@end
