//
//  AVSelectionListController.m
//  Dish Sales
//
//  Created by Brady Anderson on 1/30/13.
//  Copyright (c) 2013 AppVantage LLC. All rights reserved.
//

#import "AVSelectionListController.h"
#import "Constants.h"

@interface AVSelectionListController ()

@end

@implementation AVSelectionListController

// For multiselection;
- (id)initWithContentList:(NSArray *)contentList selectedContentDictionary:(NSMutableDictionary *)selectedContentDictionary delegate:(id <AVSelectionListDelegate>)delegate allName:(NSString *)allName {
    allowMultipleSelection = YES;
    allowNoSelection = NO;
    self = [super init];
    if (self) {
        self.allName = allName;
        self.contentList = contentList;
        self.selectedContentDictionary = selectedContentDictionary;
        self.delegate = delegate;
    }
    return self;
}

// For single selection
- (id)initWithDelegate:(id <AVSelectionListDelegate>)delegate sourceButton:(UIButton *)sourceButton contentList:(NSArray *)contentList noSelectionTitle:(NSString *)noSelectionTitle {
    allowMultipleSelection = NO;
    allowNoSelection = NO;
    self = [self initWithNibName:@"AVSelectionListController" bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.sourceButton = sourceButton;
        self.contentList = contentList;
        self.noSelectionTitle = noSelectionTitle;
        
        // If only one option, select it and disable source button
        if ([contentList count] == 1) {
            [self selectRow:[NSIndexPath indexPathForItem:0 inSection:0]];
            sourceButton.enabled = NO;
        }
        else {
            self.selectionIndex = -1;
            [sourceButton setTitle:noSelectionTitle forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)selectItem:(NSString *)item {
    if (item) {
        NSInteger row = [self.contentList indexOfObject:item];
        if (row == NSNotFound) {
            self.selectionIndex = -1;
            [self.sourceButton setTitle:self.noSelectionTitle forState:UIControlStateNormal];
        }
        else if (row != self.selectionIndex || [self.sourceButton titleForState:UIControlStateNormal] != [self.contentList objectAtIndex:row]) {
            [self selectRow:[NSIndexPath indexPathForItem:row inSection:0]];
        }
    }
    else {
        if (self.selectionIndex >= 0) {
            [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectionIndex inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
        }
        self.selectionIndex = -1;
        [self.sourceButton setTitle:self.noSelectionTitle forState:UIControlStateNormal];
    }
}

- (NSString *)selectedItem {
    if (self.selectionIndex >= 0 && self.selectionIndex < self.contentList.count) {
        return [self.contentList objectAtIndex:self.selectionIndex];
    }
    return nil;
}

- (void)reloadList{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(allowMultipleSelection)
        return [self.contentList count] + 1;
    
    return self.contentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AVCheckListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFont1 size:14];
    }
    
    if(allowMultipleSelection) {
        if (indexPath.row == 0) {
            cell.textLabel.text = self.allName;
            if (self.allContentSelected) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else {
            id contentObject = [self.contentList objectAtIndex:indexPath.row - 1];
            if ([contentObject respondsToSelector:@selector(key)]) {
                id <Keyable> keyableObject = contentObject;
                cell.textLabel.text = keyableObject.description;
                if ([self.selectedContentDictionary objectForKey:keyableObject.key]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else {
                cell.textLabel.text = contentObject;
                if ([self.selectedContentDictionary objectForKey:contentObject]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    else {
        if (self.suffixList) {
            cell.textLabel.text = [self.contentList[indexPath.row] stringByAppendingString:self.suffixList[indexPath.row]];
        }
        else{
            cell.textLabel.text = self.contentList[indexPath.row];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (indexPath.row == self.selectionIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!allowMultipleSelection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row != self.selectionIndex) {
            [self selectRow:indexPath];
        }else if (allowNoSelection){
            if (self.selectionIndex >= 0) {
                [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectionIndex inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
            }
            self.selectionIndex = -1;
            [self.sourceButton setTitle:@"None" forState:UIControlStateNormal];
            if (self.delegate && [self.delegate respondsToSelector:@selector(checkListSelectionChanged:selection:)]) {
                [self.delegate checkListSelectionChanged:self selection:@""];
            }
        }
    }
    else {      // multiple selection
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            if (!self.allContentSelected) {
                [self selectAllContent];
            }else if(allowNoSelection){
                [self deselectAllContent];
            }
        }
        else {
            id contentObject = [self.contentList objectAtIndex:indexPath.row - 1];
            id contentKey;
            if ([contentObject respondsToSelector:@selector(key)]) {
                contentKey = [(id <Keyable>) contentObject key];
            }
            else {
                contentKey = contentObject;
            }
            if (self.allContentSelected) {
                UITableViewCell *allContentsCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                allContentsCell.accessoryType = UITableViewCellAccessoryNone;
                [self.selectedContentDictionary removeObjectForKey:contentKey];
                selectedCell.accessoryType = UITableViewCellAccessoryNone;
            }
            else if ([self.selectedContentDictionary objectForKey:contentKey]) {
                if ([self.selectedContentDictionary count] > 1 || allowNoSelection) {
                    [self.selectedContentDictionary removeObjectForKey:contentKey];
                    selectedCell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else {
                [self.selectedContentDictionary setObject:contentObject forKey:contentKey];
                if (self.allContentSelected) {
                    [self selectAllContent];
                }
                else {
                    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
            
        }
        [self.delegate checkListChanged:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Private Methods

- (void)setPopoverSize {
    NSInteger height = 44 * ([self.contentList count]);
    CGSize stringSize;
    UIFont *font = [UIFont fontWithName:kFont1 size:14];
    
    NSInteger width = 61;   // Minimum width required by next button
    if(allowMultipleSelection){
        height = 44 * ([self.contentList count] + 1);
        stringSize = [self.allName sizeWithAttributes:@{NSFontAttributeName:font}];
        if (stringSize.width + 55 > width) {
            width = stringSize.width + 55;
        }
    }
    
    for (int index = 0; index < self.contentList.count; index++) {
        
        if (self.suffixList) {
            
            CGRect textRect = [[self.contentList[index] stringByAppendingString:self.suffixList[index]] boundingRectWithSize:CGSizeMake(100000, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            stringSize = textRect.size;
            
            if (stringSize.width + 50 > width) {
                width = stringSize.width + 50;
            }
        }
        else{
            
            if([self.contentList[index] isKindOfClass:[NSString class]])
                stringSize = [self.contentList[index] sizeWithAttributes:@{NSFontAttributeName:font}];
            else {
                NSString *string = [NSString stringWithFormat:@"%@",self.contentList[index]];
                stringSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
            }
            if (stringSize.width + 55 > width) {
                width = stringSize.width + 55;
            }
        }
    }
    self.preferredContentSize = CGSizeMake(width, height);
}

- (void)selectRow:(NSIndexPath *)indexPath {
    if (self.selectionIndex >= 0) {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectionIndex inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
    }
    self.selectionIndex = indexPath.row;
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSString *string = self.contentList[indexPath.row];
    [self.sourceButton setTitle:string forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkListSelectionChanged:selection:)]) {
        [self.delegate checkListSelectionChanged:self selection:self.contentList[indexPath.row]];
    }
}

#pragma mark - Custom Setters

-(void)setSelectedContentDictionary:(NSMutableDictionary *)selectedContentDictionary{
    _selectedContentDictionary = selectedContentDictionary;
    [self.tableView reloadData];
}

#pragma mark - Custom Accessors

- (void)setContentList:(NSArray *)contentList {
    
    _contentList = contentList;
    [self setPopoverSize];
    [self.tableView reloadData];
    if ([self.delegate respondsToSelector:@selector(checkListChanged:)]) {
        [self.delegate checkListChanged:self];
    }
}

- (void)setSuffixList:(NSArray *)suffixList {
    _suffixList = suffixList;
    [self setPopoverSize];
    [self.tableView reloadData];
}

- (void)allowMultipleSelection:(BOOL)choice {
    allowMultipleSelection = choice;
}

-(void)allowNoSelection:(BOOL)choice{
    allowNoSelection = choice;
}

-(void)deselectAllContent{
    [self.selectedContentDictionary removeAllObjects];
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)selectAllContent {
    
    for (id <Keyable> contentObject in self.contentList) {
        if ([contentObject respondsToSelector:@selector(key)]) {
            [self.selectedContentDictionary setObject:contentObject forKey:contentObject.key];
        }
        else {
            id nonKeyable = contentObject;
            [self.selectedContentDictionary setObject:nonKeyable forKey:nonKeyable];
        }
    }
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (BOOL)allContentSelected {
    
    return self.contentList.count == [self selectedIndexes].count;
}

// Getter for selected Indexes, (returns the indexes starting at 0 without counting the All Selected Cell)
- (NSMutableArray *)selectedIndexes
{
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.contentList.count; i++) {
        
        if ([self.selectedContentDictionary objectForKey:[self.contentList objectAtIndex:i]] != nil) {
            [indexes addObject:[NSNumber numberWithInt:(i)]];
        }
    }
    
    return indexes;
}
@end
