//
//  TotalsCell.m
//  DishTech
//
//  Created by Jeff on 9/9/12.
//
//

#import "TotalsCell.h"
#import "Constants.h"

@implementation TotalsCell
{
    NSUInteger NAME_COLUMN_WIDTH;
    NSUInteger COLUMNS_SECTION_WIDTH;
    NSUInteger COLUMN_DIVISION_WIDTH;
}

- (void)setLabelsWithTotals:(NSDictionary *)totals {
    
    self.installsLabel.text = [[totals objectForKey:kInstallCount] stringValue];
    self.salesLabel.text = [[totals objectForKey:kSaleCount] stringValue];
    self.pendingLabel.text = [[totals objectForKey:kPendingCount] stringValue];
    self.notSchedLabel.text = [[totals objectForKey:kNotScheduledCount] stringValue];
    self.cancelLabel.text = [totals objectForKey:kCancelRate];
    self.chrgbckLabel.text = [totals objectForKey:kChargebackRate];
}

- (void)updateLabelsWithTotals:(NSDictionary *)totals definitionList:(NSArray *)definitionList
{
    if (![totals isKindOfClass:[NSNull class]]  && totals.count > 0) {
        
        //Remove old labels to put new ones
        for (int i=0; i<self.statsLabels.count; i++) {
            [[self.statsLabels objectAtIndex:i] removeFromSuperview];
        }
        
        [self.columnsScrollView removeFromSuperview];
        [self.scrollViewShadow removeFromSuperview];
        
        // *********************************** FOR IPAD *****************************************
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            
            NAME_COLUMN_WIDTH = kOverviewReportsNameColumnWidthPad;
            COLUMNS_SECTION_WIDTH = self.contentView.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/totals.count;
            
            self.statsLabels = [[NSMutableArray alloc] initWithCapacity:totals.count];
            
            
            for (int i=0; i<totals.count; i++) {
                NSString *statName = [[definitionList objectAtIndex:i] objectForKey:@"Name"];
                UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPad/2, self.totalsLabel.frame.origin.y, kColumnStatLabelWidthPad, self.totalsLabel.frame.size.height)];
                [newLabel setText:[NSString stringWithFormat:@"%@",[totals objectForKey:statName]]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                newLabel.adjustsFontSizeToFitWidth = YES;
                //[newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:15]];
                [self.contentView addSubview:newLabel];
                [self.statsLabels addObject:newLabel];
            }
            
        }
        else{     // *********************************** FOR IPHONE *****************************************

            NAME_COLUMN_WIDTH = kOverviewReportsNameColumnWidthPhone;
            
            COLUMNS_SECTION_WIDTH = self.contentView.frame.size.width - NAME_COLUMN_WIDTH;
            COLUMN_DIVISION_WIDTH = COLUMNS_SECTION_WIDTH/totals.count;
            
            //Set UIScrollView if there is more that it could fit on a cell
            if (totals.count > kColumnsPerPagePhone) {
                self.columnsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(NAME_COLUMN_WIDTH, 0, COLUMNS_SECTION_WIDTH , self.frame.size.height)];
                self.columnsScrollView.contentSize = CGSizeMake(totals.count*(kColumnStatLabelWidthPhone+kColumnArrowButtonWidthPhone), self.frame.size.height);
                self.columnsScrollView.showsHorizontalScrollIndicator = NO;
                
                self.scrollViewShadow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NAME_COLUMN_WIDTH, self.columnsScrollView.frame.size.height)];
                self.scrollViewShadow.layer.shadowOffset = CGSizeMake(7, 0);
                self.scrollViewShadow.layer.shadowRadius = 2;
                self.scrollViewShadow.layer.shadowOpacity = .1;
                //self.scrollViewShadow.backgroundColor = [UIColor whiteColor];
                self.scrollViewShadow.backgroundColor = self.backgroundColor;
                
                [self.contentView addSubview:self.columnsScrollView];
                [self.contentView insertSubview:self.scrollViewShadow belowSubview:self.totalsLabel];
                
                COLUMN_DIVISION_WIDTH = self.columnsScrollView.contentSize.width/totals.count;
            }
            
            self.statsLabels = [[NSMutableArray alloc] initWithCapacity:totals.count];
            
            
            for (int i=0; i<totals.count; i++) {
                UILabel *newLabel;
                if (totals.count > kColumnsPerPagePhone) {
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, self.contentView.frame.size.height/2 - self.totalsLabel.frame.size.height/2, kColumnStatLabelWidthPhone, self.totalsLabel.frame.size.height)];
                    [self.columnsScrollView addSubview:newLabel];
                }
                else{
                    newLabel = [[UILabel alloc] initWithFrame:CGRectMake((NAME_COLUMN_WIDTH + COLUMN_DIVISION_WIDTH*i + COLUMN_DIVISION_WIDTH/2) - kColumnStatLabelWidthPhone/2, self.totalsLabel.frame.origin.y, kColumnStatLabelWidthPhone, self.totalsLabel.frame.size.height)];
                    [self.contentView addSubview:newLabel];
                }
                NSString *statName = [[definitionList objectAtIndex:i] objectForKey:@"Name"];
                [newLabel setText:[NSString stringWithFormat:@"%@",[totals objectForKey:statName]]];
                [newLabel setTextAlignment:NSTextAlignmentCenter];
                [newLabel setFont:[UIFont fontWithName:@"Avenir Heavy" size:11]];
                newLabel.adjustsFontSizeToFitWidth = YES;
                [self.statsLabels addObject:newLabel];
            }
            
        }
    }
}


- (id)checkForNSNull:(id)object {
    
    if ([object class] == [NSNull class]) {
        return nil;
    }
    return object;
}

@end
