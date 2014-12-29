//
//  SRSalesMaterialsBasicViewController.m
//  Original Sales
//
//  Created by Jordan Gardner on 2/11/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesMaterialsBasicViewController.h"
#import "SRServiceCalls.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import "SRSalesMainTabBar.h"
#import "SRMaterialsState.h"
#import "SRFolder.h"
#import "SRFile.h"

@interface SRSalesMaterialsBasicViewController ()

@property (strong, nonatomic) NSString *webViewTitle;
@property (strong, nonatomic) NSMutableArray *materialsToDisplay;

@end

@implementation SRSalesMaterialsBasicViewController

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
    
    [self.collection removeFromSuperview];
    [self.segmentedControl removeFromSuperview];
    
    //  Get items to display
    [self getMaterialsToDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.downloadView addOrientationNotification];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.table  deselectRowAtIndexPath:currentRowSelection animated:YES];
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
    
    cell.text.text = [[self.materialsToDisplay objectAtIndex:indexPath.row] title];
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
    
    cell.image.image = [UIImage imageNamed:[self getFileTypeImage:[self.materialsToDisplay objectAtIndex:indexPath.row]]];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //  Reorder materials
    id itemToMove = [materialList objectAtIndex:sourceIndexPath.row];
    [materialList removeObjectAtIndex:sourceIndexPath.row];
    [materialList insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.salesMaterials setObject:materialList forKey:@"FileName"];
    
    itemToMove = [self.materialIDs objectAtIndex:sourceIndexPath.row];
    [self.materialIDs removeObjectAtIndex:sourceIndexPath.row];
    [self.materialIDs insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.salesMaterials setObject:self.materialIDs forKey:@"IDs"];
    
    itemToMove = [self.materialListTitles objectAtIndex:sourceIndexPath.row];
    [self.materialListTitles removeObjectAtIndex:sourceIndexPath.row];
    [self.materialListTitles insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.salesMaterials setObject:self.materialListTitles forKey:@"Titles"];
    
    itemToMove = [self.materialParentFolderIDs objectAtIndex:sourceIndexPath.row];
    [self.materialParentFolderIDs removeObjectAtIndex:sourceIndexPath.row];
    [self.materialParentFolderIDs insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.salesMaterials setObject:self.materialParentFolderIDs forKey:@"ParentIDs"];
    
    itemToMove = [self.materialFavorites objectAtIndex:sourceIndexPath.row];
    [self.materialFavorites removeObjectAtIndex:sourceIndexPath.row];
    [self.materialFavorites insertObject:itemToMove atIndex:destinationIndexPath.row];
    [self.salesMaterials setObject:self.materialFavorites forKey:@"Favorites"];
    
    //  Save materials
    [self.salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
    [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
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
    if ([file isKindOfClass:[SRFile class]])
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
    if ([[self.materialsToDisplay objectAtIndex:indexPath.row] isKindOfClass:[SRFile class]])
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
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:fileURL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer setFullscreen:YES animated:YES];
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

#pragma mark Opening PDF Reader
- (void) openPDF:(NSString *)fileName title:(NSString *)title{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:[self dataFilePath:fileName] password:phrase];
    document.documentTitle = title;
    
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
    self.navigationItem.rightBarButtonItems = @[self.syncButton, self.editButton];
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
    //  Reload salesMaterials
    [self initializeArrays];
    
    //  Clear the array of dispaly items
    self.materialsToDisplay = [[NSMutableArray alloc] init];
    
//    //  Get each file to display
    for (int i = 0; i < [materialList count]; i++)
    {
        SRFile *newFile = [[SRFile alloc] initWithTitle:[self.materialListTitles objectAtIndex:i] fileName:[materialList objectAtIndex:i] fileID:[self.materialIDs objectAtIndex:i] folderID:[[self.materialParentFolderIDs objectAtIndex:i] intValue] isFavorite:NO];
        
        [self.materialsToDisplay addObject:newFile];
    }
}

- (NSString *)dataFilePath:(NSString *)fileName
{
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
