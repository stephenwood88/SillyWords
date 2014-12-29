//
//  SRSketchBoard.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SRSketchBoard : UIView {
    CGLayerRef _paintLayer;
    BOOL _fingerDragged;
    
}

@property (strong, nonatomic) UIColor* color;
@property (nonatomic) CGFloat lineWidth;
//- (UIImage*)renderDrawingWithOverlay:(UIImage*)overlay;

- (CGContextRef) setupDrawingContext;
- (void)eraseBoard;
@end
