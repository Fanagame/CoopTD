//
//  TDPathFinder.m
//  CoopTD
//
//  Created by Remy Bardou on 10/27/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDPathFinder.h"

@implementation TDPath

@end

@interface TDPathFinder ()

@property (nonatomic, strong) NSMutableDictionary *cache;

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
    }
    
    return self;
}

#pragma mark - Public API

- (TDPath *) pathForSpawnPoint:(CGPoint)spawnPosition {
    NSValue *key = [NSValue valueWithCGPoint:spawnPosition];
    
    TDPath *path = self.cache[key];
    
    return path;
}

- (void) setPath:(TDPath *)path forSpawnPoint:(CGPoint)spawnPosition {
    NSValue *key = [NSValue valueWithCGPoint:spawnPosition];
    
    if (path) {
        [self.cache setObject:path forKey:key];
    } else {
        [self.cache removeObjectForKey:key];
    }
}

- (void) clearCache {
    [self.cache removeAllObjects];
}

#pragma mark - Private methods

@end
