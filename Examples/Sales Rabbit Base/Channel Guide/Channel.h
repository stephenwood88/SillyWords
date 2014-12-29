//
//  Channel.h
//  DishTech
//
//  Created by Brady Anderson on 1/11/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *abbreviation;

- (NSComparisonResult) compareWithAnotherChannel:(Channel*) anotherChannel;

@end
