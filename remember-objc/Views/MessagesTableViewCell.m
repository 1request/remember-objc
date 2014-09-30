//
//  MessagesTableViewCell.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "MessagesTableViewCell.h"
#import "UnreadSpotView.h"

@interface MessagesTableViewCell ()

@property (strong, nonatomic) UnreadSpotView *unreadSpotView;

@end

static CGFloat const UnreadSpotSpacing = 14.0;
static CGFloat const UnreadSpotSize = 12.0;

@implementation MessagesTableViewCell

- (void)awakeFromNib {
    // Initialization code

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.playerButton];
        [self.contentView addSubview:self.messageNameLabel];
        [self.contentView addSubview:self.unreadSpotView];
    }
    return self;
}

- (void)layoutSubviews
{
    switch (self.playerStatus) {
        case Pause:
            [self.playerButton setImage:[UIImage imageNamed:@"play-active"] forState:UIControlStateNormal];
            break;
        case Play:
            [self.playerButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    NSDictionary *elementsDict = @{@"playerButton": self.playerButton, @"messageNameLabel": self.messageNameLabel, @"unreadSpotView": self.unreadSpotView};
    NSDictionary *metrics = @{@"unreadSpotLeftSpacing":[NSNumber numberWithFloat:UnreadSpotSpacing
                                                        ], @"unreadSpotSize":[NSNumber numberWithFloat:UnreadSpotSize]};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[playerButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.playerButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[messageNameLabel]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadSpotView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[unreadSpotView(unreadSpotSize)]"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-unreadSpotLeftSpacing-[unreadSpotView(unreadSpotSize)]-unreadSpotLeftSpacing-[messageNameLabel]-[playerButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
    
    if ([self isRead]) self.unreadSpotView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UI elements

- (UILabel *)messageNameLabel
{
    if (!_messageNameLabel) {
        _messageNameLabel = [UILabel new];
        _messageNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _messageNameLabel;
}

- (UnreadSpotView *)unreadSpotView
{
    if (!_unreadSpotView) {
        _unreadSpotView = [UnreadSpotView new];
        _unreadSpotView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _unreadSpotView;
}

- (UIButton *)playerButton
{
    if (!_playerButton) {
        _playerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playerButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _playerButton;
}

@end
