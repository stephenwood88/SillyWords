//
//  SRClusterAnnotationView.h
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SRClusterAnnotationView : MKAnnotationView

@property (assign, nonatomic) NSUInteger count;
@property (nonatomic) UIView *contentView;

@end
