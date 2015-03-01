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
@property (nonatomic, retain) NSArray *gamesArray;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@end

@implementation HomeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self getWallImages];
      self.gamesArray = [[NSArray alloc] init];
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"games"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSDictionary *gamesWithPlayers = [[NSDictionary alloc] init];
            
            //Make a dictionary that has the games with their corresponding players.  Parse will fetch the games with the current code but not the players that correspond to that game
            self.gamesArray = objects;
            [self.tableView reloadData];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            NSLog(@"Error with Game: %@" , error);
        }
        
    }];
}

#pragma mark - Private methods

//-(void)getWallImages
//{
//    // 1
//    PFQuery *query = [PFQuery queryWithClassName:@"WallImageObject"];
//    
//    // 2
//    [query orderByDescending:@"createdAt"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        // 3
//        if (!error) {
//            self.wallObjectsArray = objects;
//            [self loadWallViews];
//        } else {
//            // 4
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error userInfo][@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//    }];
//}
//
//-(void)loadWallViews
//{
//    // Clean the scroll view
//    [self.wallScroll.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isMemberOfClass:[UIView class]]) [obj removeFromSuperview];
//    }];
//    
//    __block int originY = 10;
//    
//    [self.wallObjectsArray enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
//        // 1
//        UIView *wallImageView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, originY, self.view.frame.size.width - 20.0f, 300.0f)];
//        
//        // 2
//        PFFile *image = (PFFile *)wallImageObject[@"image"];
//        UIImageView *userImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:[image getData]]];
//        userImage.frame = CGRectMake(0.0f, 0.0f, wallImageView.frame.size.width, 200.0f);
//        userImage.contentMode = UIViewContentModeScaleAspectFit;
//        [wallImageView addSubview:userImage];
//        
//        // 3
//        NSDate *creationDate = wallImageObject.createdAt;
//        NSDateFormatter *formatter = [NSDateFormatter new];
//        formatter.dateStyle = NSDateFormatterShortStyle;
//        formatter.timeStyle = NSDateFormatterShortStyle;
//        
//        // 4
//        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 210.0f, wallImageView.frame.size.width, 15.0f)];
//        infoLabel.text = [NSString stringWithFormat:@"Uploaded by: %@, %@", wallImageObject[@"user"], [formatter stringFromDate:creationDate]];
//        infoLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:9.0f];
//        infoLabel.textColor = [UIColor whiteColor];
//        infoLabel.backgroundColor = [UIColor clearColor];
//        [wallImageView addSubview:infoLabel];
//        
//        // 5
//        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 240.0f, wallImageView.frame.size.width, 15.0f)];
//        commentLabel.text = wallImageObject[@"comment"];
//        commentLabel.font = [UIFont fontWithName:@"ArialMT" size:13.0f];
//        commentLabel.textColor = [UIColor whiteColor];
//        commentLabel.backgroundColor = [UIColor clearColor];
//        [wallImageView addSubview:commentLabel];
//        
//        // 6
//        [self.wallScroll addSubview:wallImageView];
//        originY += (wallImageView.frame.size.height + 20);
//    }];
//    
//    // 7
//    self.wallScroll.contentSize = CGSizeMake(self.wallScroll.frame.size.width, originY);
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
