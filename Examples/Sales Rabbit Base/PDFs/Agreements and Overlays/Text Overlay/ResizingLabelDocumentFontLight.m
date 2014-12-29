//
//  ResizingLabelDocumentFontLight.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "ResizingLabelDocumentFontLight.h"

@implementation ResizingLabelDocumentFontLight

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"DIN-Light" size:self.font.pointSize];
}

@end
