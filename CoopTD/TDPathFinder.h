//
//  TDPathFinder.h
//  CoopTD
//
//  Created by Remy Bardou on 10/27/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPath : NSObject

@property (nonatomic, strong) NSMutableArray *pathArray;

@end

@interface TDPathFinder : NSObject

+ (instancetype) sharedPathCache;

- (TDPath *) pathForSpawnPoint:(CGPoint)spawnPosition;
- (void) setPath:(TDPath *)path forSpawnPoint:(CGPoint)spawnPosition;
- (void) clearCache;

@end
