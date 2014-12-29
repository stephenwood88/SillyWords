//
//  SRSalesMaterialCollectionViewCell.m
//  Pest Sales
//
//  Created by Jordan Gardner on 1/14/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRSalesMaterialCollectionViewCell.h"
#import "UIImage+TintColor.h"
#import "SRGlobalState.h"

@implementation SRSalesMaterialCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)favoriteButtonTapped:(UIButton *)sender
{
    //  Get the appropriate image
    UIColor *accentColor = [[SRGlobalState singleton] accentColor];
    
    [self.favoriteButton setBackgroundImage:[[UIImage imageNamed:(self.isFavorite ? @"favorite_unselected.png" : @"favorite_fill.png")] tintedImageWithColor:accentColor] forState:UIControlStateNormal];
    
    //  Toggle isFavorite
    [self setFavorite:!self.isFavorite];
    
    //  Send updated favorite status to the delegate
    [self.delegate salesMaterialItemWithFileName:self.fileName isFavorite:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
