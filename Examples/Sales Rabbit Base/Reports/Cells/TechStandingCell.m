//
//  TechStandingCell.m
//  DishTech
//
//  Created by Jeff on 9/12/12.
//
//

#import "TechStandingCell.h"
#import "SRConstants.h"


@implementation TechStandingCell
{
    NSUInteger NAME_COLUMN_WIDTH;
    NSUInteger COLUMNS_SECTION_WIDTH;
    NSUInteger COLUMN_DIVISION_WIDTH;
}


- (void)updateLabelsWithEntity:(Entity *)entity row:(NSInteger)rowNumber columnDefinitons:(NSArray *)definitions
{
    if (entity.statsStringList.count > 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%d. %@", (int)rowNumber + 1, entity.entityName];
        
        //Remove old labels to put new ones
        for (int i=0; i<self.statsLabels.count; i++) {
            [[self.statsLabels objectAtIndex:i] removeFromSuperview];
        }
        
        [self.columnsScrollView removeFromSuperview];
        [self.scrollViewShadow removeFromSuperview];
        
        //************************** FOR IPAD ***************************************
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){

            NAME_COLUMN_WIDTH = kStandingsReportsNameColumnWidthPad;
            COLUMNS_SECTION_WIDTH = self.contentView.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/entity.statsStringList.count;
            
            self.statsLabels = [[NSMutableArray alloc] initWithCapacity:entity.statsStringList.count];
            
            
            for (int i=0; i<entity.statsStringList.count; i++) {
                UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPad/2, self.nameLabel.frame.origin.y, kColumnStatLabelWidthPad, self.nameLabel.frame.size.height)];
                [newLabel setText:[entity.statsStringList objectAtIndex:i]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                //[newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:15]];
                [self.contentView addSubview:newLabel];
                [self.statsLabels addObject:newLabel];
            }
            
        }
        else{//************************** FOR IPHONE ***************************************
            NAME_COLUMN_WIDTH = kStandingsReportsNameColumnWidthPhone;
            
            COLUMNS_SECTION_WIDTH = self.contentView.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/entity.statsStringList.count;
            
            
            //Set UIScrollView if there is more that it could fit on a cell
            if (entity.statsStringList.count > kColumnsPerPagePhone) {
                self.columnsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(NAME_COLUMN_WIDTH, 0, COLUMNS_SECTION_WIDTH , self.frame.size.height)];
                self.columnsScrollView.contentSize = CGSizeMake(entity.statsStringList.count*(kColumnStatLabelWidthPhone+kColumnArrowButtonWidthPhone), self.frame.size.height);
                self.columnsScrollView.showsHorizontalScrollIndicator = NO;
                
                self.scrollViewShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NAME_COLUMN_WIDTH, self.columnsScrollView.frame.size.height)];
                self.scrollViewShadow.layer.shadowOffset = CGSizeMake(7, 0);
                self.scrollViewShadow.layer.shadowRadius = 2;
                self.scrollViewShadow.layer.shadowOpacity = .1;
                self.scrollViewShadow.backgroundColor = [UIColor whiteColor];
                
                [self.contentView addSubview:self.columnsScrollView];
                [self.contentView addSubview:self.scrollViewShadow];
                [self.contentView sendSubviewToBack:self.scrollViewShadow];
                COLUMN_DIVISION_WIDTH = self.columnsScrollView.contentSize.width/entity.statsStringList.count;
            }
            
            self.statsLabels = [[NSMutableArray alloc] initWithCapacity:entity.statsStringList.count];
            
            
            for (int i=0; i<entity.statsStringList.count; i++) {
                UILabel *newLabel;
                if (entity.statsStringList.count > kColumnsPerPagePhone) {
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, self.contentView.frame.size.height/2 - self.nameLabel.frame.size.height/2, kColumnStatLabelWidthPhone, self.nameLabel.frame.size.height)];
                    [self.columnsScrollView addSubview:newLabel];
                }
                else{
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, self.nameLabel.frame.origin.y, kColumnStatLabelWidthPhone, self.nameLabel.frame.size.height)];
                    [self.contentView addSubview:newLabel];
                }
                [newLabel setText:[entity.statsStringList objectAtIndex:i]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:11]];
                [self.statsLabels addObject:newLabel];
            }

        }
    }
}


- (void)setLabelsWithEntity:(Entity *)entity row:(NSInteger)rowNumber {
    
    self.nameLabel.text = [NSString stringWithFormat:@"%d. %@", (int)rowNumber + 1, entity.entityName];
    self.installsLabel.text = [entity.installs stringValue];
    self.salesLabel.text = [entity.sales stringValue];
    self.cancelLabel.text = [NSString stringWithFormat:@"%@%@", [entity.cancel stringValue], @"%"];
    self.autoPayLabel.text = [NSString stringWithFormat:@"%@", entity.autoPay];
    
}


@end
