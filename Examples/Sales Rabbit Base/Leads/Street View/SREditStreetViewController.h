//
//  SREditStreetViewController.h
//  Dish Sales
//
//  Created by Aaron Brown on 8/15/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SRGlobalState.h"

@protocol EditStreetViewDelegate <NSObject>

@required
- (void)addressEditedStreet:(NSString *)street city:(NSString *)city state:(NSString *)state zip:(NSString *)zip;

@end

@interface SREditStreetViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *administrativeArea;  // State
@property (strong, nonatomic) NSString *locality;  // City
@property (strong, nonatomic) NSString *thoroughfare;  // Street
@property (weak, nonatomic) id<EditStreetViewDelegate> delegate;

@end
