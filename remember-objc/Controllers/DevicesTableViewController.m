//
//  DevicesTableViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DevicesTableViewCell.h"
#import "AddDeviceViewController.h"
#import "LocationManager.h"
#import "BeaconFactory.h"
#import "Location.h"

@interface DevicesTableViewController ()
@property (strong, nonatomic) NSMutableArray *rangedBeacons;
@property (strong, nonatomic) NSArray *locations;
@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[LocationManager sharedInstance] startRangingBeaconRegions:[BeaconFactory beaconsRegionsToBeRangedForNewDevices]];
}

- (NSMutableArray *)rangedBeacons
{
    if (!_rangedBeacons) {
        _rangedBeacons = [[NSMutableArray alloc] init];
    }
    return _rangedBeacons;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.fetchBatchSize = 20;
    NSError *error = nil;
    self.locations = [_managedObjectContext executeFetchRequest:request error:&error];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[LocationManager sharedInstance] stopRangingBeaconRegions:[BeaconFactory beaconsRegionsToBeRangedForNewDevices]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rangedBeacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"deviceCell";
    
    DevicesTableViewCell *cell = (DevicesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[DevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CLBeacon *beacon = [self.rangedBeacons objectAtIndex:indexPath.row];
    NSString *uuid = [beacon.proximityUUID UUIDString];
    
    cell.deviceUUIDLabel.text = [uuid substringToIndex:8];
    cell.deviceRangeLabel.text = [NSString stringWithFormat:@"Within %.2fm", beacon.accuracy];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor];
    
    NSArray *filteredLocations = [self.locations filteredArrayUsingPredicate:predicate];
    
    cell.newDevice = ([filteredLocations count]) ? NO : YES;
    cell.addButton.tag = indexPath.row;
    if ([cell isNewDevice]) {
        [cell.addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

#pragma mark - helper methods

- (void)addButtonClicked:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"toAddDevice" sender:sender];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        if ([segue.destinationViewController isKindOfClass:[AddDeviceViewController class]]) {
            AddDeviceViewController *addDeviceVC = segue.destinationViewController;
            addDeviceVC.managedObjectContext = self.managedObjectContext;
            UIButton *button = sender;
            addDeviceVC.beacon = [self.rangedBeacons objectAtIndex:button.tag];
        }
    }
}

#pragma mark - LocationManager Delegate

- (void)rangedBeacons:(NSArray *)beacons InRegion:(CLBeaconRegion *)region
{
    NSUInteger count = [self.rangedBeacons count];
    
    for (CLBeacon *beacon in beacons) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"proximityUUID.UUIDString == %@ AND major == %@ AND minor == %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor];
        NSArray *filteredArray = [self.rangedBeacons filteredArrayUsingPredicate:predicate];
        if (![filteredArray count]) {
            [self.rangedBeacons addObject:beacon];
        }
    }
    
    if ([self.rangedBeacons count] > count) [self.tableView reloadData];
}

@end
