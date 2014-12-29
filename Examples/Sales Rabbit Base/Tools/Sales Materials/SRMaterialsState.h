//
//  SRMaterialsState.h
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRGlobalState.h"
#import "SRDownloadActivityView.h"
#import "SRSalesMaterialsViewController.h"

@protocol SalesMaterialsDownloadDelegate <NSObject>

@required
- (void) salesMaterialsDownloadList:(NSArray *)downloadList;

@end

@interface SRMaterialsState : NSObject{
    int numberOfFilesToDownload;
    int totalNumberOfFilesToDownload;
    
    NSMutableArray *materialListTitles;
    NSMutableArray *materialIDs;
    NSMutableArray *materialList;
    NSMutableArray *materialParentFolderIDs;
    NSMutableArray *materialFolders;
    NSMutableArray *materialFavorites;
    NSMutableDictionary *salesMaterials;
    BOOL downloadInProgress;
    NSUInteger currentExpectedTotalBytesToRead;
    
}

+ (SRMaterialsState *)singleton;

// Background downloading
@property (strong, nonatomic) DownloadActivityView *downloadView;
@property (strong, nonatomic) SRSalesMaterialsViewController *salesMaterialView;
@property (strong, nonatomic) UITabBarController *mainTabBar;
@property (weak, nonatomic) UITabBarController *tabBarViewController;

// Sales material download
- (void) checkSalesMaterialsForDownloads: (BOOL)returnResults;
- (void) startBackgroundDownload:(NSArray *)filesToDownload withNumOfFIles:(int)n;
- (void) initializeSalesMaterialsArrays;
- (BOOL) isDownloadInProgress;
@property (weak, nonatomic) NSObject<SalesMaterialsDownloadDelegate> *delegate;

@end
