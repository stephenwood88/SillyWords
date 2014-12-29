//
//  SRPremiumMapViewController.m
//  Dish Sales
//
//  Created by Raul Lopez Villalpando on 12/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRPremiumMapViewController.h"
#import "SRPremiumConstants.h"
#import "SRPremiumSalesServiceCalls.h"
#import "SRLeadDetailTableViewController.h"
#import "Constants.h"
#import "SRDataPoint.h"
#import "UserLocation.h"
#import "UserLocation+Rabbit.h"
#import "SRUserLocationAnnotationView.h"
#import "SRLocationTracker.h"
#import "Office+Rabbit.h"
#import "User+Rabbit.h"
#import "Region+Rabbit.h"
#import "Department+Rabbit.h"
#import "Area+Rabbit.h"
#import "MapPoint+Rabbit.h"
#import "SlimLead+Rabbit.h"
#import "AVSelectionListController.h"
#import "AVSimpleDatePickerController.h"
#import "SRSalesConstants.h"
#import "UIImage+TintColor.h"
#import "Address+Rabbit.h"
#import "Prequal+Rabbit.h"

const float kgravityValue = 3;

#define MAPTAB 1
#define MANAGERTAB 2
#define LEADSTAB 3

@interface SRPremiumMapViewController ()
{
    //****Instance Variables to avoid to much overhead when drawing*******
    BOOL drawMode;
    BOOL saveMode;
    BOOL updateMode;
    BOOL mouseSwiped;
    BOOL navViewHidden;
    BOOL dragMode;
    //For UIKit Dynamics Collisions
    float TOP_BOUNDARY;
    float SMALL_TOP_BOUNDARY;
    float BOTTOM_BOUNDARY;
    float SMALL_BOTTOM_BOUNDARY;
    float HIDDEN_TOP_BOUNDARY;
    //////////////////////
    NSInteger navViewTab;
    CGPoint lastPoint;
    CGPoint startPoint;
    NSOrderedSet *pointsSet;
    Area *areaToAdd;
    MKPolygon *polygonToAdd;
}

// Area Managment for rendering, selecting and drawing areas
@property (nonatomic, strong) NSMutableArray *dataPoints;
@property (nonatomic, strong) MKPolygonRenderer *selectedPolygon;
@property (nonatomic, strong) Area *currentAreaRendered; // This one is to know which area we are currently rendering so we can save the PolygonRenderer reference
@property (nonatomic, strong) Area *updateArea; // This one is to know which Area needs to be updated
@property (nonatomic, strong) Area *selectedArea; // This is to know which Area has been selected
@property (nonatomic, strong) Area *repActiveArea; // The activeArea of the user (Even for Managers)
@property (nonatomic, strong) AVSelectionListController *officesListController;
@property (nonatomic, strong) NSArray *officesList;

//Core Data Fetch Request
@property (nonatomic, strong) NSFetchRequest *areaRequest;
@property (nonatomic, strong) NSFetchRequest *userRequest;

// UIKit Dynamics

@property (strong, nonatomic) UIDynamicAnimator *navigationAnimator;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehaviour;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@property (strong, nonatomic) UIPanGestureRecognizer *tabNavPanGestureRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *tabNavTapGestureRecognizer;

// Filters

@property (strong, nonatomic) AVSelectionListController *quickDateFilterView;
@property (strong, nonatomic) AVSelectionListController *repsFilterView;
@property (strong, nonatomic) AVSimpleDatePickerController *fromDateFilterView;
@property (strong, nonatomic) AVSimpleDatePickerController *toDateFilterView;
@property (strong, nonatomic) UIActionSheet *filterActionSheet;
@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *availableRepsNames;
@property (strong, nonatomic) NSArray *availableReps;
@property (nonatomic, strong) NSMutableArray *visibleAreaArray;
@property (nonatomic, strong) NSMutableArray *visibleUserLocations;
@property (nonatomic, strong) NSMutableArray *visiblePrequal;
@property (strong, nonatomic) NSMutableArray *visibleSlimLeads;
@property (strong, nonatomic) NSMutableArray *visibleReps;
@property (strong, nonatomic) UIPopoverController *filterPopOver;
@property (weak, nonatomic) UIView *filterPopOverView;

//Misc

@property (strong, nonatomic) UIActivityIndicatorView *managerTabActivityIndicator;

@end

@implementation SRPremiumMapViewController

