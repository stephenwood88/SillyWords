//
//  FacebookCell.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/29/14.
//
//

#import "InviteFacebookCell.h"

@implementation InviteFacebookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCell:(NSString *)facebookID name:(NSString *)facebookFriendName userId:(NSString *)userId url:(NSURL *)url{
    
    self.facebookID = facebookID;
    self.userId = userId;
    self.fbProfilePicture.image =  nil;
    NSData  *data = [NSData dataWithContentsOfURL:url];
    self.facebookFriendNameLabel.text = facebookFriendName;
    self.fbProfilePicture.image = [UIImage imageWithData:data];
    
    
}

@end
