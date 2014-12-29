//
//  MonthlyBillCalculatorViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 3/16/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRMonthlyBillCalculatorViewController.h"
#import "AVSelectionListController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Flurry.h"
#import "SRPriceCalculator.h"

@interface SRMonthlyBillCalculatorViewController () <AVSelectionListDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) NSString *deviceModel;

@property (strong, nonatomic) AVSelectionListController *currentProviderList;
@property (strong, nonatomic) AVSelectionListController *betterProviderList;
@property (strong, nonatomic) AVSelectionListController *sellingPackageList;
@property (strong, nonatomic) AVSelectionListController *basePackageList;
@property (strong, nonatomic) AVSelectionListController *receiverConfigList;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;

@property (strong, nonatomic) NSString *currentProvider;

@property (strong, nonatomic) NSNumber *hardwarePriceA;
@property (strong, nonatomic) NSNumber *hardwarePriceB;
@property (strong, nonatomic) NSNumber *hardwarePriceC;
@property (strong, nonatomic) NSNumber *hdPrice;
@property (strong, nonatomic) NSNumber *packageBasePrice;
@property (strong, nonatomic) NSNumber *hboPrice;
@property (strong, nonatomic) NSNumber *showtimePrice;
@property (strong, nonatomic) NSNumber *starzPrice;
@property (strong, nonatomic) NSNumber *cinemaxPrice;
@property (strong, nonatomic) NSNumber *encorePrice;
@property (strong, nonatomic) NSNumber *totalCurrentPrice;
@property (strong, nonatomic) NSNumber *promoPrice;
@property (strong, nonatomic) NSNumber *regularPrice;
@property (strong, nonatomic) NSNumber *numberTVs;
@property (nonatomic) BOOL hboSelected;
@property (nonatomic) BOOL showtimeSelected;
@property (nonatomic) BOOL starzSelected;
@property (nonatomic) BOOL cinemaxSelected;
@property (nonatomic) BOOL encoreSelected;

@property (strong, nonatomic) NSArray *dishPackages;
@property (strong, nonatomic) NSArray *directvPackages;

@property (strong, nonatomic) NSDictionary *dishPromoPrices;
@property (strong, nonatomic) NSDictionary *dishRegularPrices;
@property (strong, nonatomic) NSDictionary *directPromoPrices;
@property (strong, nonatomic) NSDictionary *directRegularPrices;

@property (strong, nonatomic) UIView *choicesViewOne;
@property (strong, nonatomic) UIView *choicesViewTwo;
@property (strong, nonatomic) UIView *choicesViewThree;
@property (strong, nonatomic) UIView *activeView;

@end

@implementation SRMonthlyBillCalculatorViewController

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
    
    self.deviceModel = [[UIDevice currentDevice] model];
    //[self flurryTrack];
    
    NSMutableArray *newCurrentProviders = [[NSMutableArray alloc] initWithArray:kCurrentProviders];
    NSString *satelliteProviders = [[SRGlobalState singleton] satelliteProvider];
    if ([satelliteProviders isEqualToString:@"DirecTV"]) {
        [newCurrentProviders removeObject:kDirecTv];
    }else if([satelliteProviders isEqualToString:@"DishNetwork"]){
        [newCurrentProviders removeObject:kDishNetwork];
    }
    
    self.currentProviderList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.currentProviderButton contentList:newCurrentProviders noSelectionTitle:@"Current Provider"];
    [self.currentProviderList selectItem:nil];
    
    self.betterProviderList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.betterProviderButton contentList:kNewProviders noSelectionTitle:@"New Provider"];
    [self.betterProviderList selectItem:nil];
    
    // Tap Recognizer for dismissing popovers
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    self.scrollView.contentSize = CGSizeMake(768, 911);
    
    self.choicesViewOne = [[[NSBundle mainBundle] loadNibNamed:@"SRBillCalcChoicesViewOne" owner:self options:nil] lastObject];
    self.choicesViewTwo = [[[NSBundle mainBundle] loadNibNamed:@"SRBillCalcChoicesViewTwo" owner:self options:nil] lastObject];
    self.choicesViewThree = [[[NSBundle mainBundle] loadNibNamed:@"SRBillCalcChoicesViewThree" owner:self options:nil] lastObject];
    self.choicesViewOne.hidden = YES;
    self.choicesViewOne.userInteractionEnabled = NO;
    self.choicesViewTwo.hidden = YES;
    self.choicesViewTwo.userInteractionEnabled = NO;
    self.choicesViewThree.hidden = YES;
    self.choicesViewThree.userInteractionEnabled = NO;
    [self.choicesView addSubview:self.choicesViewOne];
    [self.choicesView addSubview:self.choicesViewTwo];
    [self.choicesView addSubview:self.choicesViewThree];
}

