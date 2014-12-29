//
//  SRFile.m
//  Pest Sales
//
//  Created by Jordan Gardner on 1/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import "SRFile.h"

@implementation SRFile

- (instancetype)initWithTitle:(NSString *)title fileName:(NSString *)fileName fileID:(NSString *)fileID folderID:(int)folderID isFavorite:(BOOL)isFavorite
{
    self = [super init];
    if (self)
    {
        _title = title;
        _fileName = fileName;
        _fileID = fileID;
        _folderID = folderID;
        _favorite = isFavorite;
    }
    return self;
}

- (id)init
{
    NSLog(@"DO NOT USE 'init' WITH OBJECTS OF TYPE 'SRFile' -- PLEASE USE THE METHOD 'initWithTitle:fileName:fileID:folderID' WHICH IS THE DESIGNATED INITIALIZER");
    return nil;
}

@end
