//
//  LocationsTableViewCell.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "LocationsTableViewCell.h"
#import "RadioButton.h"

@interface LocationsTableViewCell ()

@property (strong, nonatomic) RadioButton *radioButton;

@end

static CGFloat const ButtonSize = 24.0;

@implementation LocationsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.radioButton];
        [self.contentView addSubview:self.locationNameLabel];
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *elementsDict = @{@"radioButton": self.radioButton, @"locationNameLabel": self.locationNameLabel};
        NSDictionary *metrics = @{@"buttonSize": [NSNumber numberWithFloat:ButtonSize]};
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.radioButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[radioButton(buttonSize)]"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:metrics
                                                                                   views:elementsDict]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[locationNameLabel]-(8)-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:elementsDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[radioButton(buttonSize)]-(8)-[locationNameLabel]-(8)-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:metrics
                                                                                   views:elementsDict]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActive:(BOOL)active
{
    self.radioButton.checked = active;
}

#pragma mark - UI elements
- (RadioButton *)radioButton
{
    if (!_radioButton) {
        _radioButton = [RadioButton new];
        _radioButton.checked = self.active;
        _radioButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _radioButton;
}

- (UILabel *)locationNameLabel
{
    if (!_locationNameLabel) {
        _locationNameLabel = [UILabel new];
        _locationNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _locationNameLabel;
}

@end
