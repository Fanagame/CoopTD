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

@implementation TDSpawnAI

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    if ([self.character isKindOfClass:[TDSpawn class]]) {
        TDSpawn *spawn = (TDSpawn *)self.character;
        
        if (spawn.units.count < 1) {
            [spawn spawnNextUnit];
        }
    }
}

@end