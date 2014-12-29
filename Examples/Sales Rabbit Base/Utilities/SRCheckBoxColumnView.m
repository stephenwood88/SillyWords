//
//  CheckBoxColumnView.m
//  Pest Sales
//
//  Created by Matthew McArthur on 1/15/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRCheckBoxColumnView.h"
#import "ResizingLabel.h"

#define kLabelWidth 85.0
#define kLabelHeight 38.0

#define kCheckBoxWidth 20.0
#define kCheckBoxHeight 20.0

#define kPriceFieldWidth 40.0
#define kPriceFieldHeight 30.0

#define kHeaderSize 22

#define kInitialsWidth 75.0
#define kInitialsHeight 30.0

#define kPadding 5

#define kLabelTag 200
#define kPriceFieldTag 300
#define kPriceLabelTag 400
#define kInitalsButtonTag 500
#define kButtonTag 600
#define kButtonBKGTag 700

#define kFontSize 20.0
#define kTitleLabelSize 15.0

#define kBox @"\u2610"
#define kCheckedBox @"\u2611"

@implementation SRCheckBoxColumnView
{
    CGFloat globalFontSize;
    BOOL globalPriceIncluded;
    BOOL hasInitials;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Constructors

-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField
{
    globalPriceIncluded = includePriceField;
    //Use Default Values
    NSInteger numberOfColumns;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (includePriceField) {
            numberOfColumns = 2;
        }else{
            numberOfColumns = 3;
        }
    }else{
        if (includePriceField) {
            numberOfColumns = 4;
        }else{
            numberOfColumns = 6;
        }
    }
    return [self initWithContentList:contentList withPriceField:includePriceField numberOfColumms:numberOfColumns];
}

-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField numberOfColumms:(NSInteger)columns
{
    globalPriceIncluded = includePriceField;
    return [self initWithContentList:contentList withPriceField:includePriceField numberOfColumms:columns width:0 height:0];
}

-(id)initWithContentList:(NSArray *)contentList withPriceField:(BOOL)includePriceField numberOfColumms:(NSInteger)columns width:(NSNumber *)width height:(NSNumber *)height
{
    globalPriceIncluded = includePriceField;
    // Get bounding sizes and init yourself
    // Remember what the final width and height should be, but for now we just set the standard size
    // then resize the whole view at once
    CGFloat finalHeight = [height floatValue];
    CGFloat finalWidth = [width floatValue];
    if (height == 0) {
        finalHeight = [[self getViewsHeightForContentList:contentList andColumns:columns] floatValue];
    }
    if (width == 0) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        finalWidth = bounds.size.width;
    }
    if (includePriceField) {
        width = [NSNumber numberWithFloat:(columns * (kCheckBoxWidth + kPadding + kLabelWidth + kPadding + kPriceFieldWidth))];
    }else{
        width = [NSNumber numberWithFloat:(columns * (kCheckBoxWidth + kPadding + kLabelWidth))];
    }
    height = [NSNumber numberWithFloat:[[self getViewsHeightForContentList:contentList andColumns:columns] floatValue]];
    self = [super initWithFrame:CGRectMake(0, 0, [width floatValue], [height floatValue])];
    
    // Calculate the size we have available for labels
    CGFloat deltaX = ([width floatValue])/[[NSNumber numberWithInt:(int)columns] floatValue];
    
    //Starting position
    int x = 25;
    int y = kHeaderSize;
    //Create labels for every item
    for (int j = 0; j < contentList.count; j++)
    {
        //Moving left to right
        //Set up Check Box button
        UIButton *checkBoxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, kCheckBoxWidth, kCheckBoxHeight)];
        [checkBoxButton.titleLabel setFont:[UIFont fontWithName:@"ArialUnicodeMS" size:20]];
        [checkBoxButton setTitle:kBox forState:UIControlStateNormal];
        [checkBoxButton setTitle:kCheckedBox forState:UIControlStateSelected];
