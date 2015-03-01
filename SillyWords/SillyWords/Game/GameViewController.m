//
//  TPUploadImageViewController.m
//  TutorialBase
//
//  Created by Antonio MG on 7/4/12.
//  Copyright (c) 2012 AMG. All rights reserved.
//

#import "GameViewController.h"
#import "GameCell.h"

@interface GameViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) IBOutlet UITextField *commentTextField;
@property (nonatomic, strong) NSString *username;
@end

@implementation GameViewController

#pragma mark - UITableView Delegate
#pragma mark - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.game.players count]-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[GameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    return cell;
}
@end