#pragma mark - View Cycle Methods and Actions

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersChanged:) name:kUsersChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areasChanged:) name:kAreasChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentChanged) name:kDepartmentChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncUserMapFinished) name:kSyncUserMapFinishedNotification object:nil];
    if ([[SRGlobalState singleton] prequalEnabled]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prequalsChanged:) name:kPrequalsChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePrequal:) name:kPrequalConvertedToLead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePrequalAnnotations) name:kDeletedAllPrequalsForCurrentUserId object:nil];
    }
    
    //Core Data Fetch Request
    self.areaRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    self.userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    [self fetchAvailableUsers];
    [self fetchAvailableOffices];
    
    //Map Drawing set up
    self.drawView.path = [UIBezierPath bezierPath];
    self.drawView.path.lineWidth = 2;
    self.dataPoints = [[NSMutableArray alloc] init];
    self.visibleAreaArray = [[NSMutableArray alloc] init];
    drawMode = NO;
    saveMode = NO;
    updateMode = NO;
    [self. mapView addGestureRecognizer:self.mapTouchGesture];
    
    //UI Kit Dynamics
    self.tabNavPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragToHide:)];
    self.tabNavPanGestureRecognizer.delegate = self;
    [self.tabNavView addGestureRecognizer:self.tabNavPanGestureRecognizer];
    
    self.tabNavTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabNavViewTapped:)];
    self.tabNavTapGestureRecognizer.delegate = self;
    [self.tabNavView addGestureRecognizer:self.tabNavTapGestureRecognizer];
    
    //Initial Set up
    
    self.showRepActiveAreaSwitch.on = YES;
    self.showRepAreasSwitch.on = NO;
    
    //Filters
    
    self.visibleReps = [[NSMutableArray alloc] initWithArray:self.availableReps]; // At the beggining they are all selected by default
    
    NSMutableDictionary *selectedReps = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.visibleReps.count; i++) {
        User *tempUser = [self.visibleReps objectAtIndex:i];
        [selectedReps setObject:[NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName] forKey:[NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName]];
    }
    self.repsFilterView = [[AVSelectionListController alloc] initWithContentList:self.availableRepsNames selectedContentDictionary:selectedReps delegate:self allName:[NSString stringWithFormat:@"%@ %@",kAll, kSelected]];
    [self.repsFilterView selectItem:[NSString stringWithFormat:@"%@ %@",kAll, kSelected]];
    [self.repsFilterView allowNoSelection:YES];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.quickDateFilterView = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:self.customDateManagerButton contentList:kReportsQuickDates noSelectionTitle:nil];
    self.quickDateFilterView.selectionIndex = -1;
    [self.quickDateFilterView selectItem:kToday];
    
    self.fromDateFilterView = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.fromDateManagerButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:[NSDate date]];
    [self.fromDateFilterView setPickerDate:[NSDate date]];
    
    self.toDateFilterView = [[AVSimpleDatePickerController alloc] initWithDelegate:self sourceButton:self.toDateManagerButton datePickerMode:AVDatePickerModeDate date:[NSDate date] minuteInterval:1 minimumDate:nil maximumDate:nil];
    [self.toDateFilterView setPickerDate:[NSDate date]];
    
    // Offices when creating a new Area for Admins and Regionals
    if (self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional) {
        NSMutableArray *officeNames = [NSMutableArray array];
        
        for (int i=0; i<self.officesList.count; i++) {
            [officeNames addObject:[[self.officesList objectAtIndex:i] name]];
        }
        
        self.officesListController = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:nil contentList:officeNames noSelectionTitle:nil];
        self.officesListController = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:nil contentList:officeNames noSelectionTitle:@"Cancel"];
        self.officesListController.selectionIndex = -1;
    }
    //UI Set Up for Tab Nav View
    self.leadNavView.hidden = YES;
    self.mapNavView.hidden = NO;
    self.areaManagmentNavView.hidden = YES;
    //** Buttons Config
    UIImage *drawImage = [[self.areaPinButton imageForState:UIControlStateNormal] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    UIImage *drawImageSelected =[[self.areaPinButton imageForState:UIControlStateSelected] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    [self.areaPinButton setImage:drawImage forState:UIControlStateNormal];
    [self.areaPinButton setImage:drawImageSelected forState:UIControlStateSelected];
    self.areaPinButton.backgroundColor = [UIColor clearColor];
    
    UIImage *managementImage = [[self.managerTabButton imageForState:UIControlStateNormal] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    UIImage *managementImageSelected =[[self.managerTabButton imageForState:UIControlStateSelected] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    [self.managerTabButton setImage:managementImage forState:UIControlStateNormal];
    [self.managerTabButton setImage:managementImageSelected forState:UIControlStateSelected];
    
    UIImage *mapTabImage = [[self.mapTabButton imageForState:UIControlStateNormal] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    UIImage *mapTabImageSelected = [[self.mapTabButton imageForState:UIControlStateSelected] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    [self.mapTabButton setImage:mapTabImage forState:UIControlStateNormal];
    [self.mapTabButton setImage:mapTabImageSelected forState:UIControlStateSelected];
    
    UIImage *leadTabImage = [[self.leadTabButton imageForState:UIControlStateNormal] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    UIImage *LeadTabImageSelected =[[self.leadTabButton imageForState:UIControlStateSelected] tintedImageWithColor:[[SRGlobalState singleton] accentColor]];
    [self.leadTabButton setImage:leadTabImage forState:UIControlStateNormal];
    [self.leadTabButton setImage:LeadTabImageSelected forState:UIControlStateSelected];
    
    navViewTab = MAPTAB; //Default Tab
    navViewHidden = YES; // Default Nav Status
    dragMode = NO;
    
    //Setup an Activity indicator for first time login or department change
    self.managerTabActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.managerTabActivityIndicator.center = self.managerTabButton.center;
    
    [self.tabNavView addSubview:self.managerTabActivityIndicator];
    
    
    if (self.visibleReps.count > 0) {
        [self.repsManagerButton setTitle:[NSString stringWithFormat:@"%@ %@", kAll, kSelected] forState:UIControlStateNormal];
    }
    else{
        [self.repsManagerButton setTitle:[NSString stringWithFormat:@"%@", kNoSelection] forState:UIControlStateNormal];
    }
    
    [self updateVisibleAreas];
    
    //Warn The users that if no Office is assigned to the user, much of the activities on this view could not be performed correctly
    if ((![[SRGlobalState singleton] officeId] || [[[SRGlobalState singleton] officeId] isEqualToString:@"0"]) && (self.userType == SRUserTypeManager || self.userType == SRUserTypeRep)) {
        [self alertWithMessage:@"There is no Office assigned for this account. In order to perform most of the actions on the map, please visit Sales Rabbit Dashboard or reach your corresponding manager to do so." andTitle:@"Warning"];
    }
    
    
    //Disable manager features until it finishes syncing or it already has offices in case fo first log in or department change 
    if (self.officesList.count > 0 || ![self firstTimeUserMapSync]) {
        self.allowManagerFeatures = YES;
    }
    else{
        self.allowManagerFeatures = NO;
    }
    
    //Update all posible Annotations on the map like UserLeads, Rep Leads, User Locations and Prequal with Clustering optimization
    
    if ([[SRGlobalState singleton] prequalEnabled]) {
        [self updatePrequals];
    }
    [self updateVisibleAnnotations];
}

- (BOOL)firstTimeUserMapSync
{
    NSDate *lastSyncDevice = [[[[NSUserDefaults standardUserDefaults] objectForKey:kLastUserMapSyncDeviceTimestamps] objectForKey:[[SRGlobalState singleton] userId]] objectForKey:[[SRGlobalState singleton] companyId]];
    
    if (!lastSyncDevice) {
        return YES;
    }
    else{
        return NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self initializeTabNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initializeTabNavBar];
    self.tabNavView.hidden = NO;
    
    if (self.selectedArea) {
        [self.popOverController dismissPopoverAnimated:YES];
        self.selectedArea.polygonReference.lineWidth = 2;
        self.selectedArea.polygonReference.fillColor = [self.selectedArea getAreaColorWithAlpha:.3];
        [self.selectedArea.polygonReference setNeedsDisplay];
        self.selectedPolygon = nil;
        self.selectedArea = nil;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.tabNavView.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqual:@"MapToLeadDetail"]) {
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        ldtvc.leadToEdit = self.leadToEdit;
    }
    else if ([segue.identifier isEqual:@"MapToLeadDetailWithPrequal"]) {
        SRLeadDetailTableViewController *ldtvc = segue.destinationViewController;
        ldtvc.prequalForNewLead = self.selectedPrequal;
    }
    else if ([segue.identifier isEqualToString:@"addRepSegue"]) {
        SRNewRepViewController *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;
        destinationVC.selectedArea = self.selectedArea;
    }
    else if ([segue.identifier isEqualToString:@"selectedAreaSegue"]){
        SRAreaDetailedViewController *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;
        destinationVC.selectedArea = self.selectedArea;
        destinationVC.polygonToDisplay = self.selectedPolygon;
        self.detailedAreaVC = destinationVC;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

#pragma mark - Tab Nav Methods

- (void)initializeTabNavBar
{
    TOP_BOUNDARY = (self.view.frame.size.height - self.tabNavView.frame.size.height);
    BOTTOM_BOUNDARY = -(self.tabNavView.frame.size.height - self.leadTabButton.frame.size.height);
    SMALL_BOTTOM_BOUNDARY = -(self.tabNavView.frame.size.height - self.leadTabButton.frame.size.height)/2;
    SMALL_TOP_BOUNDARY = (self.view.frame.size.height - ((self.tabNavView.frame.size.height - self.leadTabButton.frame.size.height)/2 + self.leadTabButton.frame.size.height));
    
    
    // Set all the UIKitDynamic Behaviors
    self.navigationAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.tabNavView]];
    
    
    // Check the state to see if the navTabView was hidden or not
    if (navViewHidden) {
        self.tabNavView.frame = CGRectMake(0, self.view.frame.size.height, self.tabNavView.frame.size.width, self.tabNavView.frame.size.height);
        [self.view setNeedsDisplay];
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
    }
    else{
        if (navViewTab == MANAGERTAB) {
            self.tabNavView.frame = CGRectMake(0, self.view.frame.size.height - self.tabNavView.frame.size.height, self.tabNavView.frame.size.width, self.tabNavView.frame.size.height);
            [self.view setNeedsDisplay];
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
        }
        else if(navViewTab == LEADSTAB || navViewTab == MAPTAB){
            self.tabNavView.frame = CGRectMake(0, self.view.frame.size.height - (self.tabNavView.frame.size.height - (self.tabNavView.frame.size.height - self.mapTabButton.frame.size.height)/2), self.tabNavView.frame.size.width, self.tabNavView.frame.size.height);
            [self.view setNeedsDisplay];
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
        }
    }
    
    [self.navigationAnimator addBehavior:self.collisionBehavior];
    
    //Hide or show tabs depending on the type of user
    float tabWidth = self.mapTabButton.frame.size.width;
    float tabHeight = self.mapTabButton.frame.size.height;
    float tabSection = self.view.frame.size.width/3;
    int offset = 30;
    
    NSString *officeId = [[SRGlobalState singleton] officeId];
    //Admins, Regionals, and Developers should always see the Manager pane
    if ((self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional || self.userType == SRUserTypeDeveloper) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        self.mapTabButton.frame = CGRectMake(tabSection - offset, 0, tabWidth, tabHeight);
        self.leadTabButton.frame = CGRectMake(self.view.frame.size.width/2 - tabWidth/2, 0, tabWidth, tabHeight);
        self.managerTabButton.frame = CGRectMake(tabSection*2 + offset - tabWidth, 0, tabWidth, tabHeight);
    }
    //Don't show the manager pane if the users is Rep or a Manager not in an office
    else if (self.userType == SRUserTypeRep || (self.userType == SRUserTypeManager && (!officeId || [officeId isEqualToString:@"0"])))
    {
        self.mapTabButton.frame = CGRectMake(self.view.frame.size.width/2 - (tabWidth + offset/2), 0, tabWidth, tabHeight);
        self.leadTabButton.frame = CGRectMake(self.view.frame.size.width/2 + offset/2, 0, tabWidth, tabHeight);
        self.managerTabButton.hidden = YES;
    }
    //If the user isn't in an office, hide their show my area switch and hide the label as well
    if (!officeId || [officeId isEqualToString:@"0"]) {
        self.repActiveAreaSwitchLabel.hidden = YES;
        self.goToActiveAreaButton.hidden = YES;
        self.showRepActiveAreaSwitch.hidden = YES;
    }
    
    // Keep setting the UIKitDynamicBehaviors
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.tabNavView]];
    if (navViewHidden) {
        self.gravityBehavior.gravityDirection = CGVectorMake(0.0, 1.0);
    }
    else
    {
        self.gravityBehavior.gravityDirection = CGVectorMake(0.0, -1.0);
    }
    
    self.gravityBehavior.magnitude = kgravityValue;
    [self.navigationAnimator addBehavior:self.gravityBehavior];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.tabNavView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0;
    self.pushBehavior.angle = 0.0;
    [self.navigationAnimator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.tabNavView]];
    itemBehavior.elasticity = .2;
    itemBehavior.allowsRotation = NO;
    [self.navigationAnimator addBehavior:itemBehavior];
    
    //Align activity indicator 
    self.managerTabActivityIndicator.center = self.managerTabButton.center;
}

#pragma mark - Warning Methods

- (void)alertWithMessage:(NSString *)message andTitle:(NSString *)title
{
    UIAlertView *noOfficeAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [noOfficeAlert show];
}

#pragma mark - Manager Control IBActions

- (void)tabNavViewTapped:(UIGestureRecognizer *) sender
{
    [self dismissFilterPopOver];
}

- (void)dragToHide:(UIScreenEdgePanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    CGPoint draggingLocation = [sender locationInView:self.tabNavView];
    location.x = CGRectGetMidX(self.tabNavView.bounds);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        dragMode = YES;
        
        //First Change The Tab and set the boundaries for dragging
        if (CGRectContainsPoint(self.mapTabButton.frame, draggingLocation)) {
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            
            navViewTab = MAPTAB;
            self.mapTabButton.selected = YES;
            self.leadTabButton.selected = NO;
            self.managerTabButton.selected = NO;
            
            self.mapNavView.hidden = NO;
            self.leadNavView.hidden = YES;
            self.areaManagmentNavView.hidden = YES;
        }
        else if (CGRectContainsPoint(self.leadTabButton.frame, draggingLocation)){
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            
            navViewTab = LEADSTAB;
            self.mapTabButton.selected = NO;
            self.leadTabButton.selected = YES;
            self.managerTabButton.selected = NO;
            
            self.mapNavView.hidden = YES;
            self.leadNavView.hidden = NO;
            self.areaManagmentNavView.hidden = YES;
        }
        else if (CGRectContainsPoint(self.managerTabButton.frame, draggingLocation)){
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            
            navViewTab = MANAGERTAB;
            self.mapTabButton.selected = NO;
            self.leadTabButton.selected = NO;
            self.managerTabButton.selected = YES;
            
            self.mapNavView.hidden = YES;
            self.leadNavView.hidden = YES;
            self.areaManagmentNavView.hidden = NO;
        }
        else if (draggingLocation.y > self.mapTabButton.frame.size.height)
        {
            //Dragging from the tabNavView, set the collision boundaries according to the tab being dragged
            if (navViewTab == MAPTAB || navViewTab == LEADSTAB) {
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            }
            else if (navViewTab == MANAGERTAB)
            {
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            }
        }
        else
        {
            //If it is not dragging from eithre the buttons or the navigation bar don't allow dragging from anywhere else
            dragMode = NO;
        }
        
        if (dragMode) {
            [self dismissFilterPopOver];
            
            [self.navigationAnimator removeBehavior:self.gravityBehavior];
            
            self.panAttachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self.tabNavView attachedToAnchor:location];
            [self.navigationAnimator addBehavior:self.panAttachmentBehaviour];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged && dragMode) {
        self.panAttachmentBehaviour.anchorPoint = location;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && dragMode) {
        [self.navigationAnimator removeBehavior:self.panAttachmentBehaviour];
        self.panAttachmentBehaviour = nil;
        
        CGPoint velocity = [sender velocityInView:self.tabNavView];
        
        //Checking for the direction of the dragging
        if (velocity.y > 0) {
            navViewHidden = YES;
            
            self.mapTabButton.selected = NO;
            self.leadTabButton.selected = NO;
            self.managerTabButton.selected = NO;
            
            self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
        }
        else {
            navViewHidden = NO;
            self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
        }
        
        self.gravityBehavior.magnitude = kgravityValue;
        [self.navigationAnimator addBehavior:self.gravityBehavior];
        
        self.pushBehavior.pushDirection = CGVectorMake(0, velocity.y / 10.0f);
        self.pushBehavior.active = YES;
        dragMode = NO;
        
        if (drawMode) {
            [self setDrawMode:NO];
        }
    }
    
}

- (IBAction)tabButtonPressed:(UIButton *)sender {
    
    if (drawMode) {
        [self setDrawMode:NO];
    }
    
    if(self.filterPopOver)
    {
        [self dismissFilterPopOver];
    }
    
    //Deselect All Buttons from leads
    self.goBackButton.selected = NO;
    self.callbackButton.selected = NO;
    self.notHomeButton.selected = NO;
    self.notInterestedButton.selected = NO;
    self.otherButton.selected = NO;
    self.customerButton.selected = NO;
    
    if (sender == self.leadTabButton) {
        if (navViewTab == LEADSTAB || navViewHidden) { //Reselected the Tab either hide it or completely display
            if (navViewHidden) {
                self.leadTabButton.selected = YES;
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
                self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = NO;
            }
            else{
                self.leadTabButton.selected = NO;
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
                self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = YES;
            }
        }
        else if (navViewTab == MANAGERTAB && !navViewHidden){ //otherwise if there needs to be resizing, do it
            self.leadTabButton.selected = YES;
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, SMALL_BOTTOM_BOUNDARY, 0)];
            self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
            self.gravityBehavior.magnitude = kgravityValue;
        }
        else{
            self.leadTabButton.selected = YES;
        }
        navViewTab = LEADSTAB;
        self.mapNavView.hidden = YES;
        self.mapTabButton.selected = NO;
        self.leadNavView.hidden = NO;
        self.areaManagmentNavView.hidden = YES;
        self.managerTabButton.selected = NO;
    }
    else if(sender == self.managerTabButton){
        if (navViewTab == MANAGERTAB || navViewHidden) {
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
            if (navViewHidden) {
                self.managerTabButton.selected = YES;
                self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = NO;
            }
            else{
                self.managerTabButton.selected = NO;
                self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = YES;
            }
        }
        else if (navViewTab == LEADSTAB || navViewTab == MAPTAB){
            self.managerTabButton.selected = YES;
            self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
            self.gravityBehavior.magnitude = kgravityValue;
        }
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
        navViewTab = MANAGERTAB;
        self.mapNavView.hidden = YES;
        self.mapTabButton.selected = NO;
        self.leadNavView.hidden = YES;
        self.leadTabButton.selected = NO;
        self.areaManagmentNavView.hidden = NO;
    }
    else if(sender == self.mapTabButton){
        if (navViewTab == MAPTAB || navViewHidden) {
            if (navViewHidden) {
                self.mapTabButton.selected = YES;
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
                self.gravityBehavior.gravityDirection = CGVectorMake(0, -1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = NO;
            }
            else{
                self.mapTabButton.selected = NO;
                [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(SMALL_TOP_BOUNDARY, 0, BOTTOM_BOUNDARY, 0)];
                self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
                self.gravityBehavior.magnitude = kgravityValue;
                navViewHidden = YES;
            }
        }
        else if (navViewTab == MANAGERTAB && !navViewHidden){
            self.mapTabButton.selected = YES;
            [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(TOP_BOUNDARY, 0, SMALL_BOTTOM_BOUNDARY, 0)];
            self.gravityBehavior.gravityDirection = CGVectorMake(0, 1);
            self.gravityBehavior.magnitude = kgravityValue;
        }
        else{
            self.mapTabButton.selected = YES;
        }
        navViewTab = MAPTAB;
        self.mapNavView.hidden = NO;
        self.leadNavView.hidden = YES;
        self.leadTabButton.selected = NO;
        self.areaManagmentNavView.hidden = YES;
        self.managerTabButton.selected = NO;
    }
}

