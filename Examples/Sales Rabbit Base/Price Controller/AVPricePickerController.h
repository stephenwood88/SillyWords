//
//  AVPricePickerController.h
//  ElitePay Global Sales
//
//  Created by Stephen Wood on 4/9/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPricePickerController;

@protocol AVPricePickerControllerDelegate <NSObject>

@optional
- (void)valueChanged:(AVPricePickerController *)sender toValue:(NSInteger)value;

@end

@interface AVPricePickerController : UIViewController

@property (weak, nonatomic) id <AVPricePickerControllerDelegate> delegate;
@property (weak, nonatomic) UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

- (id)initWithDelegate:(id <AVPricePickerControllerDelegate>)delegate sourceButton:(UIButton *)sourceButton minimum:(NSInteger) minimum maximum:(NSInteger)maximum;

@end
