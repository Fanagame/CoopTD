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
}

- (void) spawnNextUnit {
    TDUnit *unit = [[TDUnit alloc] init];
    unit.position = self.position;
    
    [self.gameScene addNode:unit atWorldLayer:TDWorldLayerCharacter];
    [self.units addObject:unit];
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)interval {
    [super updateWithTimeSinceLastUpdate:interval];
    
    for (TDUnit *unit in self.units) {
        [unit updateWithTimeSinceLastUpdate:interval];
    }
}

@end
