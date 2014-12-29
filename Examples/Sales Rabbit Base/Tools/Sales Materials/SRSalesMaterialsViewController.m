//
//  SalesMaterialsViewController.m
//  Dish Sales
//
//  Created by Barima Kwarteng on 1/29/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRSalesMaterialsViewController.h"
#import "SRServiceCalls.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import "SRSalesMainTabBar.h"
#import "SRMaterialsState.h"
#import "SRFolder.h"
#import "SRFile.h"
#import "UIImage+TintColor.h"

@interface SRSalesMaterialsViewController ()

@property (strong, nonatomic) NSString *webViewTitle;
@property (strong, nonatomic) NSMutableArray *materialsToDisplay;

@end

@implementation SRSalesMaterialsViewController

#pragma mark Constants

#define DEMO_VIEW_CONTROLLER_PUSH FALSE

#pragma mark UIViewController methods

@synthesize materialList;

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
    [self flurryTrack];
    [self initializeArrays];
    
    tableViewEditable = NO;
    [self.table setEditing:tableViewEditable animated:YES];
    
    [self addRightBarButtons];
    self.downloadView = [[DownloadActivityView alloc] init];
    [self.view addSubview:self.downloadView];
    [self.downloadView setHidden:YES];
    
    if ([[SRMaterialsState singleton] isDownloadInProgress]) {
        
        [self.downloadView setHidden:NO];
        
        [self.syncButton setEnabled:NO];
        [self.editButton setEnabled:NO];
        [[SRMaterialsState singleton] setDownloadView:self.downloadView];
        [[SRMaterialsState singleton] setSalesMaterialView:self];
    }
    
    //  Show view based on shouldHideTableView property
    [self.table setHidden:self.shouldHideTableView];
    [self.collection setHidden:!self.shouldHideTableView];

    self.segmentedControl.tintColor = [UIColor whiteColor];
    
    //  Select the appropriate segmented controller option based on which view is displayed
    if (self.shouldHideTableView)
    {
        [self.segmentedControl setSelectedSegmentIndex:1];
    }
    
    //  Get items to display
    [self getMaterialsToDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.downloadView addOrientationNotification];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.table  deselectRowAtIndexPath:currentRowSelection animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 1] isKindOfClass:[SRSalesMaterialsViewController class]]) {
        
        //  Update views to reflect any changes
        SRSalesMaterialsViewController *previousViewController = (SRSalesMaterialsViewController *)[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 1];
        [previousViewController getMaterialsToDisplay];
        [previousViewController.table reloadData];
        [previousViewController.collection reloadData];
        
        //  Set the views to match current views
        [previousViewController.table setHidden:[self.table isHidden]];
        [previousViewController.collection setHidden:[self.collection isHidden]];
        
        //  Set the segmented controller selection according to which view is showing
        [previousViewController.segmentedControl setSelectedSegmentIndex:([previousViewController.table isHidden] ? 1 : 0)];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.downloadView removeOrientationNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark TableView setup
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.materialsToDisplay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"itemCell";
    SRSalesMaterialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //NSLog(@"%@", [[self.materialsToDisplay objectAtIndex:indexPath.row] title]);
    //NSLog(@"%ld", (long)indexPath.row);
    
    if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFolder class]])
    {
        SRFolder *thisFolder = (SRFolder *)[self.materialsToDisplay objectAtIndex:indexPath.row];
        cell.text.text = [thisFolder title];
        [cell.favoriteButton removeFromSuperview];
        
        //  Adjust the cell views to account for the removal of the favorites button
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.image.frame = CGRectMake(20, 2, 40, 40);
            cell.text.frame = CGRectMake(80, 0, 540, 44);
        }
        else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.image.frame = CGRectMake(10, 2, 40, 40);
            cell.text.frame = CGRectMake(60, 11, 220, 20);
        }
    }
    else if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFile class]])
    {
        SRFile *thisFile = (SRFile *)[self.materialsToDisplay objectAtIndex:indexPath.row];
        cell.text.text = [thisFile title];
        [cell setFavorite:[thisFile isFavorite]];
        UIColor *accentColor = [[SRGlobalState singleton] accentColor];
        [cell.favoriteButton setImage:[[UIImage imageNamed:(cell.isFavorite ? @"favorite_fill.png" : @"favorite_unselected.png")] tintedImageWithColor:accentColor] forState:UIControlStateNormal];
        [cell.favoriteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        cell.fileName = [thisFile fileName];
    }

    cell.image.image = [UIImage imageNamed:[self getFileTypeImage:[self.materialsToDisplay objectAtIndex:indexPath.row]]];
    cell.delegate = self;
    
    return cell;
}

