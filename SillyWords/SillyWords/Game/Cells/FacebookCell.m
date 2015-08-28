//
//  FacebookCell.m
//  TutorialBase
//
//  Created by Stephen Wood on 3/29/14.
//
//

#import "FacebookCell.h"

@implementation FacebookCell

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

- (void)setCell:(NSString *)facebookID name:(NSString *)facebookFriendName userId:(NSString *)userId{
    
    self.facebookID = facebookID;
    self.userId = userId;
    [self.fbPictureView setProfileID:nil];
    [self.fbPictureView setProfileID:facebookID];
    
    self.facebookFriendNameLabel.text = facebookFriendName;
    
    //you may have to create the picture view with the url rather than setting the profile id
}

@end