- (void)viewWillLayoutSubviews {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.scrollView.scrollEnabled = YES;
    }
    else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.scrollView.scrollEnabled = NO;
    }
    [self setPopoverLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self dismissAll:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reset methods

- (void)resetViewsFromProviderSelection:(NSString *)selection {
    self.currentProvider = selection;
    self.totalBillView.hidden = YES;
    self.totalCurrentPrice = @0;
    self.totalCurrentLabel.alpha = 0;
    [self animateViewLeftToRight:self.line1];
    self.line2.hidden = YES;
    
    //reset prices
    self.hardwarePriceA = @0;
    self.hardwarePriceB = @0;
    self.hardwarePriceC = @0;
    self.hdPrice = @0;
    self.packageBasePrice = @0;
    self.hboPrice = @0;
    self.showtimePrice = @0;
    self.starzPrice = @0;
    self.cinemaxPrice = @0;
    self.encorePrice = @0;
    self.numberTVs = @0;
    
    //Set up the appropriate view based on selection
    if ([selection isEqualToString:kComcast] || [selection isEqualToString:kCharter] || [selection isEqualToString:kCableOne]|| [selection isEqualToString:kBrightHouse]) {
        self.choicesViewOne.hidden = NO;
        self.choicesViewTwo.hidden = YES;
        self.choicesViewThree.hidden = YES;
        
        self.choicesViewOne.userInteractionEnabled = YES;
        self.choicesViewTwo.userInteractionEnabled = NO;
        self.choicesViewThree.userInteractionEnabled = NO;
        
        [self resetViewOne];
        self.activeView = self.choicesViewOne;
        [self animateViewTopToBottom:self.tvViewOne];
    }
    else if ([selection isEqualToString:kTimeWarner] || [selection isEqualToString:kFios] || [selection isEqualToString:kCox] ) {
        self.choicesViewOne.hidden = YES;
        self.choicesViewTwo.hidden = NO;
        self.choicesViewThree.hidden = YES;
        
        self.choicesViewOne.userInteractionEnabled = NO;
        self.choicesViewTwo.userInteractionEnabled = YES;
        self.choicesViewThree.userInteractionEnabled = NO;
        
        [self resetViewTwo];
        self.activeView = self.choicesViewTwo;
        [self animateViewTopToBottom:self.tvViewTwo];
    }
    else if ([selection isEqualToString:kDishNetwork] || [selection isEqualToString:kDirecTv] || [selection isEqualToString:kUverse]){
        self.choicesViewOne.hidden = YES;
        self.choicesViewTwo.hidden = YES;
        self.choicesViewThree.hidden = NO;
        
        self.choicesViewOne.userInteractionEnabled = NO;
        self.choicesViewTwo.userInteractionEnabled = NO;
        self.choicesViewThree.userInteractionEnabled = YES;
        
        [self resetViewThree];
        self.activeView = self.choicesViewThree;
        [self animateViewTopToBottom:self.tvViewThree];
    }
    
    //remove the selected package from the right hand dropdown, and only show providers the user sells
    NSMutableArray *newProviderList = [[NSMutableArray alloc] initWithArray:kNewProviders];
    if ([kNewProviders containsObject:selection]) {
        [newProviderList removeObject:selection];
    }
    NSString *satelliteProviders = [[SRGlobalState singleton] satelliteProvider];
    if ([satelliteProviders isEqualToString:@"DishNetwork"]) {
        newProviderList = [NSMutableArray arrayWithObject:kDishNetwork];
    }
    else if ([satelliteProviders isEqualToString:@"DirecTV"]) {
        newProviderList = [NSMutableArray arrayWithObject:kDirecTv];
    }
    self.betterProviderList.contentList = newProviderList;
}

- (void)resetViewOne {
    self.tvViewOne.hidden = YES;
    self.hdDVRViewOne.hidden = YES;
    self.hdOnlyViewOne.hidden = YES;
    self.packageViewOne.hidden = YES;
    self.movieChannelViewOne.hidden = YES;
    
    self.tvPriceLabelOne.alpha = 0;
    self.hdDVRPriceLabelOne.alpha = 0;
    self.hdOnlyPriceLabelOne.alpha = 0;
    self.packagePriceLabelOne.alpha = 0;
    self.hboPriceLabelOne.alpha = 0;
    self.showtimePriceLabelOne.alpha = 0;
    self.starzPriceLabelOne.alpha = 0;
    self.cinemaxPriceLabelOne.alpha = 0;
    self.encorePriceLabelOne.alpha = 0;
    
    self.tvSegmentedControlOne.selectedSegmentIndex = -1;
    self.hdDVRSegmentedControlOne.selectedSegmentIndex = -1;
    self.hdOnlySegmentedControlOne.selectedSegmentIndex = -1;
    self.hboSegmentedControlOne.selectedSegmentIndex = -1;
    self.showtimeSegmentedControlOne.selectedSegmentIndex = -1;
    self.starzSegmentedControlOne.selectedSegmentIndex = -1;
    self.cinemaxSegmentedControlOne.selectedSegmentIndex = -1;
    self.encoreSegmentedControlOne.selectedSegmentIndex = -1;
    
    self.hboSegmentedControlOne.enabled = YES;
    self.showtimeSegmentedControlOne.enabled = YES;
    self.starzSegmentedControlOne.enabled = YES;
    self.cinemaxSegmentedControlOne.enabled = YES;
    self.encoreSegmentedControlOne.enabled = YES;
}



- (void)resetViewTwo {
    self.tvViewTwo.hidden = YES;
    self.multiTVDVRView.hidden = YES;
    self.hdDVRViewTwo.hidden = YES;
    self.hdOnlyViewTwo.hidden = YES;
    self.packageViewTwo.hidden = YES;
    self.movieChannelViewTwo.hidden = YES;
    
    self.tvPriceLabelTwo.alpha = 0;
    self.multiTVDVRPriceLabel.alpha = 0;
    self.hdDVRPriceLabelTwo.alpha = 0;
    self.hdOnlyPriceLabelTwo.alpha = 0;
    self.packagePriceLabelTwo.alpha = 0;
    self.hboPriceLabelTwo.alpha = 0;
    self.showtimePriceLabelTwo.alpha = 0;
    self.starzPriceLabelTwo.alpha = 0;
    self.cinemaxPriceLabelTwo.alpha = 0;
    self.encorePriceLabelTwo.alpha = 0;
    
    self.tvSegmentedControlTwo.selectedSegmentIndex = -1;
    self.multiTVDVRSegmentedControl.selectedSegmentIndex = -1;
    self.hdDVRSegmentedControlTwo.selectedSegmentIndex = -1;
    self.hdOnlySegmentedControlTwo.selectedSegmentIndex = -1;
    self.hboSegmentedControlTwo.selectedSegmentIndex = -1;
    self.showtimeSegmentedControlTwo.selectedSegmentIndex = -1;
    self.starzSegmentedControlTwo.selectedSegmentIndex = -1;
    self.cinemaxSegmentedControlTwo.selectedSegmentIndex = -1;
    self.encoreSegmentedControlTwo.selectedSegmentIndex = -1;
    
    self.encoreSegmentedControlTwo.enabled = YES;
}

- (void)resetViewThree {
    self.tvViewThree.hidden = YES;
    self.dvrViewThree.hidden = YES;
    self.hdViewThree.hidden = YES;
    self.packageViewThree.hidden = YES;
    self.movieChannelViewThree.hidden = YES;
    
    self.tvPriceLabelThree.alpha = 0;
    self.dvrPriceLabelThree.alpha = 0;
    self.hdPriceLabelThree.alpha = 0;
    self.packagePriceLabelThree.alpha = 0;
    self.hboPriceLabelThree.alpha = 0;
    self.showtimePriceLabelThree.alpha = 0;
    self.starzPriceLabelThree.alpha = 0;
    self.cinemaxPriceLabelThree.alpha = 0;
    self.encorePriceLabelThree.alpha = 0;
    
    self.tvSegmentedControlThree.selectedSegmentIndex = -1;
    self.dvrSegmentedControlThree.selectedSegmentIndex = -1;
    self.hdSegmentedControlThree.selectedSegmentIndex = -1;
    self.hboSegmentedControlThree.selectedSegmentIndex = -1;
    self.showtimeSegmentedControlThree.selectedSegmentIndex = -1;
    self.starzSegmentedControlThree.selectedSegmentIndex = -1;
    self.cinemaxSegmentedControlThree.selectedSegmentIndex = -1;
    self.encoreSegmentedControlThree.selectedSegmentIndex = -1;
}

- (void)resetNewProvider{
    // Need to reset only new provider info
    [self.betterProviderButton setTitle:@"New Provider" forState:UIControlStateNormal];
    self.rightSidePackageButton.hidden = YES;
    self.betterProviderButton.hidden = YES;
    [self.betterProviderList selectItem:nil];
    
    [self resetNewPackage];
}

- (void)resetNewPackage {
    [self.rightSidePackageButton setTitle:@"Select Package" forState:UIControlStateNormal];
    self.receiverConfigButton.hidden = YES;
    [self.sellingPackageList selectItem:nil];
    
    [self resetReceiverConfig];
}

- (void)resetReceiverConfig {
    self.warrantyView.alpha = 0;
    self.promoHeaderLabel.alpha = 0;
    self.promoPriceLabel.alpha = 0;
    self.regularHeaderLabel.alpha = 0;
    self.betterPriceLabel.alpha = 0;
    self.benefitLabelA.alpha = 0;
    self.benefitLabelB.alpha = 0;
    self.benefitLabelC.alpha = 0;
    self.benefitLabelD.alpha = 0;
    self.benefitLabelE.alpha = 0;
    self.benefitLabelF.alpha = 0;
    self.promoSavingsLabel.alpha = 0;
    self.regularSavingsLabel.alpha = 0;
    self.firstYearSavingsHeader.alpha = 0;
    self.firstYearSavingsLabel.alpha = 0;
    [self.receiverConfigButton setTitle:@"Receiver Configuration" forState:UIControlStateNormal];
    
    if (self.betterProviderList.selectedItem != nil) {
        NSArray *contentList;
        if ([self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
            contentList = [[[kCalculatorDictionary objectForKey:self.betterProviderList.selectedItem] objectForKey:kReceiverConfiguration] objectAtIndex:[self.numberTVs intValue]];
        }
        else if ([self.betterProviderList.selectedItem isEqualToString:kDirecTv]) {
            contentList = [[kCalculatorDictionary objectForKey:self.betterProviderList.selectedItem] objectForKey:kReceiverConfiguration];
        }
        self.receiverConfigList = [[AVSelectionListController alloc] initWithDelegate:self
                                                                         sourceButton:self.receiverConfigButton
                                                                          contentList:contentList
                                                                     noSelectionTitle:@"Receiver Configuration"];
    }
    [self.receiverConfigList selectItem:nil];
}

#pragma mark - IBAction Methods

- (IBAction)providerButtonPressed:(UIButton *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //[self createActionSheet:sender sheetView:[self selectionForButton:sender]];
    }
    else {
        [self createPopover:sender popoverView:[self selectionForButton:sender]];
    }
}

- (IBAction)warrantyValueChanged:(UISwitch *)sender {
    [self calculateNewProviderPrice];
}

- (void)showPackageDropdownForButton:(UIButton *) button packageView:(UIView *)packageView{
    NSArray *packages = [[kCalculatorDictionary objectForKey:self.currentProvider] objectForKey:kPackage];
    self.basePackageList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:button contentList:packages noSelectionTitle:@"Package"];
    [self.basePackageList selectItem:nil];
    [self animateViewTopToBottom:packageView];
}

