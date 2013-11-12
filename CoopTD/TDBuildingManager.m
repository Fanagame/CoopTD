//
//  TDBuildingManager.m
//  CoopTD
//
//  Created by Rémy Bardou on 12/11/2013.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDBuildingManager.h"
#import "TDBaseBuilding.h"
#import "TDPathFinder.h"

@implementation TDBuildingManager

static TDBuildingManager *_sharedManager;
+ (instancetype) sharedManager {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[TDBuildingManager alloc] init];
	});
	return _sharedManager;
}


#pragma - Public API

- (BOOL) addBuilding:(TDBaseBuilding *)building {
    return [self addBuilding:building atPosition:building.position];
}

- (BOOL) addBuilding:(TDBaseBuilding *)building atPosition:(CGPoint)position {
	//    [self magnetizeMapObject:building]; // do we really need to do this again?
    
    CGPoint coordinates = [self.gameScene tileCoordinatesForPositionInMap:building.position];
    return [self addBuilding:building atTileCoordinates:coordinates];
}

- (BOOL) addBuilding:(TDBaseBuilding *)building atTileCoordinates:(CGPoint)tileCoordinates {
    if (building && [self.gameScene isConstructable:tileCoordinates]) {
        building.isPlaced = YES;
        [self.gameScene.buildings addObject:building];
        
        //TODO: invalidate only the cachedPaths for a given type of units...
        // is the building part of any cached path?
        for (TDPath *path in [[TDPathFinder sharedPathCache] cachedPaths]) {
            if ([path containsCoordinates:tileCoordinates]) {
                [path invalidate]; // then invalidate it!
            }
        }
        
        return YES;
    }
    
    return NO;
}

@end