- (IBAction)repsManagerButtonPressed:(id)sender
{
    [self fetchAvailableUsers];
    NSMutableDictionary *selectedReps = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.visibleReps.count; i++) {
        User *tempUser = [self.visibleReps objectAtIndex:i];
        [selectedReps setObject:[NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName] forKey:[NSString stringWithFormat:@"%@ %@", tempUser.firstName, tempUser.lastName]];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:self.repsFilterView];
    }
    else{
        [self createPopover:sender popoverView:self.repsFilterView];
    }
    
    if (drawMode) {
        [self setDrawMode:NO];
    }
}

- (IBAction)fromDateManagerButtonPressed:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:self.fromDateFilterView];
    }
    else{
        [self createPopover:sender popoverView:self.fromDateFilterView];
    }
    
    if (drawMode) {
        [self setDrawMode:NO];
    }
}

- (IBAction)toDateManagerButtonPressed:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:self.toDateFilterView];
    }
    else{
        [self createPopover:sender popoverView:self.toDateFilterView];
    }
    
    if (drawMode) {
        [self setDrawMode:NO];
    }
}

- (IBAction)customDateManagerButtonPressed:(id)sender
{
    if ([[self.customDateManagerButton titleForState:UIControlStateNormal] isEqual:kCustom]) {
        self.quickDateFilterView.selectionIndex = -1;
        [self.quickDateFilterView reloadList];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self createActionSheet:sender sheetView:self.quickDateFilterView];
    }
    else{
        [self createPopover:sender popoverView:self.quickDateFilterView];
    }
    
    if (drawMode) {
        [self setDrawMode:NO];
    }
}

- (IBAction)areaPinButtonPressed:(id)sender
{
    //Switch
    if (!self.showRepAreasSwitch.on) {
        [self.showRepAreasSwitch setOn:YES animated:YES];
        [self showRepAreasChanged:self.showRepAreasSwitch];
    }
    
    if ([self.areaPinButton isSelected]) {
        [self.view insertSubview:self.mapView aboveSubview:self.drawView];
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled = YES;
        self.areaPinButton.selected = NO;
        drawMode = NO;
    }
    else{
        [self.view insertSubview:self.drawView aboveSubview:self.mapView];
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.areaPinButton.selected = YES;
        drawMode = YES;
    }
}

- (IBAction)goToActiveAreaButtonPressed:(id)sender {
    
    if (self.repActiveArea) {
        //CLLocationCoordinate2D centroid = self.repActiveArea.polygonReference.polygon.coordinate;
        
        NSArray *mappoints = [self.repActiveArea.mapPoints array];
        CLLocationDegrees latitude = 0.0;
        CLLocationDegrees longitude = 0.0;
        
        for (int i=0; i<mappoints.count; i++) {
            latitude += [[mappoints[i] latitude] doubleValue];
            longitude += [[mappoints[i] longitude] doubleValue];
        }
        
        latitude = latitude/mappoints.count;
        longitude = longitude/mappoints.count;
        
        CLLocationCoordinate2D centroid = CLLocationCoordinate2DMake(latitude, longitude);
        
        MKCoordinateRegion activeAreaRegion = MKCoordinateRegionMakeWithDistance(centroid, 4000, 4000);
        
        [self.mapView setRegion:activeAreaRegion animated:YES];
    }
    else{
        
        UIAlertView *noAreaAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"No active area currently assigned found." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noAreaAlert show];
        
    }
}

- (void)setDrawMode:(BOOL)mode
{
    if (mode) {
        [self.view insertSubview:self.drawView aboveSubview:self.mapView];
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.areaPinButton.selected = YES;
        drawMode = YES;
    }
    else{
        [self.view insertSubview:self.mapView aboveSubview:self.drawView];
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled = YES;
        self.areaPinButton.selected = NO;
        drawMode = NO;
    }
}

- (IBAction)showRepLocationsChanged:(id)sender
{
    // Add Rep Tracking Annotations to MapView
    if (self.showRepLocationsSwitch.on)
    {
        [self updateVisibleRepLocations];
        [self queryAnnotations];
    }
    //Remove Rep Tracking Annotations from MapView
    else
    {
        [self removeAnnotationsForClass:[UserLocation class]];
        [self queryAnnotations];
    }
}

- (IBAction)showRepLeadsChanged:(id)sender
{
    if (((UISwitch *)sender).on)
    {
        [self updateVisibleSlimLeads];
        [self queryAnnotations];
    }
    else
    {
        [self removeAnnotationsForClass:[SlimLead class]];
        [self queryAnnotations];
    }
}

- (IBAction)showRepAreasChanged:(id)sender
{
    [self dismissFilterPopOver];
    
    if (((UISwitch *)sender).on) {
        [self updateVisibleAreas];
    }
    else
    {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self updateVisibleAreas];
        
        if (drawMode) {
            [self setDrawMode:NO];
        }
    }
}

- (IBAction)showRepActiveAreaChanged:(id)sender
{
    if (((UISwitch *)sender).on) {
        [self updateVisibleAreas];
        self.goToActiveAreaButton.enabled = YES;
    }
    else if(!self.showRepAreasSwitch.on)
    {
        [self.visibleAreaArray removeObject:self.repActiveArea];
        [self.mapView removeOverlay:self.repActiveArea.overlayReference];
        //[self updateMapOverlays];
        self.goToActiveAreaButton.enabled = NO;
    }
}

#pragma mark - Algorithm for Polygon Minimum Points Optimization (Douglar-Pecker Reduction Algorithm)

// It returns an array of the indeces of the points to keep

- (NSMutableArray *)douglasPeuckerReduction:(NSMutableArray *)points withTolerance:(double)tolerance
{
    if (points == nil || [points count] < 3)
        return points;
    
    NSUInteger firstDataPoint = 0;
    NSUInteger lastDataPoint = [points count] - 1;
    
    NSMutableArray * pointIndicesToKeep = [[NSMutableArray alloc] init];
    
    //Add the first and last index to the keepers
    [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:firstDataPoint]];
    [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:lastDataPoint]];
    
    //The first and the last point cannot be the same
    while ([[points objectAtIndex:firstDataPoint] equalsTo:[points objectAtIndex:lastDataPoint]])
    {
        lastDataPoint--;
    }
    
    NSMutableArray * pointsToKeep = [self douglasPeuckerReduction:points withFirstPoint:firstDataPoint lastPoint:lastDataPoint andTolerance:tolerance];
    [pointIndicesToKeep addObjectsFromArray:pointsToKeep];
    
    // Sort the points.
    NSSortDescriptor * sortOptions = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(compare:)];
    [pointIndicesToKeep sortUsingDescriptors:[NSArray arrayWithObject:sortOptions]];
    
    return pointIndicesToKeep;
}

- (NSMutableArray *)douglasPeuckerReduction:(NSMutableArray *)points withFirstPoint:(NSUInteger)firstDataPoint lastPoint:(NSUInteger)lastDataPoint andTolerance:(double)tolerance
{
    NSMutableArray * pointIndicesToKeep = [[NSMutableArray alloc] init];
    
    double maxDistance = 0;
    NSUInteger indexFarthest = 0;
    
    for (NSUInteger index = firstDataPoint; index < lastDataPoint; index++)
    {
        double distance = [self perpendicularDistanceOf:[points objectAtIndex:index] from:[points objectAtIndex:firstDataPoint] to:[points objectAtIndex:lastDataPoint]];
        
        
        if (distance > maxDistance)
        {
            maxDistance = distance;
            indexFarthest = index;
        }
    }
    
    if (maxDistance > tolerance && indexFarthest != 0)
    {
        //Add the largest point that exceeds the tolerance
        [pointIndicesToKeep addObject:[NSNumber numberWithUnsignedInteger:indexFarthest]];
        
        NSMutableArray * leftSide = [self douglasPeuckerReduction:points withFirstPoint:firstDataPoint lastPoint:indexFarthest andTolerance:tolerance];
        NSMutableArray * rightSide = [self douglasPeuckerReduction:points withFirstPoint:indexFarthest lastPoint:lastDataPoint andTolerance:tolerance];
        
        [pointIndicesToKeep addObjectsFromArray:leftSide];
        [pointIndicesToKeep addObjectsFromArray:rightSide];
    }
    
    return pointIndicesToKeep;
}

- (double)perpendicularDistanceOf:(SRDataPoint *)point from:(SRDataPoint *)pointA to:(SRDataPoint *)pointB
{
    //Area = |(1/2)(x1y2 + x2y3 + x3y1 - x2y1 - x3y2 - x1y3)|   *Area of triangle
    //Base = v((x1-x2)²+(x1-x2)²)                               *Base of Triangle*
    //Area = .5*Base*H                                          *Solve for height
    //Height = Area/.5/Base
    
    double area = fabs(.5 * (pointA.x * pointB.y + pointB.x *
                             point.y + point.x * pointA.y - pointB.x * pointA.y - point.x *
                             pointB.y - pointA.x * point.y));
    double bottom = sqrt(pow(pointA.x - pointB.x, 2) +
                         pow(pointA.y - pointB.y, 2));
    double height = area / bottom * 2;
    
    return height;
}

#pragma mark - Centroid for Polygon

- (SRDataPoint *)getPolygonCentroid:(NSMutableArray *)pts{
    SRDataPoint *centroid = [[SRDataPoint alloc] init];
    centroid.x = 0;
    centroid.y = 0;
    CGFloat signedArea = 0.0;
    CGFloat x0 = 0.0; // Current vertex X
    CGFloat y0 = 0.0; // Current vertex Y
    CGFloat x1 = 0.0; // Next vertex X
    CGFloat y1 = 0.0; // Next vertex Y
    CGFloat a = 0.0;  // Partial signed area
    
    // For all vertices except last
    int i;
    for (i=0; i<pts.count-1; ++i)
    {
        x0 = [[pts objectAtIndex:i] x];
        y0 = [[pts objectAtIndex:i] y];
        x1 = [[pts objectAtIndex:i+1] x];
        y1 = [[pts objectAtIndex:i+1] y];
        a = x0*y1 - x1*y0;
        signedArea += a;
        centroid.x += (x0 + x1)*a;
        centroid.y += (y0 + y1)*a;
    }
    
    // Do last vertex
    x0 = [[pts objectAtIndex:i] x];
    y0 = [[pts objectAtIndex:i] y];
    x1 = [[pts objectAtIndex:0] x];
    y1 = [[pts objectAtIndex:0] y];
    a = x0*y1 - x1*y0;
    signedArea += a;
    centroid.x += (x0 + x1)*a;
    centroid.y += (y0 + y1)*a;
    
    signedArea *= 0.5;
    centroid.x /= (6.0*signedArea);
    centroid.y /= (6.0*signedArea);
    
    return centroid;
}

