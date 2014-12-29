//
//  EncryptedImageTransformer.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/22/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptedImageTransformer : NSValueTransformer

@property (copy, nonatomic) NSString *salt;
@property (copy, nonatomic) NSString *key;

@end
