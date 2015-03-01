//
//  TableViewController.m
//  TutorialBase
//
//  Created by Stephen Wood on 8/24/14.
//
//

#import "GamePrepViewController.h"
#import "CreateGameViewController.h"
#import "GameViewController.h"
#import "NewGameCell.h"
#import "FacebookCell.h"
#import "Game+SillyWords.h"
#import "Player+SillyWords.h"
#import "Constants.h"
#import "GlobalState.h"

@interface GamePrepViewController ()

@end

@implementation GamePrepViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.gameToEdit == nil) {
        self.gameToEdit = [Game newGame];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    if ([self.gameToEdit.players count] >=2) {
        self.playGameButton.hidden = NO;
    }
    else {
        self.playGameButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.gameToEdit.players count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewGameCell"];
    
    // Configure the cell...
    
    if (cell == nil) {
        cell = [[NewGameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewGameCell"];
    }
    
    if ([self.gameToEdit.players count] > 0) {

        [cell setCell:[self.gameToEdit.players objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320 ,60)];
    UIButton *addPlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 100, 40)];
    [addPlayerButton setTitle:@"Add Player" forState:UIControlStateNormal];
    addPlayerButton.backgroundColor = [UIColor redColor];
    [addPlayerButton addTarget:self action:@selector(addPlayerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:addPlayerButton];
    return  footer;
}

- (void)addPlayerButtonPressed:(id) sender {
    [self performSegueWithIdentifier:@"GetFriendSegue" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
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
 }
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"GetFriendSegue"]) {
        CreateGameViewController *cgvc = segue.destinationViewController;
        cgvc.game = self.gameToEdit;
    }
    if ([segue.identifier isEqual:@"StartGameSegue"]) {
        GameViewController *gvc = segue.destinationViewController;
        gvc.game = self.gameToEdit;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playNewGame:(UIButton *)sender {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    Player *userPlayer = [Player newPlayer];
    userPlayer.facebookID = [[PFUser currentUser] objectForKey:kFacebookID];
    userPlayer.fullName = [GlobalState singleton].username;
    userPlayer.userId = [[PFUser currentUser] objectId];
    userPlayer.game = self.gameToEdit;
    for (Player *player in self.gameToEdit.players) {
        PFObject *newPlayer = [PFObject objectWithClassName:kPlayerClassName];
        [newPlayer setObject:[PFObject objectWithoutDataWithClassName:kUserClassName objectId:player.userId] forKey:@"user"];
        newPlayer[@"points"] = @0;
        [array addObject:newPlayer];
    }
    
    [PFObject saveAllInBackground:array block:^(BOOL success, NSError *error){
        PFObject *newGame = [PFObject objectWithClassName:kGameClassName];
        PFRelation *gameToPlayerRelation = [newGame relationForKey:@"playerList"];
        
        for (PFObject *player in array) {
            [gameToPlayerRelation addObject:player];
        }
        [newGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                PFRelation *userToGameRelation = [[PFUser currentUser] relationForKey:@"games"];
                [userToGameRelation addObject:newGame];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        GameViewController *gameController =  [self.navigationController.viewControllers objectAtIndex:1];
                        //gamePrepController.gameToEdit = self.game;
                        [self.navigationController popToViewController:gameController animated:YES];
                    }
                    else {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        NSLog(@"Error with User: %@" , error);
                    }
            }];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                NSLog(@"Error with Game: %@" , error);
            }
        }];
        
        
        
        /*WithBlock:^(BOOL succeeded, NSError *error) {
                PFRelation *relation = [newGame relationForKey:@"playerList"];
                PFQuery *query = [relation query];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    for (PFObject *player in objects) {
                        PFUser *user = [player objectForKey:@"user"];
                        PFRelation *userToGameRelation = [user relationForKey:@"games"];
                        [userToGameRelation addObject:newGame];
                        [user saveInBackground];
                    }
                }];
                
            }];*/
        
    }];
    
}
@end
