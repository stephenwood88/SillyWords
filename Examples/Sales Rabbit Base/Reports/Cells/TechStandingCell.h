//
//  TechStandingCell.h
//  DishTech
//
//  Created by Jeff on 9/12/12.
//
//

#import <UIKit/UIKit.h>
#import "Entity.h"

@interface TechStandingCell : UITableViewCell <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *installsLabel;
@property (weak, nonatomic) IBOutlet UILabel *salesLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoPayLabel;
@property (strong, nonatomic) UIScrollView *columnsScrollView;
@property (strong, nonatomic) UIView *scrollViewShadow;

@property (strong, nonatomic) NSMutableArray *statsLabels;


- (void)setLabelsWithEntity:(Entity *)entity row:(NSInteger)rowNumber;
- (void)updateLabelsWithEntity:(Entity *)entity row:(NSInteger)rowNumber columnDefinitons:(NSArray *)definitions;

@end
