//
//  TextOverlayView.m
//  Dish Sales
//
//  Created by Jeff Lockhart on 4/20/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "TextOverlayView.h"

@interface TextOverlayView()

@end

@implementation TextOverlayView


- (void)awakeFromNib {
    
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    
    [super setContentScaleFactor:contentScaleFactor];
    for (UIView *subView in self.subviews) {
        [self setView:subView contentScaleFactor:contentScaleFactor];
    }
}

- (void)setView:(UIView *)view contentScaleFactor:(CGFloat)contentScaleFactor {
    
    view.contentScaleFactor = contentScaleFactor;
    for (UIView *subView in view.subviews) {
        [self setView:subView contentScaleFactor:contentScaleFactor];
    }
}

- (void)clearSignature {
    for (SignatureController *controller in self.signatureControllers) {
        [controller clear];
    }
}

- (BOOL)verifySignature
{
    for (UIButton *button in self.signatureButtons) {
        if (![button imageForState:UIControlStateNormal]) {
            return NO;
        }
    }
    return YES;
}

- (void)signatureButtonPressedAtIndex:(NSInteger)index {
    
    if (self.allowSignature) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.parentView presentViewController:[self.signatureControllers objectAtIndex:index] animated:YES completion:nil];
        }
        else {
            if (self.popover) {
                [self dismissPopover:YES];
            }
            UIButton *sender = [self.signatureButtons objectAtIndex:index];
            
            UIView *topView = [[UIApplication sharedApplication] keyWindow];
            UIView *disableTouchesView = [[UIView alloc] initWithFrame:topView.frame];
            disableTouchesView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            disableTouchesView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            [topView addSubview:disableTouchesView];
            self.disableTouchesView = disableTouchesView;
            self.popover = [[UIPopoverController alloc] initWithContentViewController:[self.signatureControllers objectAtIndex:index]];
            self.popover.delegate = self;
            self.popoverView = sender;
            [self.popover presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
        }
    }
}

#pragma mark - Public Methods

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint point = [recognizer locationInView:self];
        for (UIButton *button in self.signatureButtons)
        {
            if (CGRectContainsPoint(button.frame, point))
            {
                NSInteger index = [self.signatureButtons indexOfObject:button];
                [self signatureButtonPressedAtIndex:index];
                return button;
            }
        }
    }
    return nil;
}

- (void)setPopoverLocation {
    
    if (self.popover) {
        [self.popover presentPopoverFromRect:self.popoverView.frame inView:self.popoverView.superview permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
    }
}

- (void)dismissAll:(BOOL)animated {
    
    if (self.popover) {
        [self dismissPopover:animated];
    }
}

- (void)dismissPopover:(BOOL)animated {
    
    [self.popover dismissPopoverAnimated:animated];
    [self popoverControllerDidDismissPopover:self.popover];
}

#pragma mark - SignatureControllerDelegate

- (void)signatureDonePressed:(id)sender {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSInteger index = [self.signatureControllers indexOfObject:sender];
        [[self.signatureControllers objectAtIndex:index] saveSignatureToButton];
       [[self.signatureControllers objectAtIndex:index] dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if (self.popover) {
            [self dismissPopover:YES];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    return NO;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    [self.disableTouchesView removeFromSuperview];
    self.disableTouchesView = nil;
    [(SignatureController *)self.popover.contentViewController saveSignatureToButton];
    self.popoverView = nil;
    self.popover = nil;
}


@end
