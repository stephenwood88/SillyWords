//
//  ChannelsViewController.m
//  DishTech
//
//  Created by Aaron Brown on 5/29/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import "ChannelsViewController.h"
#import "CategoryViewController.h"
#import "Constants.h"
#import "SRGlobalState.h"

@interface ChannelsViewController ()

@end

@implementation ChannelsViewController
@synthesize dishButton;
@synthesize directvButton;


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
    if ([[[SRGlobalState singleton] satelliteProvider] caseInsensitiveCompare:kDirecTv] == NSOrderedSame) {
        self.dishButton.hidden = YES;
    }else if ([[[SRGlobalState singleton] satelliteProvider] caseInsensitiveCompare:@"DishNetwork"] == NSOrderedSame){
        self.directvButton.hidden = YES;
    }
    //set nav bar tint color
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
}

- (void)viewDidUnload
{
    [self setDishButton:nil];
    [self setDirectvButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dishButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"category" sender:sender];
}

- (IBAction)directvButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"category" sender:sender];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    CategoryViewController *categoryVC = [segue destinationViewController];
    
    if (sender == dishButton) {
        categoryVC.categories = [[NSArray alloc] initWithObjects:@"America's Top Programming", @"Latino Programming", nil];
        categoryVC.channelType = kDishNetwork;
    }
    else if (sender == directvButton) {
        categoryVC.categories = [[NSArray alloc] initWithObjects:@"DIRECTV Choice Programming", @"Latino Más Programming", nil];
        categoryVC.channelType = kDirecTv;
    }
}
@end
