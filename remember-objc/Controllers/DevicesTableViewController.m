//
//  DevicesTableViewController.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DevicesTableViewCell.h"

@interface DevicesTableViewController ()

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"deviceCell";
    
    DevicesTableViewCell *cell = (DevicesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[DevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *uuid = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
    
    cell.deviceUUIDLabel.text = [uuid substringToIndex:8];
    cell.deviceRangeLabel.text = @"Within 100m";
    cell.newDevice = (indexPath.row == 0) ? NO : YES;
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
        // pass device detail to add device view controller
    }
}

@end
