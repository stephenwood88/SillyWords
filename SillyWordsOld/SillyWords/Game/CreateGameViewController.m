//
//  CreateGameViewController.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/6/14.
//
//

#import "CreateGameViewController.h"
#import "FriendsViewController.h"

@interface CreateGameViewController ()

@end

@implementation CreateGameViewController

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

- (IBAction)findByUserNameButtonPressed:(id)sender {
    
    
}

- (IBAction)faceboookFriendsButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"FriendsSegue" sender:self];
}

- (IBAction)randomOpponentButtonPressed:(id)sender {
}

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"ListToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.leadTableView indexPathForCell:cell];
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        Lead *selectedLead = [self.currentLeadList objectAtIndex:selectedIndex.row];
        self.leadJustEdited = YES;
        ldtvc.leadToEdit = selectedLead;
    }
}*/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"FriendsSegue"]) {
        FriendsViewController *fvc = segue.destinationViewController;
        fvc.game = self.game;
    }
}
@end
