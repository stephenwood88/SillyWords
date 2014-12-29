//
//  SRConstants.h
//  
//
//  Created by Jeff Lockhart on 8/29/13.
//
//

FOUNDATION_EXPORT NSString * const kWebServicePath;

//Web URL
FOUNDATION_EXPORT NSString * const kWebServiceBaseURL;

// App Types
FOUNDATION_EXPORT NSString * const kSateliteApp;
FOUNDATION_EXPORT NSString * const kOriginalApp;
FOUNDATION_EXPORT NSString * const kPestApp;
FOUNDATION_EXPORT NSString * const kFoodDelivery;
FOUNDATION_EXPORT NSString * const kPremiumApp;

// Social Media
FOUNDATION_EXPORT NSString * const kSRTwitterURL;
FOUNDATION_EXPORT NSString * const kSRFacebookURL;
FOUNDATION_EXPORT NSString * const kSRGoogleURL;
FOUNDATION_EXPORT NSString * const kTwitter;
FOUNDATION_EXPORT NSString * const kFacebook;
FOUNDATION_EXPORT NSString * const kGoogle;

// Customization
FOUNDATION_EXPORT NSString * const kLastAccentColorValueRed;
FOUNDATION_EXPORT NSString * const kLastAccentColorValueGreen;
FOUNDATION_EXPORT NSString * const kLastAccentColorValueBlue;

// Organizations
FOUNDATION_EXPORT NSString * const kArea;
FOUNDATION_EXPORT NSString * const kOffice;
FOUNDATION_EXPORT NSString * const kManager;
FOUNDATION_EXPORT NSString * const kUser;
FOUNDATION_EXPORT NSString * const kAccount;

// Fonts
FOUNDATION_EXPORT NSString * const kFont1;
FOUNDATION_EXPORT NSString * const kFont2;

// Yes and No
FOUNDATION_EXPORT NSString * const kYes;
FOUNDATION_EXPORT NSString * const kNo;

// Tech Entity Results Keys
FOUNDATION_EXPORT NSString * const kID;
FOUNDATION_EXPORT NSString * const kName;

FOUNDATION_EXPORT NSString * const kInstallCount;
FOUNDATION_EXPORT NSString * const kPendingCount;
FOUNDATION_EXPORT NSString * const kNotScheduledCount;
FOUNDATION_EXPORT NSString * const kCancelRate;
FOUNDATION_EXPORT NSString * const kInternetConnectionRate;
FOUNDATION_EXPORT NSString * const kCompletedRate;

FOUNDATION_EXPORT NSString * const kTotals;

// Dates
FOUNDATION_EXPORT NSString * const kToday;
FOUNDATION_EXPORT NSString * const kYesterday;
FOUNDATION_EXPORT NSString * const kTomorrow;
FOUNDATION_EXPORT NSString * const kThisWeek;
FOUNDATION_EXPORT NSString * const kThisMonth;
FOUNDATION_EXPORT NSString * const kThisYear;
FOUNDATION_EXPORT NSString * const kAllTime;
FOUNDATION_EXPORT NSString * const kLastSevenDays;
FOUNDATION_EXPORT NSString * const kNextSevenDays;
FOUNDATION_EXPORT NSString * const kCustom;
FOUNDATION_EXPORT NSString * const kMinimumDate;

// All Options
FOUNDATION_EXPORT NSString * const kAll;
FOUNDATION_EXPORT NSString * const kSelected;
FOUNDATION_EXPORT NSString * const kProducts;
FOUNDATION_EXPORT NSString * const kOffices;
FOUNDATION_EXPORT NSString * const kNoSelection;

// Invoice Statuses
FOUNDATION_EXPORT NSString * const kCompleted;
FOUNDATION_EXPORT NSString * const kPending;
FOUNDATION_EXPORT NSString * const kRescheduled;
FOUNDATION_EXPORT NSString * const kNotScheduled;
FOUNDATION_EXPORT NSString * const kCancelled;
FOUNDATION_EXPORT NSString * const kChargeback;

// Customer Results Keys
FOUNDATION_EXPORT NSString * const kCustomerName;
FOUNDATION_EXPORT NSString * const kProductCategories;
FOUNDATION_EXPORT NSString * const kProvider;
FOUNDATION_EXPORT NSString * const kInvoiceStatus;
FOUNDATION_EXPORT NSString * const kInstallDate;
FOUNDATION_EXPORT NSString * const kPhone;
FOUNDATION_EXPORT NSString * const kAddress;
FOUNDATION_EXPORT NSString * const kCity;
FOUNDATION_EXPORT NSString * const kState;
FOUNDATION_EXPORT NSString * const kZipcode;
FOUNDATION_EXPORT NSString * const kEmail;

