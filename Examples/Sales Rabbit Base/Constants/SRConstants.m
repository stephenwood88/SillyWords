//
//  SRConstants.m
//  
//
//  Created by Jeff Lockhart on 8/29/13.
//
//

//#import "SRConstants.h"

// Live
NSString * const kWebServiceBaseURL = @"https://dashboard.mysalesrabbit.com/";
// Beta
//NSString * const kWebServiceBaseURL = @"https://beta.mysalesrabbit.com/";
// Dev
//NSString * const kWebServiceBaseURL = @"https://dev.mysalesrabbit.com/";

NSString * const kWebServicePath = @"portal/";

// App Types
NSString * const kSateliteApp = @"sales";
NSString * const kOriginalApp = @"original";
NSString * const kPestApp = @"pest";
NSString * const kFoodDelivery = @"foodDelivery";
NSString * const kPremiumApp = @"premium";

// Social Media
NSString * const kSRTwitterURL = @"https://www.twitter.com/sales_rabbit";
NSString * const kSRFacebookURL = @"https://www.facebook.com/SalesRabbit";
NSString * const kSRGoogleURL = @"https://plus.google.com/111061798556588396339/";
NSString * const kTwitter = @"Twitter";
NSString * const kFacebook = @"Facebook";
NSString * const kGoogle = @"Google+";

// Customization
NSString * const kLastAccentColorValueRed = @"lastAccentColorValueRed";
NSString * const kLastAccentColorValueGreen = @"lastAccentColorValueGreen";
NSString * const kLastAccentColorValueBlue = @"lastAccentColorValueBlue";

// Organizations
NSString * const kArea = @"Area";
NSString * const kOffice = @"Office";
NSString * const kManager = @"Manager";
NSString * const kUser = @"User";
NSString * const kAccount = @"Account";

// Fonts
NSString * const kFont1 = @"Avenir-Medium";
NSString * const kFont2 = @"Avenir-Heavy";

// Yes and No
NSString * const kYes = @"Yes";
NSString * const kNo = @"No";

// Entity Results Keys
NSString * const kID = @"ID";
NSString * const kName = @"Name";

NSString * const kInstallCount = @"InstallCount";
NSString * const kPendingCount = @"PendingCount";
NSString * const kNotScheduledCount = @"NotScheduledCount";
NSString * const kCancelRate = @"CancelRate";
NSString * const kInternetConnectionRate = @"InternetConnectedRate";
NSString * const kCompletedRate = @"CompletedRate";

NSString * const kTotals = @"totals";

// Dates
NSString * const kToday = @"Today";
NSString * const kYesterday = @"Yesterday";
NSString * const kTomorrow = @"Tomorrow";
NSString * const kThisWeek = @"This Week";
NSString * const kThisMonth = @"This Month";
NSString * const kThisYear = @"This Year";
NSString * const kAllTime = @"All Time";
NSString * const kLastSevenDays = @"Last 7 Days";
NSString * const kNextSevenDays = @"Next 7 Days";
NSString * const kCustom = @"Custom";
NSString * const kMinimumDate = @"1/1/2000";

// All Options
NSString * const kAll = @"All";
NSString * const kSelected = @"Selected";
NSString * const kProducts = @"Products";
NSString * const kOffices = @"Offices";
NSString * const kNoSelection = @"No Selection";

// Invoice Statuses
NSString * const kCompleted = @"Completed";
NSString * const kPending = @"Pending";
NSString * const kRescheduled = @"Rescheduled";
NSString * const kNotScheduled = @"Not Scheduled";
NSString * const kCancelled = @"Canceled";
NSString * const kChargeback = @"Chargeback";

// Customer Results Keys
NSString * const kCustomerName = @"CustomerName";
NSString * const kProductCategories = @"ProductCategories";
NSString * const kProvider = @"Provider";
NSString * const kInvoiceStatus = @"InvoiceStatus";
NSString * const kInstallDate = @"InstallDate";
NSString * const kPhone = @"Phone";
NSString * const kAddress = @"Address";
NSString * const kCity = @"City";
NSString * const kState = @"State";
NSString * const kZipcode = @"Zipcode";
NSString * const kEmail = @"Email";

// Unicode Characters
NSString * const kUpArrowWhite = @"\u25b3";
NSString * const kUpArrowBlack = @"\u25b2";
NSString * const kDownArrowWhite = @"\u25bd";
NSString * const kDownArrowBlack = @"\u25bc";
NSString * const kObfuscationChar = @"\u25cf";
NSString * const kBox = @"\u2610";
NSString * const kCheckedBox = @"\u2611";

