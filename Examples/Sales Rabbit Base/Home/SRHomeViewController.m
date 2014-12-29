//
//  SRHomeViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRHomeViewController.h"
#import "AppDelegate.h"
#import "SRServiceCalls.h"
#import "Constants.h"

@interface SRHomeViewController ()


@end

@implementation SRHomeViewController
@synthesize delegate;

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
    
    // Current department
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDepartment = [[userDefaults objectForKey:kUserLastDepartmentDictionary] objectForKey:[[SRGlobalState singleton] userId]];
    self.homeNavigationItem.title = currentDepartment;
    
    // -------------------Company Logo-----------------------------------------------
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_companyLogo.png", [[SRGlobalState singleton] systemAccountId]]];
    
    // Check if logo update is necessary by comparing timestamps
    NSMutableDictionary *companyLogoDictionary = [[userDefaults objectForKey:kCompanyLogoDictionary] mutableCopy];
    NSDate *lastUpdateTimestamp = [companyLogoDictionary objectForKey:[[SRGlobalState singleton] systemAccountId]];
    
    if (lastUpdateTimestamp == nil || [lastUpdateTimestamp compare:self.dashboardLogoTimestamp] == NSOrderedAscending) {
        //NSLog(@"lastUpdateTimestamp is earlier than dashboardLogoTimestamp");
        // Update company logo if necessary
        SRServiceCalls *salesRabbit = [SRServiceCalls singleton];
        [salesRabbit getLogoImageCompletionHandler:^(BOOL success, UIImage *result, NSError *error) {
            if (success) {
                // Saving image into Documents folder
                BOOL fileCreated = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
                [self addSkipBackupAttributeToItemAtURL:path];
                if (!fileCreated) {
                    NSLog(@"Error creating file %@", path);
                } else {
                    NSFileHandle* myFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
                    [myFileHandle writeData:UIImagePNGRepresentation(result)];
                    [self addSkipBackupAttributeToItemAtURL:path];
                    [myFileHandle closeFile];
                    [companyLogoDictionary setObject:self.dashboardLogoTimestamp forKey:[[SRGlobalState singleton] systemAccountId]];
                    [userDefaults setObject:companyLogoDictionary forKey:kCompanyLogoDictionary];
                    [userDefaults synchronize];
                }
                self.companyLogoImage.image = result;
            }
            else {
                //Failed to update logo
            }
        }];
    }
    /*else {
        NSLog(@"No logo update needed");
    }*/
    
    // Loading image from documents and set company logo
    NSFileHandle *myFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    UIImage *loadedImage = [UIImage imageWithData:[myFileHandle readDataToEndOfFile]];
    
    self.companyLogoImage.image = loadedImage;
    // --------------------Company Logo------------------------------------------
    [self setupFrames];
    [[SRGlobalState singleton] setCompanyLogo:loadedImage];
    [[SRGlobalState singleton] setLoggedIn:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqual:@"SettingsSegue"]) {
        SRSettingsViewController *svc = segue.destinationViewController;
        svc.delegate = self;
    }
}

#pragma mark - Setup methods

- (void)setupFrames{
    // Collect the frame positions for elements in portrait mode
    NSMutableDictionary *portraitPositions = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 1; i <= 5; i++) {
        UIView *view = [self.view viewWithTag:i];
        
        [portraitPositions setObject:[NSValue valueWithCGRect:view.frame] forKey:[NSNumber numberWithInteger:i]];
    }
    self.portraitFrames = [portraitPositions copy];
    
    // Let's build the landscape frame positions dictionary
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        //Set up frames for variables in iPad version
        self.landscapeFrames = [NSDictionary dictionaryWithObjectsAndKeys:
                                //TAG_RECT(1, 348, 84, 329, 120),
                                TAG_RECT(2, 433, 422, 159, 159),
                                //TAG_RECT(3, 317, 420, 159, 159),
                                TAG_RECT(4, 120, 422, 159, 159),
                                TAG_RECT(5, 745, 422, 159, 159),
                                nil];
    }
}

#pragma mark - SettingsDelegate

- (void)updateNavBarTitle {
    
    // Current department
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentDepartment = [[userDefaults objectForKey:kUserLastDepartmentDictionary] objectForKey:[[SRGlobalState singleton] userId]];
    self.homeNavigationItem.title = currentDepartment;
}

- (void)logout {
    
    [[SRGlobalState singleton] setLoggedIn:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[NSURL URLWithString:kWebServiceBaseURL]];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Autorotation orientation

- (void)viewWillLayoutSubviews {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // Lay out for landscape mode
        [self layoutForFrameSet:self.landscapeFrames];
    }
    else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // Lay out for portrait mode
        [self layoutForFrameSet:self.portraitFrames];
    }
}

- (void)layoutForFrameSet:(NSDictionary *)frames {
    for (NSNumber *key in frames.allKeys) {
        [self.view viewWithTag:[key integerValue]].frame = [[frames objectForKey:key] CGRectValue];
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URLstring
{
    NSURL *URL = [NSURL fileURLWithPath:URLstring];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


@end
