//
//  SRSalesMaterialTableViewCell.h
//  Pest Sales
//
//  Created by Jordan Gardner on 1/28/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRSalesMaterialCellDelegate <NSObject>

@required
//  method used to tell the SalesMaterialViewer that an item is a favorite
- (void)salesMaterialItemWithFileName:(NSString *)fileName isFavorite:(BOOL)isFavorite;

@end

@interface SRSalesMaterialTableViewCell : UITableViewCell

@property (weak, nonatomic) id<SRSalesMaterialCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (strong, nonatomic) NSString *fileName;
@property (nonatomic, getter=isFavorite) BOOL favorite;

@end
