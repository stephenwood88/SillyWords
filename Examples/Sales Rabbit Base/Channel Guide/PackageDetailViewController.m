//
//  PackageDetailViewController.m
//  DishTech
//
//  Created by Brady Anderson on 1/8/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "PackageDetailViewController.h"
#import "NSDictionary+MutableDeepCopy.h"
#import "Channel.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import "Constants.h"

@interface PackageDetailViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableDictionary *mutableChannelDictionary;
@property (strong, nonatomic) NSDictionary *channelDictionary;
@property (strong, nonatomic) NSMutableArray *headerNames;
@property (strong, nonatomic) NSArray *allChannelsByNumber;
@property (strong, nonatomic) NSMutableArray *currentChannels;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) BOOL sortedByNumber;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegmentControl;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)loadDataFromCSVFileNamed:(NSString *) fileName;

@end

@implementation PackageDetailViewController

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
    
    self.sortSegmentControl.tintColor = [UIColor whiteColor];
    self.navigationItem.title = self.packageName;
    [self loadDataFromCSVFileNamed:self.csvFileName];
    [self resetSearch];
    
    [self.packageDetailTable reloadData];
    
    //Segmented control tint color bug workaround for ios7
    self.segmentedControl.tintColor = [UIColor blackColor];
    self.segmentedControl.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self flurryTrack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.sortedByNumber) {
        return 1;
    }
    return self.headerNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sortedByNumber) {
        return self.currentChannels.count;
    }
    else if ([self.headerNames count] == 0)
        return 0;
    
    NSString *key = [self.headerNames objectAtIndex:section];
    NSArray *channelSection = [self.mutableChannelDictionary objectForKey:key];
    return channelSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelDetailCell"];
    
    if (self.sortedByNumber) {
        cell.textLabel.text = [[self.currentChannels objectAtIndex:indexPath.row] number];
        cell.detailTextLabel.text = [[self.currentChannels objectAtIndex:indexPath.row] name];
    }
    else{
        NSString *key = [self.headerNames objectAtIndex:indexPath.section];
        NSArray *channelSection = [self.mutableChannelDictionary objectForKey:key];
        cell.textLabel.text = [[channelSection objectAtIndex:indexPath.row] name];
        cell.detailTextLabel.text = [[channelSection objectAtIndex:indexPath.row] number];
        cell.detailTextLabel.textColor = [[SRGlobalState singleton] accentColor];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.headerNames count] == 0 || self.searchBar.text.length > 0 || self.sortedByNumber)
        return nil;
    
    NSString *header = [self.headerNames objectAtIndex:section];
    if (header == UITableViewIndexSearch)
        return nil;
    return header;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.searchBar.text.length > 0 || self.sortedByNumber)
        return nil;
    return self.headerNames;
}


#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = [self.headerNames objectAtIndex:index];
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    } else return index;
}

#pragma mark - Custom Search Methods

- (void)resetSearch {
    self.mutableChannelDictionary = [self.channelDictionary mutableDeepCopy];
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObject:UITableViewIndexSearch];
    [keyArray addObjectsFromArray:[[self.channelDictionary allKeys]
                                   sortedArrayUsingSelector:@selector(compare:)]];
    self.headerNames = keyArray;
    self.currentChannels = [self.allChannelsByNumber mutableCopy];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    [self resetSearch];

    if (self.sortedByNumber) {
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        for (Channel *channel in self.currentChannels) {
            if ([channel.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound && [channel.number rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound){
                [toRemove addObject:channel];
            }
        }
        [self.currentChannels removeObjectsInArray:toRemove];
    }
    else{
        NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
        for (NSString *key in self.headerNames) {
            NSMutableArray *array = [self.mutableChannelDictionary valueForKey:key];
            NSMutableArray *toRemove = [[NSMutableArray alloc] init];
            for (Channel *channel in array) {
                if ([channel.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound && [channel.number rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound){
                    [toRemove addObject:channel];
                }
            }
            if ([array count] == [toRemove count]){
                [sectionsToRemove addObject:key];
            }
            [array removeObjectsInArray:toRemove];
        }
        [self.headerNames removeObjectsInArray:sectionsToRemove];
    }

    [self.packageDetailTable reloadData];
}




#pragma mark - Search Bar Delegate Methods\

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    [self handleSearchForTerm:searchTerm];
    //[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    [self.headerNames removeAllObjects];
    
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [self.packageDetailTable reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.isSearching = NO;
    searchBar.text = @"";
    [self resetSearch];
    [self.packageDetailTable reloadData];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.packageDetailTable reloadData];
}

#pragma mark - Custom Class methods

- (IBAction)sortControlChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: // Alphabetical sort
            self.sortedByNumber = NO;
            break;
        case 1: // Channel Number sort
            self.sortedByNumber = YES;
            break;
        default:
            break;
    }
    [self.packageDetailTable reloadData];
}

- (void)loadDataFromCSVFileNamed:(NSString *) fileName{
    // Path for CSV File
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"csv"];
    NSError *outError;
    NSString *fileString = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:&outError];
    if (!fileString) {
        NSLog(@"Error reading file.");
    }
    
    //Scan csv file
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
    //Characters to skip
    NSMutableCharacterSet *skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@","];
    [skippedCharacters formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    [scanner setCharactersToBeSkipped:skippedCharacters];
    //The parsing of the csv file and storing the data in a dictionary
    NSCharacterSet *newLine = [NSCharacterSet newlineCharacterSet];
    NSString *channelNumber = nil, *channelName = nil, *channelAbbreviation;
    self.mutableChannelDictionary = [[NSMutableDictionary alloc] init];
    self.currentChannels = [[NSMutableArray alloc] init];

    while ([scanner scanUpToString:@"," intoString:&channelAbbreviation] && [scanner scanUpToString:@"," intoString:&channelName] && [scanner scanUpToCharactersFromSet:newLine intoString:&channelNumber]) {
        //Process the values as needed.
        //Create channel object
        Channel *theChannel = [[Channel alloc]init];
        theChannel.abbreviation = channelAbbreviation;
        theChannel.name = channelName;
        theChannel.number = channelNumber;
        NSString *firstLetter = [[channelName substringToIndex:1] uppercaseString];
        [self.currentChannels addObject:theChannel];
        if ([self.mutableChannelDictionary objectForKey:firstLetter]) {
            [[self.mutableChannelDictionary objectForKey:firstLetter] addObject:theChannel];
        }
        else{
            [self.mutableChannelDictionary setObject:[[NSMutableArray alloc] initWithObjects:theChannel, nil] forKey:firstLetter];
        }
    }
    
    NSArray *arrayTemp = [self.currentChannels sortedArrayUsingSelector: @selector(compareWithAnotherChannel:)];
    self.currentChannels = (NSMutableArray *)arrayTemp;
    self.allChannelsByNumber = (NSMutableArray *)arrayTemp;
    self.channelDictionary = self.mutableChannelDictionary;
    NSArray *array = [[self.channelDictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
    self.headerNames = (NSMutableArray *)array;
}

- (void) flurryTrack {
    NSString *username = [[SRGlobalState singleton] userName];
    NSDictionary *articleParams = [NSDictionary dictionaryWithObjectsAndKeys:username, @"User", @"Registered", @"User_Status", nil];
    
    [Flurry logEvent:@"Package Details View Opened" withParameters:articleParams timed:YES];
}

@end
