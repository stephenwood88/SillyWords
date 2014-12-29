//
//  SRFile.h
//  Pest Sales
//
//  Created by Jordan Gardner on 1/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRFile : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileID;
@property (nonatomic) int folderID;
@property (nonatomic, getter=isFavorite) BOOL favorite;

- (instancetype)initWithTitle:(NSString *)title fileName:(NSString *)fileName fileID:(NSString *)fileID folderID:(int)folderID isFavorite:(BOOL)isFavorite;

@end
