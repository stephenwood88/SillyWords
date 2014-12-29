//
//  SRMainTabBar.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 2/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSalesMainTabBar.h"
#import "SRHomeViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SRMaterialsState.h"

@implementation SRSalesMainTabBar

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
    
    [[SRMaterialsState singleton] setTabBarViewController:self];
    
    [[self.viewControllers objectAtIndex:0] setDashboardLogoTimestamp:self.dashboardLogoTimestamp];
    [[self.viewControllers objectAtIndex:0] setSalesMaterialTimestamp:self.salesMaterialTimestamp];
    [[SRMaterialsState singleton] setMainTabBar:self];
    
    self.delegate = self;
    // TODO: Disable reports tab in offline login
    /*if (YES) { // TODO: Check if offline
        UITabBarItem *reportsItem = [self.tabBar.items lastObject];
        reportsItem.enabled = NO;
        reportsItem.badgeValue = @"Offline";
        //reportsItem.image
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillLayoutSubviews {
    // No longer using images for tab bar
}

- (void)removeToolsBadge {
    [[[self.viewControllers objectAtIndex:kToolsTab] tabBarItem] setBadgeValue:nil];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {    
    return viewController != tabBarController.selectedViewController;
}

#pragma mark- Supported Orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }else{
        return (interfaceOrientation & UIInterfaceOrientationMaskAll);
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

@end
