//
//  SRWebViewerViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 2/15/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRWebViewerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileTitle;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)close:(id)sender;

@end
