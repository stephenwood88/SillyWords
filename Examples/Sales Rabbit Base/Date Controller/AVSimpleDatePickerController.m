//
//  AVSimpleDatePickerController.m
//  Dish Sales
//
//  Created by Brady Anderson on 2/1/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AVSimpleDatePickerController.h"

#define kNumYears 7

@interface AVSimpleDatePickerController ()

@property (nonatomic) AVDatePickerMode datePickerMode;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSInteger minuteInterval;
@property (strong, nonatomic) NSDate *minimumDate;
@property (strong, nonatomic) NSDate *maximumDate;
@property (nonatomic) NSInteger startYear;
@property (nonatomic) NSInteger startMonth;

@end

static NSString *months[] = {@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"};
// For wrapping components
static NSInteger monthsBigNumber = 1000 * 12;
static NSInteger yearsBigNumber = 1000 * kNumYears;


@implementation AVSimpleDatePickerController

- (id)initWithDelegate:(id <AVSimpleDatePickerDelegate>)delegate sourceButton:(UIButton *)sourceButton datePickerMode:(AVDatePickerMode)datePickerMode date:(NSDate *)date minuteInterval:(NSInteger)minuteInterval minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate {
    
    self = [self initWithNibName:@"AVSimpleDatePickerController" bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.sourceButton = sourceButton;
        self.datePickerMode = datePickerMode;
        self.date = date;
        self.minuteInterval = minuteInterval;
        self.minimumDate = minimumDate;
        self.maximumDate = maximumDate;
        self.numericMonth = NO;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    switch (self.datePickerMode) {
        case AVDatePickerModeTime: {
            self.datePicker.datePickerMode = UIDatePickerModeTime;
            break;
        }
        case AVDatePickerModeDate: {
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            break;
        }
        case AVDatePickerModeDateNoDays: {
            [self.datePicker removeFromSuperview];
            self.datePicker = nil;  // don't need
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
            self.startYear = components.year;
           
            //NSLog(@"Start Month: %ld", components.month);
            // If first load, initialize to default
            if (self.date) {
                components = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.date];
                [self.sourceButton setTitle:[self.dateFormatter stringFromDate:self.date] forState:UIControlStateNormal];
                [self.delegate dateChanged:self toDate:self.date];
                if ([self.delegate respondsToSelector:@selector(dateChanged:toDate:)]) {
                    [self.delegate dateChanged:self toDate:self.date];
                }
            }
            else {
                NSDate *currentDate = [self.dateFormatter dateFromString:[self.sourceButton titleForState:UIControlStateNormal]];
                components = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:currentDate];
                
            }
            self.startMonth = components.month - 1;
            [self selectMonth:self.startMonth year:components.year - self.startYear];
            CGFloat width = self.numericMonth ? 150 : 250;
            self.preferredContentSize = CGSizeMake(width, self.picker.intrinsicContentSize.height);
            break;
        }
        default:
            break;
    }
    if (self.datePickerMode != AVDatePickerModeDateNoDays) {
        [self.picker removeFromSuperview];
        self.picker = nil;  // don't need
        self.datePicker.minuteInterval = self.minuteInterval;
        self.datePicker.minimumDate = self.minimumDate;
        self.datePicker.maximumDate = self.maximumDate;
        // If first load, initialize to default
        if (self.date) {
            self.datePicker.date = self.date;
        }
        else {
            NSDate *existingDate = [self.dateFormatter dateFromString:[self.sourceButton titleForState:UIControlStateNormal]];
            if (existingDate) {
                self.datePicker.date = existingDate;
            }else{
                self.datePicker.date = [NSDate date];
            }
        }
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        CGFloat width = 0;
        if (self.datePickerMode == AVDatePickerModeTime) {
            width = 196;
        }
        else if (self.datePickerMode == AVDatePickerModeDate) {
            width = 300;
        }
        self.preferredContentSize = CGSizeMake(width, self.datePicker.intrinsicContentSize.height);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.dateFormatter = nil;
}
#pragma mark - UIDatePicker Action Events

- (void)dateChanged:(UIDatePicker *)sender {
    
    NSString *dateString = [self.dateFormatter stringFromDate:sender.date];
    [self.sourceButton setTitle:dateString forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(dateChanged:toDate:)]) {
        [self.delegate dateChanged:self toDate:sender.date];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            return monthsBigNumber * 2;
        case 1:
            return yearsBigNumber * 2;
        default:
            return 0;
    }
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSMutableAttributedString *string;
    NSMutableParagraphStyle *alignment = [[NSMutableParagraphStyle alloc] init];
    switch (component) {
        case 0:
            if (self.numericMonth) {
                string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d-", (int)(row % 12) + 1]];
            }
            else {
                string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@-", months[row % 12]]];
            }
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(string.string.length - 1, 1)]; // clear '-' character to create margin
            alignment.alignment = NSTextAlignmentRight;
            break;
        case 1:
            string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)(self.startYear + (row % kNumYears))]];
            alignment.alignment = NSTextAlignmentLeft;
            break;
        default:
            return nil;
    }
    NSRange allRange = NSMakeRange(0, string.string.length);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:25.0] range:allRange];
    [string addAttribute:NSParagraphStyleAttributeName value:alignment range:allRange];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger selectedMonth = [pickerView selectedRowInComponent:0] % 12;
    NSInteger selectedYear = [pickerView selectedRowInComponent:1] % kNumYears;
    if (selectedMonth < self.startMonth && selectedYear == self.startYear) {
        selectedMonth = self.startMonth;
    }
    [self selectMonth:selectedMonth year:selectedYear]; // reset back to middle of wrapping rows
    NSString *dateString = [NSString stringWithFormat:@"%d/%d", (int)selectedMonth + 1, (int)(selectedYear + self.startYear)];
    [self.sourceButton setTitle:dateString forState:UIControlStateNormal];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = selectedMonth + 1;
    components.year = selectedYear + self.startYear;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    if ([self.delegate respondsToSelector:@selector(dateChanged:toDate:)]){
        [self.delegate dateChanged:self toDate:date];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            if (self.numericMonth) {
                return 50;
            }
            return 150;
        case 1:
            return 76;
        default:
            return 0;
    }
}

