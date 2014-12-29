//
//  SRPremiumSettingsViewController.m
//  Dish Sales
//
//  Created by Matthew McArthur on 6/19/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRPremiumSettingsViewController.h"

@interface SRPremiumSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@end

@implementation SRPremiumSettingsViewController

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSIndexPath *originalPath = self.checkedIndexPath;
        // Uncheck the previous checked row
        if(self.checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        
        self.doneButton.enabled = NO;
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
        self.activityView.tintColor = [UIColor whiteColor];
        self.activityView.color = [UIColor whiteColor];
        
        // Sync all current changes before you switch department.
        [[SRPremiumSalesServiceCalls singleton] performUserMapSyncWithCompletionBlock:^(BOOL success) {
            if (success) {
                // Set new currentDepartment
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *userLastDepartmentDictionary = [[userDefaults objectForKey:kUserLastDepartmentDictionary] mutableCopy];
                [userLastDepartmentDictionary setObject:cell.textLabel.text forKey:self.userID];
                [userDefaults setObject:userLastDepartmentDictionary forKey:kUserLastDepartmentDictionary];
                [userDefaults synchronize];
                [self.delegate updateNavBarTitle];
                
                SRGlobalState *globalState = [SRGlobalState singleton];
                NSMutableDictionary *newLoginInfoDict = [globalState.loginInfoDictionary mutableCopy];
                newLoginInfoDict[@"CompanyID"] = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%ld", (long)cell.tag]];
                globalState.loginInfoDictionary = [newLoginInfoDict copy];
                [[SRServiceCalls singleton] getDomainIncludeDepartment:YES completionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
                    
                    SRGlobalState *globalState = [SRGlobalState singleton];
                    NSMutableDictionary *newLoginInfoDict = [globalState.loginInfoDictionary mutableCopy];
                    newLoginInfoDict[@"CompanyID"] = [NSString stringWithFormat:@"%@", result[@"CompanyID"]];
                    newLoginInfoDict[@"OfficeID"] = [NSString stringWithFormat:@"%@",  result[@"OfficeID"]];
                    newLoginInfoDict[@"AreaID"] = [NSString stringWithFormat:@"%@", result[@"AreaID"]];
                    newLoginInfoDict[@"UserType"] = [NSString stringWithFormat:@"%@",  result[@"UserType"]];
                    globalState.loginInfoDictionary = [newLoginInfoDict copy];
                    [[SRPremiumSalesServiceCalls singleton] performUserMapSync];
                }];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDepartmentChangedNotification object:nil userInfo:nil];
                
                [[SRSalesServiceCalls singleton] sync];
            }else{
                // sync failed, so dont let them change department.
                if(self.checkedIndexPath)
                {
                    UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
                    uncheckCell.accessoryType = UITableViewCellAccessoryNone;
                }
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:originalPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.checkedIndexPath = originalPath;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Service call failed." message:@"Unable to switch departments." delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
                [alert show];
            }
            self.doneButton.enabled = YES;
            [self.activityView stopAnimating];
            self.activityView.hidden = YES;
        }];
    }
}

@end
