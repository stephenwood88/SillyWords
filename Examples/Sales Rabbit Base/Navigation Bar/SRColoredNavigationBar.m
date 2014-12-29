//
//  SRColoredNavigationBar.m
//  Dish Sales
//
//  Created by Brady Anderson on 10/14/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRColoredNavigationBar.h"
#import "SRGlobalState.h"

@implementation SRColoredNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    // Initialization code
    self.barTintColor = [[SRGlobalState singleton] accentColor];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