#pragma mark - Touch Event Methods for Drawing an Area

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = NO;
    if (drawMode) {
        UITouch *touch = [touches anyObject];
        lastPoint = [touch locationInView:self.drawView];
        startPoint = lastPoint;
        
        [self.drawView.path moveToPoint:startPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = YES;
    if (drawMode) {
        
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.drawView];
        
        [self.drawView.path addLineToPoint:currentPoint];
        [self.drawView setNeedsDisplay];
        
        //Store all the DataPoints to draw polygon
        [self.dataPoints addObject:[[SRDataPoint alloc] initWithX:lastPoint.x andY:lastPoint.y]];
        
        lastPoint = currentPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (drawMode && self.dataPoints.count >= 3) {
        
        //Optimized the set of Data Points to use the minimum using a given tolerance
        NSMutableArray *indicesToKeep = [self douglasPeuckerReduction:self.dataPoints withTolerance:kPolygonOptimizationTolerance];
        NSMutableArray *optimizedDataPoints = [[NSMutableArray alloc] init];
        
        // The algorithm returns an array of indeces to keep. The for loop gets the actual data points from the original NSArray
        for (int i=0; i<indicesToKeep.count-1; i++)
        {
            [optimizedDataPoints addObject:[self.dataPoints objectAtIndex:[[indicesToKeep objectAtIndex:i] integerValue]]];
        }
        
        if (optimizedDataPoints.count >= 3) {
            
            //This array will store the points for the MKPolygon
            CLLocationCoordinate2D optimizedPolygonPoints[optimizedDataPoints.count];
            
            //Create a new Area
            areaToAdd = [Area newAreaWithAreaId:@"0" office:[Office officeForOfficeId:[[SRGlobalState singleton] officeId]]];
            
            //We need a temporary office or Core Data will start to go haywire and delete all kinds of stuff
            if (!areaToAdd.office) {
                [self fetchAvailableOffices];
                areaToAdd.office = [self.officesList firstObject];
            }
            
            //Converting the screen coordinates to CLLocationCoordinate2D point and also converting to MapPoint for Core Data
            for (int i = 0; i < optimizedDataPoints.count; i++)
            {
                CGPoint tmpPoint;
                SRDataPoint *tmpDataPoint = [optimizedDataPoints objectAtIndex:i];
                tmpPoint.x = tmpDataPoint.x;
                tmpPoint.y = tmpDataPoint.y;
                CLLocationCoordinate2D coord = [self.mapView convertPoint:tmpPoint toCoordinateFromView:self.mapView];
                optimizedPolygonPoints[i] = coord;
                MapPoint *tempMapPoint = [MapPoint newMapPointFromLocation:coord];
                tempMapPoint.area = areaToAdd;
            }
            
            //Add all the non-optional attributes to the new Area
            areaToAdd.dateCreated = [NSDate date];
            areaToAdd.dateModified = [NSDate date];
            areaToAdd.userId = [[SRGlobalState singleton] userId];
            areaToAdd.areaId = [Area generateTempAreaId];
            
            //Creating MKPolygon and adding it
            saveMode = YES;
            polygonToAdd = [MKPolygon polygonWithCoordinates:optimizedPolygonPoints count:optimizedDataPoints.count];
            
            //To Keep track of the area at the time the Map needs to render it
            areaToAdd.overlayReference = polygonToAdd;
            
            [self.mapView addOverlay:polygonToAdd level:MKOverlayLevelAboveLabels];
            
            //Displaying Offices to Add to the New Area
            if(self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional){
                
                [self fetchAvailableOffices];
                //Otherwise it crashes when trying to select the only office available
                if (self.officesList.count > 1) {
                    
                    NSMutableArray *officeNames = [NSMutableArray array];
                    SRDataPoint *areaCenter = [self getPolygonCentroid:optimizedDataPoints];
                    
                    for (int i=0; i<self.officesList.count; i++) {
                        [officeNames addObject:[[self.officesList objectAtIndex:i] name]];
                    }
                    
                    self.officesListController = [[AVSelectionListController alloc] initWithDelegate:self sourceButton:nil contentList:officeNames noSelectionTitle:nil];
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                        [self createActionSheet:nil sheetView:self.officesListController];
                    }
                    else{
                        [self createPopoverAt:[areaCenter point] popoverView:self.officesListController];
                    }
                    self.areaPinButton.enabled = NO;
                }
                else if([self.officesList lastObject]){
                    areaToAdd.office = [self.officesList lastObject];
                    polygonToAdd = nil;
                }
                else if(self.officesList.count == 0){
                    //Delete it from the map
                    [self deleteRecentAreaAdded];
                    
                    [self alertWithMessage:@"There are no offices related to this account. In order to add an Area, please visit Sales Rabbit Dashboard and resolve thi issue." andTitle:@"Warning"];
                }
            }
            else if (self.userType == SRUserTypeManager){
                if (!areaToAdd.office) {
                    
                    [self deleteRecentAreaAdded];
                    
                    [self alertWithMessage:@"There is no Office assigned for this account. In order to add an Area, please visit Sales Rabbit Dashboard in order to do so." andTitle:@"Warning"];

                    
                }
                
                polygonToAdd = nil;
                
                [[SRPremiumSalesServiceCalls singleton] sync];
            }
            
        }
        
        self.drawView.path = [UIBezierPath bezierPath];
        [self.drawView setNeedsDisplay];
    }
    mouseSwiped = NO;
    
    //HouseKeeping to allow for the map to be usable again and being able to draw another polygon later
    
    [self.view sendSubviewToBack:self.drawView];
    
    drawMode = NO;
    self.areaPinButton.selected = NO;
    
    self.dataPoints = [[NSMutableArray alloc] init];
    
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
}

#pragma mark - UIPopover Delegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //Deselect the area selected
    if (self.selectedPolygon) {
        self.selectedPolygon.lineWidth = 2;
        self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.3];//[[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:.3];
        [self.selectedPolygon setNeedsDisplay];
        self.selectedPolygon = nil;
    }
    
    // This is for regionals and admins in case they didn't add an office to the area they created
    if (polygonToAdd != nil && (self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional)) {
        
        //Delete it from the map
        [self.mapView removeOverlay:areaToAdd.polygonReference.overlay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // If the area id is negative that means this area hasn't been synced so it is just deleted from Core Data otherwise we add its areaId to a list of areas to be deleted in NSUserDefaults and then send that to the server to be deleted
        if (areaToAdd.areaId.integerValue > 0) {
            NSMutableArray *areaIdsToDelete = [[defaults objectForKey:kDeletedAreaIds] mutableCopy];
            [areaIdsToDelete addObject:areaToAdd.areaId];
            [defaults setObject:areaIdsToDelete forKey:kDeletedAreaIds];
            [defaults synchronize];
        }
        [[[SRGlobalState singleton] managedObjectContext] deleteObject:areaToAdd];
        
        //Delete it from the array of Core Data Area references
        [self.visibleAreaArray removeObject:areaToAdd];
        
        [[SRPremiumSalesServiceCalls singleton] sync];
        
        self.areaPinButton.enabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled = YES;
        
        polygonToAdd = nil;
        
    }
}

