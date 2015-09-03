//
//  FacebookCell.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/29/14.
//
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface InviteFacebookCell : UITableViewCell

@property (weak, nonatomic) NSString *facebookID;
@property (weak, nonatomic) NSString *userId;

@property (weak, nonatomic) IBOutlet UILabel *facebookFriendNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fbProfilePicture;

- (void)setCell:(NSString *)facebookID name:(NSString *)facebookFriendName userId:(NSString *)userId url:(NSURL *)url;

@end
