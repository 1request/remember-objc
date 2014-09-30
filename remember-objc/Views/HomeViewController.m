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

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *clickHereImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger selectedLocationRowNumber;
@property (nonatomic) NSInteger activePlayerRowNumber;
@end

@implementation HomeViewController

#pragma mark - UI elements

- (void)setClickHereImageView:(UIImageView *)clickHereImageView
{
    _clickHereImageView = clickHereImageView;
//    _clickHereImageView.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRepeatUser"];
    _clickHereImageView.hidden = YES;
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"isRepeatUser"];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CGRect cellRect = CGRectMake(0, 0, tableView.frame.size.width, 60);
    if (indexPath.row == 0) {
        LocationsTableViewCell *locationCell = (LocationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (locationCell == nil) {
            locationCell = [[LocationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        locationCell.frame = cellRect;
        locationCell.locationNameLabel.text = @"My Office";
        locationCell.active = (indexPath.row == self.selectedLocationRowNumber) ? YES : NO;
        return locationCell;
    }
    
    MessagesTableViewCell *messageCell = (MessagesTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (messageCell == nil) {
        messageCell = [[MessagesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    messageCell.frame = cellRect;
    messageCell.read = NO;
    messageCell.messageNameLabel.text = [NSString stringWithFormat:@"Record %zd", indexPath.row];
    messageCell.playerStatus = (self.activePlayerRowNumber && self.activePlayerRowNumber == indexPath.row) ? Play : Pause;
    messageCell.playerButton.tag = indexPath.row;
    [messageCell.playerButton addTarget:self action:@selector(playerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return messageCell;
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self refreshTable];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self refreshTable];
    }];
}

- (void)refreshTable
{
    [self.tableView reloadData];
    UITableViewCellSeparatorStyle separatorStyle = self.tableView.separatorStyle;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = separatorStyle;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

@end
