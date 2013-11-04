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

#define kTDPath_KeepPathCoordinates 0

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
        
        self.isBeingCalculated = YES;
    }
    
    return self;
}

- (id) initWithStartCoordinates:(CGPoint)coordA andEndCoordinates:(CGPoint)coordB {
    self = [super init];
    
    if (self) {
        self.pendingCallbacks = [[NSMutableArray alloc] init];
        
        self.isBeingCalculated = YES;
        self.startCoordinates = coordA;
        self.endCoordinates = coordB;
    }
    
    return self;
}

//TODO: do we really need that one?
- (TDPath *) pathForSpawn:(TDSpawn *)spawn {
//    if (spawn) {
//        TDPath *p = [[TDPath alloc] init];
//    }
    
    return nil;
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

- (void) clearCache {
    [self.cache removeAllObjects];
}

- (void) pathInExplorableWorld:(TDNewGameScene *)world fromA:(CGPoint)pointA toB:(CGPoint)pointB usingDiagonal:(BOOL)useDiagonal onSuccess:(void (^)(TDPath *))onSuccess {
    
    // Do we already have a path between those 2 points?
    [self.mainLock lock];
    TDPath *path = [self pathFromSpawnPoint:pointA toGoalPoint:pointB];
    [self.mainLock unlock];
    
    if (!path) {
        // Create an empty path marked as being calculated and save it in the cache
        [self.mainLock lock];
        TDPath *newPath = [[TDPath alloc] initWithStartCoordinates:pointA andEndCoordinates:pointB];
        [newPath.pendingCallbacks addObject:onSuccess];
        [self setPath:newPath fromSpawnPoint:pointA toGoalPoint:pointB];
        [self.mainLock unlock];
        
        // Now calculate the path
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *pathAsArray = [[PathFinder sharedInstance] pathInExplorableWorld:world fromA:pointA toB:pointB usingDiagonal:useDiagonal];
            
            // Populate our path object
            newPath.isBeingCalculated = NO;
#if kTDPath_KeepPathCoordinates
            newPath.coordinatesPathArray = [pathAsArray copy];
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

#pragma mark - Private methods

- (NSString *) keyForPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    return [NSString stringWithFormat:@"(%f,%f)(%f,%f)", pointA.x, pointA.y, pointB.x, pointB.y];
}

@end
