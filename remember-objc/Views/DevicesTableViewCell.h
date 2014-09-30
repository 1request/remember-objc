//
//  DevicesTableViewCell.h
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *deviceUUIDLabel;
@property (strong, nonatomic) UILabel *deviceRangeLabel;
@property (strong, nonatomic) UIButton *addButton;
@property (nonatomic, getter=isNewDevice) BOOL newDevice;
@end
