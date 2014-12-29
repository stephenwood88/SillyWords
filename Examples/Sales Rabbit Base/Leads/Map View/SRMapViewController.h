//
//  SRMapViewController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/17/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "AVStateNames.h"
#import "SRLeadAnnotationView.h"
#import "SRLeadDetailTableViewController.h"
#import "SRLeadsListViewController.h"
#import "SRQuadTreeController.h"
#import "SRClusterAnnotation.h"
#import "SRClusterAnnotationView.h"
#import "SRCalloutView.h"

typedef NS_ENUM(NSUInteger, SRUserType) {
    SRUserTypeRep = 1,
    SRUserTypeManager = 3,
    SRUserTypeRegional = 5,
    SRUserTypeAdmin = 12,
    SRUserTypeDeveloper = 13
};

@interface SRMapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, SRCalloutViewDelegate>
{
    BOOL wasAnyLeadButtonSelectedWhenMapTap; //Pretty self explanatory :)
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void) updateAllAnnotations;

//Map Controls and Actions
@property (weak, nonatomic) IBOutlet UIButton *trackingModeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapViewControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *viewControl;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapTouchGesture;

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender;
- (IBAction)mapTypeChanged:(UISegmentedControl *)sender;
- (IBAction)trackingModePressed:(UIButton *)sender;

//Map Optimizations
@property (strong, nonatomic) SRQuadTreeController *quadTreeController;
@property (strong, nonatomic) NSOperationQueue *mapClusteringOperationQueue;

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations;
- (void)queryAnnotations;

- (void)addBounceAnnimationToView:(MKAnnotationView *)view;

//Misc
@property (nonatomic) SRUserType userType;

//Lead Controls and Actions
@property (strong, nonatomic) Lead *leadToEdit;
@property (strong, nonatomic) Prequal *selectedPrequal;
@property (strong, nonatomic) NSMutableArray *visibleLeadList;

- (void) fetchUserLeads;

@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UIButton *callbackButton;
@property (weak, nonatomic) IBOutlet UIButton *notHomeButton;
@property (weak, nonatomic) IBOutlet UIButton *notInterestedButton;
@property (weak, nonatomic) IBOutlet UIButton *customerButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;

- (IBAction)leadTypeButtonPressed:(UIButton *)sender;
- (BOOL)isLeadListVisible;


/**
 *  Return the corresponding UIImage object depending on the Lead actual status
 *
 *  @return Image from the corresponding Lead status
 */
- (UIImage *)image;

@end


