//
//  UIColor+Extensions.m
//  remember-objc
//
//  Created by Joseph Cheung on 30/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor *)appBlueColor
{
    return [UIColor colorWithRed:0 green:145.0/255.0 blue:1 alpha:1];
}

+ (UIColor *)appGreyColor
{
    return [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1];
}

+ (UIColor *)appGreenColor
{
    return [UIColor colorWithRed:62.0/255.0 green:182.0/255.0 blue:82.0/255.0 alpha:1];
}

+ (UIColor *)appRedColor
{
    return [UIColor colorWithRed:1 green:89/255.0 blue:89/255.0 alpha:1];
}

@end
