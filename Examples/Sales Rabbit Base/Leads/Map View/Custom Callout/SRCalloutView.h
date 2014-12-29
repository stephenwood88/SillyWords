//
//  SRCalloutView.h
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 7/2/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/*
 
 SRCalloutView
 -------------
 Created by Nick Farina (nfarina@gmail.com)
 Version 2.0
 
 */

// options for which directions the callout is allowed to "point" in.
typedef NS_ENUM(NSUInteger, SRCalloutArrowDirection) {
    SRCalloutArrowDirectionUp = 1UL << 0,
    SRCalloutArrowDirectionDown = 1UL << 1,
    SRCalloutArrowDirectionAny = SRCalloutArrowDirectionUp | SRCalloutArrowDirectionDown
};

// options for the callout present/dismiss animation
typedef NS_ENUM(NSInteger, SRCalloutAnimation) {
    SRCalloutAnimationBounce,	// the "bounce" animation we all know and love from UIAlertView
    SRCalloutAnimationFade,		// a simple fade in or out
    SRCalloutAnimationStretch	// grow or shrink linearly, like in the iPad Calendar app
};

// when delaying our popup in order to scroll content into view, you can use this amount to match the
// animation duration of UIScrollView when using -setContentOffset:animated.
extern NSTimeInterval kSRCalloutViewRepositionDelayForUIScrollView;

@protocol SRCalloutViewDelegate;
@class SRCalloutBackgroundView;

//
// Callout view.
//

@interface SRCalloutView : UIView

@property (nonatomic, unsafe_unretained) id<SRCalloutViewDelegate> delegate;
@property (nonatomic, copy) NSString *title, *subtitle; // title/titleView relationship mimics UINavigationBar.
@property (nonatomic, retain) UIView *leftAccessoryView, *rightAccessoryView;
@property (nonatomic, assign) SRCalloutArrowDirection permittedArrowDirection; // default SRCalloutArrowDirectionDown
@property (nonatomic, readonly) SRCalloutArrowDirection currentArrowDirection;
@property (nonatomic, assign) UIEdgeInsets constrainedInsets; // if the UIView you're constraining to has portions that are overlapped by nav bar, tab bar, etc. you'll need to tell us those insets.
@property (nonatomic, retain) SRCalloutBackgroundView *backgroundView; // default is SRCalloutMaskedBackgroundView, or SRCalloutDrawnBackgroundView when using SRClassicCalloutView

// Custom title/subtitle views. if these are set, the respective title/subtitle properties will be ignored.
// Keep in mind that SRCalloutView calls -sizeThatFits on titleView/subtitleView if defined, so your view
// may be resized as a result of that (especially if you're using UILabel/UITextField). You may want to subclass
// and override -sizeThatFits, or just wrap your view in a "generic" UIView if you do not want it to be auto-sized.
@property (nonatomic, retain) UIView *titleView, *subtitleView;

// Custom "content" view that can be any width/height. If this is set, title/subtitle/titleView/subtitleView are all ignored.
@property (nonatomic, retain) UIView *contentView;

// calloutOffset is the offset in screen points from the top-middle of the annotation view, where the anchor of the callout should be shown.
@property (nonatomic, assign) CGPoint calloutOffset;

@property (nonatomic, assign) SRCalloutAnimation presentAnimation, dismissAnimation; // default SRCalloutAnimationBounce, SRCalloutAnimationFade respectively


// Returns a new instance of SRCalloutView if running on iOS 7 or better, otherwise a new instance of SRClassicCalloutView if available.
+ (SRCalloutView *)platformCalloutView;

// Presents a callout view by adding it to "inView" and pointing at the given rect of inView's bounds.
// Constrains the callout to the bounds of the given view. Optionally scrolls the given rect into view (plus margins)
// if -delegate is set and responds to -delayForRepositionWithSize.
- (void)presentCalloutFromRect:(CGRect)rect inView:(UIView *)view constrainedToView:(UIView *)constrainedView animated:(BOOL)animated;

// Same as the view-based presentation, but inserts the callout into a CALayer hierarchy instead. Be aware that you'll have to direct
// your own touches to any accessory views, since CALayer doesn't relay touch events.
- (void)presentCalloutFromRect:(CGRect)rect inLayer:(CALayer *)layer constrainedToLayer:(CALayer *)constrainedLayer animated:(BOOL)animated;

- (void)dismissCalloutAnimated:(BOOL)animated;

// For subclassers. You can override this method to provide your own custom animation for presenting/dismissing the callout.
- (CAAnimation *)animationWithType:(SRCalloutAnimation)type presenting:(BOOL)presenting;

/**
 *  To know if the Callout is currently present or not
 *
 *  @return YES if the Callout is currently present in an annotation, returns NO if the Callout is not present
 */
- (BOOL)isPresent;

@end

//
// Background view - default draws the iOS 7 system background style (translucent white with rounded arrow).
//

// Abstract base class
@interface SRCalloutBackgroundView : UIView
@property (nonatomic, assign) CGPoint arrowPoint; // indicates where the tip of the arrow should be drawn, as a pixel offset
@property (nonatomic, assign) BOOL highlighted; // will be set by the callout when the callout is in a highlighted state
@property (nonatomic, assign) CALayer *contentMask; // returns an optional layer whose contents should mask the callout view's contents (not honored by SRClassicCalloutView)
@end

// Default for iOS 7, this reproduces the "masked" behavior of the iOS 7-style callout view.
// Accessories are masked by the shape of the callout (including the arrow itself).
@interface SRCalloutMaskedBackgroundView : SRCalloutBackgroundView
@end

//
// Delegate methods
//

@protocol SRCalloutViewDelegate <NSObject>
@optional

// Implementing this method allows the callout to be "clicked" like a button, with highlight state. default YES.
// Not honored by SRClassicCalloutView.
- (void)calloutViewClicked:(SRCalloutView *)calloutView;

// Called when the callout view detects that it will be outside the constrained view when it appears,
// or if the target rect was already outside the constrained view. You can implement this selector to
// respond to this situation by repositioning your content first in order to make everything visible. The
// CGSize passed is the calculated offset necessary to make everything visible (plus a nice margin).
// It expects you to return the amount of time you need to reposition things so the popup can be delayed.
// Typically you would return kSRCalloutViewRepositionDelayForUIScrollView if you're repositioning by
// calling [UIScrollView setContentOffset:animated:].
- (NSTimeInterval)calloutView:(SRCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset;

// Called before the callout view appears on screen, or before the appearance animation will start.
- (void)calloutViewWillAppear:(SRCalloutView*)calloutView;

// Called after the callout view appears on screen, or after the appearance animation is complete.
- (void)calloutViewDidAppear:(SRCalloutView *)calloutView;

// Called before the callout view is removed from the screen, or before the disappearance animation is complete.
- (void)calloutViewWillDisappear:(SRCalloutView*)calloutView;

// Called after the callout view is removed from the screen, or after the disappearance animation is complete.
- (void)calloutViewDidDisappear:(SRCalloutView *)calloutView;

@end