#pragma mark CollectionView setup
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.materialsToDisplay count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"itemCell";

    //  Get reuseable cell
    SRSalesMaterialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //  Configure cell...
    if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFolder class]])
    {
        SRFolder *thisFolder = (SRFolder *)[self.materialsToDisplay objectAtIndex:indexPath.row];
        [cell.favoriteButton setHidden:YES];
        cell.textLabel.text = [thisFolder title];
        [cell.textLabel sizeToFit];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.textLabel.frame = CGRectMake(10, 170, 180, cell.textLabel.frame.size.height);
        }
        else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.textLabel.frame = CGRectMake(5, 95, 90, cell.textLabel.frame.size.height);
        }
    }
    else if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFile class]])
    {
        SRFile *thisFile = (SRFile *)[self.materialsToDisplay objectAtIndex:indexPath.row];
        cell.textLabel.text = [thisFile title];
        [cell.textLabel sizeToFit];
        [cell setFavorite:[thisFile isFavorite]];
        [cell.favoriteButton setHidden:NO];
        UIColor *accentColor = [[SRGlobalState singleton] accentColor];
        [cell.favoriteButton setImage:[[UIImage imageNamed:(cell.isFavorite ?  @"favorite_fill.png" : @"favorite_unselected.png")] tintedImageWithColor:accentColor] forState:UIControlStateNormal];
        [cell.favoriteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        cell.fileName = [thisFile fileName];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            cell.textLabel.frame = CGRectMake(45, 170, 145, cell.textLabel.frame.size.height);
        }
        else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.textLabel.frame = CGRectMake(25, 95, 70, cell.textLabel.frame.size.height);
        }
    }

    cell.imageView.image = [UIImage imageNamed:[self getFileTypeImageForCollectionView:[self.materialsToDisplay objectAtIndex:indexPath.row]]];
    cell.delegate = self;
    
    return cell;
}

#pragma mark Table View Editing Section Stuff
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.materialList count] == indexPath.row)
        return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //  deleteRowsAtIndexPaths:
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    /*
     ---REORDERING IS NOT USED AT THIS POINT IN TIME---
     To allow reordering of objects, go to the addRightBarButtons:
     method and add self.editButton to the array of buttons.
     
     Additionaly, go to the valueChanged: method and do the same
     (this makes sure the edit button is displayed when alternating
     between the collection view and the table view).
     */
    
    //  TEMPORARY IMPLEMENTATION
    //  This section reorders the materialsToDisplay array
    id itemToMove = [self.materialsToDisplay objectAtIndex:sourceIndexPath.row];
    [self.materialsToDisplay removeObjectAtIndex:sourceIndexPath.row];
    [self.materialsToDisplay insertObject:itemToMove atIndex:destinationIndexPath.row];
    
    //  Reload collection view to reflect changes in the table view
    [self.collection reloadData];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)setTableEditable:(id)sender
{
    tableViewEditable = !tableViewEditable;
    [self.table setEditing:tableViewEditable animated:NO];
    
    UIBarButtonItem *EditButton = (UIBarButtonItem *)sender;
    if([EditButton.title isEqualToString:@"Edit"])
    {
        [EditButton setTitle:@"Done"];
        [EditButton setStyle:UIBarButtonItemStyleDone];
        [self.syncButton setEnabled:NO];
    }
    else
    {
        [EditButton setTitle:@"Edit"];
        [EditButton setStyle:UIBarButtonItemStyleBordered];
        [self.syncButton setEnabled:YES];
    }
}

- (NSString *) getFileTypeImage:(id)file
{
    //  Get image for table view cell
    if ([file isKindOfClass:[SRFolder class]])
    {
        return @"icon_folder.png";
    }
    else if ([file isKindOfClass:[SRFile class]])
    {
        SRFile *currentFile = (SRFile *)file;
        NSString *fileName = currentFile.fileName;
        
        fileName = [fileName lowercaseString];
        if([fileName rangeOfString:@".pdf"].location != NSNotFound) {
            return @"icon_pdf.png";
        }
        else if(([fileName rangeOfString:@".xls"].location != NSNotFound) || ([fileName rangeOfString:@".xlsx"].location != NSNotFound)) {
            return @"icon_xls.png";
        }
        else if(([fileName rangeOfString:@".pptx"].location != NSNotFound) || ([fileName rangeOfString:@".ppt"].location != NSNotFound)) {
            return @"icon_ppt.png";
        }
        else if([fileName rangeOfString:@".mp3"].location != NSNotFound ||
                [fileName rangeOfString:@".mp4"].location != NSNotFound) {
            return @"icon_video.png";
        }
    }
    return nil;
}

