//
//  NewGameCell.m
//  TutorialBase
//
//  Created by Stephen Wood on 2/26/14.
//
//

#import "NewGameCell.h"


@implementation NewGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame {
    
    if (self.superview) {
        float cellWidth = 280.0;
        frame.origin.x = (self.superview.frame.size.width - cellWidth)/2;
        frame.size.width = cellWidth;
    }
    
    [super setFrame:frame];
}

- (void)setCell:(Player *)player {
    
    NSString *facebookID = player.facebookID;
    
    //Check if there is a facebook ID, then make a Facebook Picture View
    if (facebookID != nil) {
        FBProfilePictureView *fbPicture = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(1, 1, 52, 52)];
        fbPicture.profileID = nil;
        fbPicture.profileID = facebookID;
        UILabel *fbLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, 230, 30)];
        fbLabel.text = player.fullName;
        [self.contentView addSubview:fbPicture];
        [self.contentView addSubview:fbLabel];
    }
}

@end
