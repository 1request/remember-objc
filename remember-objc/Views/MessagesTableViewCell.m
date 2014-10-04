//
//  MessagesTableViewCell.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "MessagesTableViewCell.h"
#import "UnreadSpotView.h"

static CGFloat const UnreadSpotSpacing = 14.0;
static CGFloat const UnreadSpotSize = 12.0;
static CGFloat const kBounceValue = 20.0f;

@interface MessagesTableViewCell () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UnreadSpotView *unreadSpotView;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;
@property (assign, nonatomic) CGPoint panStartPoint;
@property (assign, nonatomic) CGFloat startingRightLayoutConstraintConstant;
@property (strong, nonatomic) NSLayoutConstraint *contentViewRightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentViewLeftConstraint;

@end

@implementation MessagesTableViewCell

- (void)awakeFromNib {
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
        self.panRecognizer.delegate = self;
        [self.topView addGestureRecognizer:self.panRecognizer];
        [self.contentView addSubview:self.topView];
        [self.topView addSubview:self.playerButton];
        [self.topView addSubview:self.messageNameLabel];
        [self.topView addSubview:self.unreadSpotView];
        [self.contentView insertSubview:self.deleteButton belowSubview:self.topView];
        [self.deleteButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *topViewDict = @{@"topView":self.topView};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil views:topViewDict]];
        
        self.contentViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.topView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0 constant:0.0];
        
        self.contentViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.topView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0 constant:0.0];
        
        [self.contentView addConstraints:@[self.contentViewLeftConstraint, self.contentViewRightConstraint]];
        
        
        NSDictionary *elementsDict = @{@"playerButton": self.playerButton, @"messageNameLabel": self.messageNameLabel, @"unreadSpotView": self.unreadSpotView};
        NSDictionary *metrics = @{@"unreadSpotLeftSpacing":[NSNumber numberWithFloat:UnreadSpotSpacing
                                                            ], @"unreadSpotSize":[NSNumber numberWithFloat:UnreadSpotSize]};
        
        [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[playerButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
        
        [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:self.playerButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.playerButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[messageNameLabel]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:elementsDict]];
        
        [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadSpotView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.topView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[unreadSpotView(unreadSpotSize)]"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
        
        [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-unreadSpotLeftSpacing-[unreadSpotView(unreadSpotSize)]-unreadSpotLeftSpacing-[messageNameLabel]-[playerButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:metrics
                                                                               views:elementsDict]];
        
        NSDictionary *deleteButtonDict = @{@"deleteButton":self.deleteButton};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[deleteButton]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:deleteButtonDict]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton]|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:deleteButtonDict]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.deleteButton
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0 constant:0.0]];
        
        if ([self isRead]) self.unreadSpotView.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
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
    self.unreadSpotView.hidden = (self.read) ? YES : NO;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetConstraintConstantsToZero:NO notifyDelegateDidClose:NO];
}

#pragma mark - UI elements

- (UIView *)topView
{
    if (!_topView) {
        _topView = [UIView new];
        _topView.translatesAutoresizingMaskIntoConstraints = NO;
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

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

- (UIButton *)deleteButton
{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_deleteButton setBackgroundImage:[UIImage imageNamed:@"trash"] forState:UIControlStateNormal];
        _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _deleteButton;
}

- (void)buttonClicked:(UIButton *)sender
{
    if (sender == self.deleteButton) {
        [self.delegate deleteButtonClicked:self];
    }
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.topView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.topView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            if (self.startingRightLayoutConstraintConstant == 0) {
                // The cell was closed and is now opening
                if (!panningLeft) {
                    CGFloat constant = MAX(-deltaX, 0);
                    if (constant == 0) {
                        [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
                    }
                    else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                else {
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }
                    else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            else {
                // The cell was at least partially open.
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0);
                    if (constant == 0) {
                        [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
                    }
                    else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    if (constant == [self buttonTotalWidth]) {
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }
                    else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGFloat halfOfButton = CGRectGetWidth(self.deleteButton.frame);
            if (self.contentViewRightConstraint.constant >= halfOfButton) {
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            else {
                [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
            }
            else {
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.deleteButton.frame);
}

- (void)resetConstraintConstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidClose:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == 0 && self.contentViewRightConstraint.constant == 0) {
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate
{
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] && self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}

- (void)openCell
{
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