- (NSString *)getFileTypeImageForCollectionView:(id)file
{
    //  Get image for table view cell
    if ([file isKindOfClass:[SRFolder class]])
    {
        return @"icon_large_folder.png";
    }
    else if ([file isKindOfClass:[SRFile class]])
    {
        SRFile *currentFile = (SRFile *)file;
        NSString *fileName = currentFile.fileName;
        
        fileName = [fileName lowercaseString];
        if([fileName rangeOfString:@".pdf"].location != NSNotFound) {
            return @"icon_large_pdf.png";
        }
        else if(([fileName rangeOfString:@".xls"].location != NSNotFound) || ([fileName rangeOfString:@".xlsx"].location != NSNotFound)) {
            return @"icon_large_xls.png";
        }
        else if(([fileName rangeOfString:@".pptx"].location != NSNotFound) || ([fileName rangeOfString:@".ppt"].location != NSNotFound)) {
            return @"icon_large_ppt.png";
        }
        else if([fileName rangeOfString:@".mp3"].location != NSNotFound ||
                [fileName rangeOfString:@".mp4"].location != NSNotFound) {
            return @"icon_large_video.png";
        }
    }
    return nil;
}

- (int) getFileFormat:(SRFile *)file
{
    NSString *fileName = file.fileName;
    fileName = [fileName lowercaseString];
    if([fileName rangeOfString:@".pdf"].location != NSNotFound) {
        return PDF_FORMAT;
    }
    else if([fileName rangeOfString:@".xls"].location != NSNotFound || [fileName rangeOfString:@".xlsx"].location != NSNotFound || ([fileName rangeOfString:@".pptx"].location != NSNotFound) || ([fileName rangeOfString:@".ppt"].location != NSNotFound)) {
        return SPREADSHEET_FORMAT;
    }
    else if([fileName rangeOfString:@".pptx"].location != NSNotFound || ([fileName rangeOfString:@".ppt"].location != NSNotFound)) {
        return POWERPOINT_FORMAT;
    }
    
    else if([fileName rangeOfString:@".mp3"].location != NSNotFound || [fileName rangeOfString:@".mp4"].location != NSNotFound || [fileName rangeOfString:@".mov"].location != NSNotFound) {
        return VIDEO_FORMAT;
    }
    return NOT_SUPPORTED;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    currentRowSelection = indexPath;
    if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFolder class]])
    {
        //  Recursive push to salesMaterialViewController with updated folderID
        SRSalesMaterialsViewController *salesmaterialVC = (SRSalesMaterialsViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SalesMaterialViewer"];
        salesmaterialVC.currentFolderID = [[self.materialsToDisplay objectAtIndex:indexPath.row] folderID];
        [self.navigationController pushViewController:salesmaterialVC animated:YES];
    }
    else if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFile class]])
    {
        SRFile *file = [self.materialsToDisplay objectAtIndex:indexPath.row];
        if([self getFileFormat:file] == PDF_FORMAT) {
            // Open PDF
            [self openPDF:file.fileName title:file.title];
        }
        
        else if([self getFileFormat:file] == VIDEO_FORMAT) {
            // Open Video
            [self playMovie:file.fileName];
        }
        else {
            // Open Other file type
            NSString *fileName = file.title;
            self.webViewTitle = fileName;
            [self performSegueWithIdentifier:@"gotoWebView" sender:fileName];
        }
    }
}

