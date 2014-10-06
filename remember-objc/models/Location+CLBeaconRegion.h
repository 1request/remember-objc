//
//  Location+CLBeaconRegion.h
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Location.h"
#import <CoreLocation/CoreLocation.h>

@interface Location (CLBeaconRegion)

- (CLBeaconRegion *)beaconRegion;
+ (Location *)locationFromBeaconRegion:(CLBeaconRegion *)region InManagedObjectContext:(NSManagedObjectContext *)context;
@end
