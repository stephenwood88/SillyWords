//
//  CheckBoxColumnView.h
//  Pest Sales
//
//  Created by Matthew McArthur on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRCheckBoxColumnView;

@protocol SRCheckBoxColumnViewDelegate <NSObject>

@optional
- (void)checkBoxForView:(SRCheckBoxColumnView *)ColumnView withTitle:(NSString *)title selectionChanged:(BOOL)selected;
- (void)priceFieldForView:(SRCheckBoxColumnView *)columnView withTitle:(NSString *)title priceChanged:(NSString *)newPrice;
@end

@interface SRCheckBoxColumnView : UIView

@property (weak, nonatomic) id <SRCheckBoxColumnViewDelegate> delegate;
@property(nonatomic,strong)UILabel *titleLabel;

-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField;
-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField numberOfColumms:(NSInteger)columns;
-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField numberOfColumms:(NSInteger)columns width:(NSNumber *)width height:(NSNumber *)height;

-(void)setSelectedLabel:(NSString *)labelText selected:(BOOL)selected;
-(void)setSelectedLabels:(NSArray *)selectedLabels;
-(void)setSelectedLabel:(NSString *)labelText withPrice:(NSString *)price selected:(BOOL)selected;
-(void)setSelectedLabelsWithPrices:(NSDictionary *)labelsAndPrices;

@end
