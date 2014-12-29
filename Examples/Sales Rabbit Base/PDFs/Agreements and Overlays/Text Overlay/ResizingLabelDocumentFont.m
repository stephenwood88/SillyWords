//
//  ResizingLabelDocumentFont.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "ResizingLabelDocumentFont.h"

@implementation ResizingLabelDocumentFont

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"DIN-Medium" size:self.font.pointSize];
}

@end
