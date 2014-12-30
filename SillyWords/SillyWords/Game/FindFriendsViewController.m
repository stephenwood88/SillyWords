//
//  FindFriendsViewController.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import "FindFriendsViewController.h"
#import "GamePrepViewController.h"
#import "GlobalState.h"
#import "Constants.h"
#import "FacebookCell.h"
#import "Player+SillyWords.h"

@interface FindFriendsViewController () <UINavigationControllerDelegate>

@end

@implementation FindFriendsViewController

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
    self.friendsArray = [[NSMutableArray alloc] initWithArray:[[GlobalState singleton] userFriends]];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (Player *player in self.game.players) {
        for (NSDictionary *friendDictionary in self.friendsArray) {
            if ([player.facebookID isEqualToString:[[friendDictionary objectForKey:kFacebookInfo] objectForKey:kFacebookID]]) {
                [tempArray addObject:friendDictionary];
            }
        }
    }
    [self.friendsArray removeObjectsInArray:tempArray];
    self.chosenFriendsArray = [[NSMutableArray alloc] init];
    BOOL found;
    self.sections = [[NSMutableDictionary alloc] init];
    // Loop through the books and create our keys
    for (NSDictionary *dict in self.friendsArray)
    {
        NSString *c = [[[dict objectForKey:kFacebookInfo] objectForKey:@"first_name"] substringToIndex:1];
        
        found = NO;
        
        for (NSString *str in [self.sections allKeys])
        {
            if ([str isEqualToString:c])
            {
                found = YES;
            }
        }
        
        if (!found)
        {
            [self.sections setValue:[[NSMutableArray alloc] init] forKey:c];
        }
    }
//    NSArray *alphabet = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];NSInteger index = 0;
//    
//    for(NSString *character in alphabet)
//    {
//        index ++;
//        [self.sections setObject:[[NSMutableArray alloc] init] forKey:character];
//    }
    
    // Loop again and sort the books into their respective keys
    for (NSDictionary *dictionary in self.friendsArray)
    {
        [[self.sections objectForKey:[[[dictionary objectForKey:kFacebookInfo] objectForKey:@"first_name"] substringToIndex:1]] addObject:dictionary];
    }
    
    // Sort each section array
    for (NSString *key in [self.sections allKeys])
    {
        [[self.sections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES]]];
    }
    
    self.tableView.allowsMultipleSelection = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu", (unsigned long)[[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count]);
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"%@", indexPath);
    FacebookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell"];
    
    if (cell == nil) {
        cell = [[FacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookCell"];
    }
    
    if ([self.friendsArray count] > 0) {
        NSDictionary *dictionary = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        NSString *name = [[dictionary objectForKey:kFacebookInfo] objectForKey:@"name"];
        NSString *friendID = [[dictionary objectForKey:kFacebookInfo] objectForKey:@"id"];
        NSString *userId = [dictionary objectForKey:kUserInfo];
        [cell setCell:friendID name:name userId:userId];
    }
    
    return cell;
}

#pragma mark UITableView Delegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookCell *tableViewCell = (FacebookCell *)[tableView cellForRowAtIndexPath:indexPath];
    tableViewCell.accessoryView.hidden = NO;
    tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
    Player *newPlayer = [Player newPlayer];
    newPlayer.facebookID = tableViewCell.facebookID;
    newPlayer.fullName = tableViewCell.facebookFriendNameLabel.text;
    newPlayer.userId = tableViewCell.userId;
    newPlayer.game = self.game;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookCell *tableViewCell = (FacebookCell *)[tableView cellForRowAtIndexPath:indexPath];
    for (NSMutableDictionary *friendDictionary in self.chosenFriendsArray) {
        if ([tableViewCell.facebookID isEqualToString:[friendDictionary objectForKey:kFacebookID]]) {
            [self.chosenFriendsArray removeObject:friendDictionary];
        }
    }
    tableViewCell.accessoryView.hidden = YES;
    tableViewCell.accessoryType = UITableViewCellAccessoryNone;
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

- (IBAction)submitButtonPressed:(UIButton *)sender {
    GamePrepViewController *gamePrepController =  [self.navigationController.viewControllers objectAtIndex:2];
    gamePrepController.gameToEdit = self.game;
    [self.navigationController popToViewController:gamePrepController animated:YES];
    //[self performSegueWithIdentifier:@"ChosenFriendsSegue" sender:self];
}
@end
