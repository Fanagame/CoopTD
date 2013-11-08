//
//  TDPathFinder.m
//  CoopTD
//
//  Created by Remy Bardou on 10/27/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDPathFinder.h"
#import "TDSpawn.h"
#import "PathFinder.h"
#import "TDUnit.h"

NSString * const kTDPathFindingInvalidatePathsNotificationName = @"kTDPathFindingInvalidatePathsNotificationName";
NSString * const kTDPathFindingPathWasInvalidatedNotificationName = @"kTDPathFindingInvalidatePathNotificationName";

#define kTDPath_KeepPathCoordinates 1

@interface TDPath ()

@property (nonatomic, strong) NSMutableArray *pendingCallbacks;
@property (nonatomic, weak) SKScene *scene;

- (void) addCallback:(TDPathCallback)callback;
- (void) clearCallbacks;

@end

@implementation TDPath

#pragma mark - Public API

- (id) init {
    self = [super init];
    
    if (self) {
        self.pendingCallbacks = [[NSMutableArray alloc] init];
        self.owners = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id) initWithStartCoordinates:(CGPoint)coordA andEndCoordinates:(CGPoint)coordB {
    self = [super init];
    
    if (self) {
        self.pendingCallbacks = [[NSMutableArray alloc] init];
        self.owners = [[NSMutableArray alloc] init];
        
        self.startCoordinates = coordA;
        self.endCoordinates = coordB;
    }
    
    return self;
}

// is this coordinate included in the path?
- (BOOL) containsCoordinates:(CGPoint)coords {
    return ([self.coordinatesPathArray containsObject:[[PathNode alloc] initWithPosition:coords]]);
}

- (void) invalidate {
    self.wasInvalidated = YES;
    
    // contact units using this path and tell them to update their trajectories
    [[NSNotificationCenter defaultCenter] postNotificationName:kTDPathFindingPathWasInvalidatedNotificationName object:self];
}

- (void) addOwner:(TDUnit *)owner {
    if (![self.owners containsObject:owner]) {
        [self.owners addObject:owner];
    }
    [[TDPathFinder sharedPathCache] printCache];
}

- (void) removeOwner:(TDUnit *)owner {
    [self.owners removeObject:owner];
    
    if (!self.hasOwners) {
        [[TDPathFinder sharedPathCache] removePathFromCache:self];
    }
    
    [[TDPathFinder sharedPathCache] printCache];
}

- (BOOL) hasOwners {
    return (self.owners.count > 0);
}

- (NSString *) description {
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (PathNode *p in self.coordinatesPathArray) {
        [str appendFormat:@"(%f,%f)\n", p.position.x, p.position.y];
    }
    
    return str;
}

#pragma mark - Protected methods

- (void) addCallback:(TDPathCallback)callback {
    [self.pendingCallbacks addObject:callback];
}

- (void) clearCallbacks {
    [self.pendingCallbacks removeAllObjects];
}

@end

@interface TDPathFinder ()

@property (nonatomic, strong) NSMutableDictionary *cache;
@property (nonatomic, strong) NSLock *mainLock;

@end

@implementation TDPathFinder

static TDPathFinder *_sharedPathCache;

+ (instancetype) sharedPathCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPathCache = [[TDPathFinder alloc] init];
    });
    
    return _sharedPathCache;
}

- (id) init {
    self = [super init];
    
    if (self) {
        self.cache = [[NSMutableDictionary alloc] init];
        self.mainLock = [[NSLock alloc] init];
    }
    
    return self;
}

- (void) pathsWereInvalidated:(NSNotification *)notification {
    [self.mainLock lock];
    
    for (TDPath *path in self.cache.allValues)
        path.wasInvalidated = YES;
    
    [self.mainLock unlock];
}

#pragma mark - Public API

- (TDPath *) pathFromSpawnPoint:(CGPoint)spawnPosition toGoalPoint:(CGPoint)goalPosition {
    id key = [self keyForPointA:spawnPosition pointB:goalPosition];
    
    TDPath *path = self.cache[key];
    return path;
}

- (void) setPath:(TDPath *)path fromSpawnPoint:(CGPoint)spawnPosition toGoalPoint:(CGPoint)goalPosition {
    id key = [self keyForPointA:spawnPosition pointB:goalPosition];
    
    if (path) {
        [self.cache setObject:path forKey:key];
    } else {
        [self.cache removeObjectForKey:key];
    }
}