#pragma mark Nib One actions

- (IBAction)tvOneSegmentChanged:(id)sender {
    if (self.hdDVRViewOne.hidden) {
        [self animateViewTopToBottom:self.hdDVRViewOne];
    }
    self.numberTVs = [NSNumber numberWithInt:(int)self.tvSegmentedControlOne.selectedSegmentIndex];
    if (!self.receiverConfigButton.hidden && [self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
        [self resetReceiverConfig];
    }
    if (self.benefitLabelB.alpha != 0) {
        [self updateBenefits];
        [self calculateNewProviderPrice];
    }
}

- (IBAction)hdDVROneSegmentChanged:(id)sender {
    if (self.hdOnlyViewOne.hidden) {
        [self animateViewTopToBottom:self.hdOnlyViewOne];
    }
    self.hardwarePriceA = [SRPriceCalculator priceForHardwareOption:kHDDVR
                                                           quantity:[NSNumber numberWithInt:(int)self.hdDVRSegmentedControlOne.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.hdDVRPriceLabelOne.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceA intValue]];
    if (self.hdDVRPriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.hdDVRPriceLabelOne];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hdOnlyOneSegmentChanged:(id)sender {
    if (self.packageViewOne.hidden) {
        [self showPackageDropdownForButton:self.packageButtonOne packageView:self.packageViewOne];
    }
    self.hardwarePriceB = [SRPriceCalculator priceForHardwareOption:kHDOnlyBoxes
                                                           quantity:[NSNumber numberWithInt:(int)self.hdOnlySegmentedControlOne.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.hdOnlyPriceLabelOne.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceB intValue]];
    if (self.hdOnlyPriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.hdOnlyPriceLabelOne];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hboOneSegmentChanged:(id)sender {
    [self movieChannelOneChanged];
    if (self.hboPriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.hboPriceLabelOne];
    }
}

- (IBAction)showtimeOneSegmentChanged:(id)sender {
    [self movieChannelOneChanged];
    if (self.showtimePriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.showtimePriceLabelOne];
    }
}

- (IBAction)starzOneSegmentChanged:(id)sender {
    [self movieChannelOneChanged];
    if (self.starzPriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.starzPriceLabelOne];
    }
}

- (IBAction)cinemaxOneSegmentChanged:(id)sender {
    [self movieChannelOneChanged];
    if (self.cinemaxPriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.cinemaxPriceLabelOne];
    }
}

- (IBAction)encoreOneSegmentChanged:(id)sender {
    [self movieChannelOneChanged];
    if (self.encorePriceLabelOne.alpha == 0) {
        [self fadeInViewAnimation:self.encorePriceLabelOne];
    }
}

- (void)movieChannelOneChanged {
    
    
    if ([self allMovieChannelsChosenForViewOne] && self.totalBillView.hidden) {
        [self finishLeftHandView];
    }
    
    NSMutableArray *movieChannelsSelected = [[NSMutableArray alloc] init];
    if (self.hboSegmentedControlOne.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kHBO];
        self.hboSelected = YES;
    }
    else {
        self.hboSelected = NO;
    }
    if (self.showtimeSegmentedControlOne.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kShowtime];
        self.showtimeSelected = YES;
    }
    else {
        self.showtimeSelected = NO;
    }
    if (self.starzSegmentedControlOne.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kStarz];
        self.starzSelected = YES;
    }
    else {
        self.starzSelected = NO;
    }
    if (self.cinemaxSegmentedControlOne.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kCinemax];
        self.cinemaxSelected = YES;
    }
    else {
        self.cinemaxSelected = NO;
    }
    if (self.encoreSegmentedControlOne.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kEncore];
        self.encoreSelected = YES;
    }
    else {
        self.encoreSelected = NO;
    }
    NSDictionary *moviePricesDict = [SRPriceCalculator pricesForMovieChannels:movieChannelsSelected provider:self.currentProvider];
    
    self.hboPrice = [moviePricesDict objectForKey:kHBO];
    self.showtimePrice = [moviePricesDict objectForKey:kShowtime];
    self.starzPrice = [moviePricesDict objectForKey:kStarz];
    self.cinemaxPrice = [moviePricesDict objectForKey:kCinemax];
    self.encorePrice = [moviePricesDict objectForKey:kEncore];
    
    self.hboPriceLabelOne.text = [NSString stringWithFormat:@"$%d",[self.hboPrice intValue]];
    self.showtimePriceLabelOne.text = [NSString stringWithFormat:@"$%d",[self.showtimePrice intValue]];
    self.starzPriceLabelOne.text = [NSString stringWithFormat:@"$%d",[self.starzPrice intValue]];
    self.cinemaxPriceLabelOne.text = [NSString stringWithFormat:@"$%d",[self.cinemaxPrice intValue]];
    if (self.encoreSegmentedControlOne.enabled) {
        self.encorePriceLabelOne.text = [NSString stringWithFormat:@"$%d",[self.encorePrice intValue]];
    }
    
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)packageOnePressed:(id)sender {
    [self providerButtonPressed:sender];
}

- (IBAction)resetButtonPressed:(id)sender {
    
    [self.currentProviderList selectItem:nil];
    [self resetViewOne];
    [self resetViewTwo];
    [self resetViewThree];
    self.totalBillView.hidden = YES;
    self.totalCurrentPrice = @0;
    self.totalCurrentLabel.alpha = 0;
    self.line2.hidden = YES;
    self.line1.hidden = YES;
    [self resetNewProvider];
}

- (BOOL)allMovieChannelsChosenForViewOne {
    return (self.hboSegmentedControlOne.selectedSegmentIndex != -1 || !self.hboSegmentedControlOne.enabled) &&
    (self.showtimeSegmentedControlOne.selectedSegmentIndex != -1 || !self.showtimeSegmentedControlOne.enabled) &&
    (self.starzSegmentedControlOne.selectedSegmentIndex != -1 || !self.starzSegmentedControlOne.enabled) &&
    (self.cinemaxSegmentedControlOne.selectedSegmentIndex != -1 || !self.cinemaxSegmentedControlOne.enabled) &&
    (self.encoreSegmentedControlOne.selectedSegmentIndex != -1 || !self.encoreSegmentedControlOne.enabled) &&
    self.totalBillView.hidden == YES;
}

