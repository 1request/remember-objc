//
//  HomeViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "HomeViewController.h"
#import "LocationsTableViewCell.h"
#import "MessagesTableViewCell.h"
#import "DevicesTableViewController.h"
#import "HUD.h"
#import "LocationManager.h"
#import <CoreData/CoreData.h>
#import "Location.h"
#import "Message.h"

static NSString *const slideUpToCancel = @"Slide up to cancel";
static NSString *const releaseToCancel = @"Release to cancel";

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, MessagesTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *clickHereImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger selectedLocationRowNumber;
@property (nonatomic) NSInteger activePlayerRowNumber;
@property (strong, nonatomic) NSMutableSet *cellsCurrentlyEditing;
@property (strong, nonatomic) HUD *hudView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultController;
@end

@implementation HomeViewController

#pragma mark - UI elements

- (void)setClickHereImageView:(UIImageView *)clickHereImageView
{
    _clickHereImageView = clickHereImageView;
    _clickHereImageView.hidden = YES;
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSMutableSet *)cellsCurrentlyEditing
{
    if (!_cellsCurrentlyEditing) {
        _cellsCurrentlyEditing = [NSMutableSet new];
    }
    return _cellsCurrentlyEditing;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = nil;
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]];
    
    [request setRelationshipKeyPathsForPrefetching:@[@"messages"]];
    
    self.fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                       managedObjectContext:self.managedObjectContext
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil];
    NSError *error;
    BOOL success = [self.fetchedResultController performFetch:&error];
    if (!success) NSLog(@"[%@ %@] performFetch: failed", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    
    [self.tableView reloadData];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *rememberLogo = [UIImage imageNamed:@"Remember-logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:rememberLogo];
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.navigationItem.titleView = logoImageView;
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *fetchedLocations = [self.fetchedResultController fetchedObjects];
    NSInteger messagesCount = 0;
    for (Location *location in fetchedLocations) {
        messagesCount += [location.messages count];
    }
    return [fetchedLocations count] + messagesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *locationCellIdentifier = @"locationCell";
    static NSString *messageCellIdentifier = @"messageCell";
    CGRect cellRect = CGRectMake(0, 0, tableView.frame.size.width, 60);
    if (indexPath.row == 0) {
        LocationsTableViewCell *locationCell = (LocationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
        if (locationCell == nil) {
            locationCell = [[LocationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:locationCellIdentifier];
        }
        locationCell.frame = cellRect;
        Location *location = [self.fetchedResultController objectAtIndexPath:indexPath];
        locationCell.locationNameLabel.text = location.name;
        locationCell.active = (indexPath.row == self.selectedLocationRowNumber) ? YES : NO;
        return locationCell;
    }
    else {
        MessagesTableViewCell *messageCell = (MessagesTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
        if (messageCell == nil) {
            messageCell = [[MessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:messageCellIdentifier];
            messageCell.delegate = self;
        }
        messageCell.frame = cellRect;
        messageCell.read = NO;
        messageCell.messageNameLabel.text = [NSString stringWithFormat:@"Record %zd", indexPath.row];
        messageCell.playerStatus = (self.activePlayerRowNumber && self.activePlayerRowNumber == indexPath.row) ? Play : Pause;
        messageCell.playerButton.tag = indexPath.row;
        [messageCell.playerButton addTarget:self action:@selector(playerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
            [messageCell openCell];
        }
        return messageCell;
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == self.selectedLocationRowNumber) return;
    if (indexPath.row != self.selectedLocationRowNumber && [cell isKindOfClass:[LocationsTableViewCell class]]) {
        self.selectedLocationRowNumber = indexPath.row;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - helper methods

- (void)playerButtonClicked:(UIButton *)sender
{
    NSIndexPath *triggeredCellIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    NSArray *rowsToBeReloaded = (self.activePlayerRowNumber && self.activePlayerRowNumber != sender.tag) ? @[triggeredCellIndexPath, [NSIndexPath indexPathForRow:self.activePlayerRowNumber inSection:0]] : @[triggeredCellIndexPath];
    
    if (self.activePlayerRowNumber != sender.tag) {
        self.activePlayerRowNumber = sender.tag;
        [self.tableView reloadRowsAtIndexPaths:rowsToBeReloaded withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        // stop player and update message cell player status to pause
        self.activePlayerRowNumber = 0;
        [self.tableView reloadRowsAtIndexPaths:rowsToBeReloaded withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (IBAction)recordButtonTouchedDown:(id)sender
{
    self.hudView = [HUD hudInView:self.view];
    self.hudView.text = slideUpToCancel;
}

- (IBAction)recordButtonTouchedUpInside:(id)sender
{
    [self.hudView removeFromSuperview];
    // save audio
}

- (IBAction)recordButtonTouchedUpOutside:(id)sender
{
    [self.hudView removeFromSuperview];
    // cancel audio
}

- (IBAction)recordButtonTouchedDragExit:(id)sender
{
    self.hudView.text = releaseToCancel;
    [self.hudView setNeedsDisplay];
}

- (IBAction)recordButtonTouchedDragEnter:(id)sender
{
    self.hudView.text = slideUpToCancel;
    [self.hudView setNeedsDisplay];
}

#pragma mark - MessagesTableViewCell Delegate

- (void)deleteButtonClicked
{
    NSLog(@"in the delegate, clicked delete button");
}

- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DevicesTableViewController class]]) {
        DevicesTableViewController *deviceTableVC = segue.destinationViewController;
        deviceTableVC.managedObjectContext = self.managedObjectContext;
    }
}

@end
