//
//  HomeCell.m
//  TutorialBase
//
//  Created by Stephen Wood on 2/26/14.
//
//

#import "HomeCell.h"

@implementation HomeCell

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

@end
