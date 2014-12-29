//
//  SRMapViewController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/17/13.
//  Edited by Raul Lopez Villalpando 1/8/14
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRMapViewController.h"
#import "Lead+Rabbit.h"
#import "Address+Rabbit.h"
#import "Constants.h"
#import "Flurry.h"
#import "SRSalesServiceCalls.h"
#import "SRLeadsListViewController.h"
#import "AVLocationManager.h"

#define MapSegmentIndex 0
#define StreetSegmentIndex 1
#define ListSegmentIndex 2
#define MapTypeStandardIndex 0
#define MapTypeHybridIndex 1
#define MapTypeSatelliteIndex 2

//Custom Callout constants

#define CALLOUT_ICON_WIDTH 32
#define CALLOUT_ICON_HEIGHT 39
#define CALLOUT_HORIZANTAL_SPACING 10
#define CALLOUT_VERTICAL_SPACING 5
#define CALLOUT_LABEL_HEIGHT 14

@interface SRMapViewController ()

@property (assign, nonatomic) int initialLoad;
@property (nonatomic) BOOL animateAnnotationUpdates;
@property (weak, nonatomic) SRLeadsListViewController *leadListVC;
@property (nonatomic, strong) SRCalloutView *customCallout;

@end

@implementation SRMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initialLoad = YES;
    
    self.mapClusteringOperationQueue = [NSOperationQueue new];
    //This is so we limit the queue concurrent operations to 1 so it doesn't execute other operations on different threads, otherwise race conditions can happen
    [self.mapClusteringOperationQueue setMaxConcurrentOperationCount:1];
    
    [self fetchUserLeads];
    
    //Set up the QuadTree
    self.quadTreeController = [[SRQuadTreeController alloc] initWithOperationQueue:self.mapClusteringOperationQueue]; //Initialize with same queue to avoid problems with Background threads
    self.quadTreeController.mapView = self.mapView;
    
    [self.quadTreeController buildTree:self.visibleLeadList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leadsChanged:) name:kLeadsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleAttributesChanged:) name:kTitleAttributesChangedNotification object:nil];
    self.mapView.showsUserLocation = YES;
    self.mapViewControl.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    //To turn gps on
    if (self.viewControl.selectedSegmentIndex == 0) {
        self.mapView.showsUserLocation = YES;
    }
    
    [[SRSalesServiceCalls singleton] sync];
    [self flurryTrack];
    
    // check and see if the app was opened by a notification
    NSString *leadId = [[SRGlobalState singleton] leadIdFromNotification];
    if (leadId) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
        request.predicate = [NSPredicate predicateWithFormat:@"leadId == %@ && userId == %@", leadId, [[SRGlobalState singleton] userId]];
        NSError *error;
        NSArray *result = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
        if (result.count > 0) {
            self.leadToEdit = [result objectAtIndex:0];
            [self performSegueWithIdentifier:@"MapToLeadDetail" sender:self];
            UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:@"Scheduled Appointment"
                                                                        message:[[SRGlobalState singleton] alertBody]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
            [notificationAlert show];
        }
        [[SRGlobalState singleton] setLeadIdFromNotification:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    //To turn gps off (if no other apps are listening)
    self.mapView.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"MapToLeadDetail"] && [self.leadToEdit.status isEqualToString:kCustomer]) {
        return [self canEditCustomerLeads];
    }
    return YES;
}

-(BOOL)canEditCustomerLeads{
    if ([kAppType isEqualToString:kOriginalApp] || [kAppType isEqualToString:kPremiumApp]) {
        return YES;
    }else{
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqual:@"MapToLeadDetail"]) {
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        ldtvc.leadToEdit = self.leadToEdit;
    }
    else if ([segue.identifier isEqualToString:@"MapToLeadsList"]) {
        self.leadListVC = segue.destinationViewController;
    }
}

#pragma mark - Lead Sync methods

