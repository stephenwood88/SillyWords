//
//  Constants.m
//  Dish Sales
//
//  Created by Jeff on 11/9/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "SRBillCalcConstants.h"


@implementation SRBillCalcConstants

// Service Dictionary Keys
NSString * const kDishNetwork = @"DISH";
NSString * const kDirecTv = @"DIRECTV";
NSString * const kReceiverConfiguration = @"Receiver Configuration";
NSString * const kPackage = @"Package";
NSString * const kTvs = @"TVs";

// Bill Calculator
NSString * const kPackagePrice = @"PackagePrice";
NSString * const kPackageChannels = @"Package Channels";
NSString * const kPackagePromoPrice = @"Package Promo Price";
NSString * const kComcast = @"Comcast";
NSString * const kCox = @"Cox";
NSString * const kUverse = @"U-verse";
NSString * const kTimeWarner = @"Time Warner";
NSString * const kFios = @"FiOS";
NSString * const kCharter = @"Charter";
NSString * const kCableOne = @"CableOne";
NSString * const kBrightHouse = @"Bright House";
NSString * const kPackageIncludesMovieChannels = @"Package Includes Movie Channels:";
NSString * const kHardwarePrice = @"Hardware Price";
NSString * const kMovieChannelPrice = @"Movie Channel Price";
NSString * const kMultipleMovieChannelPrice = @"Multiple Movie Channel Prices";
NSString * const kHDOption = @"HD Option";
NSString * const kDVRCharge = @"DVR Charge";
NSString * const kTVs = @"TVs";
NSString * const kHDDVR = @"HD DVRs";
NSString * const kSDDVR = @"SD DVRs";
NSString * const kWholeHomeDVR = @"Whole Home DVRs";
NSString * const kHDOnlyBoxes = @"HD Only Boxes";
NSString * const kMultiTVDVR = @"Multi-TV DVR";
NSString * const kHBO = @"HBO";
NSString * const kShowtime = @"Showtime";
NSString * const kStarz = @"Starz";
NSString * const kCinemax = @"Cinemax";
NSString * const kEncore = @"Encore";
NSString * const kHBOAndCinemax = @"HBO & Cinemax";
NSString * const kComcastDigitalPreferred = @"Digital Preferred";
NSString * const kComcastDigitalPremier = @"Digital Premier";
NSString * const kUltimate = @"Ultimate";
NSString * const kPremier = @"Premier";
NSString * const kIncl = @"Incl";
NSString * const kReceiverPricing = @"Receiver Pricing";

