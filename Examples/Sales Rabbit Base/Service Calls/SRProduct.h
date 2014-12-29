//
//  SRProduct.h
//  DishTech
//
//  Created by Jeff on 8/29/12.
//
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, copy) NSString *productID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDictionary *providers;

- (id)initWithProductID:(NSString *)productID dictionary:(NSDictionary *)dictionary;
- (id)key;

@end

@interface Product (SBProxyForJson)

// Return dictionary of providerIDs ready for JSON encoding for service call
- (id)proxyForJson;

@end
