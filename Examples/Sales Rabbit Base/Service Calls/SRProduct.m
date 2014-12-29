//
//  Product.m
//  DishTech
//
//  Created by Jeff on 8/29/12.
//
//

#import "SRProduct.h"

@implementation Product

@synthesize productID = _productID;
@synthesize title = _title;
@synthesize providers = _providers;

- (id)init {
    self = [super init];
    if (self) {
        self.productID = @"";
        self.title = @"";
        self.providers = [[NSDictionary alloc] init];
    }
    return self;
}

- (id)initWithProductID:(NSString *)productID dictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if (productID) {
            self.productID = productID;
        }
        else {
            self.productID = @"";
        }
        NSNull* aNull = [[NSNull alloc] init];
        if ([dictionary valueForKey:@"title"] != aNull) {
            self.title = [dictionary valueForKey:@"title"];
        }
        else {
            self.title = @"";
        }
        if ([dictionary valueForKey:@"providers"] != aNull) {
            self.providers = [dictionary valueForKey:@"providers"];
        }
        else {
            self.providers = [[NSDictionary alloc] init];
        }
    }
    return self;
}

/**
 * Returns the key used to map this object in a dictionary
 */
- (id)key {
    
    return self.productID;
}

- (NSString *)description {
    
    return self.title;
}

// Return dictionary of providerIDs ready for JSON encoding for service call
- (id)proxyForJson {
    
    NSArray *keys = [self.providers allKeys];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[keys count]];
    for (int i = 0; i < [keys count]; i++) {
        [values addObject:[NSNumber numberWithInt:1]];
    }
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

@end
