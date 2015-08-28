//
//  FacebookCell.h
//  TutorialBase
//
//  Created by Stephen Wood on 3/29/14.
//
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface FacebookCell : UITableViewCell

@property (weak, nonatomic) NSString *facebookID;
@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *fbPictureView;
@property (weak, nonatomic) IBOutlet UILabel *facebookFriendNameLabel;

- (void)setCell:(NSString *)facebookID name:(NSString *)facebookFriendName userId:(NSString *)userId;

@end
