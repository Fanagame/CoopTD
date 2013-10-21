//
//  TDMap.m
//  CoopTD
//
//  Created by Remy Bardou on 10/18/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "TDMap.h"
#import "JSTileMap.h"
#import "TDUnit.h"
#import "TDUltimateGoal.h"
#import "TDSpawn.h"
#import "PathFinder.h"

NSString * const kMapObjectType_Spawn = @"SpawnPoint";
NSString * const kMapObjectType_Destination = @"DestinationPoint";

NSString * const kMapLayerName_Main = @"Map";
NSString * const kMapLayerName_Objects = @"MetaObjects";
NSString * const kMapLayerName_Meta = @"MetaLayer";

NSString * const kMapTilePropertyName_Walkable = @"Walkable";
NSString * const kMapTilePropertyName_Constructable = @"Constructable";

CGFloat const kCameraZoomLevel_Max = 3.0f;
CGFloat const kCameraZoomLevel_Min = 0.05;

@interface TDMap()

@property (nonatomic, strong, readwrite) NSString *mapName;

@property (nonatomic, strong) TMXLayer *mapLayer;
@property (nonatomic, strong) TMXLayer *metaLayer;
@property (nonatomic, strong) TMXObjectGroup *objectsGroup;

@end

@implementation TDMap

- (id) initMapNamed:(NSString *)mapName {
    self = [super init];
    
    if (self) {
        self.mapName = mapName;
        
        self.units = [[NSMutableArray alloc] init];
        self.towers = [[NSMutableArray alloc] init];
        self.players = [[NSMutableArray alloc] init];
        self.destinationPoints = [[NSMutableArray alloc] init];
        self.spawnPoints = [[NSMutableArray alloc] init];
        
        [self loadMap];
    }
    
    return self;
}

- (void) loadMap {
    if (self.mapName.length > 0) {
        // Load the map
        self.tileMap = [JSTileMap mapNamed:self.mapName];
        
        self.mapLayer = [self.tileMap layerNamed:kMapLayerName_Main];
        self.metaLayer = [self.tileMap layerNamed:kMapLayerName_Meta];
        
        // Figure out meta informations (spawn points, destination point coordinates, etc...)
        self.objectsGroup = [self.tileMap groupNamed:kMapLayerName_Objects];
        if (self.objectsGroup) {
            for (NSDictionary *object in self.objectsGroup.objects) {
                if ([object[@"type"] isEqualToString:kMapObjectType_Spawn]) {
                    [self.spawnPoints addObject:[[TDSpawn alloc] initWithDictionary:object]];
                    [self.tileMap addChild:self.spawnPoints.lastObject];
                } else if ([object[@"type"] isEqualToString:kMapObjectType_Destination]) {
                    [self.destinationPoints addObject:[[TDUltimateGoal alloc] initWithDictionary:object]];
                    [self.tileMap addChild:self.destinationPoints.lastObject];
                }
            }
        }
    }
}

- (void) resetUnits {
    TDSpawn *sp = [self nextSpawn];
    
    for (TDUnit *unit in self.units) {
        unit.status = TDUnitStatus_Standy;
        unit.position = CGPointMake(sp.position.x + 150, sp.position.y + unit.size.height * 0.5);
    }
}

- (void) addUnit:(TDUnit *)unit {
    // Configure the unit (find out where to put it
    TDSpawn *sp = [self nextSpawn];
    unit.position = CGPointMake(sp.position.x + 150, sp.position.y + unit.size.height * 0.5);
//    unit.spriteNode.position = sp.position;
    
    // Then add it to the map
    [self.units addObject:unit];
    [self.tileMap addChild:unit];
}

- (TDSpawn *) nextSpawn {
    //TODO: make it randomize through any of the spawn points available on the map
    if (self.spawnPoints.count > 0)
        return self.spawnPoints[0];
    return nil;
}

- (TDUltimateGoal *) nextGoal {
    //TODO: make it randomize through any of the destination points on the map
    if (self.destinationPoints.count > 0)
        return self.destinationPoints[0];
    return nil;
}

#pragma mark - Positon conversion

- (CGPoint) tileCoordinatesForPosition:(CGPoint)position {
    if (self.mapLayer) {
        return [self.mapLayer coordForPoint:position];
    }
    
    return CGPointZero;
}

- (CGPoint) tilePositionForCoordinate:(CGPoint)position {
    if (self.mapLayer) {
        return [self.mapLayer pointForCoord:position];
    }
    
    return CGPointZero;
}

- (void) convertCoordinatesArrayToPositions:(NSArray *)coords {
    for (PathNode *n in coords) {
        n.position = [self tilePositionForCoordinate:n.position];
    }
}

#pragma mark - Camera management

//TODO: cache the value for best performance?
- (CGFloat) bestScaleForDevice {
    CGSize winSize = self.tileMap.scene.size;
    CGSize actualMapSize = CGSizeMake(self.tileMap.mapSize.width * self.tileMap.tileSize.width, self.tileMap.mapSize.height * self.tileMap.tileSize.height);
    
    CGFloat bestXScale = winSize.width / actualMapSize.width;
    CGFloat bestYScale = winSize.height / actualMapSize.height;
    
    return MAX(bestXScale, bestYScale);
}