#pragma mark - MapView Delegation Methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    //The call to super allows any custom annotations in the parent class to be handled and then
    //we can handle other types of custom annotations here in the child class
    //If the parent class handled a custom annoation then it returns the MKAnnotationView for
    //that annotation; if that happens we just return that view.
    
    MKAnnotationView *annotationView = [super mapView:mapView viewForAnnotation: annotation];
    
    if (annotationView) {
        return annotationView;
    }
    //If the parent class didn't handle a custom annotation then the parent returns nil.
    //If that happens, custom notations may be handled in this child class.
    
    else if ([annotation isKindOfClass:[UserLocation class]]) {
        
        NSString *pinReusableIdentifier = @"UserLocationAnnotationIdentifier";
        
        SRUserLocationAnnotationView *customAnnotationView = (SRUserLocationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
        
        if (customAnnotationView == nil || ![customAnnotationView isKindOfClass:[SRUserLocationAnnotationView class]]){
            //If we fail to reuse a pin, then we will create one
            customAnnotationView =  [[SRUserLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReusableIdentifier];
        }
        else {
            customAnnotationView.annotation = annotation;
        }
        UserLocation *userLocation = (UserLocation *) annotation;
        customAnnotationView.draggable = NO;
        customAnnotationView.canShowCallout = YES;
        
        UIColor *locationAnnotationColor = [UIColor colorWithRed:[userLocation.user.red floatValue]
                                                           green:[userLocation.user.green floatValue]
                                                            blue:[userLocation.user.blue floatValue]
                                                           alpha:[userLocation.alpha floatValue]];
        customAnnotationView.image = [[UIImage imageNamed:@"leads_rep_pin.png"] tintedImageWithColor:locationAnnotationColor];
        
        customAnnotationView.opaque = NO;
        
        return customAnnotationView;
    }
    else if([annotation isKindOfClass:[SlimLead class]])
    {
        NSString *pinReusableIdentifier = @"SlimLeadAnnotationIdentifier";
        
        SRLeadAnnotationView *customAnnotationView = (SRLeadAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
        
        if (customAnnotationView == nil){
            /* If we fail to reuse a pin, then we will create one */
            customAnnotationView =  [[SRLeadAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReusableIdentifier];
        }
        else {
            customAnnotationView.annotation = annotation;
        }
        
        customAnnotationView.draggable = NO;
        customAnnotationView.canShowCallout = YES;
        //customAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customAnnotationView.tintColor = [UIColor blueColor];
        
        SlimLead *lead = (SlimLead *)annotation;
        if ([lead.status isEqual:kGoBack]){
            customAnnotationView.image = [UIImage imageNamed:@"location_green"];
        }
        else if([lead.status isEqual:kCallback]){
            customAnnotationView.image = [UIImage imageNamed:@"location_yellow"];
        }
        else if([lead.status isEqual:kNotHome]){
            customAnnotationView.image = [UIImage imageNamed:@"location_orange"];
        }
        else if([lead.status isEqual:kNotInterested]){
            customAnnotationView.image = [UIImage imageNamed:@"location_red"];
        }
        else if([lead.status isEqual:kCustomer]){
            customAnnotationView.image = [UIImage imageNamed:@"location_blue"];
        }
        else {
            customAnnotationView.image = [UIImage imageNamed:@"location_purple"];
        }
        UIImage *backgroundImage = [[UIImage imageNamed:@"slim_lead_background.png"] tintedImageWithColor:[UIColor colorWithRed:[lead.user.red floatValue] green:[lead.user.green floatValue] blue:[lead.user.blue floatValue] alpha:1.0]];
        
        customAnnotationView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        
        return customAnnotationView;
    }
    else if ([annotation isKindOfClass:[Prequal class]])
    {
        NSString *pinReusableIdentifier = @"PrequalAnnotationIdentifier";
        
        SRLeadAnnotationView *customAnnotationView = (SRLeadAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
        
        if (customAnnotationView == nil){
            /* If we fail to reuse a pin, then we will create one */
            customAnnotationView =  [[SRLeadAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReusableIdentifier];
        }
        else {
            customAnnotationView.annotation = annotation;
        }
        
        customAnnotationView.draggable = NO;
        customAnnotationView.canShowCallout = YES;
        customAnnotationView.tintColor = [UIColor blueColor];
        
        Prequal *prequal = (Prequal *)annotation;
        if ([prequal getColor]) {
            customAnnotationView.image = [[UIImage imageNamed:@"prequal_no_credit_level"] tintedImageWithColor:[prequal getColor]];
            
            UIImage *backgroundImage = [[UIImage imageNamed:@"slim_lead_background.png"] tintedImageWithColor:[UIColor colorWithWhite:0.260 alpha:1.000]];
            customAnnotationView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
            
        }
        else{
            if ([prequal.creditLevel isEqual:@"HIGH"]){
                customAnnotationView.image = [UIImage imageNamed:@"prequal_gold.png"];
            }
            else //if ([prequal.positionCertainty isEqual:@"MED"]){
            {
                customAnnotationView.image = [UIImage imageNamed:@"prequal_silver.png"];
            }
        }
        
        customAnnotationView.canShowCallout = YES;
        customAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customAnnotationView.tintColor = [UIColor blueColor];
        
        return customAnnotationView;
        
    }
    
    return nil;
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
    polygonView.lineWidth = 2;
    
    if (self.currentAreaRendered.overlayReference == overlay) {
        polygonView.strokeColor = [self.currentAreaRendered getAreaColorWithAlpha:.8];
        polygonView.fillColor = [self.currentAreaRendered getAreaColorWithAlpha:.3];
        
        //Saving the reference for the existing Area
        self.currentAreaRendered.polygonReference = polygonView;
        //** Resetting
        self.currentAreaRendered = nil;
    }
    else if(saveMode && areaToAdd.overlayReference == overlay){ // Then it means we are not rendering existing areas, it is rendering a new area so default is black
        polygonView.strokeColor = [UIColor blackColor];
        polygonView.fillColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:.3];
        
        //Saving the reference for the new Area and saving it to the array
        areaToAdd.polygonReference = polygonView;
        [self.visibleAreaArray addObject:areaToAdd];
        saveMode = NO;
    }
    else if (updateMode){
        
        updateMode = NO;
    }
    else{
        //Fetch it from Core Data with the corresponding Overlay
        NSError *error = nil;
        NSPredicate *areafromOverlayPredicate = [NSPredicate predicateWithFormat:@"overlayReference == %@", overlay];
        NSArray *areas = [self.visibleAreaArray filteredArrayUsingPredicate:areafromOverlayPredicate];
        if (!error && areas.count == 1) {
            Area *area = [areas firstObject];
            polygonView.strokeColor = [area getAreaColorWithAlpha:.8];
            polygonView.fillColor = [area getAreaColorWithAlpha:.3];
            
            area.polygonReference = polygonView;
        }
        else{
            DLog(@"Error rendering Area");
        }
    }
    
    return (MKOverlayRenderer *)polygonView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[Lead class]]){
        
        self.leadToEdit = view.annotation;
        if ([self shouldPerformSegueWithIdentifier:@"MapToLeadDetail" sender:self]) {
            [self performSegueWithIdentifier:@"MapToLeadDetail" sender:self];
        }
    }
    else if ([view.annotation isKindOfClass:[Prequal class]]) {
        
        self.selectedPrequal = view.annotation;
        
        if ([self shouldPerformSegueWithIdentifier:@"MapToLeadDetail" sender:self]) {
            [self performSegueWithIdentifier:@"MapToLeadDetailWithPrequal" sender:self];
        }
    }
}

- (void)deleteRecentAreaAdded
{
    //Delete it from the map
    [self.mapView removeOverlay:areaToAdd.polygonReference.overlay];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If the area id is negative that means this area hasn't been synced so it is just deleted from Core Data otherwise we add its areaId to a list of areas to be deleted in NSUserDefaults and then send that to the server to be deleted
    if (areaToAdd.areaId.integerValue > 0) {
        NSMutableArray *areaIdsToDelete = [[defaults objectForKey:kDeletedAreaIds] mutableCopy];
        [areaIdsToDelete addObject:areaToAdd.areaId];
        [defaults setObject:areaIdsToDelete forKey:kDeletedAreaIds];
        [defaults synchronize];
    }
    [[[SRGlobalState singleton] managedObjectContext] deleteObject:areaToAdd];
    
    //Delete it from the array of Core Data Area references
    [self.visibleAreaArray removeObject:areaToAdd];
    
    [[SRPremiumSalesServiceCalls singleton] sync];
    
    self.areaPinButton.enabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
    polygonToAdd = nil;
}

#pragma mark - Overriding Method for MapView Tapped

-(void)setAllowManagerFeatures:(BOOL)allowManagerFeatures{
    if (self.userType == SRUserTypeRep) {
        return;
    }
    
    
    if (_allowManagerFeatures != allowManagerFeatures) {
        _allowManagerFeatures = allowManagerFeatures;
    }
    
    if (allowManagerFeatures) {
        self.managerTabButton.enabled = YES;
        [self.managerTabActivityIndicator stopAnimating];
        self.managerTabActivityIndicator.hidden = YES;
    }else{
        self.managerTabButton.enabled = NO;
        
        //Check the status of the navView
        if (!navViewHidden && navViewTab == MAPTAB) {
            [self tabButtonPressed:self.mapTabButton];
        }
        
        self.managerTabActivityIndicator.hidden = NO;
        [self.managerTabActivityIndicator startAnimating];
    }
}

- (IBAction)mapTapped:(UITapGestureRecognizer *)sender
{
    
    [super mapTapped:sender];
    
    [self dismissFilterPopOver];
    
    if (!drawMode && !wasAnyLeadButtonSelectedWhenMapTap
        && ![self wasLeadInMapSelected:sender]
        && (self.showRepAreasSwitch.on || self.showRepActiveAreaSwitch.on)
        && (self.userType == SRUserTypeManager || self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional)
        && self.allowManagerFeatures) {
        
        CGPoint tapPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D tapCoord = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
        MKMapPoint mapPoint = MKMapPointForCoordinate(tapCoord);
        CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);
        BOOL wasPolygonTapped = NO;
        for (int i = (int)self.visibleAreaArray.count - 1; i>=0; i--) {
            MKPolygonRenderer *polygonRender = [[self.visibleAreaArray objectAtIndex:i] polygonReference];
            MKPolygon *polygon = polygonRender.polygon;
            
            CGMutablePathRef mpr = CGPathCreateMutable();
            
            MKMapPoint *polygonPoints = polygon.points;
            
            for (int p=0; p < polygon.pointCount; p++){
                MKMapPoint mp = polygonPoints[p];
                if (p == 0)
                    CGPathMoveToPoint(mpr, NULL, mp.x, mp.y);
                else
                    CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
            }
            
            if(CGPathContainsPoint(mpr , NULL, mapPointAsCGP, FALSE)){
                // An overlay Polygon was tapped
                wasPolygonTapped = YES;
                
                if (self.selectedPolygon == nil) {
                    self.selectedPolygon = polygonRender;
                    self.selectedArea = [self.visibleAreaArray objectAtIndex:i];
                    self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.6];
                    self.selectedPolygon.lineWidth = 4;
                    [self.selectedPolygon setNeedsDisplay];
                }
                else
                {
                    self.selectedPolygon.lineWidth = 2;
                    self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.3];
                    [self.selectedPolygon setNeedsDisplay];
                    self.selectedPolygon = polygonRender;
                    self.selectedArea = [self.visibleAreaArray objectAtIndex:i];
                    self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.6];
                    self.selectedPolygon.lineWidth = 4;
                    [self.selectedPolygon setNeedsDisplay];
                }
                
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [self performSegueWithIdentifier:@"selectedAreaSegue" sender:self];
                }
                else{
                    //Popover Set Code
                    
                    self.detailedAreaVC = [[SRAreaDetailedViewController alloc] initWithNibName:@"SRAreaDetailedViewController" bundle:nil];
                    self.detailedAreaVC.polygonToDisplay = self.selectedPolygon;
                    self.detailedAreaVC.selectedArea = self.selectedArea;
                    self.detailedAreaVC.delegate = self;
                    
                    self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.detailedAreaVC];
                    self.popOverController.delegate = self;
                    self.popOverController.popoverContentSize = self.detailedAreaVC.view.frame.size;
                    [self.popOverController presentPopoverFromRect:CGRectMake(tapPoint.x, tapPoint.y, 1, 1) inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
                }
                break;
                
            }
            
            CGPathRelease(mpr);
        }
        // No polygon was selected, but if a polygon is selected, deselected
        if (!wasPolygonTapped && self.selectedPolygon != nil) {
            self.selectedPolygon.lineWidth = 2;
            self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.3];
            [self.selectedPolygon setNeedsDisplay];
            self.selectedPolygon = nil;
            self.selectedArea = nil;
        }
    }
}

- (BOOL)wasLeadInMapSelected:(UIGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateEnded ){
        NSSet *visibleAnnotations = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
        for ( id<MKAnnotation> annotation in visibleAnnotations.allObjects ){
            UIView *av = [self.mapView viewForAnnotation:annotation];
            CGPoint point = [sender locationInView:av];
            if( [av pointInside:point withEvent:nil] ){
                // do what you wanna do when Annotation View has been tapped!
                return YES;
            }
        }
        return NO;
    }
    return NO;
}

#pragma mark - Delegate Method to delete from the UIPopover view (SRAreaDetailedViewController)

- (void)isGoingToDeleteArea:(Area *)area andController:(SRAreaDetailedViewController *)sender
{
    
    NSArray *areaReps = [area.activeUsers array];
    
    for (int i=0; i<areaReps.count; i++) {
        if ([[areaReps[i] userId] isEqualToString:[[SRGlobalState singleton] userId]] && [[SRGlobalState singleton] prequalEnabled]) {
            [self removeAnnotationsForClass:[Prequal class]];
        }
    }
    
    [self queryAnnotations];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [self.mapView removeOverlay:area.polygonReference.overlay];
    [self.popOverController dismissPopoverAnimated:YES];
    
    // If the area id is negative that means this area hasn't been synced so it is just deleted from Core Data otherwise we add its areaId to a list of areas to be deleted in NSUserDefaults and then send that to the server to be deleted
    if (area.areaId.integerValue > 0) {
        NSMutableArray *areaIdsToDelete = [[defaults objectForKey:kDeletedAreaIds] mutableCopy];
        [areaIdsToDelete addObject:area.areaId];
        [defaults setObject:areaIdsToDelete forKey:kDeletedAreaIds];
        [defaults synchronize];
    }
    [[[SRGlobalState singleton] managedObjectContext] deleteObject:area];
    
    //Delete it from the array of Core Data Area references
    DLog(@"Area deleted: %@", area.areaId);
    
    [self.visibleAreaArray removeObject:area];
    [self.navigationController popViewControllerAnimated:YES];
    
    //NSLog(@"Syncing deleted area...");
    [[SRPremiumSalesServiceCalls singleton] sync];
}

- (void)isGoingToAddNewRep
{
    [self performSegueWithIdentifier:@"addRepSegue" sender:self];
}

- (void)areaDetailed:(SRAreaDetailedViewController *)areaDetailed didDeleteActiveRep:(User *)rep
{
    self.selectedArea.polygonReference.fillColor = [self.selectedArea getAreaColorWithAlpha:.6];
    self.selectedArea.polygonReference.strokeColor = [self.selectedArea getAreaColorWithAlpha:.8];
    
    //This means the Prequal needs to change so delete all the annotations for the old Prequal area
    if ([rep.userId isEqualToString:[[SRGlobalState singleton] userId]]) {
        [self removeAnnotationsForClass:[Prequal class]];
    }
    
    [self queryAnnotations];
}

- (void)areaDetailedCancelButtonPressed:(SRAreaDetailedViewController *)areaDetailed{
    [self.navigationController popViewControllerAnimated:YES];
    self.selectedPolygon.lineWidth = 2;
    self.selectedPolygon.fillColor = [self.selectedArea getAreaColorWithAlpha:.3];
    [self.selectedPolygon setNeedsDisplay];
    self.selectedPolygon = nil;
    self.selectedArea = nil;
}


#pragma mark - Delegate Methods for adding new Reps (SRNewRepViewController)

