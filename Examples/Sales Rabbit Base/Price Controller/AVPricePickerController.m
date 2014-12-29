//
//  AVPricePickerController.m
//  ElitePay Global Sales
//
//  Created by Stephen Wood on 4/9/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "AVPricePickerController.h"

@interface AVPricePickerController ()

@end

@implementation AVPricePickerController
- (id)initWithDelegate:(id<AVPricePickerControllerDelegate>)delegate sourceButton:(UIButton *)sourceButton minimum:(NSInteger)minimum maximum:(NSInteger)maximum {
    
    self = [self initWithNibName:@"AVPricePickerController" bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.sourceButton = sourceButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 990;
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSMutableAttributedString *string;
    NSMutableParagraphStyle *alignment = [[NSMutableParagraphStyle alloc] init];
    
    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)row*100]];
    
    alignment.alignment = NSTextAlignmentLeft;
    NSRange allRange = NSMakeRange(0, string.string.length);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:25.0] range:allRange];
    [string addAttribute:NSParagraphStyleAttributeName value:alignment range:allRange];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
  
}

@end
