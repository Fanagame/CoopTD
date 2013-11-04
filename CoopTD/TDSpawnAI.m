//
//  TDSpawnAI.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDSpawnAI.h"
#import "TDMapObject.h"
#import "TDSpawn.h"

CFTimeInterval const kMinTimeIntervalBetweenSpawn = 2.0f;
NSInteger const kMaxUnitsOnMap = 1;

@implementation TDSpawnAI

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if ([self.character isKindOfClass:[TDSpawn class]]) {
        TDSpawn *spawn = (TDSpawn *)self.character;
        
        if ((!spawn.lastSpawnDate && spawn.units.count < kMaxUnitsOnMap) || (spawn.units.count < kMaxUnitsOnMap && [[NSDate date] timeIntervalSinceDate:spawn.lastSpawnDate] >= kMinTimeIntervalBetweenSpawn)) {
            [spawn spawnNextUnit];
        }
    }
}

@end