//        [checkBoxButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
        [checkBoxButton setTag:j+kButtonTag];
        [checkBoxButton.titleLabel setMinimumScaleFactor:0.000000000005];
        checkBoxButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        UIButton *checkBoxButtonBKG = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, kCheckBoxWidth+15, kCheckBoxHeight+15)];
        [checkBoxButtonBKG addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
        [checkBoxButtonBKG setTag:j+kButtonBKGTag];
        [checkBoxButtonBKG.titleLabel setMinimumScaleFactor:0.75];
        
        UIView *labelView = nil;
        
        if (includePriceField) {
            //Set up the Price Label
            ResizingLabel *priceLabel = [[ResizingLabel alloc] initWithFrame:CGRectMake(kCheckBoxWidth + kPadding, 10, kPriceFieldWidth, kPriceFieldHeight)];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                priceLabel.text = @"$____";
            }else{
                priceLabel.text = @"$______";
            }
            [priceLabel setFont:[UIFont systemFontOfSize:kFontSize]];
            [priceLabel setNumberOfLines:1];
            [priceLabel setMinimumScaleFactor:0.0000005];
            [priceLabel setTag:j+kPriceLabelTag];
            
            UITextField *priceField = [[UITextField alloc] initWithFrame:CGRectMake(kCheckBoxWidth + kPadding + 6, 10, kPriceFieldWidth-6, kPriceFieldHeight)];
            [priceField setFont:[UIFont systemFontOfSize:kFontSize]];
            [priceField setMinimumFontSize:0.0005];
            [priceField setTag:j+kPriceFieldTag];
            priceField.enabled = NO;
            [priceField addTarget:self action:@selector(specializedTextFieldEdited:) forControlEvents:UIControlEventAllEditingEvents];
            [priceField setKeyboardType:UIKeyboardTypeNumberPad];
            
            //Create Content Label
            ResizingLabel *contentLabel = [[ResizingLabel alloc] initWithFrame:CGRectMake(kCheckBoxWidth + kPadding + kPriceFieldWidth + kPadding, 2, kLabelWidth, kLabelHeight)];
            contentLabel.text = contentList[j];
            [contentLabel setFont:[UIFont systemFontOfSize:kFontSize]];
            [contentLabel setNumberOfLines:2];
            [contentLabel setMinimumScaleFactor:0.000000005];
            [contentLabel setTag:j+kLabelTag];
            contentLabel.adjustsFontSizeToFitWidth = YES;
            
            labelView = [[UIView alloc] initWithFrame:CGRectMake(x, y, kCheckBoxWidth + kPadding + kPriceFieldWidth + kPadding + kLabelWidth, 38)];
            [labelView addSubview:priceLabel];
            [labelView addSubview:priceField];
            [labelView addSubview:contentLabel];
        }else{
            //Create Content Label
            ResizingLabel *contentLabel = [[ResizingLabel alloc] initWithFrame:CGRectMake(kCheckBoxWidth + kPadding, 2, kLabelWidth, kLabelHeight)];
            contentLabel.text = contentList[j];
            [contentLabel setFont:[UIFont systemFontOfSize:kFontSize]];
            [contentLabel setNumberOfLines:2];
            [contentLabel setMinimumScaleFactor:0.000000005];
            [contentLabel setTag:j+kLabelTag];
            contentLabel.adjustsFontSizeToFitWidth = YES;
            
            labelView = [[UIView alloc] initWithFrame:CGRectMake(x, y, kCheckBoxWidth + kPadding + kLabelWidth, 38)];
            [labelView addSubview:contentLabel];
        }
        [labelView setTag:j];
        [labelView addSubview:checkBoxButton];
        [labelView addSubview:checkBoxButtonBKG];
        
        //Set the autoresizing mask for the view and all of its subviews.
        for (UIView *subview in labelView.subviews) {
            subview.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth);
            //subview.backgroundColor = [UIColor clearColor];
        }
        labelView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleBottomMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleHeight |
                                      UIViewAutoresizingFlexibleWidth);
        
        [self addSubview:labelView];
        
        x = x+deltaX;
        if ((j+1)%columns==0  && j != 0) {
            y=y+44;
            x=25;
        }
    }
    
    // set your own autoresizing mask
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                             UIViewAutoresizingFlexibleRightMargin |
                             UIViewAutoresizingFlexibleBottomMargin |
                             UIViewAutoresizingFlexibleTopMargin |
                             UIViewAutoresizingFlexibleWidth |
                             UIViewAutoresizingFlexibleHeight);
    self.autoresizesSubviews = YES;
    
    //Change the bounds size to the ones we want and let the view resize all of its subviews for us.
    [self setBounds:CGRectMake(0, 0, finalWidth-30, finalHeight)];
    [self setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                             UIViewAutoresizingFlexibleRightMargin |
                             UIViewAutoresizingFlexibleBottomMargin |
                             UIViewAutoresizingFlexibleTopMargin |
                             UIViewAutoresizingFlexibleWidth);
    [self setGlobalFontSize];
    //Create the Title Label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.bounds.size.width, kHeaderSize)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelSize];
    [self addSubview:self.titleLabel];
    //    if (includePriceField) {
    //        [self resetPriceFiedPosition];
    //    }
    return self;
}

