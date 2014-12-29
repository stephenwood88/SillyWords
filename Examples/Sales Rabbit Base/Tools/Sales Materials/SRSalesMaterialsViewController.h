//
//  SRSalesMaterialsViewController.h
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

enum FileFormatType
{
    PDF_FORMAT,
    SPREADSHEET_FORMAT,
    VIDEO_FORMAT,
    POWERPOINT_FORMAT,
    NOT_SUPPORTED
} fileFormat;



#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ReaderViewController.h"
#import "SRWebViewerViewController.h"
#import "SRDownloadActivityView.h"
#import "SRSalesMaterialCollectionViewCell.h"
#import "SRSalesMaterialTableViewCell.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@class SRFile;

@interface SRSalesMaterialsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource, ReaderViewControllerDelegate, SRSalesMaterialCellDelegate>
{
    BOOL tableViewEditable;
    NSIndexPath *currentRowSelection;
    int numberOfFilesToDownload;
}

@property (strong, nonatomic) UIBarButtonItem *syncButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (strong, nonatomic) NSMutableArray *materialList;
@property (strong, nonatomic) NSMutableArray *materialListTitles;
@property (strong, nonatomic) NSMutableArray *materialIDs;
@property (strong, nonatomic) NSMutableArray *materialParentFolderIDs;
@property (strong, nonatomic) NSMutableArray *materialFavorites;
@property (strong, nonatomic) NSMutableDictionary *salesMaterials;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) DownloadActivityView *downloadView;
@property (nonatomic) BOOL shouldHideTableView;
@property (nonatomic) int currentFolderID;

- (void)setTableEditable:(id)sender;
- (NSString *) getFileTypeImage:(id)file;
- (NSString *) getFileTypeImageForCollectionView:(id)file;
- (int) getFileFormat:(SRFile *)fileName;
- (void) openPDF:(NSString *)fileName title:(NSString *)title;
- (void) playMovie:(NSString *) fileName;
- (void)oneDownloadFinishedWithTitle:(NSString *)title;
- (void)downloadComplete;
- (void) initializeArrays;
- (void)getMaterialsToDisplay;

@end