#pragma mark Nib Two actions

- (IBAction)tvTwoSegmentChanged:(id)sender {
    if (self.multiTVDVRView.hidden) {
        [self animateViewTopToBottom:self.multiTVDVRView];
    }
    self.numberTVs = [NSNumber numberWithInt:(int)self.tvSegmentedControlTwo.selectedSegmentIndex];
    if (!self.receiverConfigButton.hidden && [self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
        [self resetReceiverConfig];
    }
    if (self.benefitLabelB.alpha != 0) {
        [self updateBenefits];
        [self calculateNewProviderPrice];
    }
}

- (IBAction)multiTVDVRSegmentChanged:(id)sender {
    if (self.hdDVRViewTwo.hidden) {
        [self animateViewTopToBottom:self.hdDVRViewTwo];
    }
    self.hardwarePriceA = [SRPriceCalculator priceForHardwareOption:kMultiTVDVR
                                                           quantity:[NSNumber numberWithInt:(int)self.multiTVDVRSegmentedControl.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.multiTVDVRPriceLabel.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceA intValue]];
    if (self.multiTVDVRPriceLabel.alpha == 0) {
        [self fadeInViewAnimation:self.multiTVDVRPriceLabel];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
};

- (IBAction)hdDVRTwoSegmentChanged:(id)sender {
    if (self.hdOnlyViewTwo.hidden) {
        [self animateViewTopToBottom:self.hdOnlyViewTwo];
    }
    self.hardwarePriceB = [SRPriceCalculator priceForHardwareOption:kHDDVR
                                                           quantity:[NSNumber numberWithInt:(int)self.hdDVRSegmentedControlTwo.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.hdDVRPriceLabelTwo.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceB intValue]];
    if (self.hdDVRPriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.hdDVRPriceLabelTwo];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hdOnlyTwoSegmentChanged:(id)sender {
    if (self.packageViewTwo.hidden) {
        [self showPackageDropdownForButton:self.packageButtonTwo packageView:self.packageViewTwo];
    }
    self.hardwarePriceC = [SRPriceCalculator priceForHardwareOption:kHDOnlyBoxes
                                                           quantity:[NSNumber numberWithInt:(int)self.hdOnlySegmentedControlTwo.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.hdOnlyPriceLabelTwo.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceC intValue]];
    if (self.hdOnlyPriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.hdOnlyPriceLabelTwo];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hboTwoSegmentChanged:(id)sender {
    [self movieChannelTwoChanged];
    if (self.hboPriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.hboPriceLabelTwo];
    }
}

- (IBAction)showtimeTwoSegmentChanged:(id)sender {
    [self movieChannelTwoChanged];
    if (self.showtimePriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.showtimePriceLabelTwo];
    }
}

- (IBAction)starzTwoSegmentChanged:(id)sender {
    [self movieChannelTwoChanged];
    if (self.starzPriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.starzPriceLabelTwo];
    }
}

- (IBAction)cinemaxTwoSegmentChanged:(id)sender {
    [self movieChannelTwoChanged];
    if (self.cinemaxPriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.cinemaxPriceLabelTwo];
    }
}

- (IBAction)encoreTwoSegmentChanged:(id)sender {
    [self movieChannelTwoChanged];
    if (self.encorePriceLabelTwo.alpha == 0) {
        [self fadeInViewAnimation:self.encorePriceLabelTwo];
    }
}

- (IBAction)packageTwoPressed:(id)sender {
    [self providerButtonPressed:sender];
}

- (BOOL)allMovieChannelsChosenForViewTwo {
    return self.hboSegmentedControlTwo.selectedSegmentIndex != -1 &&
    self.showtimeSegmentedControlTwo.selectedSegmentIndex != -1 &&
    self.starzSegmentedControlTwo.selectedSegmentIndex != -1 &&
    self.cinemaxSegmentedControlTwo.selectedSegmentIndex != -1 &&
    (self.encoreSegmentedControlTwo.selectedSegmentIndex != -1 || !self.encoreSegmentedControlTwo.enabled) &&
    self.totalBillView.hidden == YES;
}

- (void)movieChannelTwoChanged {
    if ([self allMovieChannelsChosenForViewTwo] && self.totalBillView.hidden) {
        [self finishLeftHandView];
    }
    
    NSMutableArray *movieChannelsSelected = [[NSMutableArray alloc] init];
    if (self.hboSegmentedControlTwo.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kHBO];
        self.hboSelected = YES;
    }
    else {
        self.hboSelected = NO;
    }
    if (self.showtimeSegmentedControlTwo.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kShowtime];
        self.showtimeSelected = YES;
    }
    else {
        self.showtimeSelected = NO;
    }
    if (self.starzSegmentedControlTwo.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kStarz];
        self.starzSelected = YES;
    }
    else {
        self.starzSelected = NO;
    }
    if (self.cinemaxSegmentedControlTwo.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kCinemax];
        self.cinemaxSelected = YES;
    }
    else {
        self.cinemaxSelected = NO;
    }
    if (self.encoreSegmentedControlTwo.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kEncore];
        self.encoreSelected = YES;
    }
    else {
        self.encoreSelected = NO;
    }
    NSDictionary *moviePricesDict = [SRPriceCalculator pricesForMovieChannels:movieChannelsSelected provider:self.currentProvider];
    
    self.hboPrice = [moviePricesDict objectForKey:kHBO];
    self.showtimePrice = [moviePricesDict objectForKey:kShowtime];
    self.starzPrice = [moviePricesDict objectForKey:kStarz];
    self.cinemaxPrice = [moviePricesDict objectForKey:kCinemax];
    self.encorePrice = [moviePricesDict objectForKey:kEncore];
    
    self.hboPriceLabelTwo.text = [NSString stringWithFormat:@"$%d",[self.hboPrice intValue]];
    self.showtimePriceLabelTwo.text = [NSString stringWithFormat:@"$%d",[self.showtimePrice intValue]];
    self.starzPriceLabelTwo.text = [NSString stringWithFormat:@"$%d",[self.starzPrice intValue]];
    self.cinemaxPriceLabelTwo.text = [NSString stringWithFormat:@"$%d",[self.cinemaxPrice intValue]];
    if (self.encoreSegmentedControlTwo.enabled) {
        self.encorePriceLabelTwo.text = [NSString stringWithFormat:@"$%d",[self.encorePrice intValue]];
    }
    
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

