//
//  Agreement+Rabbit.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Agreement.h"

@interface Agreement (Rabbit)

/**
 * These properties are of unknown type to core data, be sure they are
 * defined in Agreement.h when regenerating this class.
 *
 * @property (nonatomic, retain) UIImage * signature;
 * @property (nonatomic, retain) TextOverlayViewFront * textOverlayFront;
 */

+ (Agreement *)newAgreement;
+ (Agreement *)newAgreementForPerson:(Person *)person;

- (BOOL)isStarted;
- (BOOL)isCompleted;
- (void)deleteAgreement;

@end
