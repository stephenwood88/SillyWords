//
//  AVSimpleDatePickerController.h
//  Dish Sales
//
//  Created by Brady Anderson on 2/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    AVDatePickerModeTime,
    AVDatePickerModeDate,
    AVDatePickerModeDateNoDays
} AVDatePickerMode;

@class AVSimpleDatePickerController;

@protocol AVSimpleDatePickerDelegate <NSObject>

@optional
- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date;

@end


@interface AVSimpleDatePickerController : UIViewController

@property (weak, nonatomic) id <AVSimpleDatePickerDelegate> delegate;
@property (weak, nonatomic) UIButton *sourceButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
// For AVDatePickerModeDateNoDays date picker only
@property (nonatomic) BOOL numericMonth;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

- (id)initWithDelegate:(id <AVSimpleDatePickerDelegate>)delegate sourceButton:(UIButton *)sourceButton datePickerMode:(AVDatePickerMode)datePickerMode date:(NSDate *)date minuteInterval:(NSInteger)minuteInterval minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate;

- (void)setMinDate:(NSDate *) minDate;
- (void)setMaxDate:(NSDate *) maxDate;
- (void)setPickerDate:(NSDate *) date;

@end