#pragma mark - Private Methods

- (void)selectMonth:(NSInteger)monthRow year:(NSInteger)yearRow {
    [self.picker selectRow:monthRow + monthsBigNumber inComponent:0 animated:YES];
    [self.picker selectRow:yearRow + yearsBigNumber inComponent:1 animated:NO];
}

#pragma mark - Custom Accesors

- (NSDateFormatter *)dateFormatter {
    
    if (!_dateFormatter) {
        static NSLocale* en_US_POSIX = nil;
        _dateFormatter = [[NSDateFormatter alloc] init];
        if (en_US_POSIX == nil) {
            en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        }
        [_dateFormatter setLocale:en_US_POSIX];
        
        if (self.datePickerMode == AVDatePickerModeDate) {
            _dateFormatter.dateFormat = @"M/d/yyyy";
        }
        else if (self.datePickerMode == AVDatePickerModeTime) {
            _dateFormatter.dateFormat = @"h:mm a";
        }
        else if (self.datePickerMode == AVDatePickerModeDateNoDays) {
            _dateFormatter.dateFormat = @"M/yyyy";
        }
    }
    return _dateFormatter;
}

#pragma mark - public methods

- (void)setMinDate:(NSDate *)minDate {
    
    self.minimumDate = minDate;
    self.datePicker.minimumDate = minDate;
}

- (void)setMaxDate:(NSDate *)maxDate {
    
    self.maximumDate = maxDate;
    self.datePicker.maximumDate = maxDate;
}

- (void)setPickerDate:(NSDate *)date {
    
    self.date = date;
    self.datePicker.date = date;
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    [self.sourceButton setTitle:dateString forState:UIControlStateNormal];
}

- (void)setNumericMonth:(BOOL)numericMonth {
    
    if (self.datePickerMode == AVDatePickerModeDateNoDays) {
        _numericMonth = numericMonth;
        CGFloat width = numericMonth ? 150 : 250;
        self.preferredContentSize = CGSizeMake(width, self.picker.intrinsicContentSize.height);
    }
}

@end
