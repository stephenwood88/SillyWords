//
//  SRCanvasView.m
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 1/23/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRCanvasView.h"

@implementation SRCanvasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] setStroke];
    [self.path stroke];
}


@end
