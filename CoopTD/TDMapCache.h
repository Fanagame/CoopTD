//
//  TDMapCache.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDTiledMap;

@interface TDMapCache : NSObject

+ (instancetype) sharedCache;

- (void) addMapToCache:(TDTiledMap *)map;
- (TDTiledMap *) cachedMapForMapName:(NSString *)mapName;
- (void) preloadMapNamed:(NSString *)mapName;
- (void) invalidateCacheForMapNamed:(NSString *)mapName;

@end
