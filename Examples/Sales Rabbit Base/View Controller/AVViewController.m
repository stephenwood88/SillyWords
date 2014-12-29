//
//  AVViewController.m
//  Dish Sales
//
//  Created by Aaron on 8/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

//  This class contains all code which is commonly used in various view controllers throughout different apps.
//  Any view controller that uses popovers/action sheets in particular should subclass this.
//  If any of these methods need to be overridden, make sure to call super on that method.

#import "AVViewController.h"
#import "BaseConstants.h"
//#import <CoreLocation/CoreLocation.h>
//#import <AddressBook/AddressBook.h>
//#import "AVSelectionListController.h"
//#import "AVSimpleDatePickerController.h"
//#import "Constants.h"
//#import "DishSalesAppDelegate.h"
//#import "TextUtilities.h"
//#import "Person+Rabbit.h"
//#import "Address+Rabbit.h"
//#import "CreditCard+Rabbit.h"
//#import "Ach+Rabbit.h"
//#import "ServiceInfo+Rabbit.h"
//#import "TextOverlayViewFront.h"
//#import "SalesRabbitServiceCalls.h"
//#import "StateNames.h"

@interface AVViewController () <UIPopoverControllerDelegate>

//@property (strong, nonatomic) NSCharacterSet *numChars;

@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UIView *popoverView;
@property (strong, nonatomic) UIActionSheet *actionSheet;

//@property (strong, nonatomic) UIAlertView *gpsError;
//@property (strong, nonatomic) UIAlertView *connectionError;

@end

@implementation AVViewController 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAll)];
//    tap.cancelsTouchesInView = NO;
//    [self.tableView addGestureRecognizer:tap];
}

#pragma mark - Dismiss methods

- (void)dismissAll {
    
    [self dismissAll:YES];
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:animated];
        self.popoverView = nil;
        self.popover = nil;
    }
    if (self.actionSheet) {
        [self dismissActionSheet:self];
    }
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    
    [self.view endEditing:NO];
}

#pragma mark - Popover methods

- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView {
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    }
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    self.popover.delegate = self;
    // Allows touches outside the popover to create events besides just dismissing the popover (e.g. pressing another button)
    self.popover.passthroughViews = @[self.view];
    self.popoverView = sender;
    [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
}

//- (UIViewController *)popoverForButton:(UIButton *)button {
//    
//    if (button == self.dateOfBirthButton) return self.dateOfBirthPicker;
//    if (button == self.languageButton) return self.languageCheckList;
//    if (button == self.expirationDateButton) return self.expirationDatePicker;
//    if (button == self.providerButton) return self.providerCheckList;
//    if (button == self.tvsButton) return self.tvsCheckList;
//    if (button == self.receiverConfigurationButton) return self.receiverConfigurationCheckList;
//    if (button == self.packageButton) return self.packageCheckList;
//    return nil;
//}
//
//#pragma mark - IBAction Methods
//
//- (IBAction)popoverButtonPressed:(UIButton *)sender {
//    
//    [[self errorViewForView:sender] setHidden:YES];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        [self createActionSheet:sender sheetView:[self popoverForButton:sender]];
//    }
//    else {
//        [self createPopover:sender popoverView:[self popoverForButton:sender]];
//    }
//    
//    if (sender == self.dateOfBirthButton && [sender.titleLabel.text isEqualToString:kDateOfBirth]) {
//        [self dateChanged:self.dateOfBirthPicker toDate:[NSDate date]];
//    }
//    else if (sender == self.expirationDateButton && [sender.titleLabel.text isEqualToString:kExpDate]) {
//        [self dateChanged:self.expirationDatePicker toDate:[NSDate date]];
//    }
//}



- (void)viewWillLayoutSubviews {
    
    [self setPopoverLocation];
}

- (void)setPopoverLocation {
    
    if (self.popover && self.popoverView.superview.window) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    self.popoverView = nil;
    self.popover = nil;
}


#pragma mark- Action Sheet

- (void)createActionSheet:(id)sender sheetView:(UIViewController *)sheetView {
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    if (!sheetView.isViewLoaded) {
        [sheetView view]; // Load view so that its metrics will be available
    }
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect actionSheetFrame = screenFrame;
    if (sheetView.contentSizeForViewInPopover.height + 44 < actionSheetFrame.size.height) {
        actionSheetFrame.size.height = sheetView.contentSizeForViewInPopover.height + 44;
        actionSheetFrame.origin.y = actionSheetFrame.origin.y + screenFrame.size.height - actionSheetFrame.size.height;
    }
    CGRect sheetViewFrame = actionSheetFrame;
    sheetViewFrame.origin.y = 44;
    sheetViewFrame.size.height = actionSheetFrame.size.height - 44;
    
    [self.actionSheet addSubview:sheetView.view];
    
    //Only show cancel button if it is a one-item list picker, otherwise show done button
    UISegmentedControl *doneButton;
    CGFloat buttonWidth;
//    if ([sheetView isKindOfClass:[AVSelectionListController class]]) {
//        NSString *doneButtonText = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? kDone : kCancel;
//        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
//        doneButton.segmentedControlStyle = UISegmentedControlStyleBar;
//        doneButton.momentary = YES;
//        doneButton.tintColor = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1] : [UIColor blackColor];
//        buttonWidth = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? ACTION_DONE_BTN_WIDTH : ACTION_CANCEL_BTN_WIDTH;
//    }
//    else {
//        NSString *doneButtonText = kDone;
//        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
//        doneButton.segmentedControlStyle = UISegmentedControlStyleBar;
//        doneButton.momentary = YES;
//        doneButton.tintColor = [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1];
//        buttonWidth = ACTION_DONE_BTN_WIDTH;
//    }
    
    doneButton.frame = CGRectMake(screenFrame.size.width - buttonWidth - 5, 7, buttonWidth, 30);
    [doneButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [self.actionSheet addSubview:doneButton];
    
    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    // Set these frames after showing because the showInView method messes the frames up
    self.actionSheet.frame = actionSheetFrame;
    sheetView.view.frame = sheetViewFrame;
}

- (void)dismissActionSheet:(id)sender {
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    self.actionSheet = nil;
}

@end
