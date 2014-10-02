//
//  LocationManager.m
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "LocationManager.h"
#import "BeaconFactory.h"

@interface LocationManager ()

@end

@implementation LocationManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            // user are restricted from using location service or user himself denied app's location service
        }
        else if (status == kCLAuthorizationStatusNotDetermined) {
            // ask for authorization
            if ([_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_manager requestAlwaysAuthorization];
            }
        }
    }
    
    return self;
}

+ (LocationManager *)sharedInstance
{
    static LocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocationManager alloc] init];
    });
    return sharedInstance;
}


- (void)startRangingForNewDevices
{
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on region ranging: Region ranging is not available for this device.");
        return;
    }
    
    for (CLBeaconRegion *region in [BeaconFactory beaconsRegionsToBeRangedForNewDevices]) {
        [self.manager startRangingBeaconsInRegion:region];
    }
}

- (void)stopRangingForNewDevices
{
    for (CLBeaconRegion *region in [BeaconFactory beaconsRegionsToBeRangedForNewDevices]) {
        [self.manager stopRangingBeaconsInRegion:region];
    }
}

#pragma mark - CLLocationManger Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on monitoring: Location services are not enabled.");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on monitoring: Location services not authorised.");
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        NSLog(@"Couldn't turn on monitoring: Location services (Always) not authorised.");
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    
    if (self.delegate) {
        if ([beacons count]) [self.delegate rangedBeacons:beacons InRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if (self.delegate) {
            if (beaconRegion.major && beaconRegion.minor) {
                [self.delegate enteredBeaconRegion:beaconRegion];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        if (self.delegate) {
            if (beaconRegion.major && beaconRegion.minor) {
                [self.delegate exitedBeaconRegion:beaconRegion];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
        NSString *message = [NSString stringWithFormat:@"error: %@ / region: %@", [error description], beaconRegion.minor];
        NSLog(@"%@", message);
    }
}


@end