#pragma mark Nib Three actions
- (IBAction)tvThreeSegmentChanged:(id)sender {
    if (self.dvrViewThree.hidden) {
        [self animateViewTopToBottom:self.dvrViewThree];
    }
    
    self.numberTVs = [NSNumber numberWithInt:(int)self.tvSegmentedControlThree.selectedSegmentIndex];
    
    self.hardwarePriceA = [SRPriceCalculator priceForHardwareOption:kTVs
                                                           quantity:[NSNumber numberWithInt:(int)self.tvSegmentedControlThree.selectedSegmentIndex + 1]
                                                           provider:self.currentProvider];
    self.tvPriceLabelThree.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceA intValue]];
    if (self.tvPriceLabelThree.alpha == 0 && [self.hardwarePriceA intValue] != 0) {
        [self fadeInViewAnimation:self.tvPriceLabelThree];
    }
    if (!self.receiverConfigButton.hidden && [self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
        [self resetReceiverConfig];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
    else if (self.benefitLabelB.alpha != 0) {
        [self updateBenefits];
        [self calculateNewProviderPrice];
    }
}

- (IBAction)dvrThreeSegmentChanged:(id)sender {
    if (self.hdViewThree.hidden && ![self.currentProvider isEqualToString:kDishNetwork]) {
        [self animateViewTopToBottom:self.hdViewThree];
    }
    else if (self.packageViewThree.hidden && [self.currentProvider isEqualToString:kDishNetwork]) {
        [self showPackageDropdownForButton:self.packageButtonThree packageView:self.packageViewThree];
    }
    
    self.hardwarePriceB = [SRPriceCalculator priceForHardwareOption:kDVRCharge
                                                           quantity:[NSNumber numberWithInt:(int)self.dvrSegmentedControlThree.selectedSegmentIndex]
                                                           provider:self.currentProvider];
    self.dvrPriceLabelThree.text = [NSString stringWithFormat:@"$%d", [self.hardwarePriceB intValue]];
    if (self.dvrPriceLabelThree.alpha == 0 && [self.hardwarePriceB intValue] != 0) {
        [self fadeInViewAnimation:self.dvrPriceLabelThree];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hdThreeSegmentChanged:(id)sender {
    if (self.packageViewThree.hidden) {
        [self showPackageDropdownForButton:self.packageButtonThree packageView:self.packageViewThree];
    }
    if (self.hdSegmentedControlThree.selectedSegmentIndex == 0) {
        self.hdPrice = [SRPriceCalculator priceForHardwareOption:kHDOption
                                                        quantity:[NSNumber numberWithInt:1]
                                                        provider:self.currentProvider];
    }
    else {
        self.hdPrice = 0;
    }
    self.hdPriceLabelThree.text = [NSString stringWithFormat:@"$%d", [self.hdPrice intValue]];
    if (self.hdPriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.hdPriceLabelThree];
    }
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (IBAction)hboThreeSegmentChanged:(id)sender {
    [self movieChannelThreeChanged];
    if (self.hboPriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.hboPriceLabelThree];
    }
}

- (IBAction)showtimeThreeSegmentChanged:(id)sender {
    [self movieChannelThreeChanged];
    if (self.showtimePriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.showtimePriceLabelThree];
    }
}

- (IBAction)starzThreeSegmentChanged:(id)sender {
    [self movieChannelThreeChanged];
    if (self.starzPriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.starzPriceLabelThree];
    }
}

- (IBAction)cinemaxThreeSegmentChanged:(id)sender {
    [self movieChannelThreeChanged];
    if (self.cinemaxPriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.cinemaxPriceLabelThree];
    }
}

- (IBAction)encoreThreeSegmentChanged:(id)sender {
    [self movieChannelThreeChanged];
    if (self.encorePriceLabelThree.alpha == 0) {
        [self fadeInViewAnimation:self.encorePriceLabelThree];
    }
}

- (IBAction)packageThreePressed:(id)sender {
    [self providerButtonPressed:sender];
}

- (BOOL)allMovieChannelsChosenForViewThree {
    return self.hboSegmentedControlThree.selectedSegmentIndex != -1 &&
    self.showtimeSegmentedControlThree.selectedSegmentIndex != -1 &&
    self.starzSegmentedControlThree.selectedSegmentIndex != -1 &&
    self.cinemaxSegmentedControlThree.selectedSegmentIndex != -1 &&
    self.encoreSegmentedControlThree.selectedSegmentIndex != -1 &&
    self.totalBillView.hidden == YES;
}

- (void)movieChannelThreeChanged {
    if ([self allMovieChannelsChosenForViewThree] && self.totalBillView.hidden) {
        [self finishLeftHandView];
    }
    
    NSMutableArray *movieChannelsSelected = [[NSMutableArray alloc] init];
    if (self.hboSegmentedControlThree.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kHBO];
        self.hboSelected = YES;
    }
    else {
        self.hboSelected = NO;
    }
    if (self.showtimeSegmentedControlThree.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kShowtime];
        self.showtimeSelected = YES;
    }
    else {
        self.showtimeSelected = NO;
    }
    if (self.starzSegmentedControlThree.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kStarz];
        self.starzSelected = YES;
    }
    else {
        self.starzSelected = NO;
    }
    if (self.cinemaxSegmentedControlThree.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kCinemax];
        self.cinemaxSelected = YES;
    }
    else {
        self.cinemaxSelected = NO;
    }
    if (self.encoreSegmentedControlThree.selectedSegmentIndex == 0) {
        [movieChannelsSelected addObject:kEncore];
        self.encoreSelected = YES;
    }
    else {
        self.encoreSelected = NO;
    }
    NSDictionary *moviePricesDict = [SRPriceCalculator pricesForMovieChannels:movieChannelsSelected provider:self.currentProvider];
    
    self.hboPrice = [moviePricesDict objectForKey:kHBO];
    self.showtimePrice = [moviePricesDict objectForKey:kShowtime];
    self.starzPrice = [moviePricesDict objectForKey:kStarz];
    self.cinemaxPrice = [moviePricesDict objectForKey:kCinemax];
    self.encorePrice = [moviePricesDict objectForKey:kEncore];
    
    self.hboPriceLabelThree.text = [NSString stringWithFormat:@"$%d",[self.hboPrice intValue]];
    self.showtimePriceLabelThree.text = [NSString stringWithFormat:@"$%d",[self.showtimePrice intValue]];
    self.starzPriceLabelThree.text = [NSString stringWithFormat:@"$%d",[self.starzPrice intValue]];
    self.cinemaxPriceLabelThree.text = [NSString stringWithFormat:@"$%d",[self.cinemaxPrice intValue]];
    self.encorePriceLabelThree.text = [NSString stringWithFormat:@"$%d",[self.encorePrice intValue]];
    
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}

- (void)finishLeftHandView {
    [self calculateTotalCurrentPrice];
    [self animateViewTopToBottom:self.totalBillView];
    [self fadeInViewAnimation:self.totalCurrentLabel];
    [self animateViewTopToBottom:self.line2];
    if (self.betterProviderButton.hidden == YES) {
        [self animateViewTopToBottom:self.betterProviderButton];
    }
}

