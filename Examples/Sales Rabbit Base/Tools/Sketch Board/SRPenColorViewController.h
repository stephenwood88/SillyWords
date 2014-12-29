//
//  SRPenColorViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupPassData <NSObject>
@required
-(void) returnFromPopup:(NSMutableDictionary*) popupData;
@end

@interface SRPenColorViewController : UIViewController
{
    int PenSize;
    int PenColor;
    
    NSMutableDictionary *passBack;
}
@property (strong, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIImageView *highlightedImage;
@property NSString *iPenSize;
@property NSString *iPenColor;
@property (nonatomic, retain) NSString *eraserMode;
@property (weak, nonatomic) IBOutlet UIButton *blackInk;
@property (weak, nonatomic) IBOutlet UIButton *redInk;
@property (weak, nonatomic) IBOutlet UIButton *greenInk;
@property (weak, nonatomic) IBOutlet UIButton *purpleInk;
@property (weak, nonatomic) IBOutlet UIButton *blueInk;
@property (weak, nonatomic) IBOutlet UIButton *yellowInk;
@property (weak, nonatomic) IBOutlet UIButton *grayInk;
@property (weak, nonatomic) IBOutlet UIButton *pinkInk;

@property (weak, nonatomic) IBOutlet UIButton *smallPen;
@property (weak, nonatomic) IBOutlet UIButton *mediumPen;
@property (weak, nonatomic) IBOutlet UIButton *largePen;
@property (weak, nonatomic) IBOutlet UIButton *eraserButton;

- (IBAction)buttonClicked:(id)sender;
- (IBAction)exitModalView:(id)sender;
@end
