//
//  LocationManager.h
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

@optional
- (void)enteredBeaconRegion:(CLBeaconRegion *)beaconRegion;
- (void)exitedBeaconRegion:(CLBeaconRegion *)beaconRegion;
- (void)rangedBeacons:(NSArray *)beacons InRegion:(CLBeaconRegion *)region;

@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (weak, nonatomic) id <LocationManagerDelegate> delegate;

+ (LocationManager *)sharedInstance;
@property (readonly) CLLocationManager *manager;

- (void)startRangingForNewDevices;
- (void)stopRangingForNewDevices;
@end
