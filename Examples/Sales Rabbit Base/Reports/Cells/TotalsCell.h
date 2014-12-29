//
//  TotalsCell.h
//  DishTech
//
//  Created by Jeff on 9/9/12.
//
//

#import <UIKit/UIKit.h>

@interface TotalsCell : UITableViewCell

// IBOutlets
@property (strong, nonatomic) IBOutlet UILabel *installsLabel;
@property (strong, nonatomic) IBOutlet UILabel *salesLabel;
@property (strong, nonatomic) IBOutlet UILabel *pendingLabel;
@property (strong, nonatomic) IBOutlet UILabel *notSchedLabel;
@property (strong, nonatomic) IBOutlet UILabel *cancelLabel;
@property (strong, nonatomic) IBOutlet UILabel *chrgbckLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalsLabel;

@property (strong, nonatomic) UIScrollView *columnsScrollView;
@property (strong, nonatomic) UIView *scrollViewShadow;
@property (strong, nonatomic) NSMutableArray *statsLabels;

- (void)updateLabelsWithTotals:(NSDictionary *)totals definitionList:(NSArray *)definitionList;
- (void)setLabelsWithTotals:(NSDictionary *)totals;

@end
