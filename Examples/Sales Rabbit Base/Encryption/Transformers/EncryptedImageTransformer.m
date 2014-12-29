//
//  EncryptedImageTransformer.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/22/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "EncryptedImageTransformer.h"
#import "NSData+CommonCrypto.h"

@implementation EncryptedImageTransformer

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
    NSData *data = UIImagePNGRepresentation(value);
    CCCryptorStatus status = kCCSuccess;
    NSData *result = [data dataEncryptedUsingAlgorithm:kCCAlgorithmAES128 key:self.key initializationVector:self.salt options:kCCOptionPKCS7Padding error:&status];
    if (status != kCCSuccess) {
        NSError *error = [NSError errorWithCCCryptorStatus:status];
        NSLog(@"Error encrypting image %@:", error.localizedDescription);
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
    return [UIImage imageWithData:result];
}

@end
