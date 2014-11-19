//
//  FindFriendsViewController.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import <UIKit/UIKit.h>
#import "Game+SillyWords.h"

@interface FindFriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableDictionary *sections;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) NSMutableArray *chosenFriendsArray;
@property (strong, nonatomic) Game *game;

- (IBAction)submitButtonPressed:(UIButton *)sender;
@end
