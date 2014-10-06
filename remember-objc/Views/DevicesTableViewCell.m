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
        
        NSDictionary *elementsDict = @{@"ibeaconImageView":self.ibeaconImageView, @"deviceUUIDLabel":self.deviceUUIDLabel, @"deviceRangeLabel":self.deviceRangeLabel, @"addButton":self.addButton};
        NSDictionary *metrics = @{@"buttonWidth":[NSNumber numberWithFloat:ButtonWidth]};

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[ibeaconImageView]-(8)-|"
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
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[ibeaconImageView]-(8)-[deviceUUIDLabel]"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:elementsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[deviceUUIDLabel]-(8)-[deviceRangeLabel]-(8)-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:elementsDict]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[addButton]-(8)-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:elementsDict]];
        

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[addButton(buttonWidth)]-(8)-|"
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
        UIFont *font = _deviceRangeLabel.font;
        _deviceRangeLabel.font = [font fontWithSize:14.0f];
        _deviceRangeLabel.textColor = [UIColor appGreyColor];
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
        _ibeaconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _ibeaconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _ibeaconImageView;
}

@end
