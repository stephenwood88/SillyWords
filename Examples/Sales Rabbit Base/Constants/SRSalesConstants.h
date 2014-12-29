//
//  Constants.h
//  Dish Sales
//
//  Created by Jeff on 11/9/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//


FOUNDATION_EXPORT NSString * const kNA;

// Time
FOUNDATION_EXPORT NSInteger const kSecondsBetweenLeadSyncs;
FOUNDATION_EXPORT NSInteger const kSecondsBeforeForcedLogout;
FOUNDATION_EXPORT NSInteger const kCalendarEventLengthInSeconds;

FOUNDATION_EXPORT NSString * const kInitialTime;

// Sales Materials
FOUNDATION_EXPORT NSString * const kSalesMaterialsFileName;
FOUNDATION_EXPORT NSString * const kSalesMaterialsDirectory;

//Customer Summary
FOUNDATION_EXPORT NSString * const kCustomerSummary;

// Lead Statuses
FOUNDATION_EXPORT NSString * const kGoBack;
FOUNDATION_EXPORT NSString * const kCallback;
FOUNDATION_EXPORT NSString * const kNotHome;
FOUNDATION_EXPORT NSString * const kNotInterested;
FOUNDATION_EXPORT NSString * const kCustomer;
FOUNDATION_EXPORT NSString * const kOther;

// Lead Details
FOUNDATION_EXPORT NSString * const kLeadDetailsHeading1;
FOUNDATION_EXPORT NSString * const kLeadDetailsHeading2;
FOUNDATION_EXPORT NSString * const kLeadDetailsHeading3;
FOUNDATION_EXPORT NSString * const kLeadCancelConfirmation;

FOUNDATION_EXPORT NSString * const kStreet;

// Lead Detail errors
FOUNDATION_EXPORT NSString * const kLeadErrorTitle;
FOUNDATION_EXPORT NSString * const kLeadErrorMessage;

//Lead Optimizations
FOUNDATION_EXPORT NSInteger const kZoomLevelForMapCluster;

// Confirmations
FOUNDATION_EXPORT NSString * const kNewConfirmation;
FOUNDATION_EXPORT NSString * const kSubmitConfirmation;
FOUNDATION_EXPORT NSString * const kOpenConfirmation;
FOUNDATION_EXPORT NSString * const kLeadDeleteConfirmation;

// Errors
FOUNDATION_EXPORT NSString * const kNoDepartmentsTitle;
FOUNDATION_EXPORT NSString * const kNoDepartmentsMessage;
FOUNDATION_EXPORT NSString * const kGpsErrorTitle;
FOUNDATION_EXPORT NSString * const kGpsErrorMessage;
FOUNDATION_EXPORT NSString * const kOpeningAddressErrorTitle;
FOUNDATION_EXPORT NSString * const kOpeningAddressErrorMessage;
FOUNDATION_EXPORT NSString * const kLocatingAddressErrorTitle;
FOUNDATION_EXPORT NSString * const kLocatingAddressErrorMessage;
FOUNDATION_EXPORT NSString * const kNoLeadStatusErrorTitle;
FOUNDATION_EXPORT NSString * const kNoLeadStatusErrorMessage;
FOUNDATION_EXPORT NSString * const kEditStreetErrorTitle;
FOUNDATION_EXPORT NSString * const kEditStreetErrorMessage;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionSuccessTitle;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionSuccessMessage;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionFailureTitle;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionFailureMessage;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionDuplicateTitle;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionDuplicateMessage;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionNoRepIdTitle;
FOUNDATION_EXPORT NSString * const kAgreementSubmissionNoRepIdMessage;
FOUNDATION_EXPORT NSString * const kCURLCallFailedTitle;
FOUNDATION_EXPORT NSString * const kCURLCallFailedMessage;
FOUNDATION_EXPORT NSString * const kOrderFormNotPDFTitle;
FOUNDATION_EXPORT NSString * const kOrderFormNotPDFMessage;
FOUNDATION_EXPORT NSString * const kInvalidCallErrorTitle;
FOUNDATION_EXPORT NSString * const kInvalidCallErrorMessage;
FOUNDATION_EXPORT NSString * const kDuplicateCustomerErrorTitle;
FOUNDATION_EXPORT NSString * const kDuplicateCustomerErrorMessage;
FOUNDATION_EXPORT NSString * const kCustomerCreationFailureTitle;
FOUNDATION_EXPORT NSString * const kCustomerCreationFailureMessage;

