//
//  SRSketchBoardViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSketchBoardViewController.h"
#import "Flurry.h"
#import "SRGlobalState.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface SRSketchBoardViewController ()

@end

@implementation SRSketchBoardViewController
@synthesize currentPopoverSegue;
@synthesize myPopover;

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
    [self flurryTrack];
    self.sketchboard.lineWidth = 1.5f;
    eraserMode = @"NO";
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_palette.png"]
                    style:UIBarButtonItemStyleBordered target:self action:@selector(showPenModal)];
        self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(eraseBoard)];
        self.navigationItem.rightBarButtonItems = @[self.clearButton,flipButton];

    }
    else {
        [self addRightBarButtons];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (myPopover) {
        [myPopover dismissPopoverAnimated:animated];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showPopover"]) {
        myPopover = [(UIStoryboardPopoverSegue*)segue popoverController];
        
//        [[segue destinationViewController] setDelegate:self];
//        [[segue destinationViewController] setIPenColor:[NSString stringWithFormat:@"%d",penColor]];
//        [[segue destinationViewController] setIPenSize:[NSString stringWithFormat:@"%d",penSize]];
//        [[segue destinationViewController] setEraserMode:eraserMode];
    }
    else if([[segue identifier] isEqualToString:@"gotoPens"]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setIPenColor:[NSString stringWithFormat:@"%d",penColor]];
        [[segue destinationViewController] setIPenSize:[NSString stringWithFormat:@"%d",penSize]];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
}

- (void)showPenModal {
    [self performSegueWithIdentifier:@"gotoPens" sender:self];

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (myPopover) {
        [myPopover dismissPopoverAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)returnFromPopup:(NSMutableDictionary *)popupData {
    
    penSize = [[popupData objectForKey:@"PenSize" ] intValue];
    penColor = [[popupData objectForKey:@"PenColor" ] intValue];
    //[myPopover dismissPopoverAnimated:YES];
    switch(penSize) {
        case 0:
        case 9:
            self.sketchboard.lineWidth = 1.5f;
            break;
        case 10:
            self.sketchboard.lineWidth = 5.5f;
            break;
        case 11:
            self.sketchboard.lineWidth = 10.5f ;
            break;
    }
    switch(penColor) {
        case 0:
            self.sketchboard.color = [UIColor blackColor];
            break;
        case 1:
            self.sketchboard.color = [UIColor colorWithRed:176.0/255.0 green:42.0/255.0 blue:27.0/255.0 alpha:1.0];
            break;
        case 2:
            self.sketchboard.color = [UIColor colorWithRed:117.0/255.0 green:175.0/255.0 blue:33.0/255.0 alpha:1.0];
            break;
        case 3:
            self.sketchboard.color = [UIColor colorWithRed:106.0/255.0 green:32.0/255.0 blue:137.0/255.0 alpha:1.0];
            break;
        case 4:
            self.sketchboard.color = [UIColor colorWithRed:27.0/255.0 green:120.0/255.0 blue:147.0/255.0 alpha:1.0];
            break;
        case 5:
            self.sketchboard.color = [UIColor colorWithRed:254.0/255.0 green:140.0/255.0 blue:7.0/255.0 alpha:1.0];
            break;
        case 6:
            self.sketchboard.color = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
            break;
        case 7:
            self.sketchboard.color = [UIColor colorWithRed:216.0/255.0 green:42.0/255.0 blue:89.0/255.0 alpha:1.0];
            break;

        case 8:
            self.sketchboard.color = [UIColor whiteColor];
            self.sketchboard.lineWidth = 50.5f;
    }
    
    if([[popupData objectForKey:@"EraserMode"] isEqualToString:@"YES"]) {
        self.sketchboard.color = [UIColor whiteColor];
        self.sketchboard.lineWidth = 50.5f;
    }
    eraserMode = [popupData objectForKey:@"EraserMode"];
    
}

- (void)viewWillLayoutSubviews {
    [self.sketchboard setFrame:CGRectMake(0, 0, 1024, 1024)];
}

- (void)eraseBoard {
    [self.sketchboard eraseBoard];
}

- (void) addRightBarButtons {
    self.pensButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_palette.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(gotoPens:)];
    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(eraseBoard)];
    self.navigationItem.rightBarButtonItems = @[self.clearButton,self.pensButton];
    
}

- (void)gotoPens:(UIBarButtonItem *)sender {
    if (myPopover) {
        [myPopover dismissPopoverAnimated:YES];
        
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kIPadStoryBoard bundle:nil];
    SRPenColorViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PenColorView"];
    [vc setDelegate:self];
    [vc setIPenColor:[NSString stringWithFormat:@"%d",penColor]];
    [vc setIPenSize:[NSString stringWithFormat:@"%d",penSize]];
    [vc setEraserMode:eraserMode];

    vc.delegate = self;
    myPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    [myPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

}

#pragma mark - Flurry

- (void) flurryTrack {
//    NSString *username = [[(SRAppDelegate *)[[UIApplication sharedApplication] delegate] SRGlobalState] userName];
//    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
//    
//    [Flurry logEvent:@"SketchBoard opened" withParameters:articleParams timed:YES];
}

@end
