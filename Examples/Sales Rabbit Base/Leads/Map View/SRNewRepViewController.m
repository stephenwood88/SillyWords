//
//  SRNewRepViewController.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/7/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRNewRepViewController.h"
#import "SRRepTableViewCell.h"
#import "SRGlobalState.h"
#import "User+Rabbit.h"
#import "Office+Rabbit.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRPremiumConstants.h"


#define REPTYPE 1
#define MANAGERTYPE 3
#define REGIONALTYPE 5
#define ADMINTYPE 12

@interface SRNewRepViewController ()
{
    // These are to keep track of the changes to do when we tap Save button
    NSMutableArray *areasToUpdate;
    NSMutableOrderedSet *repsToAdd;
    NSMutableSet *inactiveSet;
    
    NSInteger userType;
    
    UIActionSheet *actionSheet;
}

@property (strong, nonatomic) NSFetchRequest *userRequest;
@property (strong, nonatomic) NSMutableArray *selectedCells;

@end

@implementation SRNewRepViewController

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
    
    self.userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    self.selectedCells = [[NSMutableArray alloc] init];
    
    userType = [[[SRGlobalState singleton] userType] integerValue];
        
    [self performFetchWithRequest:self.userRequest];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableRepsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRRepTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repTableViewCell"];
    
    if (cell == nil) {
        cell = [[SRRepTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repTableViewCell"];
    }
    
    User *tempUser = [self.availableRepsArray objectAtIndex:indexPath.row];
    cell.repName.text = [NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName];
    UIColor *tempColor = [UIColor colorWithRed:[tempUser.red floatValue] green:[tempUser.green floatValue] blue:[tempUser.blue floatValue] alpha:1];
    cell.repColorView.backgroundColor = tempColor;
    cell.displayStatus = YES;
    if (tempUser.activeArea) {
        cell.statusColor = [UIColor colorWithRed:0.008 green:0.699 blue:0.013 alpha:0.900];
        cell.activeAreaStatus.text = @"Assigned";
    }
    else{
        cell.statusColor = [UIColor colorWithRed:0.739 green:0.084 blue:0.101 alpha:0.900];
        cell.activeAreaStatus.text = @"Unassigned";
    }
    
    if ([self.selectedArea.activeUsers containsObject:[self.availableRepsArray objectAtIndex:indexPath.row]]) {
        [self.selectedCells addObject:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRRepTableViewCell *cell = (SRRepTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedCells removeObject:indexPath];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedCells addObject:indexPath];
    }
}


#pragma mark - IBAction Methods for Bar Buttons

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    
    repsToAdd = [[NSMutableOrderedSet alloc] init];
    inactiveSet = [[NSMutableSet alloc] initWithSet:self.selectedArea.inactiveUsers];
    NSArray *activeReps = [self.selectedArea.activeUsers array];
    areasToUpdate = [[NSMutableArray alloc] init];
    
    // Gather all the selected reps
    for (int i=0; i<self.selectedCells.count; i++) {
        User *userToAdd = [self.availableRepsArray objectAtIndex:[[self.selectedCells objectAtIndex:i] row]];
        
        //Check if this rep is active in another area already
        if (userToAdd.activeArea != nil && ![userToAdd.activeArea isEqual:self.selectedArea]) {
            [areasToUpdate addObject:userToAdd.activeArea];
        }
        
        [repsToAdd insertObject:userToAdd atIndex:0];
        [inactiveSet removeObject:userToAdd];
        
    }
    
    //Now determine which ones are going to inactive since they were deselected
    for (int i=0; i<activeReps.count; i++) {
        if (![repsToAdd containsObject:[activeReps objectAtIndex:i]]) {
            [inactiveSet addObject:[activeReps objectAtIndex:i]];
        }
    }
    
    //Before we save all the changes ask if there are any reps active in other areas and confirm we want to continue
    if (areasToUpdate.count > 0) {
        
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"The selected rep(s) is(are) active in another area.  Would you like to remove the rep(s) from their current area(s)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
        else{
            [actionSheet showFromBarButtonItem:self.saveButton animated:YES];
        }
        
    }
    else
    {
        //otherwise just update the changes to the selected area
        self.selectedArea.activeUsers = repsToAdd;
        self.selectedArea.inactiveUsers = inactiveSet;
        
        [self.delegate didPressSaveNewReps];
        //NSLog(@"Syncing reps changed in area...");
        [[SRPremiumSalesServiceCalls singleton] sync];
    }
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    [self.delegate didPresscancelSaveNewReps];
}


#pragma mark - Loading Available Reps

- (void)performFetchWithRequest:(NSFetchRequest *) request{
    // Fetch
    
    request.predicate = [NSPredicate predicateWithFormat:@"ANY offices.officeId == %@", self.selectedArea.office.officeId];

    NSError *error = nil;
    NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    self.availableRepsArray = [coreDataArray mutableCopy];
    
    NSSortDescriptor *sortfirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    NSArray *reps = [self.availableRepsArray sortedArrayUsingDescriptors:@[sortfirstName, sortLastName]];
    self.availableRepsArray = [[NSMutableArray alloc] initWithArray:reps];
    
    [self.repTableView reloadData];
}

#pragma mark - Delegate Methods for UIActionSheet



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //If there was reps that were active in another area, move them to inactive
        NSArray *reps = [repsToAdd array];
        for (int i=0; i<reps.count; i++) {
            User *tempUser = [reps objectAtIndex:i];
            Area *activeArea = tempUser.activeArea;
            NSMutableOrderedSet *activeReps = [[NSMutableOrderedSet alloc] initWithOrderedSet:activeArea.activeUsers];
            NSMutableSet *inactiveReps = [[NSMutableSet alloc] initWithSet:activeArea.inactiveUsers];
            [activeReps removeObject:tempUser];
            [inactiveReps addObject:tempUser];
            activeArea.activeUsers = activeReps;
            activeArea.inactiveUsers = inactiveReps;
        }

        // Set the final reps to the selected area and call the delegate method
        self.selectedArea.activeUsers = repsToAdd;
        self.selectedArea.inactiveUsers = inactiveSet;
        [self.delegate newRepViewController:self didSaveRep:reps fromAreas:areasToUpdate];
        
        //NSLog(@"Syncing reps changed in area...");
        [[SRPremiumSalesServiceCalls singleton] sync];
    }
}

@end
