//
//  SRMaterialsState.m
//  Original Sales
//
//  Created by Matthew McArthur on 10/21/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRMaterialsState.h"
#import "SRServiceCalls.h"
#import "SRGlobalState.h"
#import "Constants.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation SRMaterialsState

+ (SRMaterialsState *)singleton {
    static dispatch_once_t once;
    static SRMaterialsState *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void) startBackgroundDownload:(NSArray *)filesToDownload withNumOfFIles:(int)n {
    if (self.salesMaterialView != nil) {
        [self.downloadView setHidden:NO];
        [self.salesMaterialView.syncButton setEnabled:NO];
        [self.salesMaterialView.editButton setEnabled:NO];
    }
    numberOfFilesToDownload = n;
    totalNumberOfFilesToDownload = n;
    downloadInProgress = YES;
    [self initializeSalesMaterialsArrays];
    [self downloadFiles:filesToDownload];
}

- (NSString *)dataFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[SRGlobalState singleton].systemAccountId];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
    
}

- (void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *dataPath = [filePath stringByAppendingPathComponent:directoryName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error])
            ;// success
        else
        {
            NSLog(@"[%@] ERROR: attempting to write create directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

- (void) initializeSalesMaterialsArrays {
    NSString *filePath = [self dataFilePath:kSalesMaterialsFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        salesMaterials = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        [self addSkipBackupAttributeToItemAtURL:filePath];
        
        materialListTitles = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"Titles"]];
        materialIDs = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"IDs"]];
        materialList = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"FileName"]];
        materialParentFolderIDs = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"ParentIDs"]];
        materialFolders = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"Folders"]];
        materialFavorites = [[NSMutableArray alloc] initWithArray:[salesMaterials objectForKey:@"Favorites"]];

        if(materialListTitles == NULL) {
            materialListTitles = [[NSMutableArray alloc] init];
        }
    }
    else {
        // We create a new folder first
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:kSalesMaterialsDirectory];
        
        // We create a new directory
        [self createDirectory:[SRGlobalState singleton].systemAccountId atFilePath:documentsDirectory];
        
        [[NSFileManager defaultManager] createFileAtPath:[self dataFilePath:kSalesMaterialsFileName] contents:nil attributes:nil];
        materialListTitles = [[NSMutableArray alloc] init];
        materialList = [[NSMutableArray alloc] init];
        materialIDs = [[NSMutableArray alloc] init];
        materialParentFolderIDs = [[NSMutableArray alloc] init];
        materialFolders = [[NSMutableArray alloc] init];
        materialFavorites = [[NSMutableArray alloc] init];
        salesMaterials = [[NSMutableDictionary alloc] initWithObjectsAndKeys:materialListTitles, @"Titles", materialIDs, @"IDs", materialList, @"FileName", materialParentFolderIDs, @"ParentIDs", materialFolders, @"Folders", materialFavorites, @"Favorites", nil];
        [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
        [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
    }
    
}

