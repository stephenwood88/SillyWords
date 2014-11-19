////
////  Constants.m
////  Dish Sales
////
////  Created by Jeff on 11/9/12.
////  Copyright (c) 2012 AppVantage. All rights reserved.
////
//
#import "Constants.h"

NSString * const kFacebookID = @"id";
NSString * const kName = @"name";
NSString * const kFacebookInfo = @"facebookInfo";
NSString * const kUserInfo = @"userInfo";
//
//// Flags
//NSString * const kBuild20130625BugFix = @"kBuild20130625BugFix";
//NSString * const kVersion1_4SalesMaterialsBugFix = @"kBuild1.4SalesMaterialsBugFix";
//NSString * const kVersion1_10CoreDataMigration = @"kVersion1.10CoreDataMigration";
//
////All Options
//NSString * const kSatellite = @"Satellite";
//
//// Agreements
//NSString * const kAgreementHeading1 = @"Customer Info";
//NSString * const kAgreementHeading2 = @"Payment Info";
//NSString * const kAgreementHeading3 = @"Service Info";
//
//NSString * const kEnglish = @"English";
//NSString * const kSpanish = @"Spanish";
//
//NSString * const kDateOfBirth = @"Date of Birth";
//NSString * const kExpDate = @"Exp Date";
//
//NSString * const kChecking = @"Checking";
//NSString * const kSavings = @"Savings";
//
//
//// Check and submit
//NSString * const kErrorTitle = @"Agreement Incomplete";
//NSString * const kErrorCustomerInfoMessage = @"Fill in all required fields before submitting the agreement.";
//NSString * const kErrorAgreementPdfMessage = @"Sign the agreement before submitting.";
//
//// Confirmations
//NSString * const kNewConfirmation = @"Delete this agreement and start a new one?";
//NSString * const kSubmitConfirmation = @"Ready to submit this agreement?";
//NSString * const kOpenConfirmation = @"Delete the current agreement and open this one?";
//NSString * const kAgreementConfirmation = @"Delete the current agreement and start a new one with this lead?";
//
//// NSUserDefaults
//NSString * const kAgreementSettingsUpdatedDictionary = @"agreementSettingsUpdatedDictionary";
//NSString * const kAgreementContactAndTermsDictionary = @"agreementContactAndTermsDictionary";
//
//// Agreement Settings
//NSString * const kAgreementSettingsDirecTVAgreement = @"DirecTVAgreement";
//NSString * const kAgreementSettingsDishNetworkAgreement = @"DishNetworkAgreement";
//
//// Agreement Fields
//NSString * const kFName = @"FName";
//NSString * const kLName = @"LName";
//NSString * const kBusinessName = @"BusinessName";
//NSString * const kPhone2 = @"Phone2";
//NSString * const kPhone3 = @"Phone3";
//NSString * const kDob = @"DOB";
//NSString * const kSsn = @"SSN";
//NSString * const kStreet2 = @"Street2";
//NSString * const kZip = @"Zip";
//NSString * const kBillStreet = @"BillStreet";
//NSString * const kBillStreet2 = @"BillStreet2";
//NSString * const kBillCity = @"BillCity";
//NSString * const kBillState = @"BillState";
//NSString * const kBillZip = @"BillZip";
//NSString * const kCcType = @"CC Type";
//NSString * const kCcNumber = @"CC Number";
//NSString * const kExpirationDate = @"Expiration Date";
//NSString * const kCcCode = @"CC Code";
//NSString * const kFinancialName = @"Financial Name";
//NSString * const kAccountType = @"Account Type";
//NSString * const kRoutingNumber = @"Routing Number";
//NSString * const kAccountNumber = @"Account Number";
//NSString * const kSaleDate = @"Sale Date";
//NSString * const kContactDate = @"ContactDate";
//NSString * const kUserId = @"User ID";
//NSString * const kServiceInfo = @"Service Info";
//NSString * const kNumberTvs = @"numberTVs";
//NSString * const kInternetAccess = @"Internet Access";
//NSString * const kPromoPrice = @"Promo Price";
//NSString * const kRegularPrice = @"Regular Price";
//NSString * const kNotes = @"Notes";
//NSString * const kSetupPrice = @"Setup Price";
//NSString * const kagreementId = @"customerAgreementID";
//NSString * const kAgemniLeadId = @"leadID";
//
//// Credit card types
//NSString * const kAmericanExpress = @"American Express";
//NSString * const kMasterCard = @"Mastercard";
//NSString * const kVisa = @"Visa";
//NSString * const kDiscover = @"Discover";
//
//@implementation Constants
//
//// Call this method on app launch to initialize collection constants
//+ (void)initValues {
//    
//    static BOOL valuesInitialized = NO;
//    if (!valuesInitialized) {
//        
//        kReminderTimeDictionary = @{kRemindNone: @-1,
//                                    kRemind0Min: @0,
//                                    kRemind5Min: ,
//                                    kRemind15Min: ,
//                                    kRemind30Min: ,
//                                    kRemind1Hr: };
//        kLeadStatuses = @[kGoBack, kCallback, kNotHome, kNotInterested, kOther];
//        kLeadStatusesCustomer = @[kGoBack, kCallback, kNotHome, kNotInterested, kOther, kCustomer];
//        kLeadStatusesNew = @[kGoBack, kCallback];
//        kCustomerStatuses = @[@"All", @"Completed", @"Pending", @"Not Scheduled", @"Cancelled", @"Chargeback"];
//        kLeadRanks = @[@"0-Don't Call Back", @"1-Not Very Interested", @"2-Somewhat Interested", @"3-Interested", @"4-Very Interested", @"5-Golden Contact"];
//        kLeadTypes = @[@"Inside Sales", @"Switch Over-In Contract", @"Switch Over-Out of Contract", @"Doesn't Watch TV", @"Check with Husband", @"Check with Wife", @"Been Wanting Service", @"Money Tight", @"Other"];
//        kLeadWindows = @[kAnytime, kWindow8toNoon, kWindowNoonto5, kWindowAfter5];
//        kLeadQuickDates = @[@"Today", @"Yesterday", @"Tomorrow", @"This Week", @"This Month", @"This Year", @"All Time"];
//        kReportsQuickDates = @[@"Today", @"Yesterday", @"This Week", @"This Month", @"This Year", @"All Time"];
//        kLeadFilterDateOptions = @[@"Date Created", @"Appointment Date"];
//        kLeadFilterDateOptionsIphone = @[@"Date Created", @"Appt. Date"];
//        
//        kLanguageList = @[@"English", @"Spanish"];
//        
//        kServiceDictionary = @{
//                             kDishNetwork: @{
//                                     kReceiverConfiguration:
//                                         @[
//                                             @[@"Hopper", @"722", @"211"],
//                                             @[@"Hopper:1/SuperJoey:1", @"Hopper:1/Joey:1", @"722", @"722/211", @"211/211",@"222",@"211/222"],
//                                             @[@"Hopper:1/SuperJoey:1/Joey:1", @"Hopper:1/Joey:2", @"Hopper:2/Joey:1", @"722/211", @"211/211/211", @"222/211/211"],
//                                             @[@"Hopper:1/Joey:3", @"Hopper:2", @"722/722", @"722/222", @"722/211/211", @"211/211/322", @"211/211/211/211"],
//                                             @[@"Hopper:2/Joey:3", @"722/722/211", @"722/222/211"],
//                                             @[@"Hopper:2/Joey:4", @"722/722/222", @"722/222/222", @"722/222/211,211"]
//                                             ],
//                                     
//                                     kPackage:
//                                         @[@"Smart Pack", @"America's Top 120", @"America's Top 200", @"America's Top 250", @"Everything Pack", @"Latino Básico", @"Latino Clásico", @"Latino Plus", @"Latino Dos", @"Latino Max"],
//                                     kTvs:
//                                         @[@"1 TV", @"2 TVs", @"3 TVs", @"4 TVs", @"5 TVs", @"6 TVs"]
//                                     },
//                             kDirecTv: @{
//                                     kReceiverConfiguration:
//                                         @[
//                                             @[@"Genie", @"HR24", @"H25", @"R16", @"D12"],
//                                             @[@"Genie, Genie mini", @"HR24, H25", @"HR24, HR24", @"H25, H25", @"R16, D12", @"R16, R16", @"D12, D12"],
//                                             @[@"Genie, G mini, G mini", @"HR24, H25, H25", @"HR24, HR24, H25", @"H25, H25, H25", @"R16, D12, D12", @"R16, R16, D12", @"D12, D12, D12"],
//                                             @[@"Genie, G mini, G mini, G mini", @"HR24, H25, H25, H25", @"HR24, HR24, H25, H25", @"H25, H25, H25, H25", @"R16, D12, D12, D12", @"R16, R16, D12, D12", @"D12, D12, D12, D12"],
//                                             @[@"Genie, G mini, G mini, G mini", @"HR24, H25, H25, H25, H25", @"HR24, HR24, H25, H25, H25", @"H25, H25, H25, H25, H25", @"R16, D12, D12, D12, D12", @"R16, R16, D12, D12, D12", @"D12, D12, D12, D12"],
//                                             @[@"Genie, G mini, G mini, G mini, G mini, G mini", @"Genie, G mini, G mini, G mini, G mini, H25", @"Genie, G mini, G mini, G mini, H25, H25", @"HR24, H25, H25, H25, H25, H25", @"H25, H25, H25, H25, H25, H25"]
//                                             ],
//                                     
//                                     kPackage:
//                                         @[@"Select", @"Entertainment", @"Choice", @"Xtra", @"Ultimate", @"Premier", @"Mas Latino", @"Optimo Más", @"Más Ultra", @"Lo Maximo"],
//                                     kTvs:
//                                         @[@"1 TV", @"2 TVs", @"3 TVs", @"4 TVs", @"5 TVs", @"6 TVs"]
//                                     }
//                             };
//        
//        [SRBillCalcConstants initValues];
//
//        
//        valuesInitialized = YES;
//    }
//}
//
//@end
