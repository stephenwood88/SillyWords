//
//  FriendsViewController.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import "FriendsViewController.h"
#import "FindFriendsViewController.h"

#define FRIEND_INDEX 0
#define INVITE_INDEX 1

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case FRIEND_INDEX:
        {
            self.findFriendsContainerView.hidden = NO;
            self.inviteContainerView.hidden = YES;
        }
            break;
        case INVITE_INDEX:
        {
            self.findFriendsContainerView.hidden = YES;
            self.inviteContainerView.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"FindFriends"]) {
        FindFriendsViewController *ffvc = segue.destinationViewController;
        ffvc.game = self.game;
    }
}
@end
