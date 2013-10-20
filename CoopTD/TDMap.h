//
//  TDMap.h
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathFinder.h"

@class JSTileMap;
@class TDUnit;

@interface TDMap : NSObject<ExplorableWorldDelegate>

@property (nonatomic, strong, readonly) NSString *mapName;
@property (nonatomic, strong) JSTileMap *tileMap;
@property (nonatomic, strong) NSMutableArray *spawnPoints;
@property (nonatomic, strong) NSMutableArray *destinationPoints;

@property (nonatomic, strong) NSMutableArray *units;
@property (nonatomic, strong) NSMutableArray *towers;
@property (nonatomic, strong) NSMutableArray *players;

- (id) initMapNamed:(NSString *)mapName;
- (void) update:(CFTimeInterval)currentTime;

- (void) addUnit:(TDUnit *)unit;
- (void) resetUnits;

@end