#pragma mark - Setters

-(void)setSelectedLabel:(NSString *)labelText selected:(BOOL)selected
{
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        if (label && [label.text isEqualToString:labelText]) {
            UIButton *button = (UIButton *)[subview viewWithTag:(subview.tag + kButtonTag)];
            button.selected = selected;
            break;
        }
    }
}

-(void)setSelectedLabels:(NSArray *)selectedLabels
{
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        UIButton *button = (UIButton *)[subview viewWithTag:(subview.tag + kButtonTag)];
        if (label && [selectedLabels containsObject:label.text]) {
            button.selected = YES;
        }else if(label){
            button.selected = NO;
        }
    }
}

-(void)setSelectedLabel:(NSString *)labelText withPrice:(NSString *)price selected:(BOOL)selected
{
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        if (label && [label.text isEqualToString:labelText]) {
            UIButton *button = (UIButton *)[subview viewWithTag:(subview.tag + kButtonTag)];
            button.selected = selected;
            UITextField *priceField = (UITextField *)[subview viewWithTag:(subview.tag + kPriceFieldTag)];
            priceField.enabled = YES;
            priceField.text = price;
            priceField.font = [priceField.font fontWithSize:[self requiredFontSizeForTextField:priceField]];
            break;
        }
    }
}

-(void)setSelectedLabelsWithPrices:(NSDictionary *)labelsAndPrices
{
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        UIButton *button = (UIButton *)[subview viewWithTag:(subview.tag + kButtonTag)];
        UITextField *priceField = (UITextField *)[subview viewWithTag:(subview.tag + kPriceFieldTag)];
        if (label && labelsAndPrices[label.text]) {
            button.selected = YES;
            priceField.text = labelsAndPrices[label.text];
            priceField.font = [priceField.font fontWithSize:[self requiredFontSizeForTextField:priceField]];
            priceField.enabled = YES;
        }else if(label)
        {
            button.selected = NO;
            priceField.text = @"";
            priceField.enabled = NO;
        }
    }
}

#pragma mark - UIView methods

-(void)layoutSubviews{
    [super layoutSubviews];
    [self setGlobalFontSize];
    //    if (globalPriceIncluded) {
    //        [self resetPriceFiedPosition];
    //    }
}

#pragma mark - IBActions


-(void)checkBoxPressed:(UIButton *)aButton
{
    UIButton *checkBoxButton = (UIButton *)[aButton.superview viewWithTag:(aButton.superview.tag + kButtonTag)];
    checkBoxButton.selected = !checkBoxButton.selected;
    UITextField *priceField = (UITextField *)[aButton.superview viewWithTag:(aButton.superview.tag + kPriceFieldTag)];
    UILabel *label = (UILabel *)[aButton.superview viewWithTag:(aButton.superview.tag + kLabelTag)];
    if (priceField) {
        if (checkBoxButton.selected ) {
            priceField.enabled = YES;
            [priceField sendActionsForControlEvents:UIControlEventTouchUpInside];
            [priceField becomeFirstResponder];
        }else{
            priceField.enabled = NO;
            priceField.text = @"";
        }
    }
    
    [self.delegate checkBoxForView:self withTitle:label.text selectionChanged:checkBoxButton.selected];
}

-(void)specializedTextFieldEdited:(UITextField *)priceField
{
    UILabel *label = (UILabel *)[priceField.superview viewWithTag:(priceField.superview.tag + kLabelTag)];
    [self.delegate priceFieldForView:self withTitle:label.text priceChanged:priceField.text];
    
    priceField.font = [priceField.font fontWithSize:[self requiredFontSizeForTextField:priceField]];
}

#pragma mark - Helper Methods

-(NSNumber *)getViewsHeightForContentList:(NSArray *)contentList andColumns:(NSInteger)columns
{
    int height = ceil([contentList count] / [[NSNumber numberWithInt:(int)columns] floatValue]);
    return [NSNumber numberWithFloat:(height*44.0+kHeaderSize)];
}

