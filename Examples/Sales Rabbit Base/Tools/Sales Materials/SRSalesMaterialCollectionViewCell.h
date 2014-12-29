//
//  SRSalesMaterialCollectionViewCell.h
//  Pest Sales
//
//  Created by Jordan Gardner on 1/14/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRSalesMaterialTableViewCell.h"

@interface SRSalesMaterialCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<SRSalesMaterialCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) NSString *fileName;
@property (nonatomic, getter=isFavorite) BOOL favorite;

@end
