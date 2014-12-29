//
//  SavedAgreementsViewController.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/25/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSavedAgreementsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Person+Rabbit.h"

@interface SRSavedAgreementsViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) id <AgreementsDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *savedAgreements;
@property (strong, nonatomic) NSArray *submittedAgreements;

@property (strong, nonatomic) UIActionSheet *openConfirmation;
@property (weak, nonatomic) Agreement *agreementOpenConfirm;

@end

@implementation SRSavedAgreementsViewController

- (id)initWithDelegate:(id <AgreementsDelegate>)delegate {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self refreshAgreements];
    self.preferredContentSize = [self tableViewSize];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshAgreements {
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Agreement"];
    request.predicate = [NSPredicate predicateWithFormat:@"(userId == %@) AND (saved == %@)", [[SRGlobalState singleton] userId], @YES];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"submitted" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO]];
    NSError *error = nil;
    NSArray *agreements = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching saved agreements: %@", error.localizedDescription);
        self.savedAgreements = [NSMutableArray array];
        self.submittedAgreements = [NSArray array];
    }
    NSInteger i;
    for (i = 0; i < agreements.count && ![[agreements[i] submitted] boolValue]; i++);
    self.savedAgreements = [[agreements subarrayWithRange:NSMakeRange(0, i)] mutableCopy];
    self.submittedAgreements = [agreements subarrayWithRange:NSMakeRange(i, agreements.count - i)];
    
    [self.tableView reloadData];
    [self selectCurrentAgreement];
}

- (void)selectCurrentAgreement {
    
    NSIndexPath *selectedAgreement = nil;
    Agreement *currentAgreement = [self.delegate currentAgreement];
    if (currentAgreement) {
        if (![currentAgreement.submitted boolValue]) {
            selectedAgreement = [NSIndexPath indexPathForRow:[self.savedAgreements indexOfObject:currentAgreement] inSection:0];
        }
        else {
            selectedAgreement = [NSIndexPath indexPathForRow:[self.submittedAgreements indexOfObject:currentAgreement] inSection:1];
        }
        [self.tableView selectRowAtIndexPath:selectedAgreement animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)viewWillLayoutSubviews {
    
    //self.contentSizeForViewInPopover = CGSizeMake(320, 242);
    self.preferredContentSize = [self tableViewSize];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refreshAgreements];
    
    Agreement *currentAgreement = [self.delegate currentAgreement];
    if (![currentAgreement.submitted boolValue]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.savedAgreements indexOfObject:currentAgreement] inSection:0]];
        Person *person = currentAgreement.person;
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", person.firstName.length ? person.firstName : @"", person.firstName.length ? @" " : @"", person.lastName.length ? person.lastName : @""];
        if (currentAgreement.isCompleted) {
            cell.imageView.image = [UIImage imageNamed:@"agreement_status_completed"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"agreement_status_incomplete"];
        }
    }
}

- (CGSize)tableViewSize {
    
    NSInteger height = 18;
    for (NSInteger i = 0; i < [self.tableView numberOfSections]; i++) {
        height += [self.tableView rectForSection:i].size.height;
    }
    if (height < 242) {
        height = 242; // Minimum for UIActionSheet display
    }
    return CGSizeMake(320, height);
}

- (void)setEditing:(BOOL)editing {
    
    [super setEditing:editing];
    
    if (!editing) {
        [self selectCurrentAgreement];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (!editing) {
        [self selectCurrentAgreement];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.savedAgreements.count;
    }
    return self.submittedAgreements.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Saved";
    }
    return @"Submitted";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if ((section == 0 && !self.savedAgreements.count) || (section == 1 && !self.submittedAgreements.count)) {
        return @"None";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    Agreement *agreement;
    if (indexPath.section == 0) {
        agreement = self.savedAgreements[indexPath.row];
        if (agreement.isCompleted) {
            cell.imageView.image = [UIImage imageNamed:@"agreement_status_completed"];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"agreement_status_incomplete"];
        }
    }
    else {
        agreement = self.submittedAgreements[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"agreement_status_submitted"];
    }
    Person *person = agreement.person;
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@", person.firstName.length ? person.firstName : @"", person.firstName.length ? @" " : @"", person.lastName.length ? person.lastName : @""];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d/yyyy";
    cell.detailTextLabel.text = [formatter stringFromDate:agreement.dateCreated];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // Don't allow the current agreement to be deleted
        if (![[self.tableView indexPathForSelectedRow] isEqual:indexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
        [[self.savedAgreements objectAtIndex:indexPath.row] deleteAgreement];
        [self.savedAgreements removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Agreement *agreement;
    if (indexPath.section == 0) {
        agreement = self.savedAgreements[indexPath.row];
    }
    else {
        agreement = self.submittedAgreements[indexPath.row];
    }
    if (self.delegate.confirmSaveNeeded) {
        self.agreementOpenConfirm = agreement;
        self.openConfirmation = [[UIActionSheet alloc] initWithTitle:kOpenConfirmation delegate:self cancelButtonTitle:kNo destructiveButtonTitle:kYes otherButtonTitles:kSave, nil];
        [self.openConfirmation showInView:self.tableView];
    }
    else {
        [self.delegate agreementSelected:agreement savePrevious:NO];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == self.openConfirmation) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self.delegate agreementSelected:self.agreementOpenConfirm savePrevious:NO];
        }
        else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self.delegate agreementSelected:self.agreementOpenConfirm savePrevious:YES];
        }
        else if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
        self.openConfirmation = nil;
        self.agreementOpenConfirm = nil;
    }
}

@end
