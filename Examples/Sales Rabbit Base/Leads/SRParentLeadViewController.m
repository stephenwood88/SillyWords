//
//  SRParentLeadViewController.m
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 1/7/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRParentLeadViewController.h"
#import "SRLeadsListViewController.h"
#import "AppDelegate.h"

#define MapSegmentIndex 0
#define StreetSegmentIndex 1
#define ListSegmentIndex 2

@interface SRParentLeadViewController ()

@property (weak, nonatomic) SRLeadsListViewController *leadListVC;

@end

@implementation SRParentLeadViewController

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
    
    self.viewControl.tintColor = [UIColor whiteColor];
    
    self.leadsViewContainer.hidden = YES;
    self.streetViewContainer.hidden = YES;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Methods

- (IBAction)viewControlChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case MapSegmentIndex:
        {
            self.leadsViewContainer.hidden = YES;
            self.streetViewContainer.hidden = YES;
            self.mapViewVC.mapView.showsUserLocation = YES;
            self.mapViewContainer.hidden = NO;
        }
        break;
        case StreetSegmentIndex:
        {
            self.leadsViewContainer.hidden = YES;
            self.streetViewContainer.hidden = NO;
            self.mapViewVC.mapView.showsUserLocation = NO;
            self.mapViewContainer.hidden = YES;
        }
        break;
        case ListSegmentIndex:
        {
            self.leadsViewContainer.hidden = NO;
            self.streetViewContainer.hidden = YES;
            self.mapViewVC.mapView.showsUserLocation = NO;
            self.mapViewContainer.hidden = YES;
            [self.leadListVC startLocationUpdate];
        }
        break;
        default:
            break;
    }
}

#pragma mark -Segue Methods

//This method is mainly to get the view controller from the container views through the segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"MapToLeadsList"])
    {
        self.leadListVC = segue.destinationViewController;
    }
    else if ([segue.identifier isEqualToString:@"mapViewContainerSegue"])
    {
        self.mapViewVC = segue.destinationViewController;
    }
}

#pragma mark - Lead List Visible
- (BOOL)isLeadListVisible {
    return self.viewControl.selectedSegmentIndex == ListSegmentIndex;
}

@end
