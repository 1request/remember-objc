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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    LocationsTableViewCell *locationCell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    
    locationCell.locationNameLabel.text = (indexPath.row == 0) ? @"My Office" : @"My Home";
    NSLog(@"%zd", self.selectedLocationRowNumber);
    locationCell.active = (indexPath.row == self.selectedLocationRowNumber) ? YES : NO;
    
    return locationCell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedLocationRowNumber) return;
    if (indexPath.row != self.selectedLocationRowNumber) self.selectedLocationRowNumber = indexPath.row;
    [tableView reloadData];
}

@end
