//
//  TDSpawn.h
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "TDTMXObject.h"

@interface TDSpawn : TDTMXObject

@property (nonatomic, assign) CFTimeInterval timeIntervalBetweenSpawns;
@property (nonatomic, assign) NSInteger maxUnitsOnMap;

@property (nonatomic, strong) NSMutableArray *units;
@property (nonatomic, strong) NSDate *lastSpawnDate;
@property (nonatomic, weak) TDUnit *lastSpawnedUnit;

- (void) spawnNextUnit;
- (void) unitWasKilled:(TDUnit *)unit;

@end