#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection{
    //Reset everything when a new current provider is chosen
    if (sender == self.currentProviderList){
        [self resetViewsFromProviderSelection:selection];
        [self resetNewProvider];
    }
    
    //Results for choosing a current package
    else if (sender == self.basePackageList){
        self.packageBasePrice = [SRPriceCalculator priceForPackage:self.basePackageList.selectedItem provider:self.currentProvider];
        
        if (self.activeView == self.choicesViewOne) {
            self.packagePriceLabelOne.text = [NSString stringWithFormat:@"$%i", [self.packageBasePrice intValue]];
            if (self.packagePriceLabelOne.alpha == 0) {
                [self fadeInViewAnimation:self.packagePriceLabelOne];
            }
            if (self.movieChannelViewOne.hidden) {
                [self animateViewTopToBottom:self.movieChannelViewOne];
            }
            
            if ([self.currentProvider isEqualToString:kComcast]) {
                if ([selection isEqualToString:kComcastDigitalPremier]) {
                    self.hboPriceLabelOne.text = kIncl;
                    self.hboPrice = @0;
                    self.hboSelected = YES;
                    self.hboSegmentedControlOne.selectedSegmentIndex = -1;
                    self.hboSegmentedControlOne.enabled = NO;
                    
                    self.showtimePriceLabelOne.text = kIncl;
                    self.showtimePrice = @0;
                    self.showtimeSelected = YES;
                    self.showtimeSegmentedControlOne.selectedSegmentIndex = -1;
                    self.showtimeSegmentedControlOne.enabled = NO;
                    
                    self.starzPriceLabelOne.text = kIncl;
                    self.starzPrice = @0;
                    self.starzSelected = YES;
                    self.starzSegmentedControlOne.selectedSegmentIndex = -1;
                    self.starzSegmentedControlOne.enabled = NO;
                    
                    self.cinemaxPriceLabelOne.text = kIncl;
                    self.cinemaxPrice = @0;
                    self.cinemaxSelected = YES;
                    self.cinemaxSegmentedControlOne.selectedSegmentIndex = -1;
                    self.cinemaxSegmentedControlOne.enabled = NO;
                    
                    self.encorePriceLabelOne.text = kIncl;
                    self.encoreSegmentedControlOne.enabled = NO;
                    
                    if (self.hboPriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.hboPriceLabelOne];
                    }
                    if (self.showtimePriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.showtimePriceLabelOne];
                    }
                    if (self.starzPriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.starzPriceLabelOne];
                    }
                    if (self.cinemaxPriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.cinemaxPriceLabelOne];
                    }
                    if (self.encorePriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.encorePriceLabelOne];
                    }
                    if (self.totalBillView.hidden) {
                        [self finishLeftHandView];
                    }
                }
                else {
                    if (!self.hboSegmentedControlOne.enabled) {
                        self.hboPriceLabelOne.text = @"$0";
                        self.hboPrice = @0;
                        self.hboSelected = NO;
                        self.hboSegmentedControlOne.enabled = YES;
                    }
                    if (!self.showtimeSegmentedControlOne.enabled) {
                        self.showtimePriceLabelOne.text = @"$0";
                        self.showtimePrice = @0;
                        self.showtimeSelected = NO;
                        self.showtimeSegmentedControlOne.enabled = YES;
                    }
                    if (!self.starzSegmentedControlOne.enabled) {
                        self.starzPriceLabelOne.text = @"$0";
                        self.starzPrice = @0;
                        self.starzSelected = NO;
                        self.starzSegmentedControlOne.enabled = YES;
                    }
                    if (!self.cinemaxSegmentedControlOne.enabled) {
                        self.cinemaxPriceLabelOne.text = @"$0";
                        self.cinemaxPrice = @0;
                        self.cinemaxSelected = NO;
                        self.cinemaxSegmentedControlOne.enabled = YES;
                    }
                    if ([selection isEqualToString:kComcastDigitalPreferred]) {
                        self.encorePriceLabelOne.text = kIncl;
                    }
                    else {
                        self.encorePriceLabelOne.text = kNA;
                    }
                    self.encoreSegmentedControlOne.enabled = NO;
                    if (self.encorePriceLabelOne.alpha == 0) {
                        [self fadeInViewAnimation:self.encorePriceLabelOne];
                    }
                }
            }
        }
        else if (self.activeView == self.choicesViewTwo) {
            self.packagePriceLabelTwo.text = [NSString stringWithFormat:@"$%i", [self.packageBasePrice intValue]];
            if (self.packagePriceLabelTwo.alpha == 0) {
                [self fadeInViewAnimation:self.packagePriceLabelTwo];
            }
            if (self.movieChannelViewTwo.hidden) {
                [self animateViewTopToBottom:self.movieChannelViewTwo];
            }
            
            //deal with FiOS no Encore
            if (self.currentProvider == kFios) {
                self.encorePriceLabelTwo.text = kNA;
                self.encoreSegmentedControlTwo.enabled = NO;
                if (self.encorePriceLabelTwo.alpha == 0) {
                    [self fadeInViewAnimation:self.encorePriceLabelTwo];
                }
            }
        }
        else if (self.activeView == self.choicesViewThree) {
            self.packagePriceLabelThree.text = [NSString stringWithFormat:@"$%i", [self.packageBasePrice intValue]];
            
            if (self.packagePriceLabelThree.alpha == 0) {
                [self fadeInViewAnimation:self.packagePriceLabelThree];
            }
            if (self.movieChannelViewThree.hidden) {
                [self animateViewTopToBottom:self.movieChannelViewThree];
            }
            
            if ([self.currentProvider isEqualToString:kDirecTv]) {
                if ([selection isEqualToString:kUltimate]) {
                    self.encorePriceLabelThree.text = kIncl;
                    self.encorePrice = @0;
                    self.encoreSelected = YES;
                    self.encoreSegmentedControlThree.selectedSegmentIndex = -1;
                    self.encoreSegmentedControlThree.enabled = NO;
                    
                    if (!self.hboSegmentedControlThree.enabled) {
                        self.hboPriceLabelThree.text = @"$0";
                        self.hboPrice = @0;
                        self.hboSelected = NO;
                        self.hboSegmentedControlThree.enabled = YES;
                    }
                    if (!self.showtimeSegmentedControlThree.enabled) {
                        self.showtimePriceLabelThree.text = @"$0";
                        self.showtimePrice = @0;
                        self.showtimeSelected = NO;
                        self.showtimeSegmentedControlThree.enabled = YES;
                    }
                    if (!self.starzSegmentedControlThree.enabled) {
                        self.starzPriceLabelThree.text = @"$0";
                        self.starzPrice = @0;
                        self.starzSelected = NO;
                        self.starzSegmentedControlThree.enabled = YES;
                    }
                    if (!self.cinemaxSegmentedControlThree.enabled) {
                        self.cinemaxPriceLabelThree.text = @"$0";
                        self.cinemaxPrice = @0;
                        self.cinemaxSelected = NO;
                        self.cinemaxSegmentedControlThree.enabled = YES;
                    }
                    
                    if (self.encorePriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.encorePriceLabelThree];
                    }
                    if (self.totalBillView.hidden) {
                        [self finishLeftHandView];
                    }
                }
                else if ([selection isEqualToString:kPremier]) {
                    self.hboPriceLabelThree.text = kIncl;
                    self.hboPrice = @0;
                    self.hboSelected = YES;
                    self.hboSegmentedControlThree.selectedSegmentIndex = -1;
                    self.hboSegmentedControlThree.enabled = NO;
                    
                    self.showtimePriceLabelThree.text = kIncl;
                    self.showtimePrice = @0;
                    self.showtimeSelected = YES;
                    self.showtimeSegmentedControlThree.selectedSegmentIndex = -1;
                    self.showtimeSegmentedControlThree.enabled = NO;
                    
                    self.starzPriceLabelThree.text = kIncl;
                    self.starzPrice = @0;
                    self.starzSelected = YES;
                    self.starzSegmentedControlThree.selectedSegmentIndex = -1;
                    self.starzSegmentedControlThree.enabled = NO;
                    
                    self.cinemaxPriceLabelThree.text = kIncl;
                    self.cinemaxPrice = @0;
                    self.cinemaxSelected = YES;
                    self.cinemaxSegmentedControlThree.selectedSegmentIndex = -1;
                    self.cinemaxSegmentedControlThree.enabled = NO;
                    
                    self.encorePriceLabelThree.text = kIncl;
                    self.encorePrice = @0;
                    self.encoreSelected = YES;
                    self.encoreSegmentedControlThree.selectedSegmentIndex = -1;
                    self.encoreSegmentedControlThree.enabled = NO;
                    
                    if (self.hboPriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.hboPriceLabelThree];
                    }
                    if (self.showtimePriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.showtimePriceLabelThree];
                    }
                    if (self.starzPriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.starzPriceLabelThree];
                    }
                    if (self.cinemaxPriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.cinemaxPriceLabelThree];
                    }
                    if (self.encorePriceLabelThree.alpha == 0) {
                        [self fadeInViewAnimation:self.encorePriceLabelThree];
                    }
                    if (self.totalBillView.hidden) {
                        [self finishLeftHandView];
                    }
                }
                else {
                    if (!self.hboSegmentedControlThree.enabled) {
                        self.hboPriceLabelThree.text = @"$0";
                        self.hboPrice = @0;
                        self.hboSelected = NO;
                        self.hboSegmentedControlThree.enabled = YES;
                    }
                    if (!self.showtimeSegmentedControlThree.enabled) {
                        self.showtimePriceLabelThree.text = @"$0";
                        self.showtimePrice = @0;
                        self.showtimeSelected = NO;
                        self.showtimeSegmentedControlThree.enabled = YES;
                    }
                    if (!self.starzSegmentedControlThree.enabled) {
                        self.starzPriceLabelThree.text = @"$0";
                        self.starzPrice = @0;
                        self.starzSelected = NO;
                        self.starzSegmentedControlThree.enabled = YES;
                    }
                    if (!self.cinemaxSegmentedControlThree.enabled) {
                        self.cinemaxPriceLabelThree.text = @"$0";
                        self.cinemaxPrice = @0;
                        self.cinemaxSelected = NO;
                        self.cinemaxSegmentedControlThree.enabled = YES;
                    }
                    if (!self.encoreSegmentedControlThree.enabled) {
                        self.encorePriceLabelThree.text = @"$0";
                        self.encorePrice = @0;
                        self.encoreSelected = NO;
                        self.encoreSegmentedControlThree.enabled = YES;
                    }
                }
            }
        }
    }
    
    
    //On choosing a new provider
    else if (sender == self.betterProviderList){
        if (self.rightSidePackageButton.hidden == YES) {
            [self animateViewTopToBottom:self.rightSidePackageButton];
        }
        else{
            [self resetNewPackage];
        }
        
        if ([selection isEqualToString:kDishNetwork]) {
            self.promoHeaderLabel.text = @"Promo Price";
            self.regularHeaderLabel.text = @"Regular Price";
        }
        else if ([selection isEqualToString:kDirecTv]) {
            self.promoHeaderLabel.text = @"Year 1 Price";
            self.regularHeaderLabel.text = @"Year 2 Price";
        }
        
        NSArray *packages = [[kCalculatorDictionary objectForKey:selection] objectForKey:kPackage];
        self.sellingPackageList = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.rightSidePackageButton contentList:packages noSelectionTitle:@"Package"];
        [self.sellingPackageList selectItem:nil];
    }
    
    //On choosing a new package
    else if (sender == self.sellingPackageList){
        if (self.receiverConfigButton.hidden) {
            [self animateViewTopToBottom:self.receiverConfigButton];
            NSArray *contentList;
            if ([self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
                contentList = [[[kCalculatorDictionary objectForKey:self.betterProviderList.selectedItem] objectForKey:kReceiverConfiguration] objectAtIndex:[self.numberTVs intValue]];
            }
            else if ([self.betterProviderList.selectedItem isEqualToString:kDirecTv]) {
                contentList = [[kCalculatorDictionary objectForKey:self.betterProviderList.selectedItem] objectForKey:kReceiverConfiguration];
            }
            self.receiverConfigList = [[AVSelectionListController alloc] initWithDelegate:self
                                                                             sourceButton:self.receiverConfigButton
                                                                              contentList:contentList
                                                                         noSelectionTitle:@"Receiver Configuration"];
            [self.receiverConfigList selectItem:nil];
        }
        else if (self.promoHeaderLabel.alpha != 0){
            [self calculateNewProviderPrice];
            [self updateBenefits];
        }
    }
    
    //On choosing receiver configuration
    else if (sender == self.receiverConfigList) {
        [self calculateNewProviderPrice];
        [self updateBenefits];
    }
    // Dismiss popover when a selection is made
    [self dismissAll:YES];
    
    
    if (!self.totalBillView.hidden) {
        [self calculateTotalCurrentPrice];
    }
}


