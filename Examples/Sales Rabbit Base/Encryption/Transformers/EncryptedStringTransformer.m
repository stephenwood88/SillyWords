//
//  EncryptedStringTransformer.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/22/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "EncryptedStringTransformer.h"
#import "NSData+CommonCrypto.h"

@implementation EncryptedStringTransformer

+ (Class)transformedValueClass {
    
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    
    return YES;
}

- (id)transformedValue:(id)value {
    
    if (!value) {
        return nil;
    }
    NSData *data = [((NSString *) value) dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [data dataEncryptedUsingAlgorithm:kCCAlgorithmAES128 key:self.key initializationVector:self.salt options:kCCOptionPKCS7Padding error:&status];
    if (status != kCCSuccess) {
        NSError *error = [NSError errorWithCCCryptorStatus:status];
        NSLog(@"Error encrypting string %@:", error.localizedDescription);
        return nil;
    }
    return result;
}

- (id)reverseTransformedValue:(id)value {
    
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [((NSData *) value) decryptedDataUsingAlgorithm:kCCAlgorithmAES128 key:self.key initializationVector:self.salt options:kCCOptionPKCS7Padding error:&status];
    if (status != kCCSuccess) {
        NSError *error = [NSError errorWithCCCryptorStatus:status];
        NSLog(@"Error decrypting string %@:", error.localizedDescription);
        return nil;
    }
    return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

@end
