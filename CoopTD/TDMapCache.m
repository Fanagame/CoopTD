//
//  TDMapCache.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMapCache.h"
#import "TDTiledMap.h"

@interface TDMapCache () {
    NSMutableDictionary *_dataMap;
}

@end

@implementation TDMapCache

static TDMapCache *_sharedCache;

+ (instancetype) sharedCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCache = [[TDMapCache alloc] init];
    });
    
    return _sharedCache;
}

- (id) init {
    self = [super init];
    
    if (self) {
        _dataMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) addMapToCache:(TDTiledMap *)map {
    if (map && !_dataMap[map.mapName]) {
        _dataMap[map.mapName] = map;
    }
}

- (TDTiledMap *) cachedMapForMapName:(NSString *)mapName {
    return _dataMap[mapName];
}

- (void) preloadMapNamed:(NSString *)mapName {
    if (![self cachedMapForMapName:mapName]) {
        TDTiledMap *map = [[TDTiledMap alloc] initWithMapNamed:mapName];
        [self addMapToCache:map];
    }
}

- (void) invalidateCacheForMapNamed:(NSString *)mapName {
	[_dataMap removeObjectForKey:mapName];
}

@end
