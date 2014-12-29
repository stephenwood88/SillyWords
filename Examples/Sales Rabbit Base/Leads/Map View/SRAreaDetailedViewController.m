//
//  SRAreaDetailedViewController.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/28/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRAreaDetailedViewController.h"
#import "SRRepTableViewCell.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRPremiumMapViewController.h"
#import "Area+Rabbit.h"
#import "Office+Rabbit.h"

#define REPTYPE 1
#define MANAGERTYPE 3
#define REGIONALTYPE 5
#define ADMINTYPE 12
#define DEVELOPERTYPE 13

@interface SRAreaDetailedViewController ()
{
    BOOL showInactiveReps;
}

@property IBOutlet SRRepTableViewCell *customCell;

@end

@implementation SRAreaDetailedViewController

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
    // Do any additional setup after loading the view from its nib.
    self.repsSegmentedControl.tintColor = [UIColor whiteColor];
    self.activeRepsArray = [[NSMutableArray alloc] initWithArray:[self.selectedArea.activeUsers array]];
    self.inactiveRepsArray = [[NSMutableArray alloc] initWithArray:[self.selectedArea.inactiveUsers allObjects]];
    showInactiveReps = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    // If an Admin or Regional select an Area which is not on their current Office, then they should still see this view but cannot add reps
//    NSInteger userType = [[[SRGlobalState singleton] userType] integerValue];
    
//    if ((userType == ADMINTYPE || userType == REGIONALTYPE) && ![self.selectedArea.office.officeId isEqualToString:[[SRGlobalState singleton] officeId]]) {
//        self.addRepButton.enabled = NO;
//    }
//    else{
//        self.addRepButton.enabled = YES;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TablewView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (showInactiveReps) {
        return self.inactiveRepsArray.count;
    }
    else
    {
        return self.activeRepsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRRepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repAreaTableViewCell"];
    
    if (cell == nil) {
        cell = [[SRRepTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repAreaTableViewCell"];
        [[NSBundle mainBundle] loadNibNamed:@"SRRepTableViewCell" owner:self options:nil];
        cell = _customCell;
        _customCell = nil;
    }
    
    if (showInactiveReps) {
        User *tempUser = [self.inactiveRepsArray objectAtIndex:indexPath.row];
        cell.repColorView.backgroundColor = [UIColor colorWithRed:[tempUser.red floatValue] green:[tempUser.green floatValue] blue:[tempUser.blue floatValue] alpha:1];
        cell.repName.text = [NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName];
    }
    else
    {
        User *tempUser = [self.activeRepsArray objectAtIndex:indexPath.row];
        cell.repColorView.backgroundColor = [UIColor colorWithRed:[tempUser.red floatValue] green:[tempUser.green floatValue] blue:[tempUser.blue floatValue] alpha:1];
        cell.repName.text = [NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName];
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showInactiveReps) {
        User *tmpUser = [self.inactiveRepsArray objectAtIndex:indexPath.row];
        NSMutableSet *inactiveSet = [[NSMutableSet alloc] initWithSet:self.selectedArea.inactiveUsers];
        [self.inactiveRepsArray removeObject:tmpUser];
        [inactiveSet removeObject:tmpUser];
        self.selectedArea.inactiveUsers = inactiveSet;
    }
    else
    {
        User *tmpUser = [self.activeRepsArray objectAtIndex:indexPath.row];
        NSMutableOrderedSet *activeSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.selectedArea.activeUsers];
        NSMutableSet *inactiveSet = [[NSMutableSet alloc] initWithSet:self.selectedArea.inactiveUsers];
        [activeSet removeObject:tmpUser];
        [inactiveSet addObject:tmpUser];
        [self.activeRepsArray removeObject:tmpUser];
        [self.inactiveRepsArray addObject:tmpUser];
        self.selectedArea.activeUsers = activeSet;
        self.selectedArea.inactiveUsers = inactiveSet;
        
        tmpUser.activeArea = nil;
        
        [self.delegate areaDetailed:self didDeleteActiveRep:tmpUser];
    }
    
    [self.activeRepsTableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
#warning Change This after implementing deleting inactive reps on service calls and server in order to implement deletion on the UI
    if (showInactiveReps) {
        return NO;
    }
    else{
        return YES;
    }
}

- (void)updateReps
{
    self.activeRepsArray = [[NSMutableArray alloc] initWithArray:[self.selectedArea.activeUsers array]];
    self.inactiveRepsArray = [[NSMutableArray alloc] initWithArray:[self.selectedArea.inactiveUsers allObjects]];
    [self.activeRepsTableView reloadData];
}


#pragma mark - IBAction Methods

- (IBAction)deleteButtonPressed:(UIBarButtonItem *)sender {
    
    UIActionSheet *deleteAreaActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this area?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [deleteAreaActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    else
    {
        [deleteAreaActionSheet showInView:self.view];
    }
}

- (IBAction)addRepButtonPressed:(UIBarButtonItem *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"newRepSegueIphone" sender:self];
    }
    else{
        [self.delegate isGoingToAddNewRep];
    }
}

- (IBAction)repTypeValueChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        showInactiveReps = NO;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        showInactiveReps = YES;
    }
    
    [self.activeRepsTableView reloadData];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate areaDetailedCancelButtonPressed:self];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.delegate isGoingToDeleteArea:self.selectedArea andController:self];
    }
    else if(buttonIndex == 1){
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark - Prepare for Segue for Delegate (for iPhone)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"newRepSegueIphone"]) {
        UINavigationController *nav = segue.destinationViewController;
        SRNewRepViewController *destinationController = [nav.viewControllers objectAtIndex:0];
        //Passing along the delegate since SRPremiumMapController handles all the area UI manipulation
        destinationController.delegate = (SRPremiumMapViewController *)self.delegate;
        destinationController.selectedArea = self.selectedArea;
    }
}

@end