//  method called when a cell's favorite button is tapped.
- (void)salesMaterialItemWithFileName:(NSString *)fileName isFavorite:(BOOL)isFavorite
{
    
    //  Find the corresponding item and set the favorite value
    for (int i = 0; i < [self.materialList count]; i++)
    {
        if ([fileName isEqualToString:[self.materialList objectAtIndex:i]])
        {
            BOOL favoriteValue = [[self.materialFavorites objectAtIndex:i] intValue];
            [self.materialFavorites removeObjectAtIndex:i];
            [self.materialFavorites insertObject:[NSNumber numberWithBool:!favoriteValue] atIndex:i];
            
            [self.salesMaterials setObject:self.materialFavorites forKey:@"Favorites"];
            [self.salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
            [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
            
            break;
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"gotoWebView"]) {
        SRWebViewerViewController *webViewerVC = [segue destinationViewController];
        webViewerVC.fileTitle = self.webViewTitle;
    }
    [[segue destinationViewController] setFileName:sender];
}

- (void) playMovie:(NSString *)fileName
{
    NSString *filepath = [self dataFilePath:fileName];
    
    fileName = [fileName stringByDeletingPathExtension];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:YES animated:YES];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

#pragma mark Collection View methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    currentRowSelection = indexPath;
    if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFolder class]])
    {
        //  Recursive push to salesMaterialViewController with updated folderID
        SRSalesMaterialsViewController *salesmaterialVC = (SRSalesMaterialsViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"SalesMaterialViewer"];
        salesmaterialVC.currentFolderID = [[self.materialsToDisplay objectAtIndex:indexPath.row] folderID];
        salesmaterialVC.shouldHideTableView = YES;
        [self.navigationController pushViewController:salesmaterialVC animated:YES];
    }
    else if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFile class]])
    {
        SRFile *file = [self.materialsToDisplay objectAtIndex:indexPath.row];
        if([self getFileFormat:file] == PDF_FORMAT) {
            // Open PDF
            [self openPDF:file.fileName title:file.title];
        }
        
        else if([self getFileFormat:file] == VIDEO_FORMAT) {
            // Open Video
            [self playMovie:file.fileName];
        }
        else {
            // Open Other file type
            NSString *fileName = file.title;
            self.webViewTitle = fileName;
            [self performSegueWithIdentifier:@"gotoWebView" sender:fileName];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return CGSizeMake(200, 220);
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return CGSizeMake(100, 125);
    }
    else {
        return CGSizeMake(50, 50);
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    /*
     ---REORDERING IS NOT USED AT THIS POINT IN TIME---
     To allow reordering of objects, change the class of the 
     SRSalesMaterialCollectionViewCell's layout to 
     LXReorderableCollectionViewFlowLayout
     */
    
    //  TEMPORARY IMPLEMENTATION
    //  Move the item in the materialsToDisplay array
    id itemToMove = [self.materialsToDisplay objectAtIndex:fromIndexPath.row];
    [self.materialsToDisplay removeObjectAtIndex:fromIndexPath.row];
    [self.materialsToDisplay insertObject:itemToMove atIndex:toIndexPath.row];
    
    //  Reload table view to reflect changes in the collection view
    [self.table reloadData];
}

#pragma mark Segmented controller
- (IBAction)valueChanged:(UISegmentedControl *)sender {
    //  Display appropriate view based on selection
    if ([self.table isHidden]) {
        [self.table setHidden:NO];
        [self.collection setHidden:YES];
        self.navigationItem.rightBarButtonItems = @[self.syncButton];
    }
    else {
        //  Set table editing to NO if necessary
        if (tableViewEditable) {
            [self setTableEditable:self.editButton];
        }
        [self.table setHidden:YES];
        [self.collection setHidden:NO];
        self.navigationItem.rightBarButtonItems = @[self.syncButton];
    }
    
    [self getMaterialsToDisplay];
    [self.table reloadData];
    [self.collection reloadData];
}

#pragma mark Opening PDF Reader
- (void) openPDF:(NSString *)fileName title:(NSString *)title{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:[self dataFilePath:fileName] password:phrase];
    document.documentTitle = title;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
	if (document != nil)
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
		readerViewController.delegate = self;
        readerViewController.pdfFileName = document.fileName;
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
		[self.navigationController pushViewController:readerViewController animated:YES];
        
#else // present in a modal view controller
        
		readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
		//[self presentModalViewController:readerViewController animated:YES];
        [self presentViewController:readerViewController animated:YES completion:nil];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
	}
    
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
	[self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

#pragma mark Rotation Stage
- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return NO;
}

- (void) addRightBarButtons {
    self.syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_sync"] style:UIBarButtonItemStyleBordered target:self action:@selector(getSalesMaterials)];
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(setTableEditable:)];
    self.navigationItem.rightBarButtonItems = @[self.syncButton];
}

