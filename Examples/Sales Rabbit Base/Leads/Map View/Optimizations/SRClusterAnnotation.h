//
//  SRClusterAnnotation.h
//  DishOne Sales
//
//  Created by Raul Lopez Villalpando on 6/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SRClusterAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) NSInteger prequalCount;
@property (assign, nonatomic) NSInteger leadsCount;
@property (assign, nonatomic) NSInteger repLeadsCount;
@property (assign, nonatomic) NSInteger userLocationsCount;


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;


@end
