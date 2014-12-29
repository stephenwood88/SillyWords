//
//  CategoryViewController.m
//  DishTech
//
//  Created by Aaron Brown on 6/6/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import "CategoryViewController.h"
#import "PackageViewController.h"
#import "ChannelsCell.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController


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

- (void)viewDidUnload
{
    [self setCategoryTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChannelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    cell.titleLabel.text = [self.categories objectAtIndex:[indexPath row]];
    cell.titleLabel.textColor = [[SRGlobalState singleton] accentColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChannelsCell *cell = (ChannelsCell*)sender;
    self.categorySelected = cell.titleLabel.text;
    
    
    PackageViewController *packageVC = [segue destinationViewController];
    
    if ([self.categorySelected isEqualToString:@"America's Top Programming"]) {
        packageVC.packages = [[NSArray alloc] initWithObjects:@"Smart Pack", @"America's Top 120 Package", @"America's Top 200 Package", @"America's Top 250 Package", nil];
        packageVC.channelType = kDishNetwork;
        packageVC.category = @"American";
    }
    else if ([self.categorySelected isEqualToString:@"Latino Programming"]) {
        packageVC.packages = [[NSArray alloc] initWithObjects:@"Latino Básico", @"Latino Clásico", @"Latino Plus", @"Latino Dos", @"Latino Max", nil];
        packageVC.channelType = kDishNetwork;
        packageVC.category = @"Latin";
    }
    else if ([self.categorySelected isEqualToString:@"DIRECTV Choice Programming"]) {
        packageVC.packages = [[NSArray alloc] initWithObjects:@"Select Package", @"Entertainment Package", @"Choice Package", @"Xtra Package", @"Ultimate Package", @"Premier Package", nil];
        packageVC.channelType = kDirecTv;
        packageVC.category = @"American";
    }
    else if ([self.categorySelected isEqualToString:@"Latino Más Programming"]) {
        packageVC.packages = [[NSArray alloc] initWithObjects:@"Más Latino", @"Optimo Más", @"Más Ultra", @"Lo Maximo", nil];
        packageVC.channelType = kDirecTv;
        packageVC.category = @"Latin";
    }
}

@end
