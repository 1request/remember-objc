//
//  LocationManager.h
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager *)sharedInstance;

@property (readonly) CLLocationManager *manager;

- (void)startRangingBeaconRegions:(NSSet *)beaconRegions;
- (void)stopRangingBeaconRegions:(NSSet *)beaconRegions;

- (void)startMonitoringBeaconRegions:(NSSet *)beaconRegions;
- (void)stopMonitoringBeaconRegions:(NSSet *)beaconRegions;

@end
