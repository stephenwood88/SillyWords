//
//  SRToolsViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRToolsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Constants.h"

//Use this define to set frames for views
#define TAG_RECT( tag, x, y, width, height ) \
[NSValue valueWithCGRect:CGRectMake(x, y, width, height)], \
[NSNumber numberWithInteger:tag]

@interface SRToolsViewController ()

//Frames for different orientations
@property (nonatomic, strong) NSDictionary *portraitFrames;
@property (nonatomic, strong) NSDictionary *landscapeFrames;

@end

@implementation SRToolsViewController

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
    
    // -------------------Company Logo-----------------------------------------------
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_companyLogo.png", [[SRGlobalState singleton] systemAccountId]]];
    
    // Loading image from documents and set company logo
    NSFileHandle *myFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    UIImage *loadedImage = [UIImage imageWithData:[myFileHandle readDataToEndOfFile]];
    self.companyLogoImage.image = loadedImage;
    // --------------------Company Logo----------------------------------------------
    
    [self setupFrames];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup methods

- (void)setupFrames{
    // Collect the frame positions for elements in portrait mode
    NSMutableDictionary *portraitPositions = [[NSMutableDictionary alloc] init];
	for (NSInteger i = 1; i <= 37; i++) {
        UIView *view = [self.view viewWithTag:i];
        
        [portraitPositions setObject:[NSValue valueWithCGRect:view.frame] forKey:[NSNumber numberWithInteger:i]];
    }
    self.portraitFrames = [portraitPositions copy];
    
    // Let's build the landscape frame positions dictionary
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        //Set up frames for variables in iPad version
        self.landscapeFrames = [NSDictionary dictionaryWithObjectsAndKeys:
                                TAG_RECT(1, 317, 460, 159, 159),
                                TAG_RECT(2, 58, 460, 159, 159),
                                TAG_RECT(3, 564, 460, 159, 159),
                                TAG_RECT(4, 800, 460, 159, 159),
                                TAG_RECT(5, 229, 244, 222, 130),
                                TAG_RECT(6, 392, 244, 222, 130),
                                TAG_RECT(7, 585, 244, 159, 130),
                                nil];
    }
}


#pragma mark - Autorotation orientation

- (void)viewWillLayoutSubviews {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // Lay out for landscape mode
        [self layoutForFrameSet:self.landscapeFrames];
        //self.backgroundImageView.image = [UIImage imageNamed:@"iPadBackground_h"];
    } else {
        // Lay out for portrait mode
        [self layoutForFrameSet:self.portraitFrames];
        //self.backgroundImageView.image = [UIImage imageNamed:@"background_ipad"];
    }
}

- (void)layoutForFrameSet:(NSDictionary *)frames {
    for (NSNumber *key in frames.allKeys) {
        [self.view viewWithTag:[key integerValue]].frame = [[frames objectForKey:key] CGRectValue];
    }
}

@end
