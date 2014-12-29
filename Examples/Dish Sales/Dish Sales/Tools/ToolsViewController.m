//
//  ToolsViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "ToolsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Constants.h"

@implementation ToolsViewController

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
    [self setupProductLogos];
}

- (void)setupProductLogos {
    NSString *providers = [[SRGlobalState singleton] satelliteProvider];
    
    UIImageView *image1 = (UIImageView*)[self.view viewWithTag:5];
    UIImageView *image2 = (UIImageView*)[self.view viewWithTag:6];
    UIImageView *image3 = (UIImageView*)[self.view viewWithTag:7];
    
    image1.hidden = YES;
    image2.hidden = YES;
    image3.hidden = YES;
    
    if (![[SRGlobalState singleton] isAppleTester]) {
        if ([providers compare:@"all" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            // This is the default reflected in Storyboard
            image1.hidden = NO;
            image2.hidden = YES;
            image3.hidden = NO;
            
            image2.image = nil;
        }
        else if ([providers rangeOfString:@"dish" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            image1.hidden = YES;
            image2.hidden = NO;
            image3.hidden = YES;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                image2.image = [UIImage imageNamed:@"logo_dish"];
            }
            else {
                image2.image = [UIImage imageNamed:@"logo_dish_iphone"];
            }
        }
        else if ([providers rangeOfString:@"direct" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            image1.hidden = YES;
            image2.hidden = NO;
            image3.hidden = YES;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                image2.image = [UIImage imageNamed:@"logo_direct"];
            }
            else {
                image2.image = [UIImage imageNamed:@"logo_direct_iphone"];
            }
        }
    }
}

@end