// NSUserDefaults
FOUNDATION_EXPORT NSString * const kSalesMaterialsTimestampDictionary;
FOUNDATION_EXPORT NSString * const kLastLeadSyncServerTimestamps;
FOUNDATION_EXPORT NSString * const kLastLeadSyncDeviceTimestamps;
FOUNDATION_EXPORT NSString * const kLastUserMapSyncServerTimestamps;
FOUNDATION_EXPORT NSString * const kLastUserMapSyncDeviceTimestamps;
FOUNDATION_EXPORT NSString * const kDeletedLeadIds;

// User Default Keys
FOUNDATION_EXPORT NSString * const kUserSettings;
FOUNDATION_EXPORT NSString * const kAppointmentsToCal;
FOUNDATION_EXPORT NSString * const kRemindByDefault;
FOUNDATION_EXPORT NSString * const kTimeToRemind;

// Notifications
FOUNDATION_EXPORT NSString * const kLogoutNotification;
FOUNDATION_EXPORT NSString * const kLeadsChangedNotification;
FOUNDATION_EXPORT NSString * const kPrequalsChangedNotification;
FOUNDATION_EXPORT NSString * const kAddedLeads;
FOUNDATION_EXPORT NSString * const kUpdatedLeads;
FOUNDATION_EXPORT NSString * const kDeletedLeads;
FOUNDATION_EXPORT NSString * const kAnimateLeadChanges;
FOUNDATION_EXPORT NSString * const kAddressUpdatedNotification;
FOUNDATION_EXPORT NSString * const kTitleAttributesChangedNotification;
FOUNDATION_EXPORT NSString * const kUpdatedAddress;

// Reminder Time Values
FOUNDATION_EXPORT NSString * const kRemindNone;
FOUNDATION_EXPORT NSString * const kRemind0Min;
FOUNDATION_EXPORT NSString * const kRemind5Min;
FOUNDATION_EXPORT NSString * const kRemind15Min;
FOUNDATION_EXPORT NSString * const kRemind30Min;
FOUNDATION_EXPORT NSString * const kRemind1Hr;
FOUNDATION_EXPORT NSInteger const kSecondsIn5Minutes;
FOUNDATION_EXPORT NSInteger const kSecondsIn15Minutes;
FOUNDATION_EXPORT NSInteger const kSecondsIn30Minutes;
FOUNDATION_EXPORT NSInteger const kSecondsIn1Hour;

// Local Notification Dictionary
FOUNDATION_EXPORT NSString * const kLeadId;

// Lead Appointment Windows
FOUNDATION_EXPORT NSString * const kAnytime;
FOUNDATION_EXPORT NSString * const kWindow8toNoon;
FOUNDATION_EXPORT NSString * const kWindowNoonto5;
FOUNDATION_EXPORT NSString * const kWindowAfter5;

// Lead Form
NSArray *kLeadStatuses;
NSArray *kLeadStatusesNew;
NSArray *kLeadStatusesCustomer;
NSArray *kCustomerStatuses;
NSArray *kLeadRanks;
NSArray *kLeadTypes;
NSArray *kLeadWindows;
NSArray *kLeadQuickDates;
NSArray *kReportsQuickDates;
NSArray *kLeadFilterDateOptions;
NSArray *kLeadFilterDateOptionsIphone;

// Settings Section
NSArray *kRemindInMins;
NSDictionary *kReminderTimeDictionary;


#define kKeyboardAnimationDuration 0.25
#define ACTION_DONE_BTN_WIDTH   50
#define ACTION_CANCEL_BTN_WIDTH  55
#define MaxLocationAge 10.0

#import "SRConstants.h"

@interface SRSalesConstants : NSObject

/**
 * Call this method on app launch to initialize collection constants
 */
+ (void)initValues;

@end
