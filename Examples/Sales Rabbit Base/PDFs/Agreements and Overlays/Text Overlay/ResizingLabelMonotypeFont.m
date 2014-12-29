//
//  ResizingLabelMonotypeFont.m
//  Security Sales
//
//  Created by Matthew McArthur on 2/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "ResizingLabelMonotypeFont.h"

@implementation ResizingLabelMonotypeFont

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"Courier New" size:self.font.pointSize];
}

- (void)setText:(NSString *)text {
    if (text) {
        [self calculateFontSizeForText:text];
        NSAttributedString *attributedString =[[NSAttributedString alloc]
                                               initWithString:text
                                               attributes:
                                               @{
                                                 NSFontAttributeName : self.font,
                                                 NSKernAttributeName : @(12.0f)
                                                 }];
        [super setAttributedText:attributedString];
    }else{
        [super setText:text];

    }
}

@end