- (CGPoint) boundedLayerPosition:(CGPoint)newPos {
    CGSize winSize = self.tileMap.scene.size;
    CGSize mapSize = self.tileMap.calculateAccumulatedFrame.size;
    
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -mapSize.width + winSize.width);
    retval.y = MIN(retval.y, 0);
    retval.y = MAX(retval.y, -mapSize.height + winSize.height);
    
    return retval;
}

- (void) pointCameraToPoint:(CGPoint)position {
    self.tileMap.position = [self boundedLayerPosition:position];
}

- (void) pointCameraToSpawn:(TDSpawn *)spawn {
    [self pointCameraToPoint:spawn.position];
}

- (void) pointCameraToUnit:(TDUnit *)unit {
    //TODO: make it follow the unit at the same time?
    [self zoomOnObjectWithRect:unit.frame withDesiredSpaceOccupation:0.2]; // 20%
    //[self pointCameraToPoint:unit.spriteNode.position];
}

- (void) pointCameraToBuilding:(id)building {
    
}

- (void) pointCameraToDefaultElement {
    TDSpawn *spawn = [self nextSpawn];
    
    if (spawn)
        [self pointCameraToSpawn:spawn];
}

- (void) zoomOnObjectWithRect:(CGRect)objectRect withDesiredSpaceOccupation:(CGFloat)spaceOccupationDesired {
    CGSize winSize = self.tileMap.scene.size;
    
    // we want the object to occupy 20% of the screen
    // 0.2 = desiredSize / winSize
    
    CGFloat desiredWidth = winSize.width * spaceOccupationDesired;
    CGFloat desiredHeight = winSize.height * spaceOccupationDesired;
    
    CGFloat bestXScale = winSize.width / desiredWidth;
    CGFloat bestYScale = winSize.height / desiredHeight;
    
    CGFloat newScale = MIN(bestXScale, bestYScale);
    
    //
    // We now have our optimal scale to zoom on that object
    // Let's zoom on it
    //
    
    [self setCameraZoomLevel:newScale];
    
    CGRect r = self.tileMap.calculateAccumulatedFrame;
    self.tileMap.position = CGPointMake(0, 0);
//    [self pointCameraToPoint:objectRect.origin];
}

- (void) setCameraToDefaultZoomLevel {
    CGFloat newScale = [self bestScaleForDevice];
    [self.tileMap setScale:newScale];
}

- (void) setCameraZoomLevel:(CGFloat)newDesiredScale {
    [self.tileMap setScale:MIN(kCameraZoomLevel_Max, MAX(newDesiredScale, self.bestScaleForDevice))];
}

- (CGFloat) cameraZoomLevel {
    return self.tileMap.xScale;
}

#pragma mark - Handle internal logic

- (void) update:(CFTimeInterval)currentTime {
    // Process actions for each units
    for (TDUnit *unit in self.units) {
        
        // Has any unit reached the destination point?
        for (TDUltimateGoal *goal in self.destinationPoints) {
            if (CGRectIntersectsRect(unit.frame, goal.frame)) {
                //TODO: decrease score and all that shit
                TDSpawn *spawn = [self nextSpawn];
                if (spawn) {
                    unit.position = CGPointMake(spawn.position.x + 150, spawn.position.y + unit.size.height * 0.5);;
                    unit.status = TDUnitStatus_Standy;
                }
            }
        }
        
        // TODO:Has unit been touched by a bullet?
        //
        
        // Has any unit been spawn and needs direction?
        if (unit.status == TDUnitStatus_Standy) {
            TDUltimateGoal *goal = [self nextGoal];

            if (goal) {
                unit.status = TDUnitStatus_CalculatingPath;
                
                __weak TDMap *weakSelf = self;
                
                CGPoint coordA = [self tileCoordinatesForPosition:unit.position];
                CGPoint coordB = [self tileCoordinatesForPosition:goal.frame.origin];
                
                NSLog(@"Finding way from (%f,%f) to (%f,%f)", coordA.x, coordA.y, coordB.x, coordB.y);
                [[PathFinder sharedInstance] pathInExplorableWorld:self fromA:coordA toB:coordB usingDiagonal:YES onSuccess:^(NSArray *path) {
                    [weakSelf convertCoordinatesArrayToPositions:path];
                    
                    unit.status = TDUnitStatus_Moving;
                    [unit followArrayPath:path];
                }];
            }
        }
    }
}

#pragma mark - Explorable World Delegate

- (BOOL)isWalkable:(CGPoint)coord {
//    if (self.mapLayer) {
////        NSLog(@"(%f,%f)", coord.x, coord.y);
////        [self.mapLayer removeTileAtCoord:coord];
//        NSInteger gid = [self.mapLayer.layerInfo tileGidAtCoord:coord];
////        NSLog(@"(%f,%f) => gid %d", coord.x, coord.y, gid);
//        NSDictionary *dic = [self.tileMap propertiesForGid:[self.mapLayer tileGidAt:coord]];
//        
//        if (dic) {
//            if ([[dic[kMapTilePropertyName_Walkable] uppercaseString] isEqualToString:@"NO"]) {
//                return NO;
//            }
//        }
//    }
    
    return YES;
}

- (NSUInteger)weightForTileAtPosition:(CGPoint)coord {
    return 1;
}

@end
