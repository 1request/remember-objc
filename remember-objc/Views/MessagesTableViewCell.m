//
//  MessagesTableViewCell.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "MessagesTableViewCell.h"

@interface MessagesTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;

@end

@implementation MessagesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionButtonPressed:(UIButton *)sender {
}
@end
