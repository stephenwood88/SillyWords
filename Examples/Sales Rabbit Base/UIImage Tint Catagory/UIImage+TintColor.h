//
//  UIImage+TintColor.h
//  Dish Sales
//
//  Created by Matthew McArthur on 9/26/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