//returns list of Sales Materials that need to be downloaded
- (void) checkSalesMaterialsForDownloads: (BOOL)returnResults {
    SRServiceCalls *serviceCall = [SRServiceCalls singleton];
    [serviceCall getSalesMaterialTreeCompletionHandler:^(BOOL success, NSDictionary *result, NSError *error) {
        
        if (![self.salesMaterialView isKindOfClass:[NSNull class]]) {
            [self.salesMaterialView.syncButton setEnabled:NO];
            [self.salesMaterialView.editButton setEnabled:NO];
        }
        
        if (success) {
            //  Get folder information -- This will be redone
            //  even if an existing structure is found.  So,
            //  set materialFolders to nil and then use the
            //  getFolderInfo: message to reset the structure.
            //NSLog(@"%@", result);
            materialFolders = [[NSMutableArray alloc] init];
            for (NSDictionary *folder in [[result objectForKey:@"Folders"] objectEnumerator])
            {
                
                [self getFolderInfo:folder];
            }

            //  Save salesMaterials
            [salesMaterials setObject:materialFolders forKey:@"Folders"];
            [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
            [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
            
            //  Find files that haven't been downloaded
            NSMutableArray *filesToDownload = [[NSMutableArray alloc] init];

            //  The completion handler result is an NSDictionary that contains the
            //  hierarchical file structure.  This method checks ALL the folders and
            //  subfolders for materials that need to be downloaded.
            [self checkFolderForNewMaterials:result storeInArray:filesToDownload];
            
            numberOfFilesToDownload = (int)[filesToDownload count];
            
            //  Cycle through materials on the device and check if they are still on
            //  the dashboard.
            for (int n = 0; n < [materialIDs count]; n++)
            {
                
                //  Remove file if on device but not on dashboard
                if (! [self checkForSalesMaterialID:[[materialIDs objectAtIndex:n] intValue] inFolder:result])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[self dataFilePath:[materialList objectAtIndex:n]] error:nil];
                    
                    //  Remove from SalesMaterials dictionary
                    [materialListTitles removeObjectAtIndex:n];
                    [materialList removeObjectAtIndex:n];
                    [materialIDs removeObjectAtIndex:n];
                    [materialParentFolderIDs removeObjectAtIndex:n];
                    [materialFavorites removeObjectAtIndex:n];
                
                    [salesMaterials setObject:materialListTitles forKey:@"Titles"];
                    [salesMaterials setObject:materialList forKey:@"FileName"];
                    [salesMaterials setObject:materialIDs forKey:@"IDs"];
                    [salesMaterials setObject:materialParentFolderIDs forKey:@"ParentIDs"];
                    [salesMaterials setObject:materialFavorites forKey:@"Favorites"];
                    
                    //  Save SalesMaterials
                    [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
                    [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
                    
                    if (! [self.salesMaterialView isKindOfClass:[NSNull class]])
                    {
                        [self.salesMaterialView initializeArrays];
                        [self.salesMaterialView.table reloadData];
                        [self.salesMaterialView.collection reloadData];
                    }
                    n--;
                }
            }
            
            //  Delete duplicate files
            //  Find files that need to be deleted on device
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for (int i = 0; i < [materialIDs count]; i++) {
                
                //  Look for duplicates
                for (int j = i + 1; j < [materialIDs count]; j++) {
                    if ([materialIDs objectAtIndex:i] == [materialIDs objectAtIndex:j] && ![indexSet containsIndex:j]) {
                        [indexSet addIndex:j];
                    }
                }
            }
            //  Remove from SalesMaterials dictionary
            if ([indexSet count]) {
                [materialListTitles removeObjectsAtIndexes:indexSet];
                [salesMaterials setObject:materialListTitles forKey:@"Titles"];
                
                [materialList removeObjectsAtIndexes:indexSet];
                [salesMaterials setObject:materialList forKey:@"FileName"];
                
                [materialIDs removeObjectsAtIndexes:indexSet];
                [salesMaterials setObject:materialIDs forKey:@"IDs"];
                
                [materialParentFolderIDs removeObjectsAtIndexes:indexSet];
                [salesMaterials setObject:materialParentFolderIDs forKey:@"ParentIDs"];
                
                [materialFavorites removeObjectsAtIndexes:indexSet];
                [salesMaterials setObject:materialFavorites forKey:@"Favorites"];
                
                //save salesMaterials
                [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
                [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
            }
            
            //  Update the salesMaterialView to reflect any changes not related to
            //  new downloads (i.e. deleted folders or files on dashboard)
            [self.salesMaterialView getMaterialsToDisplay];
            
            //  Download new files, or notify the user that materials are up to date.
            if ([filesToDownload count] != 0) {
                if (returnResults) {
                    [self.delegate salesMaterialsDownloadList:filesToDownload];
                }
                else {
                    [self.downloadView setHidden:NO];
                    
                    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
                    [self startBackgroundDownload:filesToDownload  withNumOfFIles:numberOfFilesToDownload];
                    if (![self.salesMaterialView isKindOfClass:[NSNull class]]) {
                        [self.salesMaterialView.syncButton setEnabled:NO];
                        [self.salesMaterialView.editButton setEnabled:NO];
                    }
                }
                
                [[[self.mainTabBar.viewControllers objectAtIndex:kToolsTab] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", (int)[filesToDownload count]]];
            }
            else {
                if (self.salesMaterialView != nil) {
                    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"No Updates" message:@"Your sales materials are up-to-date." delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
                    [msg show];
                    [self.salesMaterialView.syncButton setEnabled:YES];
                    [self.salesMaterialView.editButton setEnabled:YES];
                    [self.salesMaterialView.table reloadData];
                }
                // TODO: I added this here because timestamp isn't updating. This algorithm needs to be looked at to ensure the timestamp is updated in NSUserDefaults.
                //save updated timestamp for this account
                //store timestamp based on systemAccountID
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *salesMaterialsTimestampDict = [[userDefaults objectForKey:kSalesMaterialsTimestampDictionary] mutableCopy];
                [salesMaterialsTimestampDict setObject:[NSDate date] forKey:[SRGlobalState singleton].systemAccountId];
                [userDefaults setObject:salesMaterialsTimestampDict forKey:kSalesMaterialsTimestampDictionary];
                [userDefaults synchronize];
                [[[self.mainTabBar.viewControllers objectAtIndex:kToolsTab] tabBarItem] setBadgeValue:nil];
            }
        }
        else {
            UIAlertView *alert = [UIAlertView alloc];
            alert = [alert initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
            [alert show];
            if (![self.salesMaterialView isKindOfClass:[NSNull class]]) {
                [self.salesMaterialView.syncButton setEnabled:YES];
                [self.salesMaterialView.editButton setEnabled:YES];
            }
        }
    }];
}

- (void)getFolderInfo:(NSDictionary *)result
{
    //  Get the folders title
    NSMutableDictionary *folder = [[NSMutableDictionary alloc] init];
    
    NSString *title = [result objectForKey:@"Title"];
    NSString *folderID = [result objectForKey:@"SalesMaterialFolderID"];
    NSString *parentFolderID = [result objectForKey:@"ParentFolderID"];
    
    [folder setObject:title forKey:@"Title"];
    [folder setObject:folderID forKey:@"FolderID"];
    [folder setObject:parentFolderID forKey:@"ParentID"];
    
    //  Add the folder info to materialFolders
    [materialFolders addObject:folder];
    
    //  Get information for subfolders
    if ([[result objectForKey:@"Folders"] count] > 0)
    {
        for (NSDictionary *subfolder in [[result objectForKey:@"Folders"] objectEnumerator])
        {
            [self getFolderInfo:subfolder];
        }
    }
}

- (void)checkFolderForNewMaterials:(NSDictionary *)folder storeInArray:(NSMutableArray *)storageArray
{
    //  Enumerate through the folder's sales materials and add any new files
    for (id item in [folder objectForKey:@"SalesMaterials"])
    {
        NSDictionary *newFile = (NSDictionary *)item;
        int fileID = [[newFile objectForKey:@"SalesMaterialID"] intValue];
        
        BOOL fileFound = NO;
        for (int i = 0; i < [materialIDs count]; i++)
        {
            int sd = [[materialIDs objectAtIndex:i] intValue];
            if (fileID == sd)
            {
                fileFound = YES;
                if (![[newFile objectForKey:@"Title"] isEqualToString:[materialListTitles objectAtIndex:i]])
                {
                    //  Save new title for the file
                }
                
                if (![[newFile objectForKey:@"SalesMaterialFolderID"] intValue] == [[materialParentFolderIDs objectAtIndex:i] intValue])
                {
                    //  Save new parentFolderID
                    [materialParentFolderIDs removeObjectAtIndex:i];
                    [materialParentFolderIDs insertObject:[newFile objectForKey:@"SalesMaterialFolderID"] atIndex:i];
                    
                    //  Save sales materials
                    [salesMaterials setObject:materialParentFolderIDs forKey:@"ParentIDs"];
                    [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
                    [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
                }
            }
        }
        
        //  If the file doesn't exist in the list of current materials, add it
        if (! fileFound)
        {
            [storageArray addObject:newFile];
        }
    }
    
    //  If the folder has subfolders, recursively call this method on each one to add any sales materials in subfolders
    if ([[folder objectForKey:@"Folders"] count] > 0)
    {
        for (NSDictionary *subfolder in [[folder objectForKey:@"Folders"] objectEnumerator])
        {
            [self checkFolderForNewMaterials:subfolder storeInArray:storageArray];
        }
    }
}

- (BOOL)checkForSalesMaterialID:(int)materialID inFolder:(NSDictionary *)folder
{
    //  This method returns YES if the file is in the folder, otherwise NO
    BOOL fileFound = NO;
    
    //  Look for file in folder's sales materials
    for (NSDictionary *item in [[folder objectForKey:@"SalesMaterials"] objectEnumerator])
    {
        int dashboardFileID = [[item objectForKey:@"SalesMaterialID"] intValue];    
        if (materialID == dashboardFileID)
        {
            fileFound = YES;
            break;
        }
    }
    
    //  Check any subfolders as well if not found
    if (! fileFound && [[folder objectForKey:@"Folders"] count] > 0)
    {
        for (NSDictionary *subfolder in [[folder objectForKey:@"Folders"] objectEnumerator])
        {
            fileFound = [self checkForSalesMaterialID:materialID inFolder:subfolder];
            if (fileFound)
            {
                break;
            }
        }
    }
    
    return fileFound;
}

- (void)downloadFiles:(NSArray *)results {
    /* Result is an array of dictionaries. A recursive call to do all downloads */
    
    SRServiceCalls *serviceCall = [SRServiceCalls singleton];
    numberOfFilesToDownload--;
    
    NSInteger salesmaterialID = [[[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"SalesMaterialID"]integerValue];
    currentExpectedTotalBytesToRead = [[[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"FileSize"] floatValue];
    //NSLog(@"Results: %@",results);
    [self.downloadView resetProgress];
    [serviceCall getSalesMaterialId:salesmaterialID downloadProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if(![self.downloadView isKindOfClass:[NSNull class]]) {
            [self.downloadView setStatus:[NSString stringWithFormat:@"Downloading %d of %d", (totalNumberOfFilesToDownload - numberOfFilesToDownload),totalNumberOfFilesToDownload]];
            [self.downloadView setProgress:((float)totalBytesRead / (float)currentExpectedTotalBytesToRead)];
        }
        
    } completionHandler:^(BOOL success, NSData *result, NSError *error) {
        if(success) {
            /* Store the file title name */
            NSString *fileTitle = [[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"Title"];
            [materialListTitles addObject:fileTitle];
            [salesMaterials setObject:materialListTitles forKey:@"Titles"];
            
            /* Store the fileID */
            NSString *fileID = [[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"SalesMaterialID"];
            [materialIDs addObject:fileID];
            [salesMaterials setObject:materialIDs forKey:@"IDs"];
            
            /* Store the parentID*/
            NSString *parentID = [[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"SalesMaterialFolderID"];
            [materialParentFolderIDs addObject:parentID];
            [salesMaterials setObject:materialParentFolderIDs forKey:@"ParentIDs"];
            
            /* Store the file name */
            NSString *fileName = [[NSString alloc] initWithString:fileID];
            fileName = [fileName stringByAppendingPathExtension:[[results objectAtIndex:numberOfFilesToDownload] objectForKey:@"Extension"]];
            [materialList addObject:fileName];
            [salesMaterials setObject:materialList forKey:@"FileName"];
            
            /* Set favorite value */
            NSNumber *favoriteValue = [NSNumber numberWithBool:NO]; //  all materials start out with favorite set to NO
            [materialFavorites addObject:favoriteValue];
            [salesMaterials setObject:materialFavorites forKey:@"Favorites"];
            
            [salesMaterials writeToFile:[self dataFilePath:kSalesMaterialsFileName] atomically:YES];
            [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:kSalesMaterialsFileName]];
            
            /* Now we save the downloaded file to disk */
            [result writeToFile:[self dataFilePath:fileName] atomically:YES];
            [self addSkipBackupAttributeToItemAtURL:[self dataFilePath:fileName]];
            
            if (numberOfFilesToDownload > 0) {
                [self downloadFiles:results];
                [[[self.mainTabBar.viewControllers objectAtIndex:kToolsTab] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%i", (numberOfFilesToDownload + 1)]];
                if (self.salesMaterialView != nil) {
                    [self.salesMaterialView oneDownloadFinishedWithTitle:fileTitle];
                }
            }
            else {
                downloadInProgress = NO;
                [self.downloadView dismiss];
                if (![self.salesMaterialView isKindOfClass:[NSNull class]]) {
                    [self.salesMaterialView downloadComplete];
                    [[[self.mainTabBar.viewControllers objectAtIndex:kToolsTab] tabBarItem] setBadgeValue:nil];
                    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                }
                // TODO: This saving of timestamp to NSUserDefaults isn't reached in every instance of updating.
                //save updated timestamp for this account
                //store timestamp based on systemAccountID
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *salesMaterialsTimestampDict = [[userDefaults objectForKey:kSalesMaterialsTimestampDictionary] mutableCopy];
                [salesMaterialsTimestampDict setObject:[NSDate date] forKey:[SRGlobalState singleton].systemAccountId];
                [userDefaults setObject:salesMaterialsTimestampDict forKey:kSalesMaterialsTimestampDictionary];
                [userDefaults synchronize];
            }
        }
        else {
            UIAlertView *alert = [UIAlertView alloc];
            alert = [alert initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:kOk otherButtonTitles:nil];
            [alert show];
            if (self.downloadView != nil) {
                [self.downloadView resetProgress];
                self.downloadView.hidden = YES;
            }
            if (self.salesMaterialView != nil) {
                [self.salesMaterialView.table reloadData];
                [self.salesMaterialView.editButton setEnabled:YES];
                [self.salesMaterialView.syncButton setEnabled:YES];
            }
        }
    }];
}

- (BOOL) isDownloadInProgress {
    return downloadInProgress;
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
@end
