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
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
@property (nonatomic, strong) IBOutlet UIScrollView *wallScroll;
@property (nonatomic, retain) NSMutableArray *gamesArray;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSFetchRequest *request;
@end

@implementation HomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.request = [NSFetchRequest fetchRequestWithEntityName:@"Game"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self getWallImages];
    
    //some kind of game syncing is necessary here.  Refer to the Dish Sales app.  They don't do it in the view will appera, but they call several methods as the load appers.
    
      self.gamesArray = [[NSMutableArray alloc] init];
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"games"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (id game in objects) {
                PFRelation *playerRelation = [game relationForKey:@"playerList"];
                PFQuery *playerListQuesry = [playerRelation query];
                [playerListQuesry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:game, @"game", objects, @"playerList", nil];
                    [self.gamesArray addObject:dictionary];
                    [self.tableView reloadData];

                }];
            }
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Error with Game: %@" , error);
        }
        
    }];
}

#pragma mark - Private methods

- (void)performFetchWithRequest:(NSFetchRequest *) request{
    // Fetch
    NSError *error = nil;
    NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    self.currentLeadList = [coreDataArray mutableCopy];
    if ([self.leadListSortKey isEqualToString:@"distance"]) {
        [self sortResultsByDistance];
    }
    [self.leadTableView reloadData];
}

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
        
        return [self.gamesArray count]*70.0;
    }
    
    return 44.0;
}


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

@end
