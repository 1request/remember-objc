//
//  MessagesTableViewCell.h
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlayerStatus) {
    Pause,
    Play
};

@protocol MessagesTableViewCellDelegate <NSObject>

- (void)deleteButtonClicked:(UITableViewCell *)cell;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;

@end


@interface MessagesTableViewCell : UITableViewCell
@property (weak, nonatomic) id <MessagesTableViewCellDelegate> delegate;
@property (strong, nonatomic) UILabel *messageNameLabel;
@property (nonatomic, getter=isRead) BOOL read;
@property PlayerStatus playerStatus;
@property (strong, nonatomic) UIButton *playerButton;
- (void)openCell;
@end