- (CGFloat)requiredFontSizeForTextField:(UITextField *)textField
{
    const CGRect  textBounds = [textField textRectForBounds:textField.frame];
    const CGFloat maxWidth   = textBounds.size.width;
    
    CGFloat originalFontSize = globalFontSize;
    
    UIFont* font = textField.font;
    CGFloat fontSize = originalFontSize;
    
    BOOL found = NO;
    do
    {
        if( font.pointSize != fontSize )
        {
            font = [font fontWithSize:fontSize];
        }
        NSDictionary *attributes = @{ NSFontAttributeName : font};
        CGSize size = [textField.text sizeWithAttributes:attributes];
        if( size.width <= maxWidth )
        {
            found = YES;
            break;
        }
        
        fontSize -= 1.0;
        if( fontSize < textField.minimumFontSize )
        {
            break;
        }
        
    } while( TRUE );
    
    return( fontSize );
}

- (CGFloat)requiredFontSizeForLabel:(UILabel *)label
{
    if (!label) {
        return kFontSize;
    }
    CGFloat originalFontSize = kFontSize;
    
    UIFont* font = label.font;
    CGFloat fontSize = originalFontSize;
    
    BOOL found = NO;
    do
    {
        if( font.pointSize != fontSize )
        {
            font = [font fontWithSize: fontSize];
        }
        if([self wouldThisFont:font workForThisLabel:label])
        {
            found = YES;
            break;
        }
        
        fontSize -= 0.1;
        if( fontSize < (label.minimumScaleFactor * label.font.pointSize))
        {
            break;
        }
        
    } while( TRUE );
    
    return( fontSize );
}

-(void)setGlobalFontSize
{
    CGFloat minFontSize = kFontSize;
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        if (label && [self requiredFontSizeForLabel:label] < minFontSize) {
            minFontSize = [self requiredFontSizeForLabel:label];
        }
    }
    for (UIView *subview in self.subviews) {
        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
        UITextField *textField = (UITextField *)[subview viewWithTag:(subview.tag + kPriceFieldTag)];
        UILabel *priceLabel = (UILabel *)[subview viewWithTag:(subview.tag + kPriceLabelTag)];
        [textField setFont:[textField.font fontWithSize:minFontSize]];
        [label setFont:[label.font fontWithSize:minFontSize]];
        [priceLabel setFont:[priceLabel.font fontWithSize:[self requiredFontSizeForLabel:priceLabel]]];
    }
    globalFontSize = minFontSize;
}


- (BOOL) wouldThisFont:(UIFont *)testFont workForThisLabel:(UILabel *)testLabel {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:testFont, NSFontAttributeName, nil];
    NSAttributedString *as = [[NSAttributedString alloc] initWithString:testLabel.text attributes:attributes];
    CGRect bounds = [as boundingRectWithSize:CGSizeMake(CGRectGetWidth(testLabel.frame), CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    BOOL itWorks = [self doesThisSize:bounds.size fitInThisSize:testLabel.bounds.size];
    return itWorks;
}

- (BOOL)doesThisSize:(CGSize)aa fitInThisSize:(CGSize)bb {
    if ( aa.width > bb.width ) return NO;
    if ( aa.height > bb.height ) return NO;
    return YES;
}

//- (void)resetPriceFiedPosition
//{
//    for (UIView *subview in self.subviews) {
//        UILabel *label = (UILabel *)[subview viewWithTag:(subview.tag + kLabelTag)];
//        UITextField *textField = (UITextField *)[subview viewWithTag:(subview.tag + kPriceFieldTag)];
//        UILabel *priceLabel = (UILabel *)[subview viewWithTag:(subview.tag + kPriceLabelTag)];
//        //get the actual width of the text being displayed
//        if (label) {
//            NSDictionary *attributes = @{ NSFontAttributeName : [label.font fontWithSize:globalFontSize]};
//            CGRect rect = [label.text boundingRectWithSize:CGSizeMake(label.bounds.size.width, label.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
//
//            //Set the updated bounds
//            priceLabel.bounds = CGRectMake(label.bounds.origin.x + rect.size.width, priceLabel.bounds.origin.y, priceLabel.bounds.size.width, priceLabel.bounds.size.height);
//            textField.bounds =  CGRectMake(priceLabel.bounds.origin.x + kPadding, textField.bounds.origin.y, textField.bounds.size.width, textField.bounds.size.height);
//        }
//    }
//}

@end
