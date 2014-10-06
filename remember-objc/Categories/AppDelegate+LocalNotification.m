//
//  AppDelegate+LocalNotification.m
//  remember-objc
//
//  Created by Joseph Cheung on 6/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AppDelegate+LocalNotification.h"

@implementation AppDelegate (LocalNotification)

- (void)sendLocalNotificationWithMessage:(NSString *)message
{
    UILocalNotification *notification = [UILocalNotification new];
    
    // Notification details
    notification.alertBody = message;
    notification.alertAction = NSLocalizedString(@"View Details", nil);
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    if ([notification respondsToSelector:@selector(regionTriggersOnce)]) {
        notification.regionTriggersOnce = YES;
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil] ;
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