- (void)getSalesMaterials {
    if ([[SRMaterialsState singleton] isDownloadInProgress]) {
        UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Updates" message:@"The Download is in Progress" delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
        [msg show];
        return;
    }
    
    [self.syncButton setEnabled:NO];
    [self.editButton setEnabled:NO];
    
    [[SRMaterialsState singleton] setDownloadView:self.downloadView];
    [[SRMaterialsState singleton] setSalesMaterialView:self];
    [[SRMaterialsState singleton] initializeSalesMaterialsArrays];
    [[SRMaterialsState singleton] checkSalesMaterialsForDownloads:NO];
}

//  This method is used to display materials that are in the current folder
- (void)getMaterialsToDisplay
{
    //  This method is called if the current folder is the favorites folder
    if (self.currentFolderID == -1)
    {
        [self getFavoritesToDisplay];
        return;
    }
    
    //  Reload salesMaterials
    [self initializeArrays];
    
    //  Clear the array of dispaly items
    self.materialsToDisplay = [[NSMutableArray alloc] init];
    
    //  Display Favorites folder only in the inital view controller
    if (self.currentFolderID == 0) {
        SRFolder *favorites = [[SRFolder alloc] initWithTitle:@"Favorites" folderID:-1 parentFolderID:0];
        [self.materialsToDisplay addObject:favorites];
    }
    
    //  First, determine which folders should be displayed
    NSArray *folders = [self.salesMaterials objectForKey:@"Folders"];
    for (int i = 0; i < [folders count]; i++)
    {
        NSDictionary *currentFolder = [folders objectAtIndex:i];
        if ([[currentFolder objectForKey:@"ParentID"] intValue] == self.currentFolderID)
        {
            //  Only display the folder if it or any of its subfolders has sales materials to display
            if ([self folderWithIDContainsMaterialsToDisplay:[[currentFolder objectForKey:@"FolderID"] intValue]])
            {
                SRFolder *newFolder = [[SRFolder alloc] initWithTitle:[currentFolder objectForKey:@"Title"] folderID:[[currentFolder objectForKey:@"FolderID"] intValue] parentFolderID:[[currentFolder objectForKey:@"ParentID"] intValue]];
                [self.materialsToDisplay addObject:newFolder];
            }
        }
    }
    
    //  Second, add materials that are in the current folder
    for (int i = 0; i < [materialList count]; i++)
    {
        if ([[self.materialParentFolderIDs objectAtIndex:i] intValue] == self.currentFolderID)
        {
            BOOL favorite = NO;
            if ([[self.materialFavorites objectAtIndex:i] intValue] > 0)
            {
                favorite = YES;
            }

            SRFile *newFile = [[SRFile alloc] initWithTitle:[self.materialListTitles objectAtIndex:i] fileName:[materialList objectAtIndex:i] fileID:[self.materialIDs objectAtIndex:i] folderID:[[self.materialParentFolderIDs objectAtIndex:i] intValue] isFavorite:favorite];
            [self.materialsToDisplay addObject:newFile];
        }
    }
}

- (BOOL)folderWithIDContainsMaterialsToDisplay:(int)folderID
{
    //  Check for materials in the folder
    for (int i = 0; i < [self.materialParentFolderIDs count]; i++)
    {
        if (folderID == [[self.materialParentFolderIDs objectAtIndex:i] intValue])
        {
            return YES;
        }
    }
    //  Check any subfolders for contents
    for (NSDictionary *folder in [self.salesMaterials objectForKey:@"Folders"])
    {
        //  Check if folder is a subfolder
        if ([[folder objectForKey:@"ParentID"] intValue] == folderID)
        {
            //  Check for sales materials
            return [self folderWithIDContainsMaterialsToDisplay:[[folder objectForKey:@"FolderID"] intValue]];
        }
    }
    
    //  If the folder and any subfolders don't have any materials, this folder shouldn't be displayed
    return NO;
}

