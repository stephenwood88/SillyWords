//
//  CustomerCell.h
//  DishTech
//
//  Created by Jeff on 9/14/12.
//
//

#import <UIKit/UIKit.h>

@interface CustomerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productLabel;
@property (weak, nonatomic) IBOutlet UILabel *providerLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *installLabel;

- (void)setLabelsWithDictionary:(NSDictionary *)dictionary;

@end
