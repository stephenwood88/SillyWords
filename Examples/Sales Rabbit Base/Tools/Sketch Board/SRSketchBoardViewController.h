//
//  SRSketchBoardViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRSketchBoard.h"
#import "SRPenColorViewController.h"
@interface SRSketchBoardViewController : UIViewController <UIPopoverControllerDelegate, PopupPassData>
{
    //__weak UIPopoverController *myPopover;
    int penSize;
    int penColor;
    NSString *eraserMode;
}

@property (strong, nonatomic) UIBarButtonItem *pensButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;
@property (strong, nonatomic) UIStoryboardPopoverSegue *currentPopoverSegue;
@property (weak, nonatomic) IBOutlet SRSketchBoard *sketchboard;
@property (strong, nonatomic) UIPopoverController *myPopover;

- (void)eraseBoard;
@end
