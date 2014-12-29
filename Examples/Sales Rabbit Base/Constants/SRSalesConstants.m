//
//  Constants.m
//  Dish Sales
//
//  Created by Jeff on 11/9/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import "SRSalesConstants.h" 

NSString * const kNA = @"N/A";

// Time
NSInteger const kSecondsBetweenLeadSyncs = 1 * 60; // 1 minute
NSInteger const kSecondsBeforeForcedLogout = 8 * 60 * 60; // 8 hours
NSInteger const kCalendarEventLengthInSeconds = 30 * 60; //30 minutes

NSString * const kInitialTime = @"12:00pm";

// Sales Materials
NSString * const kSalesMaterialsFileName = @"SRabbitSalesMaterials";
NSString * const kSalesMaterialsDirectory = @"SalesMaterials";

// Customer Summary
NSString * const kCustomerSummary = @"Installs: %@  Pending: %@  Not Scheduled: %@  Cancelled: %@  Chargeback: %@";

// Lead Statuses
NSString * const kGoBack = @"Go Back";
NSString * const kCallback = @"Callback";
NSString * const kNotHome = @"Not Home";
NSString * const kNotInterested = @"Not Interested";
NSString * const kCustomer = @"Customer";
NSString * const kOther = @"Other";

// Lead Details
NSString * const kLeadDetailsHeading1 = @"Contact Info";
NSString * const kLeadDetailsHeading2 = @"Appointment/Callback Time";
NSString * const kLeadDetailsHeading3 = @"Lead Info";
NSString * const kLeadCancelConfirmation = @"Do you want to discard this lead? \n(Lead status must be set to save a lead.)";
NSString * const kStreet = @"Street";

// Lead Detail errors
NSString * const kLeadErrorTitle = @"Lead has errors";
NSString * const kLeadErrorMessage = @"Fix any errors before saving the lead.";

// Confirmations
NSString * const kLeadDeleteConfirmation = @"Are you sure you want to delete this lead?";

// Lead Optimizations

NSInteger const kZoomLevelForMapCluster = 14;


// Errors
NSString * const kNoDepartmentsTitle = @"No Sales Departments";
NSString * const kNoDepartmentsMessage = @"You must be assigned to a sales department in order to log in to Sales Rabbit.";
NSString * const kGpsErrorTitle = @"GPS Error";
NSString * const kGpsErrorMessage = @"Unable to acquire a geolocation.";
NSString * const kOpeningAddressErrorTitle = @"Error Opening Address";
NSString * const kOpeningAddressErrorMessage = @"There was an error opening the lead's address in maps.";
NSString * const kLocatingAddressErrorTitle = @"Error Locating Address";
NSString * const kLocatingAddressErrorMessage = @"There was an error locating the customer's address.";
NSString * const kNoLeadStatusErrorTitle = @"No Lead Status";
NSString * const kNoLeadStatusErrorMessage = @"You must set the status in order to create a lead.";
NSString * const kEditStreetErrorTitle = @"Address Incomplete";
NSString * const kEditStreetErrorMessage = @"Please fill in all required fields.";
NSString * const kAgreementSubmissionSuccessTitle = @"Success";
NSString * const kAgreementSubmissionSuccessMessage = @"Agreement submitted";
NSString * const kAgreementSubmissionFailureTitle = @"Failure";
NSString * const kAgreementSubmissionFailureMessage = @"Agreement submission failed.  Try again or contact technical support.";
NSString * const kAgreementSubmissionDuplicateTitle = @"Duplicate Phone Number";
NSString * const kAgreementSubmissionDuplicateMessage = @"An agreement with this phone number has already been submitted, which is not allowed.";
NSString * const kAgreementSubmissionNoRepIdTitle = @"No Rep ID";
NSString * const kAgreementSubmissionNoRepIdMessage = @"Your Sales Rabbit user does not have an Agemni ID associated with it. This is required in order to submit agreements.";
NSString * const kCURLCallFailedTitle = @"Connection Timed Out";
NSString * const kCURLCallFailedMessage = @"Be sure you are connected to the internet and try resending.";
NSString * const kOrderFormNotPDFTitle = @"Problem with Agreement Form";
NSString * const kOrderFormNotPDFMessage = @"There was an error when initially uploading the agreement form.  Be sure you are connected to the Internet and try again.";
NSString * const kInvalidCallErrorTitle = @"Error";
NSString * const kInvalidCallErrorMessage = @"There was an error submitting this form.  Contact technical support to check for errors in your account.";
NSString * const kDuplicateCustomerErrorTitle = @"Duplicate Information";
NSString * const kDuplicateCustomerErrorMessage = @"An aggreement with some of the information has already been submitted, which is not allowed.";
NSString * const kCustomerCreationFailureTitle = @"Submission Failure";
NSString * const kCustomerCreationFailureMessage = @"There was an error creating this customer.  The Credit Card and Notes fields may already be on record.";