- (void)leadsChanged:(NSNotification *)notification {
    NSDictionary *result = notification.object;
    if ([result objectForKey:kAnimateLeadChanges] != nil) {
        self.animateAnnotationUpdates = [[result objectForKey:kAnimateLeadChanges] boolValue];
    }
    else {
        self.animateAnnotationUpdates = NO;
    }
    
    BOOL needToUpdateLeads = NO;
    
    NSArray *addedLeads = [result objectForKey:kAddedLeads];
    for (Lead *lead in addedLeads) {
        if (lead.latitude != nil && lead.longitude != nil) {
            [self.visibleLeadList addObject:lead];
            [self.quadTreeController insertData:dataFromAnnotation(lead, [lead.latitude doubleValue], [lead.longitude doubleValue])];
            needToUpdateLeads = YES;
        }
    }
    
    NSArray *updatedLeads = [result objectForKey:kUpdatedLeads];
    for (Lead *lead in updatedLeads) {
        if (lead.latitude != nil && lead.longitude != nil) {
            //In case status changed
            MKAnnotationView *view = [self.mapView viewForAnnotation:lead];
            view.image = [lead image];
            [self addDropAnnimationToView:view withDelay:0];
        }
    }
    
    NSArray *deletedLeads = [result objectForKey:kDeletedLeads];
    for (Lead *lead in deletedLeads) {
        if ([self.mapView.annotations containsObject:lead]) {
            [self.visibleLeadList removeObject:lead];
            [self.quadTreeController deleteData:dataFromAnnotation(lead, [lead.latitude doubleValue], [lead.longitude doubleValue])];
            needToUpdateLeads = YES;
        }
    }
    
    if (needToUpdateLeads) {
        [self queryAnnotations];
    }
}

- (void)titleAttributesChanged:(NSNotification *)notification {
    NSDictionary *result = notification.object;
    
    NSArray *updatedLeads = [result objectForKey:kUpdatedLeads];
    for (Lead *lead in updatedLeads) {
        lead.subtitle = [lead subtitle];
    }
}

