//
//  Channel.m
//  DishTech
//
//  Created by Brady Anderson on 1/11/13.
//  Copyright (c) 2013 AppVantage. All rights reserved.
//

#import "Channel.h"

@implementation Channel

- (NSComparisonResult) compareWithAnotherChannel:(Channel*) anotherChannel{
    return [[self number] compare:[anotherChannel number]];
}

@end
