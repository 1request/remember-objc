//
//  Location+CLBeaconRegion.m
//  remember-objc
//
//  Created by Joseph Cheung on 2/10/14.
//  Copyright (c) 2014 Reque.st. All rights reserved.
//

#import "Location+CLBeaconRegion.h"

@implementation Location (CLBeaconRegion)

- (CLBeaconRegion *)beaconRegion
{
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.uuid]
                                                                           major:[self.major integerValue]
                                                                           minor:[self.minor integerValue]
                                                                      identifier:[NSString stringWithFormat:@"%@-%f", self.name, [self.createdAt timeIntervalSince1970]]];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    return beaconRegion;
}

+ (Location *)locationFromBeaconRegion:(CLBeaconRegion *)region InManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@ AND major == %@ AND minor == %@", region.proximityUUID.UUIDString, region.major, region.minor];
    request.predicate = predicate;
    [request setRelationshipKeyPathsForPrefetching:@[@"messages"]];
    NSError *error = nil;
    NSArray *locations = [context executeFetchRequest:request error:&error];
    
    if (!error) {
        if (locations.count) {
            return locations.firstObject;
        }
    }
    return nil;
}

@end
