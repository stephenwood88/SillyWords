//
//  DownloadActivityView.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 4/22/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRDownloadActivityView.h"

@interface DownloadActivityView ()

@property (nonatomic, strong) NSNumber *width;

@end

@implementation DownloadActivityView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        NSNumber *ratio = [NSNumber numberWithFloat:(64.0/39.0)];
        self.width = [NSNumber numberWithFloat:2*(self.center.x/[ratio floatValue])];
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x - ([self.width floatValue]/2), self.center.y + 15, [self.width floatValue], 50)];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(self.center.x - 130, self.center.y, 300, 50)];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //NSLog(@"Contents %@", [self description]);
    //[self setFrame:[[UIScreen mainScreen] bounds]];
    [self.statusLabel setFrame:CGRectMake(self.center.x - ([self.width floatValue]/2), self.center.y + 15, [self.width floatValue], 50)];
    [self.progressView setFrame:CGRectMake(self.center.x - ([self.width floatValue]/2), self.center.y, [self.width floatValue], 50)];
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7f]];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.progressView setProgressViewStyle:UIProgressViewStyleBar];
    activityIndicator.center = self.center;
    [activityIndicator startAnimating];
    
    [self.statusLabel setTextColor:[UIColor whiteColor]];
    [self.statusLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.statusLabel];
    [self addSubview:self.progressView];
}

- (void)showWithStatus:(NSString *)message {
    [activityIndicator startAnimating];
}

- (void)setStatus:(NSString *)message {
    [_statusLabel setText:message];
}

- (void)dismiss {
    [activityIndicator stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [self removeFromSuperview];
}

- (void)removeOrientationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)addOrientationNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)setProgress:(float)prog {
    [self.progressView setProgress:prog animated:YES] ;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)resetProgress {
    [self.progressView setProgress:0.0f animated:NO];
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.statusLabel setFrame:CGRectMake(self.center.x - 130, self.center.y + 15, 300, 50)];
    [self.progressView setFrame:CGRectMake(self.center.x - 130, self.center.y, 300, 50)];
}



@end
