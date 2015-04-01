//
//  NewGameCell.m
//  TutorialBase
//
//  Created by Stephen Wood on 2/26/14.
//
//

#import "GameCell.h"
#import "Game+SillyWords.h"


@implementation GameCell

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

- (void)setCell:(NSDictionary *)game {
    
    if (game != nil) {
        int count = 1;
        float x;
        float y;
        for (id player in [game objectForKey:@"playerList"]) {
            
            // turn each player in each gamme into a Player object
            
//            NSString *facebookID = player.facebookID;
//            FBProfilePictureView *fbPicture;
//            if (facebookID != nil) {
//                x = 1;
//                y = 1 + count*52;
//                fbPicture = [[FBProfilePictureView alloc] initWithFrame:CGRectMake(x, y, 52, 52)];
//                fbPicture.profileID = facebookID;
//            }
//            
//            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 52, y + 12, 150, 30)];
//            nameLabel.text = player.partName;
//            [self.contentView addSubview:fbPicture];
//            [self.contentView addSubview:nameLabel];
//        
//            count ++;
        }
    }
}


@end
