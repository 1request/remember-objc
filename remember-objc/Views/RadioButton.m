//
//  RadioButton.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "RadioButton.h"

@implementation RadioButton

static CGFloat const OuterCircleStrokeLineWidth = 1;

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [[UIColor clearColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    UIBezierPath *outterCirclePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(OuterCircleStrokeLineWidth, OuterCircleStrokeLineWidth, self.frame.size.width - (OuterCircleStrokeLineWidth * 2), self.frame.size.height - (OuterCircleStrokeLineWidth * 2))];
    
    UIColor *outerCircleStrokeColor = [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1];
    
    [outerCircleStrokeColor setStroke];
    [outterCirclePath setLineWidth:1];
    [outterCirclePath stroke];
    
    if (![self isChecked]) return;
    
    UIBezierPath *innerCirclePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.frame.size.width / 8, self.frame.size.height / 8, self.frame.size.width * 3 / 4, self.frame.size.height * 3 / 4)];
    
    UIColor *innerCircleFillColor = [UIColor colorWithRed:0 green:145.0/255.0 blue:1 alpha:1];
    
    [innerCircleFillColor setFill];
    [innerCirclePath fill];
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    [self setNeedsDisplay];
}

@end