- (void)getFavoritesToDisplay
{
    //  Get materials
    [self initializeArrays];
    
    //  Reset materialsToDisplay
    self.materialsToDisplay = [[NSMutableArray alloc] init];
    
    //  Gets all materials that are favorites
    for (int i = 0; i < [self.materialFavorites count]; i++)
    {
        BOOL isFavorite = [[self.materialFavorites objectAtIndex:i] intValue];
        if (isFavorite)
        {
            SRFile *newFile = [[SRFile alloc] initWithTitle:[self.materialListTitles objectAtIndex:i] fileName:[materialList objectAtIndex:i] fileID:[self.materialIDs objectAtIndex:i] folderID:[[self.materialParentFolderIDs objectAtIndex:i] intValue] isFavorite:isFavorite];
            [self.materialsToDisplay addObject:newFile];
        }
    }
}

- (NSString *)dataFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[[SRGlobalState singleton] systemAccountId]];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
    
}

-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:directoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error])
            ;// success
        else
        {
            NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

- (void) initializeArrays {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:kSalesMaterialsFileName]]) {
        self.salesMaterials = [[NSMutableDictionary alloc] initWithContentsOfFile:[self dataFilePath:kSalesMaterialsFileName]];
        self.materialListTitles = [[NSMutableArray alloc] initWithArray:[self.salesMaterials objectForKey:@"Titles"]];
        self.materialIDs = [[NSMutableArray alloc] initWithArray:[self.salesMaterials objectForKey:@"IDs"]];
        self.materialList = [[NSMutableArray alloc] initWithArray:[self.salesMaterials objectForKey:@"FileName"]];
        self.materialParentFolderIDs = [[NSMutableArray alloc] initWithArray:[self.salesMaterials objectForKey:@"ParentIDs"]];
        self.materialFavorites = [[NSMutableArray alloc] initWithArray:[self.salesMaterials objectForKey:@"Favorites"]];
        
        if(self.materialListTitles == NULL) {
            self.materialListTitles = [[NSMutableArray alloc] init];
        }
    }
    else {
        // We create a new folder first
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *companyID = [[SRGlobalState singleton] systemAccountId];
        
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:companyID];
        
        // We create a new directory
        [self createDirectory:companyID atFilePath:documentsDirectory];
        
        [[NSFileManager defaultManager] createFileAtPath:[self dataFilePath:kSalesMaterialsFileName] contents:nil attributes:nil];
        [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
        self.materialListTitles = [[NSMutableArray alloc] init];
        self.materialList = [[NSMutableArray alloc] init];
        self.materialIDs = [[NSMutableArray alloc] init];
        self.materialParentFolderIDs = [[NSMutableArray alloc] init];
        self.materialFavorites = [[NSMutableArray alloc] init];
        self.salesMaterials = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.materialListTitles, @"Titles", self.materialIDs, @"IDs", self.materialList, @"FileName", self.materialParentFolderIDs, @"ParentIDs", self.materialFavorites, @"Favorites", nil];
        [self.salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
        [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
    }
    
}

- (void)oneDownloadFinishedWithTitle:(NSString *)title {
    //  Update array of materials to display
    [self getMaterialsToDisplay];
    //  Update table view
    [self.table reloadData];
    //  Update collection view
    [self.collection reloadData];
}

- (void)downloadComplete {
    [self getMaterialsToDisplay];
    [self.table reloadData];
    [self.collection reloadData];
    [self.downloadView setHidden:YES];
    NSDictionary *loginInfo = [[SRGlobalState singleton] loginInfoDictionary];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"%@ %f", [loginInfo objectForKey:@"salesMaterialsUpdatedDate"], [[loginInfo objectForKey:@"salesMaterialsUpdatedDate"] doubleValue]);
    [userDefaults setObject:[loginInfo objectForKey:@"salesMaterialsUpdatedDate"] forKey:@"salesMaterialsTimestamp"];
    [userDefaults synchronize];
    [self.syncButton setEnabled:YES];
    [self.editButton setEnabled:YES];
    
    //remove the "Tools" Badge
    SRSalesMainTabBar *tabBar = (SRSalesMainTabBar *)self.tabBarController;
    [tabBar removeToolsBadge];
}

#pragma mark - Autorotation orientation
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
    
}

- (void)viewWillLayoutSubviews {
    //[self.downloadView setFrame:[[UIScreen mainScreen] bounds]];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URLstring
{
    NSURL *URL = [NSURL fileURLWithPath:URLstring];
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Flurry

- (void) flurryTrack {
//    NSString *username = [[(SRAppDelegate *)[[UIApplication sharedApplication] delegate] SRGlobalState] userName];
//    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
//    
//    [Flurry logEvent:@"Sales Materials opened" withParameters:articleParams timed:YES];
}

@end
