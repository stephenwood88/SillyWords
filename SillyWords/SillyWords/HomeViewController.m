//
//  HomeViewController.m
//  TutorialBase
//
//  Created by Antonio MG on 6/23/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import "HomeViewController.h"
#import "GameViewController.h"
#import "HomeCell.h"
#import "GameCell.h"
#import "StoreViewController.h"
#import "CreateGameViewController.h"
#import "GlobalState.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
@property (nonatomic, strong) IBOutlet UIScrollView *wallScroll;
@property (nonatomic, retain) NSMutableArray *gamesArray;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSFetchRequest *request;
@property (nonatomic, strong) NSPredicate *gameUpdatePredicateTemplate;

@end

@implementation HomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
    [self updateGamesFromCoreData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self getWallImages];
    
    //some kind of game syncing is necessary here.  Refer to the Dish Sales app.  They don't do it in the view will appear, but they call several methods as the load appers.
    
    //So the Sales Rabbit does not perform a fetch request on viewwillappear.  Instead, a notification is given on viewdidLoad, and if there is a change in core data, then a fetch request is performed.  The order of the core data items should probably be determined by date create, that way the home table view is not rearranged every time the table reloads.
    
    NSManagedObjectContext *context = [[GlobalState singleton] managedObjectContext];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *timeStamp = [defaults objectForKey:kTimestamp];
    if (timeStamp == nil) {
        timeStamp = [NSDate distantPast];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updatedAt >= %@", timeStamp];
    PFQuery *query = [PFQuery queryWithClassName:@"Game" predicate:predicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if (objects) {
                if (objects.count) {
                    NSMutableArray *oldGameIds = [[NSMutableArray alloc] init];
                    for (PFObject *game in objects) {
                        [oldGameIds addObject:game.objectId];
                    }
                    NSFetchRequest *updateFetch = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
            //        updateFetch.predicate = [self.gameUpdatePredicateTemplate predicateWithSubstitutionVariables:@{@"GAME_IDS": oldGameIds}];
                    NSArray *gamesToUpdate = [context executeFetchRequest:updateFetch error:&error];
                }
            }
        }
    } ];
}

//#pragma mark - Private methods
//
//- (void)performFetchWithRequest:(NSFetchRequest *) request{
//    // Fetch
//    NSError *error = nil;
//    NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
//    self.currentLeadList = [coreDataArray mutableCopy];
//    if ([self.leadListSortKey isEqualToString:@"distance"]) {
//        [self sortResultsByDistance];
//    }
//    [self.leadTableView reloadData];
//}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        if ([self.gamesArray count] >0 ) {
            return [self.gamesArray count];
        }
        else {
            return 1;
        }
    }
    
    return 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
    
        GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameCell"];
    
        if (cell == nil) {
            cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameCell"];
        }
        
        if ([self.gamesArray count] > 0) {
            [cell setCell:[self.gamesArray objectAtIndex:indexPath.row]];
        }
        else {
            cell.textLabel.text = @"No Games";
        }
        
        [cell.layer setCornerRadius:7.0f];
        [cell.layer setMasksToBounds:YES];
        [cell.layer setBorderWidth:0.1f];
        
        return cell;
    }
    
    else {
        HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
        
        if (cell == nil) {
            cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
        }
        if (indexPath.section == 0) {
            cell.textLabel.text = @"New Game";
        }
    
        if (indexPath.section == 2) {
            cell.textLabel.text = @"Store";
        }
        
        [cell.layer setCornerRadius:7.0f];
        [cell.layer setMasksToBounds:YES];
        [cell.layer setBorderWidth:0.1f];
        
        return cell;
    }
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"CreateGameSegue" sender:self];
    }
    
    if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"StoreSegue" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 32;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Games";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && [self.gamesArray count]>0) {
        
        Game *temp = [self.gamesArray objectAtIndex:indexPath.row];
        
        //return number of players in the game
        return [temp.players count]*70.0;
    }
    
    return 44.0;
}

#pragma mark - Update Methods
-(void)updateGamesFromCoreData {
    self.gamesArray = [[[[GlobalState singleton] managedObjectContext] executeFetchRequest:self.request error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - Action methods
-(IBAction)logoutPressed:(id)sender
{
    [PFUser logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showErrorView:(NSString *)errorMsg{
    
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [errorAlertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if ([segue.identifier isEqualToString:@"StoreSegue"]) {
        StoreViewController *storeController = [segue destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"CreateGameSegue"]) {
        CreateGameViewController *createGameController = [segue destinationViewController];
    }
}

- (NSPredicate *)gameUpdatePredicateTemplate {
    
    if (!_gameUpdatePredicateTemplate) {
        _gameUpdatePredicateTemplate = [NSPredicate predicateWithFormat:@"(gameId IN $GAME_IDS)"];
    }
    return _gameUpdatePredicateTemplate;
}

@end
