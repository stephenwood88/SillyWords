//
//  Lead+Rabbit.h
//  Dish Sales
//
//  Created by Brady Anderson on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Lead.h"
#import "Person.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>

@interface Lead (Rabbit) <MKAnnotation>

+ (Lead *)newLead;
+ (Lead *)newLeadForPerson:(Person *)person;

- (void)setCoordinateFromAddressWithCompletionHandler:(void (^)(BOOL success, Lead *lead, NSError *error))completionHandler;
- (void)setAddressFromCoordinateWithCompletionHandler:(void (^)(BOOL success, Lead *lead, NSError *error))completionHandler;
- (void)deleteLeadSync:(BOOL)syncDelete;
- (id)proxyForJson;
- (void)updateFromJson:(NSDictionary *)json withDateModified:(NSDate *)dateModified;
- (void)scheduleNotification;

/**
 *  Return the corresponding UIImage object depending on the Lead actual status
 *
 *  @return Image from the corresponding Lead status
 */
- (UIImage *)image;

//- (void)setCalendarEventIfNecessary;
//- (void)removeCalendarEvent;

@end
