//
//  BeaconFactory.m
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "BeaconFactory.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kRadiusNetwork1Name  = @"Radius Network 2F234454";
static NSString *const kAirLocate1Name      = @"AirLocate E2C56DB5";
static NSString *const kAirLocate2Name      = @"AirLocate 5A4BCFCE";
static NSString *const kAirLocate3Name      = @"AirLocate 74278BDA";
static NSString *const kNullIBeaconName     = @"Null iBeacon 00000000";
static NSString *const kRedBearName         = @"RedBear 5AFFFFFF";
static NSString *const kTwoCanoesName       = @"TwoCanoes 92AB49BE";
static NSString *const kEstimoteName        = @"RedBear B9407F30";
static NSString *const kRadiusNetwork2Name  = @"Radius Network 52414449";


static NSString *const kRadiusNetwork1UUID  = @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6";
static NSString *const kAirLocate1UUID      = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
static NSString *const kAirLocate2UUID      = @"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5";
static NSString *const kAirLocate3UUID      = @"74278BDA-B644-4520-8F0C-720EAF059935";
static NSString *const kNullIBeaconUUID     = @"00000000-0000-0000-0000-000000000000";
static NSString *const kRedBearUUID         = @"5AFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF";
static NSString *const kTwoCanoesUUID       = @"92AB49BE-4127-42F4-B532-90FAF1E26491";
static NSString *const kEstimoteUUID        = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString *const kRadiusNetwork2UUID  = @"52414449-5553-4E45-5457-4F524B53434F";

@implementation BeaconFactory

+ (NSSet *)beaconsRegionsToBeRangedForNewDevices
{
    static NSString *const kBeaconNameKey = @"name";
    static NSString *const kBeaconUUIDKey = @"uuid";
    
    NSArray *uuidStrings = @[@{kBeaconNameKey:kRadiusNetwork1Name, kBeaconUUIDKey:kRadiusNetwork1UUID},
                             @{kBeaconNameKey:kAirLocate1Name, kBeaconUUIDKey:kAirLocate1UUID},
                             @{kBeaconNameKey:kAirLocate2Name, kBeaconUUIDKey:kAirLocate2UUID},
                             @{kBeaconNameKey:kAirLocate3Name, kBeaconUUIDKey:kAirLocate3UUID},
                             @{kBeaconNameKey:kNullIBeaconName, kBeaconUUIDKey:kNullIBeaconUUID},
                             @{kBeaconNameKey:kRedBearName, kBeaconUUIDKey:kRedBearUUID},
                             @{kBeaconNameKey:kTwoCanoesName, kBeaconUUIDKey:kTwoCanoesUUID},
                             @{kBeaconNameKey:kEstimoteName, kBeaconUUIDKey:kEstimoteUUID},
                             @{kBeaconNameKey:kRadiusNetwork2Name, kBeaconUUIDKey:kRadiusNetwork2UUID}
                             ];
    
    NSMutableSet *beaconRegions = [NSMutableSet new];
    
    for (NSDictionary *beaconDetail in uuidStrings) {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:beaconDetail[kBeaconUUIDKey]]
                                                                          identifier:beaconDetail[kBeaconNameKey]];
        [beaconRegions addObject:beaconRegion];
    }
    return [beaconRegions copy];
}

@end
