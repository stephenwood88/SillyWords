//
//  SRHomeViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SRSettingsViewController.h"
#import "SRGlobalState.h"

//Use this define to set frames for views
#define TAG_RECT( tag, x, y, width, height ) \
[NSValue valueWithCGRect:CGRectMake(x, y, width, height)], \
[NSNumber numberWithInteger:tag]

@interface SRHomeViewController : UIViewController <SettingsDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) id delegate;
@property (strong, nonatomic) NSDate *dashboardLogoTimestamp;
@property (strong, nonatomic) NSDate *salesMaterialTimestamp;

@property (weak, nonatomic) IBOutlet UIImageView *companyLogoImage;
@property (weak, nonatomic) IBOutlet UINavigationBar *homeNavBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *homeNavigationItem;

//Frames for different orientations
@property (nonatomic, strong) NSDictionary *portraitFrames;
@property (nonatomic, strong) NSDictionary *landscapeFrames;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URLstring;

- (void)logout;

@end