- (void) didPressSaveNewReps
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.detailedAreaVC updateReps];
    
    self.selectedArea.polygonReference.fillColor =  [self.selectedArea getAreaColorWithAlpha:.6];
    self.selectedArea.polygonReference.strokeColor = [self.selectedArea getAreaColorWithAlpha:.8];
    [self.selectedArea.polygonReference setNeedsDisplay];
    
    [[SRPremiumSalesServiceCalls singleton] sync];
}

- (void) didPresscancelSaveNewReps
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//This Delegate is to know which areas where affected by the change
- (void)newRepViewController:(SRNewRepViewController *)newRepViewController didSaveRep:(NSArray *)reps fromAreas:(NSArray *)areas{
    for (int i=0; i<areas.count; i++) {
        Area *tempArea = [areas objectAtIndex:i];
        tempArea.polygonReference.fillColor = [tempArea getAreaColorWithAlpha:.3];
        tempArea.polygonReference.strokeColor = [tempArea getAreaColorWithAlpha:.8];
        [tempArea.polygonReference setNeedsDisplay];
    }
    
    self.selectedArea.polygonReference.fillColor = [self.selectedArea getAreaColorWithAlpha:.6];
    self.selectedArea.polygonReference.strokeColor = [self.selectedArea getAreaColorWithAlpha:.8];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.detailedAreaVC updateReps];
    
    for (int i=0; i<reps.count; i++) {
        if ([[[reps objectAtIndex:i] userId] isEqualToString:[[SRGlobalState singleton] userId]] && [[SRGlobalState singleton] prequalEnabled]) {
            [self removeAnnotationsForClass:[Prequal class]];
            
            //This is a rare corner case, this is so if the active area swith is off and you just changed the active area, the are doesn't seem to just dissapear so we turn the switch on to keep it consistent
            if (self.showRepActiveAreaSwitch.on == NO) {
                self.showRepActiveAreaSwitch.on = YES;
                [self showRepActiveAreaChanged:self.showRepActiveAreaSwitch];
            }
        }
    }
    
    [self queryAnnotations];
}

#pragma mark - Filtering Methods

//Creates a popOver for the filtering menu (iPad)
- (void)createPopover:(id)sender popoverView:(UIViewController *)popoverView
{
    [self dismissFilterPopOver];
    if (self.filterPopOver) {
        [self.filterPopOver dismissPopoverAnimated:YES];
    }
    self.filterPopOver = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    self.filterPopOver.delegate = self;
    self.filterPopOver.passthroughViews = [NSArray arrayWithObject:self.view];
    //self.filterPopOverView = sender;
    [self.filterPopOver presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)createPopoverAt:(CGPoint)point popoverView:(UIViewController *)popoverView
{
    if (self.filterPopOver) {
        [self.filterPopOver dismissPopoverAnimated:YES];
    }
    self.filterPopOver = [[UIPopoverController alloc] initWithContentViewController:popoverView];
    self.filterPopOver.delegate = self;
    self.filterPopOver.passthroughViews = [NSArray arrayWithObject:self.view];
    [self.filterPopOver presentPopoverFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)dismissFilterPopOver
{
    if (self.filterPopOver) {
        [self.filterPopOver dismissPopoverAnimated:YES];
        
        if (polygonToAdd != nil && (self.userType == SRUserTypeAdmin || self.userType == SRUserTypeRegional)) {
            
            //Delete it from the map
            [self.mapView removeOverlay:areaToAdd.polygonReference.overlay];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            // If the area id is negative that means this area hasn't been synced so it is just deleted from Core Data otherwise we add its areaId to a list of areas to be deleted in NSUserDefaults and then send that to the server to be deleted
            if (areaToAdd.areaId.integerValue > 0) {
                NSMutableArray *areaIdsToDelete = [[defaults objectForKey:kDeletedAreaIds] mutableCopy];
                [areaIdsToDelete addObject:areaToAdd.areaId];
                [defaults setObject:areaIdsToDelete forKey:kDeletedAreaIds];
                [defaults synchronize];
            }
            [[[SRGlobalState singleton] managedObjectContext] deleteObject:areaToAdd];
            
            //Delete it from the array of Core Data Area references
            [self.visibleAreaArray removeObject:areaToAdd];
            
            [[SRPremiumSalesServiceCalls singleton] sync];
            
            polygonToAdd = nil;
            
            self.areaPinButton.enabled = YES;
            self.mapView.scrollEnabled = YES;
            self.mapView.zoomEnabled = YES;
        }
    }
}

- (void)setQuickDate:(NSString *)quickDateString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    if ([quickDateString isEqualToString:kToday]) {
        self.fromDate = self.toDate = today;
    }
    else if ([quickDateString isEqualToString:kYesterday]) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = -1;
        self.fromDate = self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    else if ([quickDateString isEqualToString:kTomorrow]) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.day = 1;
        self.fromDate = self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    else if ([quickDateString isEqualToString:kThisWeek]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfMonthCalendarUnit) fromDate:today];
        comps.weekday = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        comps.weekday = 7;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kThisMonth]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:today];
        comps.day = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:today];
        comps.day = dayRange.length;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kThisYear]) {
        NSDateComponents *comps = [calendar components:(NSYearCalendarUnit) fromDate:today];
        comps.month = 1;
        comps.day = 1;
        self.fromDate = [calendar dateFromComponents:comps];
        NSRange monthRange = [calendar rangeOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:today];
        comps.month = monthRange.length;
        NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[calendar dateFromComponents:comps]];
        comps.day = dayRange.length;
        self.toDate = [calendar dateFromComponents:comps];
    }
    else if ([quickDateString isEqualToString:kAllTime]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        self.fromDate = [dateFormatter dateFromString:kMinimumDate];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = 1;
        self.toDate = [calendar dateByAddingComponents:comps toDate:today options:0];
    }
    
    //adjust button titles
    if ([self.customDateManagerButton titleForState:UIControlStateNormal] == kAllTime) {
        [self.fromDateManagerButton setTitle:kNA forState:UIControlStateNormal];
        [self.toDateManagerButton setTitle:kNA forState:UIControlStateNormal];
    }
    else if([self.customDateManagerButton titleForState:UIControlStateNormal] != kCustom){
        [self.fromDateFilterView setPickerDate:self.fromDate];
        [self.fromDateFilterView setMaxDate:self.toDate];
        [self.toDateFilterView setPickerDate:self.toDate];
        [self.toDateFilterView setMinDate:self.fromDate];
    }
    
    // Adjust the dates accordingly
    [self adjustToAndFromDatesForFetchRequest];
}


- (void)createActionSheet:(id)sender sheetView:(UIViewController *)sheetView {
    
    self.filterActionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
    [self.filterActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    if (!sheetView.isViewLoaded) {
        [sheetView view]; // Load view so that its metrics will be available
    }
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect actionSheetFrame = screenFrame;
    if (sheetView.preferredContentSize.height + 44 < actionSheetFrame.size.height) {
        actionSheetFrame.size.height = sheetView.preferredContentSize.height + 44;
        actionSheetFrame.origin.y = actionSheetFrame.origin.y + screenFrame.size.height - actionSheetFrame.size.height;
    }
    CGRect sheetViewFrame = actionSheetFrame;
    sheetViewFrame.origin.y = 44;
    sheetViewFrame.size.height = actionSheetFrame.size.height - 44;
    
    [self.filterActionSheet addSubview:sheetView.view];
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenFrame.size.width, 44)];
    background.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1];
    [self.filterActionSheet addSubview:background];
    
    //Only show cancel button if it is a one-item list picker, otherwise show done button
    UISegmentedControl *doneButton;
    CGFloat buttonWidth;
    if ([sheetView isKindOfClass:[AVSelectionListController class]]) {
        NSString *doneButtonText = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? kDone : kCancel;
        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
        doneButton.momentary = YES;
        doneButton.tintColor = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1] : [UIColor blackColor];
        buttonWidth = ([[(AVSelectionListController *)sheetView contentList] count] > 1) ? ACTION_DONE_BTN_WIDTH : ACTION_CANCEL_BTN_WIDTH;
    }
    else {
        NSString *doneButtonText = kDone;
        doneButton = [[UISegmentedControl alloc] initWithItems:@[doneButtonText]];
        doneButton.momentary = YES;
        doneButton.tintColor = [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1];
        buttonWidth = ACTION_DONE_BTN_WIDTH;
    }
    doneButton.frame = CGRectMake(screenFrame.size.width - buttonWidth - 5, 7, buttonWidth, 30);
    [doneButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [self.filterActionSheet addSubview:doneButton];
    
    [self.filterActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    // Set these frames after showing because the showInView method messes the frames up
    self.filterActionSheet.frame = actionSheetFrame;
    sheetView.view.frame = sheetViewFrame;
}

- (void)dismissActionSheet:(id)sender {
    
    [self.filterActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    self.filterActionSheet = nil;
    
    if (polygonToAdd != nil) {
        
        //Delete it from the map
        [self.mapView removeOverlay:areaToAdd.polygonReference.overlay];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // If the area id is negative that means this area hasn't been synced so it is just deleted from Core Data otherwise we add its areaId to a list of areas to be deleted in NSUserDefaults and then send that to the server to be deleted
        if (areaToAdd.areaId.integerValue > 0) {
            NSMutableArray *areaIdsToDelete = [[defaults objectForKey:kDeletedAreaIds] mutableCopy];
            [areaIdsToDelete addObject:areaToAdd.areaId];
            [defaults setObject:areaIdsToDelete forKey:kDeletedAreaIds];
            [defaults synchronize];
        }
        [[[SRGlobalState singleton] managedObjectContext] deleteObject:areaToAdd];
        
        //Delete it from the array of Core Data Area references
        [self.visibleAreaArray removeObject:areaToAdd];
        
        [[SRPremiumSalesServiceCalls singleton] sync];
        
        self.areaPinButton.enabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled = YES;
        
        polygonToAdd = nil;
    }
}


- (void)adjustToAndFromDatesForFetchRequest{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *fromComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.fromDate];
    [fromComponents setHour:0];
    [fromComponents setMinute:0];
    [fromComponents setSecond:0];
    self.fromDate = [calendar dateFromComponents:fromComponents];
    
    NSDateComponents *toComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.toDate];
    [toComponents setHour:23];
    [toComponents setMinute:59];
    [toComponents setSecond:59];
    self.toDate = [calendar dateFromComponents:toComponents];
}



#pragma mark - AVSelectionListController Delegate Methods

- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection
{
    if (sender == self.quickDateFilterView){
        [self setQuickDate:selection];
        [self updateVisibleManagerAnnotationsAndOverlays];
    }
    else if (sender == self.officesListController){
        areaToAdd.office = [self.officesList objectAtIndex:sender.selectionIndex];
        
        //NSLog(@"You have added the area with the office: %@", areaToAdd.office.name);
        areaToAdd.areaId = [Area generateTempAreaId];
        self.areaPinButton.enabled = YES;
        self.mapView.scrollEnabled = YES;
        self.mapView.zoomEnabled = YES;
        
        polygonToAdd = nil;
        
        [self dismissActionSheet:self];
    }
    
    [self.filterPopOver dismissPopoverAnimated:YES];
    
    //DLog(@"Staging new area for sync...");
    [[SRPremiumSalesServiceCalls singleton] sync];
}