#pragma  mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (self.initialLoad && userLocation.coordinate.latitude != 0) {
        CLLocationCoordinate2D loc = [userLocation coordinate];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 200, 200);
        [self.mapView setRegion:region animated:YES];
        if (userLocation.location.horizontalAccuracy < 100) {
            self.initialLoad = NO;
        }
        // This is only tracking this in Flurry for the initial load
        [Flurry setLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude horizontalAccuracy:userLocation.location.horizontalAccuracy verticalAccuracy:userLocation.location.verticalAccuracy];
    }
    
    [[AVLocationManager singleton] updateUserLocation:userLocation.location];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    if (self.mapView.userTrackingMode == MKUserTrackingModeNone) {
        [self.trackingModeButton setBackgroundImage:[UIImage imageNamed:@"button_none"] forState:UIControlStateNormal];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollow){
        [self.trackingModeButton setBackgroundImage:[UIImage imageNamed:@"button_none_sel"] forState:UIControlStateNormal];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading){
        [self.trackingModeButton setBackgroundImage:[UIImage imageNamed:@"button_none_head"] forState:UIControlStateNormal];
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
   
    if ([annotation isKindOfClass:[Lead class]]) {
        
        NSString *pinReusableIdentifier = @"AnnotationIdentifier";
        
        SRLeadAnnotationView *customAnnotationView = (SRLeadAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
        
        if (customAnnotationView == nil){
            /* If we fail to reuse a pin, then we will create one */
            customAnnotationView =  [[SRLeadAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReusableIdentifier];
        }
        else {
            customAnnotationView.annotation = annotation;
        }
        
        customAnnotationView.draggable = YES;
        customAnnotationView.canShowCallout = YES;
        customAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customAnnotationView.tintColor = [UIColor blueColor];
        
        Lead *lead = (Lead *)annotation;
        
        customAnnotationView.image = [lead image];
        
        if([lead.status isEqual:kCustomer] && ![self canEditCustomerLeads]) {
                customAnnotationView.rightCalloutAccessoryView = nil;
        }
        
        return customAnnotationView;
    }
    else if ([annotation isKindOfClass:[SRClusterAnnotation class]])
    {
        static NSString *const TBAnnotatioViewReuseID = @"SRAnnotatioViewReuseID";
        
        SRClusterAnnotationView *annotationView = (SRClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
        
        if (!annotationView) {
            annotationView = [[SRClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
        }
        
        //Do not present Apple's callout since we are presenting a custom one
        annotationView.canShowCallout = NO;
        annotationView.count = [(SRClusterAnnotation *)annotation count];
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    SRLeadAnnotationView *aV;
    
    if (self.animateAnnotationUpdates) {
        for (aV in views)
        {
            
            // Don't pin drop if annotation is user location
            if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            [self addDropAnnimationToView:aV withDelay:[views indexOfObject:aV]];
            
        }
    }
    else
    {
        for (MKAnnotationView *view in views) {
            [self addBounceAnnimationToView:view];
        }
    }
    self.animateAnnotationUpdates = NO;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{

    if ([self.customCallout isPresent]) {
        [self.customCallout dismissCalloutAnimated:NO];
    }
    
    if ([view isKindOfClass:[SRClusterAnnotationView class]]) {
        //Initialize customCallout for clustered annotations
        self.customCallout = [SRCalloutView platformCalloutView];
        self.customCallout.delegate = self;
        
        // Apply the MKAnnotationView's desired calloutOffset (from the top-middle of the view)
        self.customCallout.calloutOffset = view.calloutOffset;
        
        self.customCallout.contentView = [self customCalloutViewForAnnotationView:view];
        
        // iOS 7 only: Apply our view controller's edge insets to the allowable area in which the callout can be displayed.
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            self.customCallout.constrainedInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
        
        [self.customCallout presentCalloutFromRect:view.bounds inView:view constrainedToView:self.view animated:YES];
    }
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    [self.customCallout dismissCalloutAnimated:YES];
}

/**
 *  Returns the custom UIView that need to go on the contentView of the customCallout depending on the class of the annotation. 
 *
 *  @param view MKAnnotationView that will display the custom UIView.
 *
 *  @return UIView with custom content deoending on the annotationtype given. If the annotation from the MKannotationView is of class SRClusterAnnotation it will return a UIView with the information of each type on annotation clustered inside. Otherwise it will return nil.
 */
- (UIView *)customCalloutViewForAnnotationView:(MKAnnotationView *) view
{
    if ([view.annotation isKindOfClass:[SRClusterAnnotation class]]) {
        SRClusterAnnotation *annotation = (SRClusterAnnotation *)view.annotation;
        UIView *customView;
        
        NSInteger verticalSpacingCount = CALLOUT_HORIZANTAL_SPACING;
        NSInteger numberOfElements = 0;
        
        UIImageView *prequalIcon;
        UIImageView *leadsIcon;
        UIImageView *repLeadsIcon;
        UIImageView *userLocationsIcon;
        
        UILabel *prequalCountLabel;
        UILabel *leadsCountLabel;
        UILabel *repLeadsCountLabel;
        UILabel *userLocationsCountLabel;
        
        
        
        if (annotation.prequalCount > 0) {
            prequalIcon = [[UIImageView alloc] initWithFrame:CGRectMake(verticalSpacingCount, CALLOUT_VERTICAL_SPACING, CALLOUT_ICON_WIDTH, CALLOUT_ICON_HEIGHT)];
            prequalIcon.image = [UIImage imageNamed:@"prequal_silver"];
            
            prequalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(prequalIcon.frame.origin.x, prequalIcon.frame.origin.y + prequalIcon.frame.size.height + CALLOUT_VERTICAL_SPACING, prequalIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING*.7, CALLOUT_LABEL_HEIGHT)];
            prequalCountLabel.center = CGPointMake(prequalIcon.center.x, prequalCountLabel.center.y);
            prequalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)annotation.prequalCount];
            prequalCountLabel.font = [UIFont fontWithName:@"Avenir Medium" size:14];
            prequalCountLabel.textAlignment = NSTextAlignmentCenter;
            prequalCountLabel.adjustsFontSizeToFitWidth = YES;
            
            verticalSpacingCount += prequalIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING;
            numberOfElements++;
        }
        
        if (annotation.leadsCount > 0) {
            leadsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(verticalSpacingCount, CALLOUT_VERTICAL_SPACING, CALLOUT_ICON_WIDTH, CALLOUT_ICON_HEIGHT)];
            leadsIcon.image = [UIImage imageNamed:@"location_blue"];
            
            leadsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(leadsIcon.frame.origin.x, leadsIcon.frame.origin.y + leadsIcon.frame.size.height + CALLOUT_VERTICAL_SPACING, leadsIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING*.7, CALLOUT_LABEL_HEIGHT)];
            leadsCountLabel.center = CGPointMake(leadsIcon.center.x, leadsCountLabel.center.y);
            leadsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)annotation.leadsCount];
            leadsCountLabel.font = [UIFont fontWithName:@"Avenir Medium" size:14];
            leadsCountLabel.textAlignment = NSTextAlignmentCenter;
            leadsCountLabel.adjustsFontSizeToFitWidth = YES;
            
            verticalSpacingCount += leadsIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING;
            numberOfElements++;
        }
        
        if (annotation.repLeadsCount > 0 && self.userType != SRUserTypeRep) {
            repLeadsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(verticalSpacingCount, CALLOUT_VERTICAL_SPACING, CALLOUT_ICON_WIDTH, CALLOUT_ICON_HEIGHT)];
            repLeadsIcon.image = [UIImage imageNamed:@"slim_lead_background"];
            
            repLeadsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(repLeadsIcon.frame.origin.x, repLeadsIcon.frame.origin.y + repLeadsIcon.frame.size.height + CALLOUT_VERTICAL_SPACING, repLeadsIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING*.7, CALLOUT_LABEL_HEIGHT)];
            repLeadsCountLabel.center = CGPointMake(repLeadsIcon.center.x, repLeadsCountLabel.center.y);
            repLeadsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)annotation.repLeadsCount];
            repLeadsCountLabel.font = [UIFont fontWithName:@"Avenir Medium" size:14];
            repLeadsCountLabel.textAlignment = NSTextAlignmentCenter;
            repLeadsCountLabel.adjustsFontSizeToFitWidth = YES;
            
            verticalSpacingCount += repLeadsIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING;
            numberOfElements++;
        }
        
        if (annotation.userLocationsCount > 0 && self.userType != SRUserTypeRep) {
            userLocationsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(verticalSpacingCount + CALLOUT_HORIZANTAL_SPACING, CALLOUT_VERTICAL_SPACING, CALLOUT_ICON_WIDTH, CALLOUT_ICON_HEIGHT)];
            userLocationsIcon.image = [UIImage imageNamed:@"leads_rep_pin"];
            
            userLocationsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(userLocationsIcon.frame.origin.x, userLocationsIcon.frame.origin.y + userLocationsIcon.frame.size.height + CALLOUT_VERTICAL_SPACING, userLocationsIcon.frame.size.width + CALLOUT_HORIZANTAL_SPACING*.7, CALLOUT_LABEL_HEIGHT)];
            userLocationsCountLabel.center = CGPointMake(userLocationsIcon.center.x, userLocationsCountLabel.center.y);
            userLocationsCountLabel.text = [NSString stringWithFormat:@"%ld", (long)annotation.userLocationsCount];
            userLocationsCountLabel.font = [UIFont fontWithName:@"Avenir Medium" size:14];
            userLocationsCountLabel.textAlignment = NSTextAlignmentCenter;
            userLocationsCountLabel.adjustsFontSizeToFitWidth = YES;
            
            verticalSpacingCount += userLocationsCountLabel.frame.size.width + CALLOUT_HORIZANTAL_SPACING;
            numberOfElements++;
        }
        
        
        switch (self.userType) {
            case SRUserTypeRep:
                customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CALLOUT_HORIZANTAL_SPACING*(numberOfElements+1) + CALLOUT_ICON_WIDTH*numberOfElements, CALLOUT_ICON_HEIGHT + CALLOUT_LABEL_HEIGHT + 3*CALLOUT_VERTICAL_SPACING)];
                [customView addSubview:leadsIcon];
                [customView addSubview:leadsCountLabel];
                [customView addSubview:prequalIcon];
                [customView addSubview:prequalCountLabel];
                break;
            case SRUserTypeManager:
            case SRUserTypeRegional:
            case SRUserTypeAdmin:
            case SRUserTypeDeveloper:
                customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CALLOUT_HORIZANTAL_SPACING*(numberOfElements+1) + CALLOUT_ICON_WIDTH*numberOfElements, CALLOUT_ICON_HEIGHT + CALLOUT_LABEL_HEIGHT + 3*CALLOUT_VERTICAL_SPACING)];
                [customView addSubview:leadsIcon];
                [customView addSubview:leadsCountLabel];
                [customView addSubview:prequalIcon];
                [customView addSubview:prequalCountLabel];
                [customView addSubview:repLeadsIcon];
                [customView addSubview:repLeadsCountLabel];
                [customView addSubview:userLocationsIcon];
                [customView addSubview:userLocationsCountLabel];
                break;
            default:
                break;
        }
        return customView;
    }
    
    return  nil;
}


