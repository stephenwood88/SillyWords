//
//  SRRepTableViewCell.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/10/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRRepTableViewCell.h"


#define REPNAME_Y_OFFSET 10

@interface SRRepTableViewCell()

@property (strong, nonatomic) UIView *repStatusCircle;


@end

@implementation SRRepTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    //Crop the Reps Pictures to be Circular
    self.repPicture.layer.cornerRadius = self.repPicture.frame.size.width/2;
    self.repPicture.backgroundColor = [UIColor whiteColor];
    self.repPicture.clipsToBounds = YES;
    
    self.repColorView.layer.cornerRadius = self.repColorView.frame.size.width/2;
    self.repColorView.clipsToBounds = YES;
}

- (void) prepareForReuse
{
    
    [super prepareForReuse];
    
    
    //Clean up the programatically added subviews
    
    [self.activeAreaStatus removeFromSuperview];
    [self.repStatusCircle removeFromSuperview];
    

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



//Custom Setters

- (void)setDisplayStatus:(BOOL)displayStatus
{
    _displayStatus = displayStatus;
    
    if (_displayStatus) {
        
        self.repName.frame = CGRectMake(self.repName.frame.origin.x, 12, self.repName.frame.size.width, self.repName.frame.size.height);
        
        self.repStatusCircle = [[UIView alloc] initWithFrame:CGRectMake(self.repName.frame.origin.x, self.repName.frame.origin.y + self.repName.frame.size.height, 15, 15)];
        self.repStatusCircle.layer.cornerRadius = self.repStatusCircle.frame.size.width/2;
        
        [self.contentView addSubview:self.repStatusCircle];
        
        self.activeAreaStatus = [[UILabel alloc] initWithFrame:CGRectMake(self.repStatusCircle.frame.origin.x + self.repStatusCircle.frame.size.width*1.2, self.repStatusCircle.frame.origin.y, 100, self.repStatusCircle.frame.size.height)];
        self.activeAreaStatus.textColor = [UIColor colorWithWhite:0.601 alpha:0.800];
        self.activeAreaStatus.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:self.activeAreaStatus];
        
    }
}

- (void)setStatusColor:(UIColor *)statusColor
{
    _statusColor = statusColor;
    
    self.repStatusCircle.backgroundColor = statusColor;
    [self.contentView setNeedsDisplay];
}

@end