#pragma mark - Popover and Action Sheet Methods

// Selects the approriate list or picker
- (UIViewController *)selectionForButton:(UIButton *)button {
    if (button == self.currentProviderButton) return self.currentProviderList;
    if (button == self.betterProviderButton) return self.betterProviderList;
    if (button == self.rightSidePackageButton) return self.sellingPackageList;
    if (button == self.packageButtonOne || button == self.packageButtonTwo || button == self.packageButtonThree) return self.basePackageList;
    if (button == self.receiverConfigButton) return self.receiverConfigList;
    return nil;
}

// For popovers (iPads)
- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    }
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    //self.popover.delegate = self;
    self.popover.passthroughViews = [NSArray arrayWithObject:self.view];
    self.popoverView = sender;
    [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popoverView = nil;
    self.popover = nil;
}

- (void)setPopoverLocation {
    
    if (self.popover && self.popoverView.superview.window) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        self.popoverView = nil;
        self.popover = nil;
    }
    /*if (self.actionSheet) {
     [self dismissActionSheet:self];
     }*/
}


#pragma mark - Animations

- (void)animateViewTopToBottom:(UIView *) view{
    CGRect endFrame = view.frame;
    CGRect startFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 0);
    view.frame = startFrame;
    
    //Unhide right before we animate
    view.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         view.frame = endFrame;
                     }
                     completion:^(BOOL finished) {
                         //NSLog(@"Done!");
                     }];
}

- (void)animateViewLeftToRight:(UIView *) view{
    CGRect endFrame = view.frame;
    CGRect startFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 0, view.frame.size.height);
    view.frame = startFrame;
    
    //Unhide right before we animate
    view.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         view.frame = endFrame;
                     }
                     completion:^(BOOL finished) {
                         //NSLog(@"Done!");
                     }];
}

- (void)fadeInViewAnimation:(UIView *) view{
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         //NSLog(@"Done!");
                     }];
}

#pragma mark - Calculations
- (void)updateBenefits {
    int currentChannels = [[[[kCalculatorDictionary objectForKey:self.currentProviderList.selectedItem] objectForKey:kPackageChannels] objectForKey:self.basePackageList.selectedItem] intValue];
    int newChannels = [[[[kCalculatorDictionary objectForKey:self.betterProviderList.selectedItem] objectForKey:kPackageChannels] objectForKey:self.sellingPackageList.selectedItem] intValue];
    if (newChannels > currentChannels) {
        self.benefitLabelA.text = [NSString stringWithFormat:@"✔ %d more channels", (newChannels - currentChannels)];
        if (self.benefitLabelA.alpha == 0) {
            [self fadeInViewAnimation:self.benefitLabelA];
        }
    }
    else {
        self.benefitLabelA.alpha = 0;
    }
    
    if ([self.betterProviderList.selectedItem isEqualToString:kDirecTv]) {
        self.benefitLabelB.text = [NSString stringWithFormat:@"✔ %d Digital TVs", [self.numberTVs intValue] + 1];
        self.benefitLabelC.text = @"✔ 5 Tuners";
        self.benefitLabelD.text = @"✔ Quick Tune";
        self.benefitLabelE.text = @"✔ TV Anywhere";
        self.benefitLabelF.text = @"✔ Most Full-Time HD";
    }
    else if ([self.betterProviderList.selectedItem isEqualToString:kDishNetwork]) {
        self.benefitLabelB.text = [NSString stringWithFormat:@"✔ %d Digital TVs", [self.numberTVs intValue] + 1];
        self.benefitLabelC.text = @"✔ Free HD for 24 months";
        self.benefitLabelD.text = @"✔ Free Blockbuster";
        self.benefitLabelE.text = @"✔ TV Anywhere";
        self.benefitLabelF.text = @"✔ Record 500 HD hours";
    }
    
    if (self.benefitLabelB.alpha == 0) {
        [self fadeInViewAnimation:self.benefitLabelB];
    }
    if (self.benefitLabelC.alpha == 0) {
        [self fadeInViewAnimation:self.benefitLabelC];
    }
    if (self.benefitLabelD.alpha == 0) {
        [self fadeInViewAnimation:self.benefitLabelD];
    }
    if (self.benefitLabelE.alpha == 0) {
        [self fadeInViewAnimation:self.benefitLabelE];
    }
    if (self.benefitLabelF.alpha == 0) {
        [self fadeInViewAnimation:self.benefitLabelF];
    }
}

