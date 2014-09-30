//
//  UnreadSpotView.m
//  remember-objc
//
//  Created by Joseph Cheung on 30/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "UnreadSpotView.h"
#import "UIColor+Extensions.h"

@implementation UnreadSpotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    UIColor *blueColor = [UIColor appBlueColor];
    [blueColor setFill];
    [circlePath fill];
}

@end