- (void)checkListChanged:(id)sender
{
    if (sender == self.repsFilterView) {
        NSArray *repsIndexes = self.repsFilterView.selectedIndexes;
        self.visibleReps = [[NSMutableArray alloc] init];
        for (int i = 0; i < repsIndexes.count; i++) {
            User *tempUser = [self.availableReps objectAtIndex:[[repsIndexes objectAtIndex:i] integerValue]];
            [self.visibleReps addObject:tempUser];
        }
        
        if (self.availableReps.count == repsIndexes.count) {
            [self.repsManagerButton setTitle:[NSString stringWithFormat:@"%@ %@", kAll, kSelected] forState:UIControlStateNormal];
        }
        else if(repsIndexes.count == 1){
            NSString *label = [self.availableRepsNames objectAtIndex:[[repsIndexes objectAtIndex:0] integerValue]];
            [self.repsManagerButton setTitle:label forState:UIControlStateNormal];
        }
        else
        {
            [self.repsManagerButton setTitle:[NSString stringWithFormat:@"%lu %@",(unsigned long)repsIndexes.count,kSelected] forState:UIControlStateNormal];
        }
    }
    
    [self updateVisibleManagerAnnotationsAndOverlays];
}

#pragma mark - AVSimpleDatePickerController Delegate Methods

- (void)dateChanged:(AVSimpleDatePickerController *)sender toDate:(NSDate *)date
{
    // When from button picker selects a date
    if (sender == self.fromDateFilterView) {
        self.fromDate = date;
        [self.toDateFilterView setMinDate:date];
        [self.customDateManagerButton setTitle:kCustom forState:UIControlStateNormal];
    }
    
    // When to button picker selects a date
    if (sender == self.toDateFilterView) {
        self.toDate = date;
        [self.fromDateFilterView setMaxDate:date];
        [self.customDateManagerButton setTitle:kCustom forState:UIControlStateNormal];
    }
    
    // Call methods to setup new fetch request and display the results in the table view
    [self updateVisibleManagerAnnotationsAndOverlays];
}

#pragma mark - User Map Sync methods

- (void)usersChanged:(NSNotification *)notification {
    [self fetchAvailableUsers];
    NSDictionary *result = notification.object;
    
    BOOL updateRequired = NO;
    
    //Refactor by grouping by type
    
    //Added
    NSArray *addedUsers = [result objectForKey:kAddedUsers];
    for (User *user in addedUsers) {
        //Make sure to added to the filtering if "All Selected" so data for that user doesn't get filtered out
        if ([self.repsManagerButton.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%@ %@", kAll, kSelected]] && [self.availableReps containsObject:user]) {
            [self.visibleReps addObject:user];
        }
    }
    if (self.showRepLeadsSwitch.on) {
        NSArray *addedSlimLeads = [result objectForKey:kAddedSlimLeads];
        for (SlimLead *slimLead in addedSlimLeads) {
            if ([slimLead.dateCreated compare:self.fromDate] == NSOrderedDescending && [slimLead.dateCreated compare:self.toDate] == NSOrderedAscending && [self.visibleReps containsObject:slimLead.user]) {
                [self.visibleSlimLeads addObject:slimLead];
                [self.quadTreeController insertData:dataFromAnnotation(slimLead, [slimLead.latitude doubleValue], [slimLead.longitude doubleValue])];
                updateRequired = YES;
            }
        }
    }
    
    if (self.showRepLocationsSwitch.on) {
        NSArray *addedUserLocations = [result objectForKey:kAddedUserLocations];
        for (UserLocation *userLocation in addedUserLocations) {
            if ([userLocation.dateCreated compare:self.fromDate] == NSOrderedDescending && [userLocation.dateCreated compare:self.toDate] == NSOrderedAscending && [self.visibleReps containsObject:userLocation.user]) {
                [self.visibleUserLocations addObject:userLocation];
                [self.quadTreeController insertData:dataFromAnnotation(userLocation, [userLocation.latitude doubleValue], [userLocation.longitude doubleValue])];
                updateRequired = YES;
            }
        }
    }
    
    //Updated
    if (self.showRepLeadsSwitch.on) {
        NSArray *updatedSlimLeads = [result objectForKey:kUpdatedSlimLeads];
        for (SlimLead* lead in updatedSlimLeads) {
            if ([self.mapView.annotations containsObject:lead]) {
                //In case Status changed
                MKAnnotationView *view = [self.mapView viewForAnnotation:lead];
                view.image = [lead image];
                
                [self addBounceAnnimationToView:view];
            }
        }
    }
    
    //Deleted
    NSArray *deletedUsers = [result objectForKey:kDeletedUsers];
    for (User *user in deletedUsers) {
        
        //Remove User's slim lead annotations
        for (SlimLead *lead in user.slimLeads) {
            if ([self.visibleSlimLeads containsObject:lead]) {
                [self.visibleSlimLeads removeObject:lead];
                [self.quadTreeController deleteData:dataFromAnnotation(lead, [lead.latitude doubleValue], [lead.longitude doubleValue])];
                updateRequired = YES;
            }
        }
        //Remove User's location annotations
        for (UserLocation* location in user.userLocations) {
            if ([self.visibleUserLocations containsObject:location]) {
                [self.visibleUserLocations removeObject:location];
                [self.quadTreeController deleteData:dataFromAnnotation(location, [location.latitude doubleValue], [location.longitude doubleValue])];
                updateRequired = YES;
            }
        }
    }
    
    NSArray* deletedSlimLeads = [result objectForKey:kDeletedSlimLeads];
    for (SlimLead* lead in deletedSlimLeads) {
        if ([self.visibleSlimLeads containsObject:lead]) {
            [self.visibleSlimLeads removeObject:lead];
            [self.quadTreeController deleteData:dataFromAnnotation(lead, [lead.latitude doubleValue], [lead.longitude doubleValue])];
            updateRequired = YES;
        }
    }
    
    //Check if any change required to update de mapView annotations
    if (updateRequired) {
        [self queryAnnotations];
    }
}

-(void)syncUserMapFinished{
    self.allowManagerFeatures = YES;
}

- (void)departmentChanged {
    [self updateVisibleManagerAnnotationsAndOverlays];
    self.allowManagerFeatures = NO;
}

- (void)areasChanged:(NSNotification *)notification {
    
    NSDictionary *result = notification.object;
    
    NSArray *addedAreas = [result objectForKey:kAddedAreas];
    for (Area *area in addedAreas) {
        //Draw area on map
        if(self.showRepAreasSwitch.on){
            self.currentAreaRendered = area;
            NSArray *points = [self.currentAreaRendered.mapPoints array];
            CLLocationCoordinate2D locationArray[points.count];
            for (int i=0; i<points.count; i++) {
                locationArray[i] = [[points objectAtIndex:i] returnLocation];
            }
            
            MKPolygon *newPolygon = [MKPolygon polygonWithCoordinates:locationArray count:self.currentAreaRendered.mapPoints.count];
            
            //Add it to the visible areas
            [self.visibleAreaArray addObject:area];
            
            //Add it to the map overlays
            [self.mapView addOverlay:newPolygon level:MKOverlayLevelAboveLabels];
        }
    }
    
    NSArray *upadatedAreas = [result objectForKey:kUpdatedAreas];
    for (Area *area in upadatedAreas) {
        //Raúl
        //I'm not sure if an area would need to be updated since the changed active and inactive users would be pulled from core data
        //Maybe just detecting if a color change needs to be made? That might be better done when iterating through changed users, let me know what you think.
        updateMode = YES;
        self.updateArea = area;
        
        if ([self.visibleAreaArray containsObject:area]) {
            area.polygonReference.fillColor = [area getAreaColorWithAlpha:.3];
            area.polygonReference.strokeColor = [area getAreaColorWithAlpha:.8];
        }
        
        //Active Area was updated and probably removed
        if (!self.repActiveArea) {
            [self removeAnnotationsForClass:[Prequal class]];
            [self queryAnnotations];
        }
    }
    
    NSArray *deletedAreas = [result objectForKey:kDeletedAreas];
    for (Area *area in deletedAreas) {
        //Remove area from map
        [self.mapView removeOverlay:area.polygonReference.overlay];
        [self.visibleAreaArray removeObject:area];
        
        if (area == self.repActiveArea || !self.repActiveArea) {
            [self removeAnnotationsForClass:[Prequal class]];
            [self queryAnnotations];
        }
    }
    
    [self updateVisibleAreas];
}

- (void)prequalsChanged:(NSNotification *)notification
{
    //Inserted the added prequals to the QuadTree
    NSArray *addedPrequals = notification.object;
    for (Prequal *prequal in addedPrequals) {
        if (![self.visiblePrequal containsObject:prequal]) {
            [self.visiblePrequal addObject:prequal];
            [self.quadTreeController insertData:dataFromAnnotation(prequal, [prequal.latitude doubleValue], [prequal.longitude doubleValue])];
        }
    }
    
    [self queryAnnotations];
}

#pragma mark - Prequal Helper Methods

- (void)updatePrequals
{
    [self removeAnnotationsForClass:[Prequal class]];
    
    [self fetchVisiblePrequal];
    
    for (int i=0; i<self.visiblePrequal.count; i++) {
        Prequal *tempPrequal = self.visiblePrequal[i];
        [self.quadTreeController insertData:dataFromAnnotation(tempPrequal, [tempPrequal.latitude doubleValue], [tempPrequal.longitude doubleValue])];
    }
}

- (void)fetchVisiblePrequal
{
    //Check if there is an Active Area assigned otherwise there will be Prequal data just floating around
    if (self.repActiveArea) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Prequal"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"latitude != nil AND longitude != nil AND userId == %@ AND areaId = %@", [[SRGlobalState singleton] userId], self.repActiveArea.areaId];
        [fetchRequest setFetchLimit:1000];
        NSError *error = nil;
        NSArray *coreDataPrequals = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (!error) {
            self.visiblePrequal = [NSMutableArray arrayWithArray:coreDataPrequals];
        }
        else{
            DLog(@"Error fetching prequals: %@", error);
        }
        
    }
}

- (void)deletePrequal:(NSNotification *) notification
{
    Prequal *prequalToDelete = notification.object;
    [self.visiblePrequal removeObject:prequalToDelete];
    [self.quadTreeController deleteData:dataFromAnnotation(prequalToDelete, [prequalToDelete.latitude doubleValue], [prequalToDelete.longitude doubleValue])];
    
    [[[SRGlobalState singleton] managedObjectContext] deleteObject:prequalToDelete];
    
    [self queryAnnotations];
}

- (void)removePrequalAnnotations
{
    [self removeAnnotationsForClass:[Prequal class]];
    [self queryAnnotations];
}

#pragma mark - Manage Map Annotations Methods

- (void)removeAnnotationsForClass:(Class)classToRemove
{
    if([SlimLead class] == classToRemove)
    {
        for (int i=0; i<self.visibleSlimLeads.count; i++) {
            SlimLead *tempSlimLead = self.visibleSlimLeads[i];
            [self.quadTreeController deleteData:dataFromAnnotation(tempSlimLead, [tempSlimLead.latitude doubleValue], [tempSlimLead.longitude doubleValue])];
        }
    }
    else if([UserLocation class] == classToRemove)
    {
        for (int i=0; i<self.visibleUserLocations.count; i++) {
            UserLocation *tempUserLocation = self.visibleUserLocations[i];
            [self.quadTreeController deleteData:dataFromAnnotation(tempUserLocation, [tempUserLocation.latitude doubleValue], [tempUserLocation.longitude doubleValue])];
        }
    }
    else if ([Prequal class] == classToRemove) {
        for (int i=0; i<self.visiblePrequal.count; i++) {
            Prequal *tempPrequal= self.visiblePrequal[i];
            [self.quadTreeController deleteData:dataFromAnnotation(tempPrequal, [tempPrequal.latitude doubleValue], [tempPrequal.longitude doubleValue])];
        }
    }
}


#pragma mark - Core Data Helper Methods

