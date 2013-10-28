//
//  TDPathFinder.h
//  CoopTD
//
//  Created by Remy Bardou on 10/27/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathFinder.h"

@class TDPath, TDNewGameScene;

typedef void (^TDPathCallback)(TDPath *path);

@interface TDPath : NSObject

// coordinates are the position on the grid
@property (nonatomic, assign) CGPoint startCoordinates;
@property (nonatomic, assign) CGPoint endCoordinates;

// position is the absolute pixel position
@property (nonatomic, assign) CGPoint startPosition;
@property (nonatomic, assign) CGPoint endPosition;

@property (atomic, assign) BOOL isBeingCalculated;
// do we really need to keep this one?
@property (nonatomic, strong) NSArray *coordinatesPathArray;
@property (nonatomic, strong) NSArray *positionsPathArray;

- (id) initWithStartCoordinates:(CGPoint)coordA andEndCoordinates:(CGPoint)coordB;

@end

@interface TDPathFinder : NSObject

+ (instancetype) sharedPathCache;

- (TDPath *) pathFromSpawnPoint:(CGPoint)spawnPosition toGoalPoint:(CGPoint)goalPosition;
- (void) setPath:(TDPath *)path fromSpawnPoint:(CGPoint)spawnPosition toGoalPoint:(CGPoint)goalPosition;
- (void) clearCache;

- (void)pathInExplorableWorld:(TDNewGameScene *)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(TDPathCallback)onSuccess;

@end
