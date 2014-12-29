//
//  SRNewRepViewController.h
//  Security Sales
//
//  Created by Raul Lopez Villalpando on 2/7/14.
//  Copyright (c) 2014 AppVantage LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Area+Rabbit.h"

@class SRNewRepViewController;

@protocol SRNewRepViewControllerDelegate <NSObject>

@optional
- (void)didPressSaveNewReps;
- (void)didPresscancelSaveNewReps;

@required
- (void)newRepViewController: (SRNewRepViewController *)newRepViewController didSaveRep:(NSArray *)reps fromAreas:(NSArray *) areas;

@end

@interface SRNewRepViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITableView *repTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) id<SRNewRepViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *availableRepsArray;
@property (strong, nonatomic) Area *selectedArea;


- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;

@end