- (void)addBounceAnnimationToView:(MKAnnotationView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 4; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)addDropAnnimationToView:(MKAnnotationView *)view withDelay:(NSInteger) delay
{
    CGRect endFrame = view.frame;
    
    // Move annotation out of view
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
    
    // Animate drop
    [UIView animateWithDuration:0.5 delay:0.04*delay options:UIViewAnimationOptionCurveLinear animations:^{
        view.frame = endFrame;
        
        // Animate squash
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.05 animations:^{
                view.transform = CGAffineTransformMakeScale(1.0, 0.8);
                
            }completion:^(BOOL finished){
                [UIView animateWithDuration:0.1 animations:^{
                    view.transform = CGAffineTransformIdentity;
                }completion:^(BOOL finished){
                    if (wasAnyLeadButtonSelectedWhenMapTap) {
                        [self.mapView selectAnnotation:view.annotation animated:YES];
                    }
                }];
            }];
        }
    }];

}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    self.leadToEdit = view.annotation;
    if ([self shouldPerformSegueWithIdentifier:@"MapToLeadDetail" sender:self]) {
        [self performSegueWithIdentifier:@"MapToLeadDetail" sender:self];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapClusteringOperationQueue addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.quadTreeController clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

#pragma mark - Callout Delegate Methods

- (NSTimeInterval)calloutView:(SRCalloutView *)calloutView delayForRepositionWithSize:(CGSize)offset {
    
    // When the callout is being asked to present in a way where it or its target will be partially offscreen, it asks us
    // if we'd like to reposition our surface first so the callout is completely visible. Here we scroll the map into view,
    // but it takes some math because we have to deal in lon/lat instead of the given offset in pixels.
    
    CLLocationCoordinate2D coordinate = self.mapView.centerCoordinate;
    
    // where's the center coordinate in terms of our view?
    CGPoint center = [self.mapView convertCoordinate:coordinate toPointToView:self.view];
    
    // move it by the requested offset
    center.x -= offset.width;
    center.y -= offset.height;
    
    // and translate it back into map coordinates
    coordinate = [self.mapView convertPoint:center toCoordinateFromView:self.view];
    
    // move the map!
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    
    // tell the callout to wait for a while while we scroll (we assume the scroll delay for MKMapView matches UIScrollView)
    return kSRCalloutViewRepositionDelayForUIScrollView;
}

#pragma mark - IBAction methods
#pragma mark Map IBAction Methods

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    wasAnyLeadButtonSelectedWhenMapTap = NO;
    
    // Go Back
    if (self.goBackButton.selected) {
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kGoBack atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.goBackButton.selected = NO;
    }
    // Callback
    else if (self.callbackButton.selected){
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kCallback atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.callbackButton.selected = NO;
    }
    // Not Home
    else if (self.notHomeButton.selected){
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kNotHome atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.notHomeButton.selected = NO;
    }
    // Not Interested
    else if (self.notInterestedButton.selected){
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kNotInterested atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.notInterestedButton.selected = NO;
    }
    // Customer
    else if (self.customerButton.selected){
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kCustomer atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.customerButton.selected = NO;
    }
    // Other
    else if (self.otherButton.selected){
        wasAnyLeadButtonSelectedWhenMapTap = YES;
        [self createLeadOfStatus:kOther atCoordinate:touchMapCoordinate];
        self.animateAnnotationUpdates = YES;
        self.otherButton.selected = NO;
    }
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case MapTypeStandardIndex:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case MapTypeHybridIndex:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case MapTypeSatelliteIndex:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}

