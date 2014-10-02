//
//  BeaconFactory.m
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "BeaconFactory.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kRedBearName = @"Red Bear E2C56DB5";
static NSString *const kEstimoteName = @"Estimote B9407F30";

static NSString *const kRedBearUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
static NSString *const kEstimoteUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";

@implementation BeaconFactory

+ (NSArray *)beaconsRegionsToBeRangedForNewDevices
{
    static NSString *const kBeaconNameKey = @"name";
    static NSString *const kBeaconUUIDKey = @"uuid";
    
    NSArray *uuidStrings = @[@{kBeaconNameKey:kRedBearName, kBeaconUUIDKey:kRedBearUUID},
                             @{kBeaconNameKey:kEstimoteName, kBeaconUUIDKey:kEstimoteUUID}
                             ];
    
    NSMutableArray *beaconRegions = [NSMutableArray new];
    
    for (NSDictionary *beaconDetail in uuidStrings) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:beaconDetail[kBeaconUUIDKey]]
                                                                          identifier:beaconDetail[kBeaconNameKey]];
        [beaconRegions addObject:beaconRegion];
    }
    return [beaconRegions copy];
}

@end
