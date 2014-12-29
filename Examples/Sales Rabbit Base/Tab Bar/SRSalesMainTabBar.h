//
//  SRMainTabBar.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 2/18/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SRSalesMainTabBar : UITabBarController <UITabBarControllerDelegate>

//There is a warning here which states that the tabBar will not synthesize properly.  This is from an update in iOS 7.1
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (strong, nonatomic) NSDate *dashboardLogoTimestamp;
@property (strong, nonatomic) NSDate *salesMaterialTimestamp;

- (void)removeToolsBadge;

@end
