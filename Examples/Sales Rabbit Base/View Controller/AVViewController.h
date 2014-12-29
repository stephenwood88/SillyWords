//
//  AVViewController.h
//  Dish Sales
//
//  Created by Aaron on 8/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

//  This class contains all code which is commonly used in various view controllers throughout different apps.
//  Any view controller that uses popovers/action sheets in particular should subclass this.
//  If any of these methods need to be overridden, make sure to call super on that method.

#import <UIKit/UIKit.h>

@interface AVViewController : UITableViewController <UITextViewDelegate>

- (void)dismissAll:(BOOL)animated;

@end