// Buttons
NSString * const kOk = @"OK";
NSString * const kClose = @"Close";
NSString * const kSave = @"Save";
NSString * const kDone = @"Done";
NSString * const kCancel = @"Cancel";
NSString * const kNew = @"New";

// Alerts
NSString * const kLoginErrorTitle = @"Login Error";
NSString * const kLoginErrorMessage = @"Please check your email and password and try again.";
NSString * const kLoginInactiveTitle = @"Inactive User";
NSString * const kLoginInactiveMessage = @"Your user has been deactivated.  Please contact your organization if this is an mistake.";
NSString * const kIncorrectModuleTitle = @"Unauthorized Access";
NSString * const kIncorrectModuleMessage = @"Your user is not authorized to access this app.";
NSString * const kConnectionErrorTitle = @"Connection Error";
NSString * const kConnectionErrorMessage = @"Please ensure your device is properly connected to the internet.";
NSString * const kExpirationErrorTitle = @"Password Expired";
NSString * const kExpirationErrorMessage =@"Your password is older than 3 months.  Please change it in the website";
NSString * const kMinimumRequirementsErrorTitle = @"Password Invalid";
NSString * const kMinimumRequirementsErrorMessage = @"Your password no longer meets the minimum requirements.  Please change it in the website";
NSString * const kMaintenanceErrorTitle = @"Closed for Maintenance";
NSString * const kMaintenanceErrorMessage = @"Sales Rabbit is down for maintenance";
NSString * const kEmailErrorTitle = @"Email Error";
NSString * const kEmailErrorMessage = @"Your device is not set up for the delivery of email.";
NSString * const kUnknownErrorTitle = @"Error";
NSString * const kUnknownErrorMessage = @"An unknown error has occurred.";

// Notifications
NSString * const kCoreDataAutoSaved = @"coreDataAutoSaved";
NSString * const kDepartmentChangedNotification = @"DepartmentChangedNotification";

// NSUserDefaults
NSString * const kCompanyLogoDictionary = @"companyLogoDictionary";
NSString * const kUserLastDepartmentDictionary = @"userLastDepartmentDictionary";

NSString * const kAgreementSettingsName = @"Name";
NSString * const kAgreementSettingsAddress = @"Address";
NSString * const kAgreementSettingsCity = @"City";
NSString * const kAgreementSettingsState = @"State";
NSString * const kAgreementSettingsZip = @"Zip";
NSString * const kAgreementSettingsPhone = @"Phone";
NSString * const kAgreementSettingsEmail = @"Email";

// PDF
NSString * const kPdfAuthor = @"Sales Rabbit";
NSString * const kPdfCreator = @"Sales Rabbit App";
NSString * const kPdfTitle = @"Customer Agreement";

// Sales Report
NSString * const kSaleCount = @"SaleCount";
NSString * const kCancelCount = @"CancelCount";
NSString * const kAutoPay = @"AutoPay";
NSString * const kChargebackRate = @"ChargebackRate";
NSString * const kChargebackCount = @"ChargebackCount";

NSUInteger const kColumnsPerPagePhone = 5;

NSUInteger const kColumnStatLabelWidthPhone = 34;
NSUInteger const kColumnStatLabelWidthPad = 46;

NSUInteger const kColumnArrowButtonWidthPhone = 8;
NSUInteger const kColumnArrowButtonWidthPad = 13;

NSUInteger const kStandingsReportsNameColumnWidthPhone = 86;
NSUInteger const kStandingsReportsNameColumnWidthPad = 200;

NSUInteger const kOverviewReportsNameColumnWidthPhone = 100;
NSUInteger const kOverviewReportsNameColumnWidthPad = 210;


// Service Calls

//Leads

NSString * const kLastUserMapSyncDeviceTimestampsLeads = @"lastUserMapSyncDeviceTimestamps";
NSString * const kLastUserMapSyncServerTimestampsLeads = @"lastUserMapSyncServerTimestamps";




// No class definition needed unless we need to initialize values

//@implementation SRConstants

/*+ (void)initValues {
    
    static BOOL valuesInitialized = NO;
    if (!valuesInitialized) {
        valuesInitialized = YES;
    }
}*/

//@end
