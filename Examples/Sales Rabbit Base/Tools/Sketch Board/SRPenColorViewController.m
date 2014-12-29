//
//  SRPenColorViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRPenColorViewController.h"

@interface SRPenColorViewController ()

@end

@implementation SRPenColorViewController
@synthesize delegate, highlightedImage;
@synthesize iPenColor, iPenSize;
@synthesize blackInk;
@synthesize redInk;
@synthesize greenInk;
@synthesize purpleInk;
@synthesize blueInk;
@synthesize yellowInk;
@synthesize pinkInk;
@synthesize grayInk;
@synthesize eraserButton;

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
    passBack = [[NSMutableDictionary alloc] init];
    PenColor = 0;
    PenSize = 9;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setHighlightedPenInk:(int)[iPenColor integerValue]];
    [self setHighlightedPenSize:(int)[iPenSize integerValue]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate returnFromPopup:passBack];
}

- (IBAction)buttonClicked:(id)sender {
    
    UIButton *btnClicked = (UIButton *)sender;
    
    //[passBack setObject:[NSString stringWithFormat:@"%d", btnClicked.tag] forKey:@"PenSize"] ;
    
    if(btnClicked.tag >= 0 && btnClicked.tag <= 8) {
        if(btnClicked.tag != 8) {
            //highlightedImage.alpha = 1.0f;
            // set back to current pen thickness
            if(_smallPen.alpha == 1.0)
                [passBack setObject:[NSString stringWithFormat:@"%d", (int)_smallPen.tag] forKey:@"PenSize"];
            else if(_mediumPen.alpha == 1.0)
                [passBack setObject:[NSString stringWithFormat:@"%d", (int)_mediumPen.tag] forKey:@"PenSize"];
            else if(_largePen.alpha == 1.0)
                [passBack setObject:[NSString stringWithFormat:@"%d", (int)_largePen.tag] forKey:@"PenSize"];
            
            
            highlightedImage.center = btnClicked.center;
            [passBack setObject:@"NO" forKey:@"EraserMode"];
            self.eraserMode = @"NO";
            [self setHighlightedPenSize:PenSize];
            PenColor = (int)btnClicked.tag;
            [passBack setObject:[NSString stringWithFormat:@"%d", (int)btnClicked.tag] forKey:@"PenColor"] ;
        }
        else {
            // The eraser was chosen
            _smallPen.alpha = 0.5f;
            _mediumPen.alpha = 0.5f;
            _largePen.alpha = 0.5f;
            eraserButton.alpha = 1.0f;
            //highlightedImage.alpha = 0.0f;
            [passBack setObject:@"YES" forKey:@"EraserMode"];
        }
        
        
    }
    else {
        // A Pen was picked
        self.eraserMode = @"NO";
        //highlightedImage.alpha = 1.0f;
        PenSize = (int)btnClicked.tag;
        [self setHighlightedPenSize:(int)btnClicked.tag];
        [passBack setObject:[NSString stringWithFormat:@"%d", (int)btnClicked.tag] forKey:@"PenSize"];
        [passBack setObject:@"NO" forKey:@"EraserMode"];
    }
    
//    if ([delegate respondsToSelector:@selector(setEditedSelection:)]) {
//        [[self delegate] returnFromPopup:passBack];
//    }
}

- (IBAction)exitModalView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setHighlightedPenInk:(int) value {
    if([self.eraserMode isEqualToString:@"YES"]) {
        //highlightedImage.alpha = 0.0f;
        [passBack setObject:@"YES" forKey:@"EraserMode"];
    }
    if(value == 0){
        highlightedImage.center = blackInk.center;
    }
    else if(value == 1){
        highlightedImage.center = redInk.center;
    }
    else if(value == 2){
        highlightedImage.center = greenInk.center;
    }
    else if(value == 3){
        highlightedImage.center = purpleInk.center;
    }
    else if(value == 4){
        highlightedImage.center = blueInk.center;
    }
    else if(value == 5){
        highlightedImage.center = yellowInk.center;
    }
    else if(value == 6){
        highlightedImage.center = grayInk.center;
    }
    else if(value == 7){
        highlightedImage.center = pinkInk.center;
    }

    
    PenColor = value;
    [passBack setObject:[NSString stringWithFormat:@"%d", PenColor] forKey:@"PenColor"];
}

- (void) setHighlightedPenSize:(int) value {
    PenSize = value;
    if (value == 0 || value == 9) {
        // highlight first pen
        _smallPen.alpha = 1.0f;
        _mediumPen.alpha = 0.5f;
        _largePen.alpha = 0.5f;
        eraserButton.alpha = 0.5f;
    }
    else if (value == 10) {
        _smallPen.alpha = 0.5f;
        _mediumPen.alpha = 1.0f;
        _largePen.alpha = 0.5f;
        eraserButton.alpha = 0.5f;
    }
    else {
        _smallPen.alpha = 0.5f;
        _mediumPen.alpha = 0.5f;
        _largePen.alpha = 1.0f;
        eraserButton.alpha = 0.5f;
    }
    
    if([self.eraserMode isEqualToString:@"YES"]) {
        _smallPen.alpha = 0.5f;
        _mediumPen.alpha = 0.5f;
        _largePen.alpha = 0.5f;
        eraserButton.alpha = 1.0f;
        [passBack setObject:@"YES" forKey:@"EraserMode"];
    }

    [passBack setObject:[NSString stringWithFormat:@"%d", PenSize] forKey:@"PenSize"];
}

#pragma mark- Supported Orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }else{
        return (interfaceOrientation & UIInterfaceOrientationMaskAll);
    }
}
- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

@end
