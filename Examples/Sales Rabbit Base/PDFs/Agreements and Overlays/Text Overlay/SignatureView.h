//
//  SignatureView.h
//  Dish Sales
//
//  Created by Jeff on 11/17/12.
//  Copyright (c) 2012 AppVantage. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignatureViewDelegate <NSObject>

- (void)signatureSigned;
- (CGFloat)lineWidth;
- (UIColor *)lineColor;

@end

@interface SignatureView : UIView

@property (weak, nonatomic) id <SignatureViewDelegate> delegate;

- (void)clear;

- (BOOL)isSigned;

- (UIImage *)signatureImage;

@end
