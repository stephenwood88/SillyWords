//
//  OverviewCell.h
//  DishTech
//
//  Created by Jeff on 9/8/12.
//
//

#import <UIKit/UIKit.h>
#import "Entity.h"

@interface OverviewCell : UITableViewCell

// IBOutlets
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *installsLabel;
@property (strong, nonatomic) IBOutlet UILabel *salesLabel;
@property (strong, nonatomic) IBOutlet UILabel *pendingLabel;
@property (strong, nonatomic) IBOutlet UILabel *notSchedLabel;
@property (strong, nonatomic) IBOutlet UILabel *cancelLabel;
@property (strong, nonatomic) IBOutlet UILabel *chrgbckLabel;

@property (strong, nonatomic) NSMutableArray *statsLabels;
@property (strong, nonatomic) UIScrollView *columnsScrollView;
@property (strong, nonatomic) UIView *scrollViewShadow;




@property (nonatomic) BOOL expanded;

- (void)setLabelsWithEntity:(Entity *)entity;
- (void)updateLabelsWithEntity:(Entity *)entity row:(NSInteger)rowNumber columnDefinitons:(NSArray *)definitions;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end