// NSUserDefaults
NSString * const kSalesMaterialsTimestampDictionary = @"salesMaterialsTimestampDictionary";
NSString * const kLastLeadSyncServerTimestamps = @"lastLeadSyncServerTimestamps";
NSString * const kLastLeadSyncDeviceTimestamps = @"lastLeadSyncDeviceTimestamps";
NSString * const kLastUserMapSyncServerTimestamps = @"lastUserMapSyncServerTimestamps";
NSString * const kLastUserMapSyncDeviceTimestamps = @"lastUserMapSyncDeviceTimestamps";
NSString * const kDeletedLeadIds = @"deletedLeadIds";

// Notifications
NSString * const kLogoutNotification = @"LogoutNotification";
NSString * const kLeadsChangedNotification = @"leadsChangedNotification";
NSString * const kPrequalsChangedNotification = @"prequalsChangedNotification";
NSString * const kAddedLeads = @"addedLeads";
NSString * const kUpdatedLeads = @"updatedLeads";
NSString * const kDeletedLeads = @"deletedLeads";
NSString * const kAnimateLeadChanges = @"animateLeadChanges";
NSString * const kTitleAttributesChangedNotification = @"titleAttributesChangedNotification";
NSString * const kAddressUpdatedNotification = @"addressUpdatedNotification";
NSString * const kUpdatedAddress = @"updatedAddress";

// Reminder Time Values
NSString * const kRemindNone = @"No reminder";
NSString * const kRemind0Min = @"At time of appointment";
NSString * const kRemind5Min = @"5 minutes before";
NSString * const kRemind15Min = @"15 minutes before";
NSString * const kRemind30Min = @"30 minutes before";
NSString * const kRemind1Hr = @"1 hour before";
NSInteger const kSecondsIn5Minutes = 5 * 60;
NSInteger const kSecondsIn15Minutes = 15 * 60;
NSInteger const kSecondsIn30Minutes = 30 * 60;
NSInteger const kSecondsIn1Hour = 60 * 60;

// User Default Keys
NSString * const kUserSettings = @"userSettings";
NSString * const kAppointmentsToCal = @"appointmentsToCal";
NSString * const kRemindByDefault = @"remindByDefault";
NSString * const kTimeToRemind = @"timeToRemind";

// Local Notifications
NSString * const kLeadId = @"leadId";

// Lead Appointment Windows
NSString * const kAnytime = @"Anytime";
NSString * const kWindow8toNoon = @"8AM - Noon";
NSString * const kWindowNoonto5 = @"Noon - 5PM";
NSString * const kWindowAfter5 = @"After 5PM";



@implementation SRSalesConstants

// Call this method on app launch to initialize collection constants
+ (void)initValues {
    
    static BOOL valuesInitialized = NO;
    if (!valuesInitialized) {
        
        kRemindInMins = @[kRemindNone, kRemind0Min, kRemind5Min, kRemind15Min, kRemind30Min, kRemind1Hr];
        kReminderTimeDictionary = @{kRemindNone: @-1,
                                    kRemind0Min: @0,
                                    kRemind5Min: [NSNumber numberWithInt:kSecondsIn5Minutes],
                                    kRemind15Min: [NSNumber numberWithInt:kSecondsIn15Minutes],
                                    kRemind30Min: [NSNumber numberWithInt:kSecondsIn30Minutes],
                                    kRemind1Hr: [NSNumber numberWithInt:kSecondsIn1Hour]};
        kLeadStatuses = @[kGoBack, kCallback, kNotHome, kNotInterested, kOther];
        kLeadStatusesCustomer = @[kGoBack, kCallback, kNotHome, kNotInterested, kCustomer, kOther];
        kLeadStatusesNew = @[kGoBack, kCallback];
        kLeadRanks = @[@"0-Don't Call Back", @"1-Not Very Interested", @"2-Somewhat Interested", @"3-Interested", @"4-Very Interested", @"5-Golden Contact"];
        kLeadTypes = @[@"Inside Sales", @"Switch Over-In Contract", @"Switch Over-Out of Contract", @"Check with Husband", @"Check with Wife", @"Been Wanting Service", @"Money Tight", @"No Need", @"Other"];
        kLeadWindows = @[kAnytime, kWindow8toNoon, kWindowNoonto5, kWindowAfter5];
        kLeadQuickDates = @[@"Today", @"Yesterday", @"Tomorrow", @"This Week", @"This Month", @"This Year", @"All Time"];
        kReportsQuickDates = @[@"Today", @"Yesterday", @"This Week", @"This Month", @"This Year", @"All Time"];
        kLeadFilterDateOptions = @[@"Date Created", @"Appointment Date"];
        kLeadFilterDateOptionsIphone = @[@"Date Created", @"Appt. Date"];
        
                
        valuesInitialized = YES;
    }
}

@end
