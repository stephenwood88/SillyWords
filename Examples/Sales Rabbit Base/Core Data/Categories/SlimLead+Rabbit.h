//
//  SlimLead+Rabbit.h
//  Security Sales
//
//  Created by Bryan Bryce on 2/26/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SlimLead.h"
#import "User+Rabbit.h"
#import <MapKit/MapKit.h>

@interface SlimLead (Rabbit) <MKAnnotation>

+ (SlimLead *)newSlimLeadFromJSON:(id)json forUser:(User *)user;
- (void)updateFromJSON:(id)json;

/**
 *  Return the corresponding UIImage object depending on the Lead actual status
 *
 *  @return Image from the corresponding Lead status
 */
- (UIImage *)image;

@end
