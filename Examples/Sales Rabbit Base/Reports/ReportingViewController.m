//
//  ReportingViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 2/5/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "ReportingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SRProduct.h"
#import "Entity.h"
#import "OverViewController.h"
#import "StandingsViewController.h"
#import "CustomerViewController.h"

@interface ReportingViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) OverViewController *overViewVC;
@property (weak, nonatomic) StandingsViewController *standingVC;
@property (weak, nonatomic) CustomerViewController *customerVC;

@end

@implementation ReportingViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentChanged) name:kDepartmentChangedNotification object:nil];
    
    //Load Products if it applies to the App
    
    if (kReportProducts) {
        [self fetchProducts];
    }
    else{
        [self fetchOffices];
        [self.customerVC startNewReportOnlyIfParametersChanged:NO refreshDataForPullDown:NO];
    }
    
    //[self fetchStandingDomains];
    
    //Set up the container Views
    [_overViewContainer setHidden:NO];
    [_salesStandingsContainer setHidden:YES];
    [_customerContainer setHidden:YES];
    // Setup date and time formatters
    

    self.segmentControl.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"overViewContainerSegue"])
    {
        self.overViewVC = segue.destinationViewController;
    }
    else if([segue.identifier isEqualToString:@"standingContainerSegue"])
    {
        self.standingVC = segue.destinationViewController;
    }
    else if([segue.identifier isEqualToString:@"customerContainerSegue"])
    {
        self.customerVC = segue.destinationViewController;
    }
}



- (void) departmentChanged {
    [self viewDidLoad];
}

- (IBAction)selectionChanged:(id)sender {
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0: {   // Overview
            [_overViewContainer setHidden:NO];
            [_salesStandingsContainer setHidden:YES];
            [_customerContainer setHidden:YES];
            [self flurryTrack:@"Opened the Overview viewcontroller"];
            break;
         }
        case 1: {   // Tech Standings
            [_overViewContainer setHidden:YES];
            [_salesStandingsContainer setHidden:NO];
            [_customerContainer setHidden:YES];
            [self flurryTrack:@"Opened the Standings viewcontroller"];
            break;
         }
        case 2: {   // Customer
            [_overViewContainer setHidden:YES];
            [_salesStandingsContainer setHidden:YES];
            [_customerContainer setHidden:NO];
            [self flurryTrack:@"Opened the Customer viewcontroller"];
            break;
        }
    }
}

#pragma mark - Service Call