- (void) removePathFromCache:(TDPath *)path {
    [self.mainLock lock];
    [self.cache removeObjectForKey:[self keyForPointA:path.startCoordinates pointB:path.endCoordinates]];
    [self.mainLock unlock];
}

- (void) clearCache {
    [self.mainLock lock];
    NSArray *paths = [self cachedPaths];
    
    for (int i = paths.count - 1; i >= 0; i--) {
        TDPath *path = paths[i];
        
        if (!path.hasOwners) {
            [self.cache removeObjectForKey:[self keyForPointA:path.startCoordinates pointB:path.endCoordinates]];
        }
    }
    [self.mainLock unlock];
}

- (void) pathInExplorableWorld:(TDNewGameScene *)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(void (^)(TDPath *))onSuccess {
    
    // Do we already have a path between those 2 points?
    [self.mainLock lock];
    TDPath *path = [self pathFromSpawnPoint:pointA toGoalPoint:pointB];
    [self.mainLock unlock];
    
    if (!path || path.wasInvalidated) {
        // Create an empty path marked as being calculated and save it in the cache
        [self.mainLock lock];
        TDPath *newPath = path;
        if (!newPath) {
            newPath = [[TDPath alloc] initWithStartCoordinates:pointA andEndCoordinates:pointB];
            [self setPath:newPath fromSpawnPoint:pointA toGoalPoint:pointB];
        }
        newPath.isBeingCalculated = YES;
        newPath.wasInvalidated = NO;
        [newPath.pendingCallbacks addObject:onSuccess];
        [self.mainLock unlock];
        
        // Now calculate the path
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDate *startDate = [NSDate date];
            
            NSArray *pathAsArray = [[PathFinder sharedInstance] pathInExplorableWorld:world fromA:pointA toB:pointB usingDiagonal:useDiagonal];
            
#ifdef kTDPath_PRINT_CACHE_CONTENT
            NSLog(@"*** PATHFINDING *** Found path in %f seconds!", -[startDate timeIntervalSinceNow]);
#endif
            newPath.isBeingCalculated = NO;
            
            if (newPath.wasInvalidated) {
                // The path we just finished calculating got invalidated during the calculation!
                // let's recalculate it!
                
                //TODO: do we need to do something about the multiple callbacks?
                [[TDPathFinder sharedPathCache] pathInExplorableWorld:world fromA:pointA toB:pointB usingDiagonal:useDiagonal onSuccess:onSuccess];
                
                return;
            }
            
            // Populate our path object
#if kTDPath_KeepPathCoordinates
            newPath.coordinatesPathArray = [[NSArray alloc] initWithArray:pathAsArray copyItems:YES];
#endif
            [world convertCoordinatesArrayToPositionsInMapArray:pathAsArray];
            newPath.positionsPathArray = pathAsArray;
            
            // Notify our pending callers that the work here is done!
            for (TDPathCallback pendingCallback in newPath.pendingCallbacks) {
                pendingCallback(newPath);
            }
            
            // We don't need to store those callback any longer, let's remove them now
            [newPath clearCallbacks];
        });
    } else if (path.isBeingCalculated) {
        // wait until it is calculated before answering
        [path addCallback:onSuccess];
    } else {
        // return the path immediately!
        onSuccess(path);
    }
}

- (NSArray *) cachedPaths {
    return self.cache.allValues;
}

#pragma mark - DEBUG

- (void) printCache {
#if DEBUG
#ifdef kTDPath_PRINT_CACHE_CONTENT
    NSLog(@"=========================================");
    NSLog(@"====    PathFinder cache content   ======");
    NSLog(@"=========================================");
    
    NSLog(@"Amount of cached paths: %d", self.cachedPaths.count);
    for (TDPath *p in self.cachedPaths) {
        NSLog(@"Path with key %@ is owned by %d units.", [self keyForPointA:p.startCoordinates pointB:p.endCoordinates], p.owners.count);
        NSLog(@"%@", p.description);
    }
#endif
#endif
}

#pragma mark - Private methods

- (NSString *) keyForPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    return [NSString stringWithFormat:@"(%f,%f)(%f,%f)", pointA.x, pointA.y, pointB.x, pointB.y];
}

@end
