//
//  SRFolder.m
//  Pest Sales
//
//  Created by Jordan Gardner on 1/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRFolder.h"

@implementation SRFolder

- (instancetype)initWithTitle:(NSString *)title folderID:(int)folderID parentFolderID:(int)parentFolderID
{
    self = [super init];
    if (self)
    {
        _title = title;
        _folderID = folderID;
        _parentFolderID = parentFolderID;
    }
    return self;
}

- (id)init
{
    NSLog(@"DO NOT USE 'init' WITH OBJECTS OF TYPE 'SRFolder' -- PLEASE USE THE METHOD 'initWithTitle:folderID:parentFolderID' WHICH IS THE DESIGNATED INITIALIZER");
    return nil;
}

@end
