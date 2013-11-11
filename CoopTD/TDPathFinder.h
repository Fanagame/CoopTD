//
//  TDPathFinder.h
//  CoopTD
//
//  Created by Remy Bardou on 10/27/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathFinder.h"

extern NSString * const kTDPathFindingInvalidatePathsNotificationName;
extern NSString * const kTDPathFindingPathWasInvalidatedNotificationName;

@class TDPath, TDNewGameScene, TDUnit;

typedef void (^TDPathCallback)(TDPath *path);

@interface TDPath : NSObject

// coordinates are the position on the grid
@property (nonatomic, assign) CGPoint startCoordinates;
@property (nonatomic, assign) CGPoint endCoordinates;

// position is the absolute pixel position
@property (nonatomic, assign) CGPoint startPosition;
@property (nonatomic, assign) CGPoint endPosition;

@property (nonatomic, strong) NSString *type;

@property (atomic, assign) BOOL isBeingCalculated;
@property (atomic, assign) BOOL wasInvalidated;

@property (nonatomic, strong) NSArray *coordinatesPathArray;
@property (nonatomic, strong) NSArray *positionsPathArray;

@property (nonatomic, strong) NSMutableArray *owners;

- (id) initWithStartCoordinates:(CGPoint)coordA andEndCoordinates:(CGPoint)coordB andType:(NSString *)type;
- (BOOL) containsCoordinates:(CGPoint)coords;
- (void) invalidate;

- (void) addOwner:(TDUnit *)owner;
- (void) removeOwner:(TDUnit *)owner;
- (BOOL) hasOwners;

@end

@interface TDPathFinder : NSObject

+ (instancetype) sharedPathCache;

- (TDPath *) pathFromSpawnPoint:(CGPoint)spawnPosition toGoalPoint:(CGPoint)goalPosition withObject:(id<ExploringObjectDelegate>)object;
- (void) cachePath:(TDPath *)path;
- (void) clearCache;
- (void) removePathFromCache:(TDPath *)path;
- (NSArray *) cachedPaths;

- (void)  pathInExplorableWorld:(TDNewGameScene *)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal withObject:(id<ExploringObjectDelegate>)exploringObject onSuccess:(void (^)(TDPath *))onSuccess;
- (void)pathInExplorableWorld:(TDNewGameScene *)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(TDPathCallback)onSuccess;


- (void) printCache;

@end
