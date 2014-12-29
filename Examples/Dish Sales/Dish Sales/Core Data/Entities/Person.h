//
//  Person.h
//  Dish Sales
//
//  Created by Matthew McArthur on 1/31/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Agreement, Lead, CustomerInfoViewController, SRPremiumLeadDetailTableViewController;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * businessName;
@property (nonatomic, retain) CustomerInfoViewController * customerInfoView;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) UITableViewController * editingView;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) SRPremiumLeadDetailTableViewController * leadDetailView;
@property (nonatomic, retain) NSString * phoneAlternate;
@property (nonatomic, retain) NSString * phoneCell;
@property (nonatomic, retain) NSString * phonePrimary;
@property (nonatomic, retain) NSString * salt;
@property (nonatomic, retain) NSString * ssn;
@property (nonatomic, retain) NSData * ssnEncrypted;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) Agreement *agreement;
@property (nonatomic, retain) Address *billingAddress;
@property (nonatomic, retain) Lead *lead;

@end
