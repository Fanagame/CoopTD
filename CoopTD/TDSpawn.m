//
//  TDSpawn.m
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDSpawn.h"
#import "TDUnit.h"
#import "TDNewGameScene.h"
#import "TDSpawnAI.h"

@implementation TDSpawn

- (void) setup {
    self.color = [UIColor redColor];
    
    self.units = [[NSMutableArray alloc] init];
    self.intelligence = [[TDSpawnAI alloc] initWithCharacter:self andTarget:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unitWasKilled:) name:kTDUnitDiedNotificationName object:nil];
}

- (void) spawnNextUnit {
    self.lastSpawnDate = [NSDate date];
    
    TDUnit *unit = [[TDUnit alloc] init];
    unit.unitID = self.lastSpawnedUnit.unitID + 1;
    unit.position = self.position;
    
    [self.gameScene addNode:unit atWorldLayer:TDWorldLayerCharacter];
    [self.units addObject:unit];
}

- (TDUnit *) lastSpawnedUnit {
    return [self.units lastObject];
}

- (void) unitWasKilled:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[TDUnit class]])
        [self.units removeObject:notification.object];
    
    // do we need to do anything else?
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    for (TDUnit *unit in self.units) {
        [unit updateWithTimeSinceLastUpdate:interval];
    }
}

@end