// Call this method on app launch to initialize collection constants
+ (void)initValues {
    
    static BOOL valuesInitialized = NO;
    if (!valuesInitialized) {
                
        // Bill Calculator
        kCurrentProviders = @[kBrightHouse, kCableOne, kCharter, kComcast, kCox, kDishNetwork, kDirecTv, kFios, kTimeWarner, kUverse, ];
        kCurrentProvidersLeads = @[kBrightHouse, kCableOne, kCharter, kComcast, kCox, kDishNetwork, kDirecTv, kFios, kTimeWarner, kUverse, kOther];
        kNewProviders = @[kDishNetwork, kDirecTv];
        kCalculatorDictionary = @{
                                  kDishNetwork: @{
                                          kReceiverConfiguration:
                                              @[
                                                  @[@"Hopper", @"222", @"722"],
                                                  @[@"Hopper:1/Joey:1", @"Hopper:2/Joey:0", @"222", @"722"],
                                                  @[@"Hopper:1/Joey:2", @"Hopper:2/Joey:1", @"222/211", @"722/211"],
                                                  @[@"Hopper:1/Joey:3", @"Hopper:2/Joey:2", @"222/211/211", @"722/211/211"],
                                                  @[@"Hopper:2/Joey:3", @"722/222/211", @"222/211/211/211"],
                                                  @[@"Hopper:2/Joey:4", @"722/222/222"],
                                                  ],
                                          kReceiverPricing: @{
                                              @"Hopper": @5,
                                              @"722": @0,
                                              @"222": @-7,
                                              @"Hopper:1/Joey:1": @12,
                                              @"Hopper:2/Joey:0": @17,
                                              @"722/211": @7,
                                              @"222/211": @0,
                                              @"Hopper:1/Joey:2": @19,
                                              @"Hopper:2/Joey:1": @24,
                                              @"722/211/211": @14,
                                              @"222/211/211": @7,
                                              @"Hopper:1/Joey:3": @26,
                                              @"Hopper:2/Joey:2": @31,
                                              @"722/222/211": @21,
                                              @"222/211/211/211": @14,
                                              @"Hopper:2/Joey:3": @38,
                                              @"Hopper:2/Joey:4": @45,
                                              @"722/222/222": @28,
                                          },
                                          kPackage:
                                              @[@"Smart Pack", @"America's Top 120", @"America's Top 200", @"America's Top 250", @"Everything Pack" , @"LATINO Dos" , @"LATINO Max"],
                                          kPackagePrice: @{
                                                  @"Smart Pack": @40,
                                                  @"America's Top 120": @62,
                                                  @"America's Top 200": @77,
                                                  @"America's Top 250": @87,
                                                  @"Everything Pack": @132,
                                                  @"LATINO Dos": @61,
                                                  @"LATINO Max": @72,
                                                  },
                                          kPackagePromoPrice: @{
                                                  @"Smart Pack": @20,
                                                  @"America's Top 120": @37,
                                                  @"America's Top 200": @47,
                                                  @"America's Top 250": @52,
                                                  @"Everything Pack": @97,
                                                  @"LATINO Dos": @37,
                                                  @"LATINO Max": @47
                                                  },
                                          kPackageChannels: @{
                                                  @"Smart Pack": @55,
                                                  @"America's Top 120": @120,
                                                  @"America's Top 200": @200,
                                                  @"America's Top 250": @250,
                                                  @"Everything Pack": @315,
                                                  },
                                          kHardwarePrice: @{
                                                  kTVs: @7,
                                                  kDVRCharge: @7,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @16,
                                                  kShowtime: @13,
                                                  kStarz: @13,
                                                  kCinemax: @13,
                                                  kEncore: @5,
                                                  },
                                          kMultipleMovieChannelPrice: @[@13, @26, @35, @45],
                                          },
                                  kDirecTv: @{
                                          kReceiverConfiguration: @[kHDDVR, @"HD only", @"Standard"],
                                          kReceiverPricing: @{
                                                  kHDDVR: @15,
                                                  @"HD only": @10,
                                                  @"Standard": @0,
                                                  },
                                          kPackage:
                                              @[@"Select", @"Entertainment", @"Choice", @"Choice Xtra", kUltimate, kPremier, @"Optimo Mas", @"Mas Ultra", @"Lo Maximo"],
                                          kPackagePrice: @{
                                                  @"Select": @50,
                                                  @"Entertainment": @58,
                                                  @"Choice": @67,
                                                  @"Choice Xtra": @74,
                                                  @"Ultimate": @82,
                                                  @"Premier": @130,
                                                  @"Optimo Mas": @51,
                                                  @"Mas Ultra": @68,
                                                  @"Lo Maximo": @130,
                                                  },
                                          kPackagePromoPrice: @{
                                                  @"Select": @25,
                                                  @"Entertainment": @30,
                                                  @"Choice": @35,
                                                  @"Choice Xtra": @40,
                                                  @"Ultimate": @45,
                                                  @"Premier": @93,
                                                  @"Optimo Mas": @25,
                                                  @"Mas Ultra": @35,
                                                  @"Lo Maximo": @97,
                                                  },
                                          kPackageChannels: @{
                                                  @"Select": @130,
                                                  @"Entertainment": @140,
                                                  @"Choice": @150,
                                                  @"Choice Xtra": @205,
                                                  @"Ultimate": @225,
                                                  @"Premier": @285,
                                                  @"Optimo Mas": @175,
                                                  @"Mas Ultra": @210,
                                                  @"Lo Maximo": @300,
                                                  },
                                          kHardwarePrice: @{
                                                  kTVs: @5,
                                                  kDVRCharge: @6,
                                                  kHDOption: @10,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @18,
                                                  kShowtime: @13,
                                                  kStarz: @13,
                                                  kCinemax: @13,
                                                  kEncore: @5,
                                                  },
                                          kMultipleMovieChannelPrice: @[@13, @24, @34, @42],
                                          },
                                  kComcast: @{
                                          kPackage:
                                              @[@"Limited Basic", @"Digital Economy", @"Digital Starter", kComcastDigitalPreferred, kComcastDigitalPremier],
                                          kPackagePrice: @{
                                                  @"Limited Basic": @25,
                                                  @"Digital Economy": @30,
                                                  @"Digital Starter": @66,
                                                  kComcastDigitalPreferred: @85,
                                                  kComcastDigitalPremier: @98,
                                                  },
                                          kPackageChannels: @{
                                                  @"Limited Basic": @10,
                                                  @"Digital Economy": @45,
                                                  @"Digital Starter": @80,
                                                  kComcastDigitalPreferred: @160,
                                                  kComcastDigitalPremier: @300
                                                  },
                                          kHardwarePrice: @{
                                                  kHDDVR: @18,
                                                  kHDOnlyBoxes: @10,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @10,
                                                  kShowtime: @10,
                                                  kStarz: @10,
                                                  kCinemax: @10,
                                                  },
                                          kPackageIncludesMovieChannels: @{
                                                  kComcastDigitalPreferred: @[kEncore],
                                                  kComcastDigitalPremier: @[kHBO, kShowtime, kStarz, kCinemax, kEncore],
                                                  },
                                          },
                                  kCox: @{
                                          kPackage:
                                              @[@"Cox TV Starter", @"Cox TV Economy", @"Cox TV Essential", @"Cox Advanced TV", @"Cox Advanced TV Preferred", @"Cox Advanced TV Premier"],
                                          kPackagePrice: @{
                                                  @"Cox TV Starter": @22,
                                                  @"Cox TV Economy": @35,
                                                  @"Cox TV Essential": @63,
                                                  @"Cox Advanced TV": @63,
                                                  @"Cox Advanced TV Preferred": @73,
                                                  @"Cox Advanced TV Premier": @83,
                                                  },
                                          kPackageChannels: @{
                                                  @"Cox TV Starter": @10,
                                                  @"Cox TV Economy": @50,
                                                  @"Cox TV Essential": @100,
                                                  @"Cox Advanced TV": @150,
                                                  @"Cox Advanced TV Preferred": @200,
                                                  @"Cox Advanced TV Premier": @250,
                                                  },
                                          kHardwarePrice: @{
                                                  kMultiTVDVR: @23.99,
                                                  kHDDVR: @10,
                                                  kHDOnlyBoxes: @10,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @15,
                                                  kShowtime: @15,
                                                  kStarz: @15,
                                                  kCinemax: @15,
                                                  kEncore: @7,
                                                  },
                                          kMultipleMovieChannelPrice: @[@15, @25, @34, @42],
                                          },
                                  kUverse: @{
                                          kPackage:
                                              @[@"U-family", @"U200", @"U300", @"U450"],
                                          kPackagePrice: @{
                                                  @"U-family": @59,
                                                  @"U200": @74,
                                                  @"U300": @89,
                                                  @"U450": @121,
                                                  },
                                          kPackageChannels: @{
                                                  @"U-family": @100,
                                                  @"U200": @250,
                                                  @"U300": @350,
                                                  @"U450": @400,
                                                  },
                                          kHardwarePrice: @{
                                                  kHDOption: @10,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @16,
                                                  kShowtime: @14,
                                                  kStarz: @14,
                                                  kCinemax: @14,
                                                  kEncore: @14,
                                                  kHBOAndCinemax: @13
                                                  },
                                          },
                                  kTimeWarner: @{
                                          kPackage:
                                              @[@"Basic TV", @"Standard TV", @"Digital Cable"],
                                          kPackagePrice: @{
                                                  @"Basic TV": @25,
                                                  @"Standard TV": @65,
                                                  @"Digital Cable": @79,
                                                  },
                                          kPackageChannels: @{
                                                  @"Basic TV": @20,
                                                  @"Standard TV": @70,
                                                  @"Digital Cable": @200,
                                                  },
                                          kHardwarePrice: @{
                                                  kMultiTVDVR: @30.24,
                                                  kHDDVR: @23.20,
                                                  kHDOnlyBoxes: @10.25,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @16,
                                                  kShowtime: @28,
                                                  kStarz: @16,
                                                  kCinemax: @36,
                                                  kEncore: @10,
                                                  },
                                          },
                                  kFios: @{
                                          kPackage:
                                              @[@"Select HD", @"Prime HD", @"Extreme HD", @"Ultimate HD"],
                                          kPackagePrice: @{
                                                  @"Select HD": @50,
                                                  @"Prime HD": @65,
                                                  @"Extreme HD": @75,
                                                  @"Ultimate HD": @90
                                                  },
                                          kPackageChannels: @{
                                                  @"Select HD": @150,
                                                  @"Prime HD": @200,
                                                  @"Extreme HD": @300,
                                                  @"Ultimate HD": @350,
                                                  },
                                          kHardwarePrice: @{
                                                  kMultiTVDVR: @20,
                                                  kHDDVR: @17,
                                                  kHDOnlyBoxes: @12,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @19,
                                                  kShowtime: @14,
                                                  kStarz: @14,
                                                  kCinemax: @14,
                                                  },
                                          },
                                  kCharter: @{
                                          kPackage:
                                              @[@"Select", @"Silver", @"Gold"],
                                          kPackagePrice: @{
                                                  @"Silver": @80,
                                                  @"Gold": @100,
                                                  @"Select": @60,
                                                  },
                                          kPackageChannels: @{
                                                  @"Silver": @100,
                                                  @"Gold": @150,
                                                  @"Select": @200,
                                                  },
                                          kHardwarePrice: @{
                                                  kHDDVR: @20,
                                                  kHDOnlyBoxes: @12,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @15,
                                                  kShowtime: @15,
                                                  kStarz: @15,
                                                  kCinemax: @15,
                                                  kEncore: @15
                                                  },
                                          },
                                  kCableOne: @{
                                          kPackage:
                                              @[@"Economy", @"Standard", @"Digital Value Pack"],
                                          kPackagePrice: @{
                                                  @"Economy": @29,
                                                  @"Standard": @62,
                                                  @"Digital Value Pack": @74,
                                                  },
                                          kPackageChannels: @{
                                                  @"Economy": @20,
                                                  @"Standard": @100,
                                                  @"Digital Value Pack": @150,
                                                  },
                                          kHardwarePrice: @{
                                                  kHDDVR: @15,
                                                  kHDOnlyBoxes: @5,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @15,
                                                  kShowtime: @15,
                                                  kStarz: @15,
                                                  kCinemax: @15,
                                                  kEncore: @5
                                                  },
                                          },
                                  kBrightHouse: @{
                                          kPackage:
                                              @[@"Basic", @"Standard", @"Digital"],
                                          kPackagePrice: @{
                                                  @"Basic": @26,
                                                  @"Standard": @69,
                                                  @"Digital": @83,
                                                  },
                                          kPackageChannels: @{
                                                  @"Economy": @20,
                                                  @"Standard": @100,
                                                  @"Digital Value Pack": @150,
                                                  },
                                          kHardwarePrice: @{
                                                  kHDDVR: @12,
                                                  kHDOnlyBoxes: @8,
                                                  },
                                          kMovieChannelPrice: @{
                                                  kHBO: @15,
                                                  kShowtime: @15,
                                                  kStarz: @15,
                                                  kCinemax: @15,
                                                  kEncore: @5
                                                  },
                                          },
                                  };
        
        valuesInitialized = YES;
    }
}

@end
