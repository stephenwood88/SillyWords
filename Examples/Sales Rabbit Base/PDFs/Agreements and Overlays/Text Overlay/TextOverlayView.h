//
//  TextOverlayView.h
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignatureController.h"

@interface TextOverlayView : UIView <UIPopoverControllerDelegate, SignatureControllerDelegate>

/**
 * Overwrite to detect and handle any tap actions the overlay should handle.
 * The default implementation returns nil. If the tap is handled, return the view
 * that handles it.
 */
- (id)processSingleTap:(UITapGestureRecognizer *)recognizer;

@property (nonatomic, strong) NSManagedObject *agreementModel;

@property (nonatomic) BOOL allowSignature;
@property (weak, nonatomic) UIViewController *parentView;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIView *disableTouchesView;
@property (weak, nonatomic) UIView *popoverView;
@property (nonatomic, strong) NSArray *signatureControllers;
@property (nonatomic, strong) NSArray *signatureButtons;

- (void)setPopoverLocation;
- (void)dismissPopover:(BOOL)animated;
- (void)dismissAll:(BOOL)animated;
- (BOOL)verifySignature;
- (void)clearSignature;

@end
