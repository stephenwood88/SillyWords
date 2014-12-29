//
//  PackageViewController.m
//  DishTech
//
//  Created by Aaron Brown on 6/6/12.
//  Copyright (c) 2012 AppVantage LLC. All rights reserved.
//

#import "PackageViewController.h"
#import "PackageDetailViewController.h"
#import "ChannelsCell.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface PackageViewController ()

@end

@implementation PackageViewController

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
    [self setPackageTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.packages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ChannelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"packageCell"];
    cell.titleLabel.text = [self.packages objectAtIndex:[indexPath row]];
    cell.titleLabel.textColor = [[SRGlobalState singleton] accentColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ChannelsCell *cell = (ChannelsCell*)sender;
    self.packageSelected = cell.titleLabel.text;
    
    PackageDetailViewController *packageDetailVC = [segue destinationViewController];
    packageDetailVC.packageName = self.packageSelected;
    
    if ([self.packageSelected isEqualToString:@"Smart Pack"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-SmartPack", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"America's Top 120 Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Top120", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"America's Top 200 Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Top200", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"America's Top 250 Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Top250", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Latino Básico"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LatinoBasico", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Latino Clásico"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LatinoClasico", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Latino Plus"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LatinoPlus", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Latino Dos"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LatinoDos", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Latino Max"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LatinoMax", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Select Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Select", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Entertainment Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Entertainment", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Choice Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Choice", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Xtra Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Xtra", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Ultimate Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Ultimate", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Premier Package"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-Premier", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Más Latino"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-MasLatino", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Optimo Más"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-OptimoMas", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Más Ultra"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-MasUltra", self.channelType, self.category];
    }
    else if ([self.packageSelected isEqualToString:@"Lo Maximo"]) {
        packageDetailVC.csvFileName = [NSString stringWithFormat:@"%@-%@-LoMaximo", self.channelType, self.category];
    }
}

@end
