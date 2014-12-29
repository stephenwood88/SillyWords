//
//  SRPremiumLeadsListViewController.m
//  Dish Sales
//
//  Created by Matthew McArthur on 12/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRPremiumLeadsListViewController.h"
#import "SRLeadDetailTableViewController.h"

@interface SRPremiumLeadsListViewController ()

@end

@implementation SRPremiumLeadsListViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqual:@"ListToLeadDetail"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *selectedIndex = [self.leadTableView indexPathForCell:cell];
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        Lead *selectedLead = [self.currentLeadList objectAtIndex:selectedIndex.row];
        self.leadJustEdited = YES;
        ldtvc.leadToEdit = selectedLead;
    }
}

@end
