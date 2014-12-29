//
//  InviteViewController.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import <UIKit/UIKit.h>

@interface InviteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *friendsArray;

@end
