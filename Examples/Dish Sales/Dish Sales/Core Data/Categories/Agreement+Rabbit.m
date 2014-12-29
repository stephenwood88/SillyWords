//
//  Agreement+Rabbit.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "Agreement+Rabbit.h"
#import "AppDelegate.h"
#import "TextOverlayViewFront.h"
#import "EncryptedImageTransformer.h"
#import "ServiceInfo+Rabbit.h"
#import "CreditCard+Rabbit.h"
#import "Ach+Rabbit.h"
#import "Person+Rabbit.h"
#import "AVTextUtilities.h"

@interface Agreement (PrimitiveAccessor)

- (UIImage *)primitiveSignature;
- (NSData *)primitiveSignatureEncrypted;

- (void)setPrimitiveSignature:(UIImage *)signature;
- (void)setPrimitiveSignatureEncrypted:(NSData *)signatureEncrypted;
- (void)setPrimitiveSignedDate:(NSDate *)signedDate;
- (void)setPrimitiveNotes:(NSString *)notes;
- (void)setPrimitiveTerms:(NSString *)terms;

@end

@implementation Agreement (Rabbit)

/**
 * Since super can't be called in categories, be sure this method is overwritten
 * in Agreement.m when regenerating this class.
 *

#import "AppDelegate.h"

@interface Agreement (PrimitiveAccessor)

- (void)setPrimitiveDateCreated:(NSDate *)dateCreated;
- (void)setPrimitiveDateModified:(NSDate *)dateModified;
- (void)setPrimitiveUserId:(NSString *)userId;

@end

- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    [self setPrimitiveDateCreated:date];
    [self setPrimitiveDateModified:date];
    [self setPrimitiveUserId:[[SRGlobalState singleton] userId]];
}
*/

+ (Agreement *)newAgreement {
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Agreement *agreement = [NSEntityDescription insertNewObjectForEntityForName:@"Agreement" inManagedObjectContext:context];
    agreement.serviceInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceInfo" inManagedObjectContext:context];
    agreement.creditCard = [NSEntityDescription insertNewObjectForEntityForName:@"CreditCard" inManagedObjectContext:context];
    agreement.ach = [NSEntityDescription insertNewObjectForEntityForName:@"Ach" inManagedObjectContext:context];
    [Person newPersonForAgreement:agreement];
    return agreement;
}

+ (Agreement *)newAgreementForPerson:(Person *)person {
    
    NSAssert(person != nil, @"Person should not be nil");
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    Agreement *agreement = [NSEntityDescription insertNewObjectForEntityForName:@"Agreement" inManagedObjectContext:context];
    agreement.serviceInfo = [NSEntityDescription insertNewObjectForEntityForName:@"ServiceInfo" inManagedObjectContext:context];
    agreement.creditCard = [NSEntityDescription insertNewObjectForEntityForName:@"CreditCard" inManagedObjectContext:context];
    agreement.ach = [NSEntityDescription insertNewObjectForEntityForName:@"Ach" inManagedObjectContext:context];
    agreement.person = person;
    if (person.lead) {
        agreement.saved = @YES;
    }
    return agreement;
}

- (BOOL)isStarted {
    
    return self.signature || self.notes.length || (!self.person.lead && self.person.isStarted) || self.serviceInfo.isStarted || self.creditCard.isStarted || self.ach.isStarted;
}

// These algorithms should mirror the CustomerInfoViewController verifyInfo algorithm. They should both return the same result.
- (BOOL)isCompleted {
    
    return self.signature && self.signedDate && self.person.isCompleted && (!self.creditCard.number.length || self.creditCard.isCompleted) && (!self.ach.isStarted || self.ach.isCompleted) && self.serviceInfo.isCompleted;
}

- (void)deleteAgreement {
    
    NSManagedObjectContext *context = [[SRGlobalState singleton] managedObjectContext];
    
    NSAssert(self.person != nil, @"Person should not be nil");
    if (!self.person.lead) {
        [context deleteObject:self.person];
    }
    [context deleteObject:self];
}

- (void)setSignature:(UIImage *)signature {
    
    [self willChangeValueForKey:@"signature"];
    [self setPrimitiveSignature:signature];
    [self didChangeValueForKey:@"signature"];
    if (signature) {
        EncryptedImageTransformer *transformer = (EncryptedImageTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedImageTransformer"];
        if (!self.salt) {
            self.salt = [AVTextUtilities randomStringOfLength:32];
        }
        transformer.salt = self.salt;
        [self setPrimitiveSignatureEncrypted:[transformer transformedValue:signature]];
    }
    else {
        [self setPrimitiveSignatureEncrypted:nil];
    }
    if (self.textOverlayFront) {
        [self.textOverlayFront.signature setImage:signature forState:UIControlStateNormal];
    }
    if (signature) {
        self.signedDate = [NSDate date];
    }
    else {
        self.signedDate = nil;
    }
    
    self.dateModified = [NSDate date];
}

- (UIImage *)signature {
    
    [self willAccessValueForKey:@"signature"];
    UIImage *signature = [self primitiveSignature];
    [self didAccessValueForKey:@"signature"];
    if (!signature && self.salt) { // If salt not set, the signature was never saved
        NSData *signatureEncrypted = [self primitiveSignatureEncrypted];
        if (signatureEncrypted) {
            EncryptedImageTransformer *transformer = (EncryptedImageTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedImageTransformer"];
            transformer.salt = self.salt;
            signature = [transformer reverseTransformedValue:signatureEncrypted];
            [self setPrimitiveSignature:signature];
        }
    }
    return signature;
}

- (void)setSignedDate:(NSDate *)signedDate {
    
    [self willChangeValueForKey:@"signedDate"];
    [self setPrimitiveSignedDate:signedDate];
    [self didChangeValueForKey:@"signedDate"];
    if (self.textOverlayFront) {
        if (signedDate) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"M/d/yyyy";
            NSString *signedDateString = [formatter stringFromDate:signedDate];
            self.textOverlayFront.signedDate.text = signedDateString;
        }
        else {
            self.textOverlayFront.signedDate.text = nil;
        }
    }
}

- (void)setNotes:(NSString *)notes {
    
    [self willChangeValueForKey:@"notes"];
    [self setPrimitiveNotes:notes];
    [self didChangeValueForKey:@"notes"];
    if (self.textOverlayFront) {
        self.textOverlayFront.notes.text = notes;
    }
    
    self.dateModified = [NSDate date];
}

- (void)setTerms:(NSString *)terms {
    
    [self willChangeValueForKey:@"terms"];
    [self setPrimitiveTerms:terms];
    [self didChangeValueForKey:@"terms"];
    if (self.textOverlayFront) {
        self.textOverlayFront.termsOfAgreement.text = terms;
    }
    
    self.dateModified = [NSDate date];
}

@end
