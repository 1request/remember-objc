//
//  AppDelegate.m
//  remember-objc
//
//  Created by Joseph Cheung on 29/9/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <Mixpanel/Mixpanel.h>
#import "HomeViewController.h"
#import "LocationManager.h"
#import "Location+CLBeaconRegion.h"
#import "AppDelegate+LocalNotification.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:@"a73df0ceadf9f0995f97da85f3a3ca791c3e0de1"];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:@"3b27052c32a6e7426f27e17b0a1f2e7e"];
    [mixpanel track:@"Start"];
    
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    HomeViewController *homeViewController = (HomeViewController *)nav.topViewController;
    homeViewController.managedObjectContext = self.managedObjectContext;
    
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(registerForRemoteNotifications)]) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    } else {
        [app registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredRegion:) name:kEnteredBeaconNotificationName object:nil];
    
    [self monitorLocations];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self clearNotifications];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self clearNotifications];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1007);
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "request.enterprise.remember_objc" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"remember_objc" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"remember_objc.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - helper methods

- (void)monitorLocations
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    NSError *error;
    NSArray *locations = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!error) {
        NSMutableSet *beaconRegions = [NSMutableSet new];
        for (Location *location in locations) {
            [beaconRegions addObject:[location beaconRegion]];
        }
        [[LocationManager sharedInstance] startMonitoringBeaconRegions:beaconRegions];
        [[LocationManager sharedInstance] startRangingBeaconRegions:beaconRegions];
    }
}

- (void)enteredRegion:(NSNotification *)notification
{
    CLBeaconRegion *region = [notification.userInfo objectForKey:@"region"];
    Location *location = [Location locationFromBeaconRegion:region InManagedObjectContext:self.managedObjectContext];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval currentTime = [currentDate timeIntervalSince1970];
    NSTimeInterval previousTriggeredTime = [location.lastTriggerTime timeIntervalSince1970];
    location.updatedAt = currentDate;
    location.lastTriggerTime = currentDate;
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"read == nil"];
    NSSet *unreadMessages = [location.messages filteredSetUsingPredicate:predicate];
    if (unreadMessages.count && currentTime - previousTriggeredTime >= 3600) {
        [self sendLocalNotificationWithMessage:[NSString stringWithFormat:@"%@ got %zd new notifications!", location.name, unreadMessages.count]];
    }
}

@end
