//
//  CustomerCell.m
//  DishTech
//
//  Created by Jeff on 9/14/12.
//
//

#import "CustomerCell.h"
#import "Constants.h"

@implementation CustomerCell

- (void)setLabelsWithDictionary:(NSDictionary *)dictionary {
    
    self.nameLabel.text = [self checkForNSNull:[dictionary objectForKey:kCustomerName]];
    self.productLabel.text = [self checkForNSNull:[dictionary objectForKey:kProductCategories]];
    self.providerLabel.text = [self checkForNSNull:[dictionary objectForKey:kProvider]];
    self.statusLabel.text = [self checkForNSNull:[dictionary objectForKey:kInvoiceStatus]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    NSDate *installDate = [dictionary objectForKey:kInstallDate];
    self.installLabel.text = [dateFormatter stringFromDate:installDate];
}

- (id)checkForNSNull:(id)object {
    
    if ([object class] == [NSNull class]) {
        return nil;
    }
    return object;
}

@end
