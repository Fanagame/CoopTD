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
@class TDUnit, TDSpawn;

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

- (void) pointCameraToDefaultElement;
- (void) pointCameraToPoint:(CGPoint)position;
- (void) pointCameraToSpawn:(TDSpawn *)spawn;
- (void) pointCameraToUnit:(TDUnit *)unit;

- (void) setCameraToDefaultZoomLevel;
- (void) setCameraZoomLevel:(CGFloat)newDesiredScale;
- (CGFloat) cameraZoomLevel;

// Methods that should probably be removed/cleaned later
- (void) addUnit:(TDUnit *)unit;
- (void) resetUnits;

@end
