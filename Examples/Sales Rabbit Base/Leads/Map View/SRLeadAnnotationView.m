//
//  SRLeadAnnotationView.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/24/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "SRLeadAnnotationView.h"
#import "AppDelegate.h"
#import "SRSalesServiceCalls.h"
#import "Constants.h"

@implementation SRLeadAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated
{
    if (newDragState == MKAnnotationViewDragStateStarting)
    {
        // lift the pin and set the state to dragging
        
        CGPoint endPoint = CGPointMake(self.center.x,self.center.y-40);
        [UIView animateWithDuration:0.2
                         animations:^{ self.center = endPoint; }
                         completion:^(BOOL finished)
         { self.dragState = MKAnnotationViewDragStateDragging; }];
    }
    else if (newDragState == MKAnnotationViewDragStateEnding)
    {
        CGPoint endPoint = CGPointMake(self.center.x,self.center.y-20);
        [UIView animateWithDuration:0.4
                         animations:^{ self.center = endPoint; }
                         completion:^(BOOL finished)
         { self.dragState = MKAnnotationViewDragStateDragging; }];
        
        
        endPoint = CGPointMake(self.center.x,self.center.y+20);
        [UIView animateWithDuration:0.4
                         animations:^{ self.center = endPoint; }
                         completion:^(BOOL finished)
         { self.dragState = MKAnnotationViewDragStateNone; }];
        [[SRSalesServiceCalls singleton] sync];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:nil];
    }
    else if (newDragState == MKAnnotationViewDragStateCanceling)
    {
        // drop the pin and set the state to none
        
        CGPoint endPoint = CGPointMake(self.center.x,self.center.y-20);
        [UIView animateWithDuration:0.4
                         animations:^{ self.center = endPoint; }
                         completion:^(BOOL finished)
         { self.dragState = MKAnnotationViewDragStateDragging; }];
        
        endPoint = CGPointMake(self.center.x,self.center.y+20);
        [UIView animateWithDuration:0.4
                         animations:^{ self.center = endPoint; }
                         completion:^(BOOL finished)
         { self.dragState = MKAnnotationViewDragStateNone; }];
        [[SRSalesServiceCalls singleton] sync];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLeadsChangedNotification object:nil];
    }
}

@end
