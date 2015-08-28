//
//  InviteViewController.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/27/14.
//
//

#import "InviteViewController.h"
#import "GlobalState.h"
#import "FacebookCell.h"

@interface InviteViewController ()

@end

@implementation InviteViewController

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
    // Do any additional setup after loading the view.
    self.friendsArray = [[NSArray alloc] initWithArray:[[GlobalState singleton] allFriends]];

    
    self.sections = [[NSMutableDictionary alloc] init];
    NSArray *alphabet = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];NSInteger index = 0;
    
    for(NSString *character in alphabet)
    {
        index ++;
        [self.sections setObject:[[NSMutableArray alloc] init] forKey:character];
    }
    
    // Loop again and sort the books into their respective keys
    for (NSDictionary *dictionary in self.friendsArray)
    {
        [[self.sections objectForKey:[[dictionary objectForKey:@"name"] substringToIndex:1]] addObject:dictionary];
    }
    
    // Sort each section array
    for (NSString *key in [self.sections allKeys])
    {
        [[self.sections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.sections allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    FacebookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell"];
    
    if (cell == nil) {
        cell = [[FacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookCell"];
    }
 
    if ([[[GlobalState singleton] allFriends] count] > 0) {
        NSDictionary *dictionary = [[self.sections valueForKey:[[[self.sections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        //NSDictionary *dictionary = [self.friendsArray objectAtIndex:indexPath.row];
        NSString *name = [dictionary objectForKey:@"name"];
        NSString *friendID = [dictionary objectForKey:@"id"];
        [cell setCell:friendID name:name userId:nil];
    }
    
    return cell;
}

#pragma mark UITableView Delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    FacebookCell *cell = (FacebookCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    NSString *facebookID = cell.facebookID;
//    NSMutableDictionary* params =
//   // [NSMutableDictionary dictionaryWithObject:facebookID forKey:@"to"];
//    [NSMutableDictionary dictionaryWithObjectsAndKeys:
//     @"Let's Play Silly Words!", @"name",
//     @"Play a game with this person.", @"description",
//     facebookID, @"to",
////     theUrl, @"al:ios:url",
////     @"688613329", @"al:ios_id",
////     @"Silly Words", @"al:ios:app_name",
//     @"{\"should_fallback\": false}", @"web",
//     [[[FBSession activeSession] accessTokenData] accessToken], @"access_token",
////     [[[FBAppCall ] appLinkData] targetUrl], @"link",
////     @"https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png", @"picture",
//     nil];
//    
//    
//    FBSession *facebookSession = [PFFacebookUtils session]; //You may changed this if you are not using parse.com
//    
//    [FBWebDialogs presentFeedDialogModallyWithSession:facebookSession parameters:params handler:
//     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
//     {
//         if (error)
//         {
//             // Case A: Error launching the dialog or sending request.
//             UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Facebook" message: error.description delegate: nil cancelButtonTitle: @"Ok" otherButtonTitles: nil];
//             [alert show];
//         }
//         else
//         {
//             if (result == (FBWebDialogResultDialogCompleted))
//             {
//                 // Handle the publish feed callback
//                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                 
//                 if ([urlParams valueForKey: @"request"])
//                 {
//                     // User clicked the Share button
//                     NSLog(@"Send");
//                 }
//             }
//         }
//     }];
//}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