- (void)calculateNewProviderPrice{
    
    
    // Calculate promo and regular prices for new provider
    self.promoPrice = [SRPriceCalculator priceForPackage:self.sellingPackageList.selectedItem
                                                provider:self.betterProviderList.selectedItem
                                           configuration:self.receiverConfigList.selectedItem
                                                 isPromo:YES
                                               numberTVs:self.numberTVs];
    self.regularPrice = [SRPriceCalculator priceForPackage:self.sellingPackageList.selectedItem
                                                  provider:self.betterProviderList.selectedItem
                                             configuration:self.receiverConfigList.selectedItem
                                                   isPromo:NO
                                                 numberTVs:self.numberTVs];
    
    
    // Add movie channel costs
    NSMutableArray *movieChoices = [[NSMutableArray alloc] init];
    if (self.hboSelected) {
        [movieChoices addObject:kHBO];
    }
    if (self.showtimeSelected) {
        [movieChoices addObject:kShowtime];
    }
    if (self.starzSelected) {
        [movieChoices addObject:kStarz];
    }
    if (self.cinemaxSelected) {
        [movieChoices addObject:kCinemax];
    }
    if (self.encoreSelected) {
        [movieChoices addObject:kEncore];
    }
    
    if ([self.betterProviderList.selectedItem isEqualToString:kDirecTv]) {
        if ([self.sellingPackageList.selectedItem isEqualToString:kUltimate]) {
            [movieChoices removeObject:kEncore];
        }
        else if ([self.sellingPackageList.selectedItem isEqualToString:kPremier]) {
            [movieChoices removeAllObjects];
        }
    }
    
    int moviesTotal = [[SRPriceCalculator totalPriceForMovieChannels:movieChoices provider:self.betterProviderList.selectedItem] intValue];
    if (!([self.sellingPackageList.selectedItem isEqualToString:@"Everything Pack"] || [self.sellingPackageList.selectedItem isEqualToString:@"Lo Maximo"] || [self.sellingPackageList.selectedItem isEqualToString:@"Premier"])) {
        self.promoPrice = [NSNumber numberWithInt:([self.promoPrice intValue] + moviesTotal)];
        self.regularPrice = [NSNumber numberWithInt:([self.regularPrice intValue] + moviesTotal)];
    }
    
    // Add in warranty if applicable (right now only DIRECTV)
    if (self.warrantySwitch.on) {
        int warranty = [[SRPriceCalculator priceForWarrantyWithProvider:self.betterProviderList.selectedItem] intValue];
        self.promoPrice = [NSNumber numberWithInt:([self.promoPrice intValue] + warranty)];
        self.regularPrice = [NSNumber numberWithInt:([self.regularPrice intValue] + warranty)];
    }
    
    // Update price and benefit labels
    self.promoPriceLabel.text = [NSString stringWithFormat:@"$%i", [self.promoPrice intValue]];
    self.betterPriceLabel.text = [NSString stringWithFormat:@"$%i", [self.regularPrice intValue]];
    
    int promoMonthlySavings = [self.totalCurrentPrice intValue] - [self.promoPrice intValue];
    self.promoSavingsLabel.text = [NSString stringWithFormat:@"Save $%i/month", promoMonthlySavings];
    
    int regularMonthlySavings = [self.totalCurrentPrice intValue] - [self.regularPrice intValue];
    self.regularSavingsLabel.text = [NSString stringWithFormat:@"Save $%i/month", regularMonthlySavings];
    
    int firstYearSavings = promoMonthlySavings * 12;
    self.firstYearSavingsLabel.text = [NSString stringWithFormat:@"$%i", firstYearSavings];
    
    // View animations
    if (!self.receiverConfigButton.hidden) {
        if (self.promoHeaderLabel.alpha == 0) {
            [self fadeInViewAnimation:self.promoHeaderLabel];
            [self fadeInViewAnimation:self.promoPriceLabel];
            [self fadeInViewAnimation:self.regularHeaderLabel];
            [self fadeInViewAnimation:self.betterPriceLabel];
        }
        
        if ([self.betterProviderList.selectedItem isEqualToString:kDirecTv] && (self.warrantyView.alpha == 0)) {
            [self fadeInViewAnimation:self.warrantyView];
        }
        
        if (promoMonthlySavings > 0 && self.promoSavingsLabel.alpha == 0) {
            [self fadeInViewAnimation:self.promoSavingsLabel];
        }
        else if (promoMonthlySavings <= 0 && self.promoSavingsLabel.alpha != 0) {
            self.promoSavingsLabel.alpha = 0;
        }
        
        if (regularMonthlySavings > 0 && self.regularSavingsLabel.alpha == 0) {
            [self fadeInViewAnimation:self.regularSavingsLabel];
        }
        else if (regularMonthlySavings <= 0 && self.regularSavingsLabel.alpha != 0) {
            self.regularSavingsLabel.alpha = 0 ;
        }
        
        if (firstYearSavings > 0 && self.firstYearSavingsHeader.alpha == 0) {
            [self fadeInViewAnimation:self.firstYearSavingsHeader];
            [self fadeInViewAnimation:self.firstYearSavingsLabel];
        }
        else if (firstYearSavings <= 0 && self.firstYearSavingsHeader.alpha != 0) {
            self.firstYearSavingsHeader.alpha = 0;
            self.firstYearSavingsLabel.alpha = 0;
        }
    }
}

- (void)calculateTotalCurrentPrice{
    self.totalCurrentPrice = [NSNumber numberWithInt:([self.hardwarePriceA intValue] + [self.hardwarePriceB intValue] + [self.hardwarePriceC intValue] + [self.hdPrice intValue] + [self.packageBasePrice intValue] + [self.hboPrice intValue] + [self.showtimePrice intValue] + [self.starzPrice intValue] + [self.cinemaxPrice intValue] + [self.encorePrice intValue])];
    self.totalCurrentLabel.text = [NSString stringWithFormat:@"$%i", [self.totalCurrentPrice intValue]];
    
    //update right hand side if necessary
    if (self.benefitLabelB.alpha != 0) {
        [self updateBenefits];
        [self calculateNewProviderPrice];
    }
}

#pragma mark - Flurry
//
- (void) flurryTrack {
    NSString *username = [[SRGlobalState singleton] userName];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
    
    [Flurry logEvent:@"Bill Calculator view opened" withParameters:articleParams timed:YES];
}

@end
