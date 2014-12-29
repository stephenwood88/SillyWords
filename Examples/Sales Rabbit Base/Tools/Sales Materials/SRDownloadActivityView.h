//
//  DownloadActivityView.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 4/22/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadActivityView : UIView {
    UIActivityIndicatorView *activityIndicator;
    
}

@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIProgressView *progressView;

- (void)showWithStatus:(NSString *)message;
- (void)setStatus:(NSString *)message;
- (void)setProgress:(float)progress;
- (void)resetProgress;
- (void)dismiss;
- (void)removeOrientationNotification;
- (void)addOrientationNotification;
@end
