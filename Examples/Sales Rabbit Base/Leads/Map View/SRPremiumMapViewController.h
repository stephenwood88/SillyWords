//
//  SRPremiumMapViewController.h
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 12/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRMapViewController.h"
#import "SRCanvasView.h"
#import "SRAreaDetailedViewController.h"
#import "SRNewRepViewController.h"

@interface SRPremiumMapViewController : SRMapViewController <UIPopoverControllerDelegate, SRAreaDetailedViewControllerDelegate, SRNewRepViewControllerDelegate, AVSelectionListDelegate, AVSimpleDatePickerDelegate>

// UIView subclass for drawing
@property (weak, nonatomic) IBOutlet SRCanvasView *drawView;

// Detailed are popover
@property (strong, nonatomic) UIPopoverController *popOverController;
@property (strong, nonatomic) SRAreaDetailedViewController *detailedAreaVC;

//Manager Controls and Actions
@property (weak, nonatomic) IBOutlet UIButton *repsManagerButton;
@property (weak, nonatomic) IBOutlet UIButton *fromDateManagerButton;
@property (weak, nonatomic) IBOutlet UIButton *toDateManagerButton;
@property (weak, nonatomic) IBOutlet UIButton *customDateManagerButton;
@property (weak, nonatomic) IBOutlet UIButton *goToActiveAreaButton;
@property (weak, nonatomic) IBOutlet UILabel *drawAreaLabel;
@property (weak, nonatomic) IBOutlet UIButton *areaPinButton;
@property (weak, nonatomic) IBOutlet UISwitch *showRepLocationsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showRepLeadsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showRepAreasSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showRepActiveAreaSwitch;
@property (weak, nonatomic) IBOutlet UILabel *repActiveAreaSwitchLabel;

@property (strong, nonatomic) IBOutlet UIView *tabNavView;
@property (strong, nonatomic) IBOutlet UIView *mapNavView;
@property (strong, nonatomic) IBOutlet UIView *leadNavView;
@property (strong, nonatomic) IBOutlet UIView *areaManagmentNavView;
@property (weak, nonatomic) IBOutlet UIButton *mapTabButton;
@property (weak, nonatomic) IBOutlet UIButton *managerTabButton;
@property (weak, nonatomic) IBOutlet UIButton *leadTabButton;
@property (nonatomic) BOOL allowManagerFeatures;


- (IBAction)tabButtonPressed:(UIButton *)sender;

- (IBAction)repsManagerButtonPressed:(id)sender;
- (IBAction)fromDateManagerButtonPressed:(id)sender;
- (IBAction)toDateManagerButtonPressed:(id)sender;
- (IBAction)customDateManagerButtonPressed:(id)sender;
- (IBAction)areaPinButtonPressed:(id)sender;
- (IBAction)goToActiveAreaButtonPressed:(id)sender;

- (IBAction)showRepLocationsChanged:(id)sender;
- (IBAction)showRepLeadsChanged:(id)sender;
- (IBAction)showRepAreasChanged:(id)sender;
- (IBAction)showRepActiveAreaChanged:(id)sender;

@end
