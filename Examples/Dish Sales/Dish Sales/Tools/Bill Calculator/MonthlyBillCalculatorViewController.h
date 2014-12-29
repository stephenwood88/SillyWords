//
//  MonthlyBillCalculatorViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 3/16/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthlyBillCalculatorViewController : UIViewController

//Choices View One (Comcast, Cox, U-verse, Charter, CableOne)
//Views
@property (weak, nonatomic) IBOutlet UIView *tvViewOne;
@property (weak, nonatomic) IBOutlet UIView *hdDVRViewOne;
@property (weak, nonatomic) IBOutlet UIView *hdOnlyViewOne;
@property (weak, nonatomic) IBOutlet UIView *packageViewOne;
@property (weak, nonatomic) IBOutlet UIView *movieChannelViewOne;
//Price Labels
@property (weak, nonatomic) IBOutlet UILabel *tvPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *hdDVRPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *hdOnlyPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *hboPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *showtimePriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *starzPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *cinemaxPriceLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *encorePriceLabelOne;
//Segmented Controls
@property (weak, nonatomic) IBOutlet UISegmentedControl *tvSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hdDVRSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hdOnlySegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hboSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showtimeSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *starzSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cinemaxSegmentedControlOne;
@property (weak, nonatomic) IBOutlet UISegmentedControl *encoreSegmentedControlOne;
//Package Dropdown Button
@property (weak, nonatomic) IBOutlet UIButton *packageButtonOne;
//Actions
- (IBAction)tvOneSegmentChanged:(id)sender;
- (IBAction)hdDVROneSegmentChanged:(id)sender;
- (IBAction)hdOnlyOneSegmentChanged:(id)sender;
- (IBAction)hboOneSegmentChanged:(id)sender;
- (IBAction)showtimeOneSegmentChanged:(id)sender;
- (IBAction)starzOneSegmentChanged:(id)sender;
- (IBAction)cinemaxOneSegmentChanged:(id)sender;
- (IBAction)encoreOneSegmentChanged:(id)sender;
- (IBAction)packageOnePressed:(id)sender;


//Choices View Two (Time Warner, Fios (Verizon)
//Views
@property (weak, nonatomic) IBOutlet UIView *tvViewTwo;
@property (weak, nonatomic) IBOutlet UIView *multiTVDVRView;
@property (weak, nonatomic) IBOutlet UIView *hdDVRViewTwo;
@property (weak, nonatomic) IBOutlet UIView *hdOnlyViewTwo;
@property (weak, nonatomic) IBOutlet UIView *packageViewTwo;
@property (weak, nonatomic) IBOutlet UIView *movieChannelViewTwo;
//Price Labels
@property (weak, nonatomic) IBOutlet UILabel *tvPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *multiTVDVRPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *hdDVRPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *hdOnlyPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *hboPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *showtimePriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *starzPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *cinemaxPriceLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *encorePriceLabelTwo;
//Segmented Controls
@property (weak, nonatomic) IBOutlet UISegmentedControl *tvSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiTVDVRSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hdDVRSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hdOnlySegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hboSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showtimeSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *starzSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cinemaxSegmentedControlTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *encoreSegmentedControlTwo;
//Package Dropdown Button
@property (weak, nonatomic) IBOutlet UIButton *packageButtonTwo;
//Actions
- (IBAction)tvTwoSegmentChanged:(id)sender;
- (IBAction)multiTVDVRSegmentChanged:(id)sender;
- (IBAction)hdDVRTwoSegmentChanged:(id)sender;
- (IBAction)hdOnlyTwoSegmentChanged:(id)sender;
- (IBAction)hboTwoSegmentChanged:(id)sender;
- (IBAction)showtimeTwoSegmentChanged:(id)sender;
- (IBAction)starzTwoSegmentChanged:(id)sender;
- (IBAction)cinemaxTwoSegmentChanged:(id)sender;
- (IBAction)encoreTwoSegmentChanged:(id)sender;
- (IBAction)packageTwoPressed:(id)sender;


//Choices View Three (DISH, DirecTV)
//Views
@property (weak, nonatomic) IBOutlet UIView *tvViewThree;
@property (weak, nonatomic) IBOutlet UIView *dvrViewThree;
@property (weak, nonatomic) IBOutlet UIView *hdViewThree;
@property (weak, nonatomic) IBOutlet UIView *packageViewThree;
@property (weak, nonatomic) IBOutlet UIView *movieChannelViewThree;
//Price labels
@property (weak, nonatomic) IBOutlet UILabel *tvPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *dvrPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *hdPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *hboPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *showtimePriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *starzPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *cinemaxPriceLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *encorePriceLabelThree;
//Segmented Controls
@property (weak, nonatomic) IBOutlet UISegmentedControl *tvSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dvrSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hdSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *hboSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showtimeSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *starzSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cinemaxSegmentedControlThree;
@property (weak, nonatomic) IBOutlet UISegmentedControl *encoreSegmentedControlThree;
//Package Dropdown Button
@property (weak, nonatomic) IBOutlet UIButton *packageButtonThree;
//Actions
- (IBAction)tvThreeSegmentChanged:(id)sender;
- (IBAction)dvrThreeSegmentChanged:(id)sender;
- (IBAction)hdThreeSegmentChanged:(id)sender;
- (IBAction)hboThreeSegmentChanged:(id)sender;
- (IBAction)showtimeThreeSegmentChanged:(id)sender;
- (IBAction)starzThreeSegmentChanged:(id)sender;
- (IBAction)cinemaxThreeSegmentChanged:(id)sender;
- (IBAction)encoreThreeSegmentChanged:(id)sender;
- (IBAction)packageThreePressed:(id)sender;


//Dropdown buttons
@property (weak, nonatomic) IBOutlet UIButton *currentProviderButton;
@property (weak, nonatomic) IBOutlet UIButton *betterProviderButton;
@property (weak, nonatomic) IBOutlet UIButton *rightSidePackageButton;
@property (weak, nonatomic) IBOutlet UIButton *receiverConfigButton;

//Switches
@property (weak, nonatomic) IBOutlet UISwitch *warrantySwitch;
@property (weak, nonatomic) IBOutlet UIView *warrantyView;

//Price labels
@property (weak, nonatomic) IBOutlet UILabel *totalCurrentLabel;
@property (weak, nonatomic) IBOutlet UILabel *promoPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *promoSavingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *betterPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularSavingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstYearSavingsHeader;
@property (weak, nonatomic) IBOutlet UILabel *firstYearSavingsLabel;

@property (weak, nonatomic) IBOutlet UILabel *promoHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularHeaderLabel;

//Comparison labels
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelA;
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelB;
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelC;
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelD;
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelE;
@property (weak, nonatomic) IBOutlet UILabel *benefitLabelF;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//Divider views
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;

@property (weak, nonatomic) IBOutlet UIView *choicesView;
@property (weak, nonatomic) IBOutlet UIView *totalBillView;

- (IBAction)providerButtonPressed:(UIButton *)sender;
- (IBAction)warrantyValueChanged:(UISwitch *)sender;


@end