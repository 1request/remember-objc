//
//  AppDelegate+LocalNotification.h
//  remember-objc
//
//  Created by Joseph Cheung on 6/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (LocalNotification)

- (void)sendLocalNotificationWithMessage:(NSString *)message;
- (void)clearNotifications;

@end