// Unicode Characters
FOUNDATION_EXPORT NSString * const kUpArrowWhite;
FOUNDATION_EXPORT NSString * const kUpArrowBlack;
FOUNDATION_EXPORT NSString * const kDownArrowWhite;
FOUNDATION_EXPORT NSString * const kDownArrowBlack;
FOUNDATION_EXPORT NSString * const kObfuscationChar;
FOUNDATION_EXPORT NSString * const kBox;
FOUNDATION_EXPORT NSString * const kCheckedBox;

// Buttons
FOUNDATION_EXPORT NSString * const kOk;
FOUNDATION_EXPORT NSString * const kClose;
FOUNDATION_EXPORT NSString * const kSave;
FOUNDATION_EXPORT NSString * const kDone;
FOUNDATION_EXPORT NSString * const kCancel;
FOUNDATION_EXPORT NSString * const kNew;

// Alerts
FOUNDATION_EXPORT NSString * const kLoginErrorTitle;
FOUNDATION_EXPORT NSString * const kLoginErrorMessage;
FOUNDATION_EXPORT NSString * const kLoginInactiveTitle;
FOUNDATION_EXPORT NSString * const kLoginInactiveMessage;
FOUNDATION_EXPORT NSString * const kIncorrectModuleTitle;
FOUNDATION_EXPORT NSString * const kIncorrectModuleMessage;
FOUNDATION_EXPORT NSString * const kConnectionErrorTitle;
FOUNDATION_EXPORT NSString * const kConnectionErrorMessage;
FOUNDATION_EXPORT NSString * const kExpirationErrorTitle;
FOUNDATION_EXPORT NSString * const kExpirationErrorMessage;
FOUNDATION_EXPORT NSString * const kMinimumRequirementsErrorTitle;
FOUNDATION_EXPORT NSString * const kMinimumRequirementsErrorMessage;
FOUNDATION_EXPORT NSString * const kMaintenanceErrorTitle;
FOUNDATION_EXPORT NSString * const kMaintenanceErrorMessage;
FOUNDATION_EXPORT NSString * const kEmailErrorTitle;
FOUNDATION_EXPORT NSString * const kEmailErrorMessage;
FOUNDATION_EXPORT NSString * const kUnknownErrorTitle;
FOUNDATION_EXPORT NSString * const kUnknownErrorMessage;

// Notifications
FOUNDATION_EXPORT NSString * const kCoreDataAutoSaved;
FOUNDATION_EXPORT NSString * const kDepartmentChangedNotification;

// NSUserDefaults
FOUNDATION_EXPORT NSString * const kCompanyLogoDictionary;
FOUNDATION_EXPORT NSString * const kUserLastDepartmentDictionary;

FOUNDATION_EXPORT NSString * const kAgreementSettingsName;
FOUNDATION_EXPORT NSString * const kAgreementSettingsAddress;
FOUNDATION_EXPORT NSString * const kAgreementSettingsCity;
FOUNDATION_EXPORT NSString * const kAgreementSettingsState;
FOUNDATION_EXPORT NSString * const kAgreementSettingsZip;
FOUNDATION_EXPORT NSString * const kAgreementSettingsPhone;
FOUNDATION_EXPORT NSString * const kAgreementSettingsEmail;

// PDF
FOUNDATION_EXPORT NSString * const kPdfAuthor;
FOUNDATION_EXPORT NSString * const kPdfCreator;
FOUNDATION_EXPORT NSString * const kPdfTitle;


// Sales Reports
// Entity Results Keys
FOUNDATION_EXPORT NSString * const kSaleCount;
FOUNDATION_EXPORT NSString * const kAutoPay;
FOUNDATION_EXPORT NSString * const kCancelCount;
FOUNDATION_EXPORT NSString * const kChargebackRate;
FOUNDATION_EXPORT NSString * const kChargebackCount;

FOUNDATION_EXPORT NSUInteger const kColumnsPerPagePhone;

FOUNDATION_EXPORT NSUInteger const kColumnStatLabelWidthPhone;
FOUNDATION_EXPORT NSUInteger const kColumnStatLabelWidthPad;

FOUNDATION_EXPORT NSUInteger const kColumnArrowButtonWidthPhone;
FOUNDATION_EXPORT NSUInteger const kColumnArrowButtonWidthPad;

FOUNDATION_EXPORT NSUInteger const kStandingsReportsNameColumnWidthPhone;
FOUNDATION_EXPORT NSUInteger const kStandingsReportsNameColumnWidthPad;

FOUNDATION_EXPORT NSUInteger const kOverviewReportsNameColumnWidthPhone;
FOUNDATION_EXPORT NSUInteger const kOverviewReportsNameColumnWidthPad;


//Service Calls

//Leads

FOUNDATION_EXPORT NSString * const kLastUserMapSyncDeviceTimestampsLeads;
FOUNDATION_EXPORT NSString * const kLastUserMapSyncServerTimestampsLeads;


// No class definition needed unless we need to initialize values

//@interface SRConstants : NSObject

/**
 * Call this method on app launch to initialize collection constants
 */
//+ (void)initValues;

//@end