- (void)fetchProducts {
    
    [[SRServiceCalls singleton] fetchProductsCompletionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            NSMutableArray *productList = [[NSMutableArray alloc] initWithCapacity:[result count]];
            NSMutableDictionary *selectedProductDictionary = [[NSMutableDictionary alloc] initWithCapacity:[result count]];
            for (NSString *productID in result) {
                Product *product = [[Product alloc] initWithProductID:productID dictionary:[result objectForKey:productID]];
                [productList addObject:product];
                // Select all products
                if ([[product description] isEqualToString:kSatellite]) {
                    [selectedProductDictionary setObject:product forKey:productID];
                }
            }
            
            //Set up eveything on COntainer View that have products on them
            
            self.overViewVC.productList = productList;
            self.overViewVC.selectedProductDictionary = selectedProductDictionary;
            
            self.standingVC.productList = productList;
            self.standingVC.selectedProductDictionary = selectedProductDictionary;
            
            self.customerVC.productList = productList;
            self.customerVC.selectedProductDictionary = selectedProductDictionary;
            
            [self.overViewVC updateProductButtonText];
            self.overViewVC.productOptions = [[AVSelectionListController alloc] initWithContentList:self.overViewVC.productList selectedContentDictionary:self.overViewVC.selectedProductDictionary delegate:self.overViewVC allName:[NSString stringWithFormat:@"%@ %@", kAll, kProducts]];
            
            [self.standingVC updateProductButtonText];
            self.standingVC.productOptions = [[AVSelectionListController alloc] initWithContentList:self.standingVC.productList selectedContentDictionary:self.standingVC.selectedProductDictionary delegate:self.standingVC allName:[NSString stringWithFormat:@"%@ %@", kAll, kProducts]];
            
            [self.customerVC updateProductButtonText];
            self.customerVC.productOptions = [[AVSelectionListController alloc] initWithContentList:self.customerVC.productList selectedContentDictionary:self.customerVC.selectedProductDictionary delegate:self.customerVC allName:[NSString stringWithFormat:@"%@ %@", kAll, kProducts]];
            
            [self.overViewVC.productsIndicator stopAnimating];
            [self.overViewVC.productsBtnIndicator stopAnimating];
            [self.overViewVC.refreshControl endRefreshing];
            
            [self.standingVC.productsBtnIndicator stopAnimating];
            [self.standingVC.refreshControl endRefreshing];
            
            [self.customerVC.productsActivityIndicator stopAnimating];
            [self.customerVC.refreshControl endRefreshing];
            [self.customerVC startNewReportOnlyIfParametersChanged:NO refreshDataForPullDown:NO];
            
            
            [self fetchOffices];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)fetchOffices {
    
    [[SRServiceCalls singleton] fetchOrganizationDomain:kOffice completionHandler:^(BOOL success, NSArray *result, NSError *error) {
        if (success) {
            NSMutableArray *officeList = [[NSMutableArray alloc] initWithCapacity:[result count]];
            NSMutableDictionary *selectedOfficeDictionary = [[NSMutableDictionary alloc] initWithCapacity:[result count]];
            for (NSDictionary *officeDict in result) {
                Entity *office = [[Entity alloc] initWithType:EntityOffice parent:nil dictionary:officeDict];
                [officeList addObject:office];
                [selectedOfficeDictionary setObject:office forKey:office.key];
            }
            
            self.overViewVC.officeList = officeList;
            self.overViewVC.selectedOfficeDictionary = selectedOfficeDictionary;
            
            self.standingVC.officeList = officeList;
            self.standingVC.selectedOfficeDictionary = selectedOfficeDictionary;
            
            self.overViewVC.officeOptions = [[AVSelectionListController alloc] initWithContentList:self.overViewVC.officeList selectedContentDictionary:self.overViewVC.selectedOfficeDictionary delegate:self.overViewVC allName:[NSString stringWithFormat:@"%@ %@", kAll, kOffices]];
            self.standingVC.officeOptions = [[AVSelectionListController alloc] initWithContentList:self.standingVC.officeList selectedContentDictionary:self.standingVC.selectedOfficeDictionary delegate:self.standingVC allName:[NSString stringWithFormat:@"%@ %@", kAll, kOffices]];
            
            [self.standingVC updateOfficeButtonText];
            [self.standingVC.officesBtnIndicator stopAnimating];
            
            
            
            [self fetchReportDepth];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)fetchReportDepth {
    
    [[SRServiceCalls singleton] getReportDepthCompletionHandler:^(BOOL success, NSString *result, NSError *error) {
        if (success) {
            self.overViewVC.reportDepth = [result capitalizedString];
            self.standingVC.reportDepth = [result capitalizedString];
            
            [self.overViewVC startNewReportOnlyIfParametersChanged:NO  refreshDataForPullDown:NO];
            
            [self fetchStandingDomains];
        }
        else {
            [self connectionFailedWithError:error];
        }
    }];
}

- (void)fetchStandingDomains {
    [[SRServiceCalls singleton] fetchStandingDomainsCompletionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        if (success) {
            NSMutableArray *domainList = [[NSMutableArray alloc] initWithCapacity:result.count];
            
            if ([[result objectForKey:@"User"] isEqualToString:@"1"]) {
                [domainList addObject:[Entity mapEntityNameConversionFromString:@"User"]];
            }
            if ([[result objectForKey:@"Manager"] isEqualToString:@"1"]) {
                [domainList addObject:[Entity mapEntityNameConversionFromString:@"Manager"]];
            }
            if ([[result objectForKey:@"Office"] isEqualToString:@"1"]) {
                [domainList addObject:[Entity mapEntityNameConversionFromString:@"Office"]];
            }
            if ([[result objectForKey:@"Area"] isEqualToString:@"1"]) {
                [domainList addObject:[Entity mapEntityNameConversionFromString:@"Area"]];
            }
            
            self.standingVC.domainList = domainList;
            
            if (domainList.count != 0) {
                
                self.standingVC.domainOptions = [[AVSelectionListController alloc] initWithDelegate:self.standingVC sourceButton:self.standingVC.domainsButton contentList:self.standingVC.domainList noSelectionTitle:kNoSelection];
                
                self.standingVC.domainOptions.selectionIndex = 0;
                self.standingVC.reportDepth = [self.standingVC.domainList firstObject];
                [self.standingVC updateDomainButtonText];
                
                [self.standingVC startNewReportOnlyIfParametersChanged:NO  refreshDataForPullDown:NO];

            }
            else{
                UIAlertView *noDomainAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"There are no levels assigned for this Company's reports. In order to view Standing Reports, please go to Dashboard with an Admin account to change this." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [noDomainAlert show];
                
                self.standingVC.domainOptions.selectionIndex = -1;
            }
            
        }
    }];
}


- (void)connectionFailedWithError:(NSError *)error {
    if (![[SRGlobalState singleton] alertViewActive]) {
        UIAlertView *connectionError = [[UIAlertView alloc] initWithTitle:kConnectionErrorTitle message:kConnectionErrorMessage delegate:self cancelButtonTitle:kOk otherButtonTitles:nil];
        [connectionError show];
        
        [[SRGlobalState singleton] setAlertViewActive:YES];
    }
    
    [self.overViewVC.productsIndicator stopAnimating];
    [self.overViewVC.productsBtnIndicator stopAnimating];
    [self.overViewVC.refreshControl endRefreshing];
}


#pragma mark - Flurry

- (void) flurryTrack:(NSString *)msg {
    NSString *username = [[SRGlobalState singleton] userName];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
    
    [Flurry logEvent:msg withParameters:articleParams timed:YES];
}

@end
