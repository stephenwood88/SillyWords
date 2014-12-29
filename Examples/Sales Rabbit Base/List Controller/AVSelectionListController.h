//
//  AVSelectionListController.h
//  Dish Sales
//
//  Created by Brady Anderson on 1/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVSelectionListController;

@protocol AVSelectionListDelegate <NSObject>

@optional
- (void)checkListSelectionChanged:(AVSelectionListController *)sender selection:(NSString *)selection;
- (void)checkListChanged:(id)sender;
@end

@protocol Keyable <NSObject>
@required
-(id)key;
@end

@interface AVSelectionListController : UITableViewController {
    BOOL allowMultipleSelection;
    BOOL allowNoSelection;
}

@property (weak, nonatomic) id <AVSelectionListDelegate> delegate;
@property (weak, nonatomic) UIButton *sourceButton;
@property (strong, nonatomic) NSArray *contentList;
@property (nonatomic) NSInteger selectionIndex;
@property (copy, nonatomic) NSString *noSelectionTitle;
@property (strong, nonatomic) NSArray *suffixList;

// Multiple Selection
@property (strong, nonatomic) NSMutableDictionary *selectedContentDictionary;
@property (strong, nonatomic) NSMutableArray *selectedContentList;
@property (copy, nonatomic) NSString *allName;
@property (strong, nonatomic) NSMutableArray *selectedIndexes;

// End of recently added

- (id)initWithContentList:(NSArray *)contenList selectedContentDictionary:(NSMutableDictionary *)selectedContentDictionary delegate:(id <AVSelectionListDelegate>)delegate allName:(NSString *)allName;

- (id)initWithDelegate:(id <AVSelectionListDelegate>)delegate sourceButton:(UIButton *)sourceButton contentList:(NSArray *)contentList noSelectionTitle:(NSString *)noSelectionTitle;
- (void)selectItem:(NSString *)item;
- (NSString *)selectedItem;
- (void)reloadList;

// Recently added
- (void)allowMultipleSelection:(BOOL)choice;
- (void)allowNoSelection:(BOOL)choice;
- (BOOL)allContentSelected;
@end
