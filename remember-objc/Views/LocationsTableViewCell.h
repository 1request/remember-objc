//
//  LocationsTableViewCell.h
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsTableViewCell : UITableViewCell

@property (nonatomic, getter=isActive) BOOL active;
@property (strong, nonatomic) UILabel *locationNameLabel;
@end
