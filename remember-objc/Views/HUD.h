//
//  HUD.h
//  remember-objc
//
//  Created by Joseph Cheung on 1/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HUD : UIView

@property (strong, nonatomic) NSString *text;

+ (HUD *)hudInView:(UIView *)view;

@end