- (IBAction)trackingModePressed:(UIButton *)sender {
    
    if (self.mapView.userTrackingMode == MKUserTrackingModeNone) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollow){
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
    else if (self.mapView.userTrackingMode == MKUserTrackingModeFollowWithHeading){
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

#pragma mark Lead IBAction Methods

- (IBAction)leadTypeButtonPressed:(UIButton *)sender {
    
    BOOL buttonWasSelected = sender.selected;
    
    // Only one button can be selected at a time
    self.goBackButton.selected = NO;
    self.callbackButton.selected = NO;
    self.notHomeButton.selected = NO;
    self.notInterestedButton.selected = NO;
    self.customerButton.selected = NO;
    self.otherButton.selected = NO;
    
    sender.selected = !buttonWasSelected;
}

# pragma mark - Manage Map Annotations Methods

- (void)createLeadOfStatus:(NSString *) status atCoordinate:(CLLocationCoordinate2D) coordinate{
    
    // Creates Lead
    Lead *newLead = [Lead newLead];
    newLead.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    newLead.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    newLead.saved = @YES;
    newLead.status = status;
    newLead.dateCreated = [NSDate date];
    if (!newLead.latitude || !newLead.longitude) {
        [[[SRGlobalState singleton] managedObjectContext] deleteObject:newLead];
        return;
    }
    
    [self.mapView addAnnotation:newLead];
    
    [newLead setAddressFromCoordinateWithCompletionHandler:^(BOOL success, Lead *lead, NSError *error) {
        //sync leads regardless of success status
        [[SRSalesServiceCalls singleton] sync];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kUpdatedLeads:@[lead]}];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:@{kAddedLeads:@[newLead]}];
}

- (void) fetchUserLeads
{
    // Only fetches those leads with a both latitude, longitude and current userID to display on the map as annotations
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Lead"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"latitude != nil AND longitude != nil AND userId = %@", [[SRGlobalState singleton] userId]];
    
    NSError *error = nil;
    NSArray *coreDataAnnotations = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    self.visibleLeadList = [[NSMutableArray alloc] initWithArray:coreDataAnnotations];
}

- (void) updateAllAnnotations{
    
    [self fetchUserLeads];
    
    [self.quadTreeController buildTree:self.visibleLeadList];
    
    [self queryAnnotations];
}

- (void)queryAnnotations
{
    
    [self.mapClusteringOperationQueue addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.quadTreeController clusteredAnnotationsWithinMapRect:self.mapView.visibleMapRect withZoomScale:scale];
        
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];

    
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
        [before removeObject:[self.mapView userLocation]];
        NSSet *after = [NSSet setWithArray:annotations];
        
        NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
        [toKeep intersectSet:after];
        
        NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
        [toAdd minusSet:toKeep];
        
        NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
        [toRemove minusSet:after];
        
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
    
}


#pragma mark - Flurry

- (void) flurryTrack {
//    NSString *username = [[(AppDelegate.h *)[[UIApplication sharedApplication] delegate] SRGlobalState] userName];
//    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
//    
//    [Flurry logEvent:@"Maps view opened" withParameters:articleParams timed:YES];
}

#pragma mark - Lead List Visible
- (BOOL)isLeadListVisible {
    return self.viewControl.selectedSegmentIndex == ListSegmentIndex;
}


#pragma mark - Custom Getters
- (SRUserType)userType
{
    NSInteger type = [[[SRGlobalState singleton] userType] integerValue];
    if (type == 1) {
        return SRUserTypeRep;
    }
    else if (type == 3){
        return SRUserTypeManager;
    }
    else if (type == 5){
        return SRUserTypeRegional;
    }
    else if (type == 12){
        return SRUserTypeAdmin;
    }
    else{
        return SRUserTypeDeveloper;
    }
}


@end
