//
//  DevicesTableViewCell.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "DevicesTableViewCell.h"
#import "UIColor+Extensions.h"

@interface DevicesTableViewCell ()
@property (strong, nonatomic) UIImageView *ibeaconImageView;
@end

static CGFloat const ButtonWidth = 80.0;

@implementation DevicesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.ibeaconImageView];
        [self.contentView addSubview:self.deviceUUIDLabel];
        [self.contentView addSubview:self.deviceRangeLabel];
        [self.contentView addSubview:self.addButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self isNewDevice]) {
        [self.addButton setTitle:@"Add" forState:UIControlStateNormal];
        self.addButton.backgroundColor = [UIColor appGreenColor];
        [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.addButton.layer.cornerRadius = 5;
        self.addButton.clipsToBounds = YES;
    }
    else {
        [self.addButton setTitle:@"Added" forState:UIControlStateNormal];
        [self.addButton setTitleColor:[UIColor appGreyColor] forState:UIControlStateNormal];
        self.addButton.enabled = NO;
    }
    
    NSDictionary *elementsDict = @{@"ibeaconImageView":self.ibeaconImageView, @"deviceUUIDLabel":self.deviceUUIDLabel, @"deviceRangeLabel":self.deviceRangeLabel, @"addButton":self.addButton};
    NSDictionary *metrics = @{@"buttonWidth":[NSNumber numberWithFloat:ButtonWidth]};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[ibeaconImageView]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[deviceUUIDLabel]-[deviceRangeLabel]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[addButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.ibeaconImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.ibeaconImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[ibeaconImageView]-[deviceUUIDLabel]"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[addButton(buttonWidth)]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.deviceRangeLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.deviceUUIDLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0]];
}


#pragma mark - UI elements

- (UILabel *)deviceUUIDLabel
{
    if (!_deviceUUIDLabel) {
        _deviceUUIDLabel = [UILabel new];
        _deviceUUIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _deviceUUIDLabel;
}

- (UILabel *)deviceRangeLabel
{
    if (!_deviceRangeLabel) {
        _deviceRangeLabel = [UILabel new];
        _deviceRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _deviceRangeLabel;
}

- (UIButton *)addButton
{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _addButton;
}

- (UIImageView *)ibeaconImageView
{
    if (!_ibeaconImageView) {
        _ibeaconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ibeacon"]];
        _ibeaconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _ibeaconImageView;
}

@end
