//
//  Constants.h
//  Dish Sales
//
//  Created by Jeff on 11/9/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//
#import "SRSalesConstants.h"

// Service Dictionary Keys
FOUNDATION_EXPORT NSString * const kDishNetwork;
FOUNDATION_EXPORT NSString * const kDirecTv;
FOUNDATION_EXPORT NSString * const kReceiverConfiguration;
FOUNDATION_EXPORT NSString * const kPackage;
FOUNDATION_EXPORT NSString * const kTvs;

// Bill Calculator
FOUNDATION_EXPORT NSString * const kPackagePrice;
FOUNDATION_EXPORT NSString * const kPackageChannels;
FOUNDATION_EXPORT NSString * const kPackagePromoPrice;
FOUNDATION_EXPORT NSString * const kComcast;
FOUNDATION_EXPORT NSString * const kCox;
FOUNDATION_EXPORT NSString * const kUverse;
FOUNDATION_EXPORT NSString * const kTimeWarner;
FOUNDATION_EXPORT NSString * const kFios;
FOUNDATION_EXPORT NSString * const kCharter;
FOUNDATION_EXPORT NSString * const kBrightHouse;
FOUNDATION_EXPORT NSString * const kCableOne;
FOUNDATION_EXPORT NSString * const kHardwarePrice;
FOUNDATION_EXPORT NSString * const kMovieChannelPrice;
FOUNDATION_EXPORT NSString * const kMultipleMovieChannelPrice;
FOUNDATION_EXPORT NSString * const kPackageIncludesMovieChannels;
FOUNDATION_EXPORT NSString * const kHDOption;
FOUNDATION_EXPORT NSString * const kDVRCharge;
FOUNDATION_EXPORT NSString * const kTVs;
FOUNDATION_EXPORT NSString * const kHDDVR;
FOUNDATION_EXPORT NSString * const kSDDVR;
FOUNDATION_EXPORT NSString * const kWholeHomeDVR;
FOUNDATION_EXPORT NSString * const kHDOnlyBoxes;
FOUNDATION_EXPORT NSString * const kMultiTVDVR;
FOUNDATION_EXPORT NSString * const kHBO;
FOUNDATION_EXPORT NSString * const kShowtime;
FOUNDATION_EXPORT NSString * const kStarz;
FOUNDATION_EXPORT NSString * const kCinemax;
FOUNDATION_EXPORT NSString * const kEncore;
FOUNDATION_EXPORT NSString * const kHBOAndCinemax;
FOUNDATION_EXPORT NSString * const kComcastDigitalPreferred;
FOUNDATION_EXPORT NSString * const kComcastDigitalPremier;
FOUNDATION_EXPORT NSString * const kUltimate;
FOUNDATION_EXPORT NSString * const kPremier;
FOUNDATION_EXPORT NSString * const kIncl;
FOUNDATION_EXPORT NSString * const kReceiverPricing;

// Bill Calculator Constants
NSArray *kCurrentProviders;
NSArray *kCurrentProvidersLeads;
NSArray *kNewProviders;
NSDictionary *kCalculatorDictionary;


#import "SRConstants.h"

@interface SRBillCalcConstants : NSObject

/*
 Call this method on app launch to initialize collection constants
 */
+ (void)initValues;

@end
