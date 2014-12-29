//
//  CreditCard+Rabbit.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "CreditCard+Rabbit.h"
#import "Agreement+Rabbit.h"
#import "TextOverlayViewFront.h"
#import "EncryptedStringTransformer.h"
#import "AVTextUtilities.h"

// Generated by @dynamic - https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreData/Articles/cdAccessorMethods.html
@interface CreditCard (PrimitiveAccessor)

- (NSString *)primitiveNumber;
- (NSData *)primitiveNumberEncrypted;

- (void)setPrimitiveNumber:(NSString *)number;
- (void)setPrimitiveNumberEncrypted:(NSData *)numberEncrypted;
- (void)setPrimitiveExpirationDate:(NSDate *)expirationDate;
- (void)setPrimitiveCvv:(NSString *)cvv;

@end

@implementation CreditCard (Rabbit)

- (BOOL)isStarted {
    
    return self.number.length || self.cvv.length;
}

// These algorithms should mirror the CustomerInfoViewController verifyInfo algorithm. They should both return the same result.
- (BOOL)isCompleted {
    
    return [AVTextUtilities isValidCreditCardNumber:self.number] && self.expirationDate && (self.cvv.length == 3 || self.cvv.length == 4);
}

- (void)setNumber:(NSString *)number {
    
    [self willChangeValueForKey:@"number"];
    [self setPrimitiveNumber:number];
    [self didChangeValueForKey:@"number"];
    if (number) {
        EncryptedStringTransformer *transformer = (EncryptedStringTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedStringTransformer"];
        if (!self.salt) {
            self.salt = [AVTextUtilities randomStringOfLength:32];
        }
        transformer.salt = self.salt;
        [self setPrimitiveNumberEncrypted:[transformer transformedValue:number]];
    }
    else {
        [self setPrimitiveNumberEncrypted:nil];
    }
    if (self.agreement.textOverlayFront) {
        self.agreement.textOverlayFront.creditCardNumber.text = [AVTextUtilities obfuscatedNumber:number showNumDigits:4];
    }
    
    self.agreement.dateModified = [NSDate date];
}

- (NSString *)number {
    
    [self willAccessValueForKey:@"number"];
    NSString *number = [self primitiveNumber];
    [self didAccessValueForKey:@"number"];
    if (!number && self.salt) { // If salt not set, the number was never saved
        NSData *numberEncrypted = [self primitiveNumberEncrypted];
        if (numberEncrypted) {
            EncryptedStringTransformer *transformer = (EncryptedStringTransformer *) [NSValueTransformer valueTransformerForName:@"EncryptedStringTransformer"];
            transformer.salt = self.salt;
            number = [transformer reverseTransformedValue:numberEncrypted];
            [self setPrimitiveNumber:number];
        }
    }
    return number;
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    
    [self willChangeValueForKey:@"expirationDate"];
    [self setPrimitiveExpirationDate:expirationDate];
    [self didChangeValueForKey:@"expirationDate"];
    if (self.agreement.textOverlayFront) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/yy";
        self.agreement.textOverlayFront.expirationDate.text = [formatter stringFromDate:expirationDate];
    }
    
    self.agreement.dateModified = [NSDate date];
}

- (void)setCvv:(NSString *)cvv {
    
    [self willChangeValueForKey:@"cvv"];
    [self setPrimitiveCvv:cvv];
    [self didChangeValueForKey:@"cvv"];
    if (self.agreement.textOverlayFront) {
        self.agreement.textOverlayFront.cvv.text = cvv;
    }
    
    self.agreement.dateModified = [NSDate date];
}

@end