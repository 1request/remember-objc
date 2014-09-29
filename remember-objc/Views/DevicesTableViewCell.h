//
//  DevicesTableViewCell.h
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceUUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceRangeLabel;

@end
