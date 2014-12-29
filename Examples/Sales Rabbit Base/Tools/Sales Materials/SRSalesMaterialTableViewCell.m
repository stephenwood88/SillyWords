//
//  SRSalesMaterialTableViewCell.m
//  Pest Sales
//
//  Created by Jordan Gardner on 1/28/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesMaterialTableViewCell.h"
#import "UIImage+TintColor.h"
#import "SRGlobalState.h"

@implementation SRSalesMaterialTableViewCell

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

- (IBAction)favoriteButtonTapped:(UIButton *)sender
{
    //  Get the appropriate image
    UIColor *accentColor = [[SRGlobalState singleton] accentColor];
    [self.favoriteButton setImage:[[UIImage imageNamed:(self.isFavorite ? @"favorite_unselected.png" : @"favorite_fill.png")] tintedImageWithColor:accentColor] forState:UIControlStateNormal];
    [self.favoriteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    //  Toggle isFavorite
    [self setFavorite:!self.isFavorite];
    
    //  Send updated favorite status to the delegate
    [self.delegate salesMaterialItemWithFileName:self.fileName isFavorite:self.isFavorite];
}

@end