- (void)fetchAvailableUsers
{
    NSError *error = nil;
    
    //Determine the userType to see which ID to filter with
    if (self.userType == SRUserTypeManager) {
        self.userRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY offices.officeId == %@) AND (userId != %@)", [[SRGlobalState singleton] officeId], [[SRGlobalState singleton] userId]];
    }
    else if (self.userType == SRUserTypeRegional){
        self.userRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY offices.region.regionId == %@) AND (userId != %@)", [[SRGlobalState singleton] areaId], [[SRGlobalState singleton] userId]];
    }
    else if (self.userType == SRUserTypeAdmin){
        self.userRequest.predicate = [NSPredicate predicateWithFormat:@"(ANY offices.region.department.departmentId == %@) AND (userId != %@)", [[SRGlobalState singleton] companyId], [[SRGlobalState singleton] userId]];
    }
    
    self.availableReps = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:self.userRequest error:&error];
    
    //Sort it
    NSSortDescriptor *sortfirstName = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
    NSSortDescriptor *sortLastName = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    self.availableReps = [self.availableReps sortedArrayUsingDescriptors:@[sortfirstName, sortLastName]];
    
    //Select only the names
    NSMutableArray *reps = [NSMutableArray array];
    NSMutableArray *repIds = [NSMutableArray array];
    for (int i=0; i<self.availableReps.count; i++) {
        [reps addObject:[NSString stringWithFormat:@"%@ %@",[[self.availableReps objectAtIndex:i] firstName],[[self.availableReps objectAtIndex:i] lastName]]];
        [repIds addObject:[[self.availableReps objectAtIndex:i] userId]];
    }
    self.availableRepsNames = reps;
}

-(void)setAvailableRepsNames:(NSArray *)availableRepsNames{
    if (![_availableRepsNames isEqualToArray:availableRepsNames]) {
        _availableRepsNames = availableRepsNames;
        self.repsFilterView.contentList = availableRepsNames;
    }
}

- (void)fetchAvailableOffices
{
    NSError *error = nil;
    NSPredicate *predicate;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Office"];
    
    if (self.userType == SRUserTypeRegional) {
        predicate = [NSPredicate predicateWithFormat:@"region.regionId == %@", [[SRGlobalState singleton] areaId]];
    }
    else if (self.userType == SRUserTypeAdmin){
        predicate = [NSPredicate predicateWithFormat:@"region.department.departmentId == %@", [[SRGlobalState singleton] companyId]];
    }
    else if (self.userType == SRUserTypeManager)
    {
        predicate = [NSPredicate predicateWithFormat:@"officeId == %@", [[SRGlobalState singleton] officeId]];
    }
    
    request.predicate = predicate;
    
    NSArray *unsortedOffices = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    
    self.officesList = [unsortedOffices sortedArrayUsingComparator:^NSComparisonResult(Office *obj1, Office *obj2) {
        return [obj1.name compare:obj2.name];
    }];
    //NSLog(@"I found %lu Offices", (unsigned long)self.officesList.count);
    
}

#pragma mark - Update Visible Helper Methods

- (void)updateVisibleManagerAnnotationsAndOverlays
{
    [self updateVisibleAreas];
    
    [self updateVisibleSlimLeads];
    
    [self updateVisibleRepLocations];
    
    [self queryAnnotations];
}

- (void)updateVisibleAnnotations
{
    
    [self fetchVisibleSlimLeads];
    
    for (int i=0; i<self.visibleSlimLeads.count; i++) {
        SlimLead *tempSlimLead = self.visibleSlimLeads[i];
        [self.quadTreeController insertData:dataFromAnnotation(tempSlimLead, [tempSlimLead.latitude doubleValue], [tempSlimLead.longitude doubleValue])];
    }
    
    [self fetchVisibleRepLocations];
    
    for (int i=0; i<self.visibleUserLocations.count; i++) {
        UserLocation *tempUserLocation = self.visibleUserLocations[i];
        [self.quadTreeController insertData:dataFromAnnotation(tempUserLocation, [tempUserLocation.latitude doubleValue], [tempUserLocation.longitude doubleValue])];
    }
    
    [self queryAnnotations];
}

#pragma mark - Sales Area Helper Methods

- (void)updateMapOverlays
{
    //First Delete all Overlays
    [self.mapView removeOverlays:[self.mapView overlays]];
    
    for(int i=0; i<self.visibleAreaArray.count; i++)
    {
        self.currentAreaRendered = [self.visibleAreaArray objectAtIndex:i];
        NSArray *points = [self.currentAreaRendered.mapPoints array];
        CLLocationCoordinate2D locationArray[points.count];
        for (int i=0; i<points.count; i++) {
            locationArray[i] = [(MapPoint *)[points objectAtIndex:i] returnLocation];
        }
        
        MKPolygon *newPolygon = [MKPolygon polygonWithCoordinates:locationArray count:self.currentAreaRendered.mapPoints.count];
        //To Keep track of the area at the time the Map needs to render it
        self.currentAreaRendered.overlayReference = newPolygon;
        
        //Add the overlay to the area
        [self.mapView addOverlay:newPolygon level:MKOverlayLevelAboveLabels];

    }
}

- (void)updateVisibleAreas
{
    self.visibleAreaArray = [[NSMutableArray alloc] init];
    
    if (self.showRepAreasSwitch.on) {
        
        //Construct Predicate
        NSMutableArray *predicateArray = [[NSMutableArray alloc] init];
        
        NSPredicate *repFilter;
        
        NSPredicate *noRepsAreaPredicate;
        
        //Determine the userType to see which ID to filter with------- First predicate is for all the areas with active reps to show no matter what ------ Second predicate is to filter the areas without actuve reps by date
        if (self.userType == SRUserTypeManager) {
            repFilter = [NSPredicate predicateWithFormat:@"ANY activeUsers IN %@ AND office.officeId = %@", self.visibleReps, [[SRGlobalState singleton] officeId]];
            noRepsAreaPredicate = [NSPredicate predicateWithFormat:@"activeUsers.@count == 0 AND office.officeId = %@ AND dateCreated >= %@ AND dateCreated <= %@",[[SRGlobalState singleton] officeId], self.fromDate, self.toDate];
        }
        else if (self.userType == SRUserTypeRegional){
            repFilter = [NSPredicate predicateWithFormat:@"ANY activeUsers IN %@ AND office.region.regionId = %@", self.visibleReps, [[SRGlobalState singleton] areaId]];
            noRepsAreaPredicate = [NSPredicate predicateWithFormat:@"activeUsers.@count == 0 AND office.region.regionId = %@ AND dateCreated >= %@ AND dateCreated <= %@", [[SRGlobalState singleton] areaId], self.fromDate, self.toDate];
        }
        else if (self.userType == SRUserTypeAdmin){
            repFilter = [NSPredicate predicateWithFormat:@"ANY activeUsers IN %@ AND office.region.department.departmentId = %@", self.visibleReps, [[SRGlobalState singleton] companyId]];
            noRepsAreaPredicate = [NSPredicate predicateWithFormat:@"activeUsers.@count == 0 AND office.region.department.departmentId = %@ AND dateCreated >= %@ AND dateCreated <= %@", [[SRGlobalState singleton] companyId], self.fromDate, self.toDate];
        }
        
        [predicateArray addObject:repFilter];
        // This is so the recently drawn areas with no reps don't get filtered
        [predicateArray addObject:noRepsAreaPredicate];
        
        // Put all the predicates on an OR Predicate
        self.areaRequest.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:(NSArray *)predicateArray];
        
        
        // Fetch
        NSError *error = nil;
        NSArray *coreDataArray = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:self.areaRequest error:&error];
        self.visibleAreaArray = [coreDataArray mutableCopy];
        
    }
        
    if ((self.showRepActiveAreaSwitch.on || self.showRepAreasSwitch.on) && self.repActiveArea) {
        if (![self.visibleAreaArray containsObject:self.repActiveArea]) {
            [self.visibleAreaArray addObject:self.repActiveArea];
        }
    }
    else if(self.repActiveArea){
        [self.visibleAreaArray removeObject:self.repActiveArea];
    }
    
    [self updateMapOverlays];
}

- (void)updateMapViewOverlaysWithOverlays:(NSArray *)overlays
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.overlays];
        NSSet *after = [NSSet setWithArray:overlays];
        
        NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
        [toKeep intersectSet:after];
        
        NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
        [toAdd minusSet:toKeep];
        
        NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
        [toRemove minusSet:after];
        
        [self.mapView addOverlays:[toAdd allObjects] level:MKOverlayLevelAboveLabels];
        [self.mapView removeOverlays:[toRemove allObjects]];
    }];
}

#pragma mark - User Location Helper Methods

- (void)updateVisibleRepLocations
{
    [self removeAnnotationsForClass:[UserLocation class]];
    
    [self fetchVisibleRepLocations];
    
    for (int i=0; i<self.visibleUserLocations.count; i++) {
        UserLocation *tempUserLocation = self.visibleUserLocations[i];
        [self.quadTreeController insertData:dataFromAnnotation(tempUserLocation, [tempUserLocation.latitude doubleValue], [tempUserLocation.longitude doubleValue])];
    }
}

- (void)fetchVisibleRepLocations
{
    if (self.showRepLocationsSwitch.on) {
        NSArray *userLocations = [[SRLocationTracker singleton] getUserLocationsForUserIds:[self getVisibleRepsIds]
                                                                                  fromDate:self.fromDate
                                                                                    toDate:self.toDate];
        self.visibleUserLocations = [NSMutableArray arrayWithArray:userLocations];
    }
}

#pragma mark - Slim Lead Helper Methods

- (void)updateVisibleSlimLeads
{
    [self removeAnnotationsForClass:[SlimLead class]];
    
    [self fetchVisibleSlimLeads];
    
    for (int i=0; i<self.visibleSlimLeads.count; i++) {
        SlimLead *tempSlimLead = self.visibleSlimLeads[i];
        [self.quadTreeController insertData:dataFromAnnotation(tempSlimLead, [tempSlimLead.latitude doubleValue], [tempSlimLead.longitude doubleValue])];
    }
}

- (void)fetchVisibleSlimLeads
{
    if (self.showRepLeadsSwitch.on) {
        NSFetchRequest *slimLeadRequest = [NSFetchRequest fetchRequestWithEntityName:@"SlimLead"];
        NSArray *visibleRepsIds = [self getVisibleRepsIds];
        
        if (self.userType == SRUserTypeManager) {
            slimLeadRequest.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (user.userId != %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.officeId == %@)",
                                         visibleRepsIds, [[SRGlobalState singleton] userId], self.fromDate, self.toDate, [[SRGlobalState singleton] officeId]];
        }
        else if (self.userType == SRUserTypeRegional){
            slimLeadRequest.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.region.regionId == %@)",
                                         visibleRepsIds, self.fromDate, self.toDate, [[SRGlobalState singleton] areaId]];
            [slimLeadRequest setFetchLimit:500];
        }
        else if (self.userType == SRUserTypeAdmin){
            slimLeadRequest.predicate = [NSPredicate predicateWithFormat:@"(user.userId IN %@) AND (dateCreated >= %@) AND (dateCreated <= %@) AND (ANY user.offices.region.department.departmentId == %@)",
                                         visibleRepsIds, self.fromDate, self.toDate, [[SRGlobalState singleton] companyId]];
            [slimLeadRequest setFetchLimit:500];
        }
        
        NSError *slimLeadFetchError = nil;
        NSArray *slimLeads = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:slimLeadRequest error:&slimLeadFetchError];
        
        self.visibleSlimLeads = [NSMutableArray arrayWithArray:slimLeads];
    }
}

- (NSArray *)getVisibleRepsIds
{
    NSMutableArray *visibleRepsIds = [NSMutableArray array];
    for (User *user in self.visibleReps) {
        [visibleRepsIds addObject:user.userId];
    }
    return visibleRepsIds;
}

#pragma mark - Getters

- (Area *)repActiveArea
{
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@",[[SRGlobalState singleton] userId]];
    
    request.predicate = predicate;
    
    NSArray *users = [[[SRGlobalState singleton] managedObjectContext] executeFetchRequest:request error:&error];
    if (users.count > 0) {
        return [[users objectAtIndex:0] activeArea];
    }
    else
        return nil;
}

@end
