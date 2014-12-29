//
//  SRFolder.h
//  Pest Sales
//
//  Created by Jordan Gardner on 1/24/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRFolder : NSObject

@property (strong, nonatomic) NSString *title;
@property (nonatomic) int folderID;
@property (nonatomic) int parentFolderID;

- (instancetype)initWithTitle:(NSString *)title folderID:(int)folderID parentFolderID:(int)parentFolderID;

@end
